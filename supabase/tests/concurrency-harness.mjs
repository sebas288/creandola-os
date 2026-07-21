/**
 * Concurrency harness for entity creation idempotency.
 *
 * Tests that concurrent create_entity calls with the same idempotency key
 * serialize correctly via advisory locks.
 *
 * Usage: node supabase/tests/concurrency-harness.mjs
 */

import pg from 'pg';

const DB_URL = 'postgresql://postgres:postgres@127.0.0.1:54322/postgres';

const ALICE_UID = 'a0000000-0000-0000-0000-000000000001';
const ALICE_EMAIL = 'alice@example.com';

const LOCK_WAIT_TIMEOUT_MS = 15000;

async function setAuthCtx(client, userId) {
  // Session-level (not local) so it persists across implicit transactions
  await client.query(`SELECT set_config('request.jwt.claim.sub', $1, false)`, [userId]);
  await client.query(`SET ROLE authenticated`);
}

async function clearAuthCtx(client) {
  await client.query(`RESET ROLE`);
  await client.query(`SELECT set_config('request.jwt.claim.sub', '', false)`);
}

async function getAliceWorkspaceId(client) {
  const res = await client.query(
    `SELECT id FROM public.workspaces WHERE personal_owner_id = $1`,
    [ALICE_UID]
  );
  return res.rows[0].id;
}

async function main() {
  let passed = 0;
  let failed = 0;

  function record(name, ok, detail = '') {
    if (ok) { passed++; console.log(`  ✅ ${name}`); }
    else { failed++; console.log(`  ❌ ${name}${detail ? ': ' + detail : ''}`); }
  }

  console.log('=== Concurrency Harness: Entity Idempotency ===\n');

  const pool = new pg.Pool({ connectionString: DB_URL, max: 4 });
  const clientA = await pool.connect();
  const clientB = await pool.connect();
  const observer = await pool.connect();

  try {
    // Provision Alice
    await clientA.query(`BEGIN`);
    await clientA.query(`
      INSERT INTO auth.users (id, email, raw_user_meta_data, instance_id, aud, role, email_confirmed_at, encrypted_password)
      VALUES ($1, $2, '{"full_name":"Alice"}', '00000000-0000-0000-0000-000000000000',
              'authenticated', 'authenticated', now(), '')
      ON CONFLICT (id) DO NOTHING
    `, [ALICE_UID, ALICE_EMAIL]);
    await clientA.query(`COMMIT`);
    console.log('  ℹ️  Alice provisioned\n');

    const wsId = await getAliceWorkspaceId(clientA);

    // ═══ TEST 1: Concurrent matching payload (replay) ═══
    console.log('--- Test 1: Concurrent matching payload ---');
    const key = 'conc-test-key-001';
    const name = 'Conc entity';

    await setAuthCtx(clientA, ALICE_UID);
    await setAuthCtx(clientB, ALICE_UID);

    // A: BEGIN + create_entity (holds lock)
    await clientA.query(`BEGIN`);
    const { rows: [rA] } = await clientA.query(
      `SELECT public.create_entity($1, 'task'::public.entity_type, $2, '{}'::jsonb, $3) AS id`,
      [wsId, name, key]
    );
    const uuidA = rA.id;

    const { rows: [cntA] } = await clientA.query(
      `SELECT count(*)::int AS n FROM public.entities WHERE name = $1`, [name]
    );
    record('A: 1 row created', cntA.n === 1, `n=${cntA.n}`);

    // B: concurrent call (will block on advisory lock)
    let bResult = null, bError = null;
    const bPromise = clientB.query(
      `SELECT public.create_entity($1, 'task'::public.entity_type, $2, '{}'::jsonb, $3) AS id`,
      [wsId, name, key]
    ).then(r => { bResult = r.rows[0].id; }).catch(e => { bError = e; });

    await new Promise(r => setTimeout(r, 1500));

    // Observer: check B is waiting
    const { rows: [obsRows] } = await observer.query(`
      SELECT count(*)::int AS n FROM pg_stat_activity
      WHERE wait_event_type = 'Lock' AND state = 'active' AND pid <> pg_backend_pid()
    `);
    record('Observer: B waits on Lock before A commits', obsRows.n >= 1, `waiters=${obsRows.n}`);

    // A commits — releases lock
    await clientA.query(`COMMIT`);
    console.log('  A committed');

    // Wait for B
    let timedOut = false;
    const timeout = new Promise(r => setTimeout(() => { timedOut = true; r(); }, LOCK_WAIT_TIMEOUT_MS));
    await Promise.race([bPromise, timeout]);
    record('B completed', !timedOut, timedOut ? 'timed out' : '');
    record('B got same UUID', bResult === uuidA, `A=${uuidA}, B=${bResult}`);
    record('B no error', bError === null, bError ? bError.message : '');

    const { rows: [cntF] } = await clientA.query(
      `SELECT count(*)::int AS n FROM public.entities WHERE name = $1`, [name]
    );
    record('Final: 1 row', cntF.n === 1, `n=${cntF.n}`);

    await clearAuthCtx(clientA);
    await clearAuthCtx(clientB);

    // ═══ TEST 2: Concurrent conflicting payload ═══
    console.log('\n--- Test 2: Concurrent conflicting payload ---');
    const cKey = 'conc-conflict-key-001';
    const cName = 'Conflict conc entity';

    await setAuthCtx(clientA, ALICE_UID);
    await setAuthCtx(clientB, ALICE_UID);

    // A: create with v=1
    await clientA.query(`BEGIN`);
    const { rows: [rC] } = await clientA.query(
      `SELECT public.create_entity($1, 'task'::public.entity_type, $2, '{"v":"1"}'::jsonb, $3) AS id`,
      [wsId, cName, cKey]
    );
    const uuidC = rC.id;

    // B: concurrent with v=2 (different payload)
    let cError = null;
    const cP = clientB.query(
      `SELECT public.create_entity($1, 'task'::public.entity_type, $2, '{"v":"2"}'::jsonb, $3) AS id`,
      [wsId, cName, cKey]
    ).catch(e => { cError = e; });

    await new Promise(r => setTimeout(r, 1500));

    // Observer
    const { rows: [obsC] } = await observer.query(`
      SELECT count(*)::int AS n FROM pg_stat_activity
      WHERE wait_event_type = 'Lock' AND state = 'active' AND pid <> pg_backend_pid()
    `);
    record('Conflict: B waits on Lock', obsC.n >= 1, `waiters=${obsC.n}`);

    await clientA.query(`COMMIT`);

    let cTimedOut = false;
    const cTimeout = new Promise(r => setTimeout(() => { cTimedOut = true; r(); }, LOCK_WAIT_TIMEOUT_MS));
    await Promise.race([cP, cTimeout]);
    record('Conflict: B completed', !cTimedOut);
    record('Conflict: B got 22023', cError && cError.code === '22023',
      cError ? `code=${cError.code}` : 'no error');

    const { rows: [orig] } = await clientA.query(
      `SELECT properties->>'v' AS v FROM public.entities WHERE id = $1`, [uuidC]
    );
    record('Original row unchanged (v=1)', orig.v === '1', `v=${orig.v}`);

    await clearAuthCtx(clientA);
    await clearAuthCtx(clientB);

    // ═══ Cleanup (order matters due to FKs) ═══
    await clientA.query(`DELETE FROM public.entities WHERE created_by = $1`, [ALICE_UID]);
    await clientA.query(`DELETE FROM public.memberships WHERE profile_id = $1`, [ALICE_UID]);
    await clientA.query(`DELETE FROM public.workspaces WHERE personal_owner_id = $1`, [ALICE_UID]);
    await clientA.query(`DELETE FROM public.profiles WHERE id = $1`, [ALICE_UID]);
    await clientA.query(`DELETE FROM auth.users WHERE id = $1`, [ALICE_UID]);

  } finally {
    try { await clientA.query(`ROLLBACK`); } catch {}
    try { await clientB.query(`ROLLBACK`); } catch {}
    try { await observer.query(`ROLLBACK`); } catch {}
    clientA.release(); clientB.release(); observer.release();
    await pool.end();
  }

  console.log(`\n=== ${passed}/${passed + failed} passed ===`);
  if (failed > 0) process.exit(1);
}

main().catch(e => { console.error('CRASH:', e.message); process.exit(2); });
