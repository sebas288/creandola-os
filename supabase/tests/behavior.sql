-- pgTAP behavioral tests: provisioning, RLS, authorization, idempotency
-- Supabase test db handles pgTAP loading automatically.
-- For RLS tests: we set JWT claims + SET LOCAL ROLE authenticated directly
-- (not via functions, since functions can't change role)

BEGIN;
SELECT no_plan();

-- =========================================================================
-- 1. PROVISIONING TESTS
-- =========================================================================

-- Insert two auth users (simulating what the auth system does on signup).
-- The trigger on_auth_user_created should provision them automatically.
INSERT INTO auth.users (id, email, raw_user_meta_data, instance_id, aud, role, email_confirmed_at, encrypted_password)
VALUES
  ('a0000000-0000-0000-0000-000000000001', 'alice@example.com',
   '{"full_name": "Alice Smith"}', '00000000-0000-0000-0000-000000000000',
   'authenticated', 'authenticated', now(), ''),
  ('a0000000-0000-0000-0000-000000000002', 'bob.smith@example.com',
   '{"full_name": "Bob Smith"}', '00000000-0000-0000-0000-000000000000',
   'authenticated', 'authenticated', now(), '');

-- Check Alice's automatic provisioning (trigger-created rows)
SELECT results_eq(
  $$SELECT count(*)::int FROM public.profiles WHERE id = 'a0000000-0000-0000-0000-000000000001'$$,
  $$VALUES (1)$$
);

SELECT results_eq(
  $$SELECT count(*)::int FROM public.workspaces WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000001'$$,
  $$VALUES (1)$$
);

SELECT results_eq(
  $$SELECT count(*)::int FROM public.memberships
    WHERE profile_id = 'a0000000-0000-0000-0000-000000000001'
      AND role = 'owner'::public.membership_role$$,
  $$VALUES (1)$$
);

-- Replay provisioning: calling provision_user again MUST return same workspace UUID
-- and NOT create duplicate rows.
SELECT is(
  (SELECT private.provision_user(
    'a0000000-0000-0000-0000-000000000001'::uuid,
    'alice@example.com',
    '{"full_name": "Alice Smith"}'::jsonb
  )),
  (SELECT id FROM public.workspaces
    WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000001'),
  'Provisioning replay returns same workspace UUID'
);

-- Row counts must remain unchanged after replay
SELECT results_eq(
  $$SELECT count(*)::int FROM public.profiles WHERE id = 'a0000000-0000-0000-0000-000000000001'$$,
  $$VALUES (1)$$
);
SELECT results_eq(
  $$SELECT count(*)::int FROM public.workspaces WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000001'$$,
  $$VALUES (1)$$
);
SELECT results_eq(
  $$SELECT count(*)::int FROM public.memberships WHERE profile_id = 'a0000000-0000-0000-0000-000000000001'$$,
  $$VALUES (1)$$
);

-- Two users with the same name prefix must get distinct slugs
SELECT isnt(
  (SELECT slug FROM public.workspaces WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000001'),
  (SELECT slug FROM public.workspaces WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000002'),
  'Two users with same base slug get distinct workspace slugs'
);

-- Both slugs must be valid
SELECT ok(
  (SELECT slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$' FROM public.workspaces WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000001'),
  'Alice slug is valid'
);
SELECT ok(
  (SELECT slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$' FROM public.workspaces WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000002'),
  'Bob slug is valid'
);

-- =========================================================================
-- 2. RLS VISIBILITY: authenticated users see only their own rows
-- =========================================================================

-- Switch to Alice's auth context
SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000001', true);
SET LOCAL ROLE authenticated;

SELECT results_eq(
  $$SELECT count(*)::int FROM public.profiles$$,
  $$VALUES (1)$$
);

-- Switch to Bob's auth context
RESET ROLE;
SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000002', true);
SET LOCAL ROLE authenticated;

SELECT results_eq(
  $$SELECT count(*)::int FROM public.profiles$$,
  $$VALUES (1)$$
);

RESET ROLE;
SELECT set_config('request.jwt.claim.sub', '', true);

-- =========================================================================
-- 3. DIRECT WRITE DENIAL
-- =========================================================================

-- Authenticated user must NOT be able to INSERT into entities directly
SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000001', true);
SET LOCAL ROLE authenticated;

SELECT throws_ok(
  $$INSERT INTO public.entities (id, workspace_id, entity_type, name, status, properties, fingerprint, created_by)
    VALUES (extensions.gen_random_uuid(), extensions.gen_random_uuid(), 'task', 'hack', 'active', '{}',
            repeat('0', 64), extensions.gen_random_uuid())$$,
  '42501'
);

RESET ROLE;
SELECT set_config('request.jwt.claim.sub', '', true);

-- =========================================================================
-- 3b. HOST MAPPINGS: seed, RLS visibility, write denial, host checks
-- =========================================================================

DO $$
DECLARE
  v_alice_ws uuid;
  v_bob_ws uuid;
BEGIN
  SELECT id INTO v_alice_ws FROM public.workspaces
    WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000001';
  SELECT id INTO v_bob_ws FROM public.workspaces
    WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000002';

  INSERT INTO public.domain_mappings (workspace_id, host, status)
  VALUES
    (v_alice_ws, 'portal.alice.example', 'active'),
    (v_bob_ws, 'portal.bob.example', 'active');

  INSERT INTO public.workspace_settings (workspace_id, presentation)
  VALUES
    (v_alice_ws, '{"brand":"Alice Co","locale":"es-CO"}'::jsonb),
    (v_bob_ws, '{"brand":"Bob Co","locale":"es-CO"}'::jsonb);
END;
$$;

-- Uppercase / scheme / port hosts must be rejected
SELECT throws_ok(
  $$INSERT INTO public.domain_mappings (workspace_id, host)
    SELECT id, 'Portal.Alice.Example' FROM public.workspaces
    WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000001'$$,
  '23514'
);

SELECT throws_ok(
  $$INSERT INTO public.domain_mappings (workspace_id, host)
    SELECT id, 'https://evil.example' FROM public.workspaces
    WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000001'$$,
  '23514'
);

SELECT throws_ok(
  $$INSERT INTO public.domain_mappings (workspace_id, host)
    SELECT id, 'evil.example:443' FROM public.workspaces
    WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000001'$$,
  '23514'
);

-- Duplicate host rejected
SELECT throws_ok(
  $$INSERT INTO public.domain_mappings (workspace_id, host)
    SELECT id, 'portal.alice.example' FROM public.workspaces
    WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000002'$$,
  '23505'
);

-- Non-object presentation rejected
SELECT throws_ok(
  $$UPDATE public.workspace_settings
    SET presentation = '["not","object"]'::jsonb
    WHERE workspace_id = (
      SELECT id FROM public.workspaces
      WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000001'
    )$$,
  '23514'
);

-- Alice sees only her mapping and settings
SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000001', true);
SET LOCAL ROLE authenticated;

SELECT results_eq(
  $$SELECT host FROM public.domain_mappings ORDER BY host$$,
  $$VALUES ('portal.alice.example')$$
);

SELECT results_eq(
  $$SELECT presentation->>'brand' FROM public.workspace_settings$$,
  $$VALUES ('Alice Co')$$
);

-- Authenticated cannot INSERT mappings
SELECT throws_ok(
  $$INSERT INTO public.domain_mappings (workspace_id, host)
    SELECT id, 'hack.alice.example' FROM public.workspaces
    WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000001'$$,
  '42501'
);

RESET ROLE;

-- Bob sees only his mapping
SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000002', true);
SET LOCAL ROLE authenticated;

SELECT results_eq(
  $$SELECT host FROM public.domain_mappings ORDER BY host$$,
  $$VALUES ('portal.bob.example')$$
);

RESET ROLE;
SELECT set_config('request.jwt.claim.sub', '', true);

-- =========================================================================
-- 4. ROLE-LIMITED ENTITY CREATION (via public.create_entity)
-- =========================================================================

-- Alice (owner) can create an entity in her workspace
SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000001', true);
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_ws_id uuid;
BEGIN
  SELECT id INTO v_ws_id FROM public.workspaces
    WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000001';
  PERFORM public.create_entity(v_ws_id, 'task'::public.entity_type, 'Test task', '{}'::jsonb, NULL);
END;
$$;

RESET ROLE;
SELECT set_config('request.jwt.claim.sub', '', true);

-- Verify entity was created with correct created_by (running as postgres to bypass RLS)
SELECT results_eq(
  $$SELECT count(*)::int FROM public.entities
    WHERE name = 'Test task'
      AND created_by = 'a0000000-0000-0000-0000-000000000001'$$,
  $$VALUES (1)$$
);

-- =========================================================================
-- 5. IDEMPOTENCY: KEY VALIDATION
-- =========================================================================

-- Helper: a block to get workspace ID and store in shared temp table
DO $$
DECLARE
  v_ws_id uuid;
BEGIN
  SELECT id INTO v_ws_id FROM public.workspaces
    WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000001';
  -- Store for later use in a temp table (with ON COMMIT DROP for cleanup)
  CREATE TEMP TABLE IF NOT EXISTS _test_ws (id uuid) ON COMMIT DROP;
  DELETE FROM _test_ws;
  INSERT INTO _test_ws VALUES (v_ws_id);
END;
$$;

-- Grant SELECT so authenticated role can read the temp table during RLS tests
GRANT SELECT ON TABLE _test_ws TO authenticated;

-- Empty key must be rejected with SQLSTATE 22023
SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000001', true);
SET LOCAL ROLE authenticated;

SELECT throws_ok(
  $$SELECT public.create_entity(
    (SELECT id FROM _test_ws),
    'task'::public.entity_type, 'empty key test', '{}'::jsonb, ''
  )$$,
  '22023'
);

-- Key with space must be rejected
SELECT throws_ok(
  $$SELECT public.create_entity(
    (SELECT id FROM _test_ws),
    'task'::public.entity_type, 'space key test', '{}'::jsonb, 'key with spaces'
  )$$,
  '22023'
);

-- Key with Unicode must be rejected
SELECT throws_ok(
  $$SELECT public.create_entity(
    (SELECT id FROM _test_ws),
    'task'::public.entity_type, 'unicode key test', '{}'::jsonb, 'café'
  )$$,
  '22023'
);

RESET ROLE;
SELECT set_config('request.jwt.claim.sub', '', true);

-- =========================================================================
-- 6. IDEMPOTENCY: SAME KEY + SAME PAYLOAD = REPLAY
-- =========================================================================

SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000001', true);
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_ws_id uuid;
  v_id1 uuid;
  v_id2 uuid;
BEGIN
  SELECT id INTO v_ws_id FROM _test_ws;
  v_id1 := public.create_entity(v_ws_id, 'task'::public.entity_type, 'Idempotent entity', '{}'::jsonb, 'idem-key-001');
  v_id2 := public.create_entity(v_ws_id, 'task'::public.entity_type, 'Idempotent entity', '{}'::jsonb, 'idem-key-001');
  IF v_id1 <> v_id2 THEN
    RAISE EXCEPTION 'Idempotent replay returned different UUID: % vs %', v_id1, v_id2;
  END IF;
END;
$$;

RESET ROLE;
SELECT set_config('request.jwt.claim.sub', '', true);

SELECT results_eq(
  $$SELECT count(*)::int FROM public.entities WHERE name = 'Idempotent entity'$$,
  $$VALUES (1)$$
);

-- =========================================================================
-- 7. IDEMPOTENCY: SAME KEY, DIFFERENT PAYLOAD = REJECTION
-- =========================================================================

-- Create entity with specific key and payload
SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000001', true);
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_ws_id uuid;
BEGIN
  SELECT id INTO v_ws_id FROM _test_ws;
  PERFORM public.create_entity(v_ws_id, 'task'::public.entity_type, 'Conflict entity',
    '{"priority":"low"}'::jsonb, 'conflict-key-001');
END;
$$;

RESET ROLE;
SELECT set_config('request.jwt.claim.sub', '', true);

-- Same key with DIFFERENT payload must raise 22023
SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000001', true);
SET LOCAL ROLE authenticated;

SELECT throws_ok(
  $$SELECT public.create_entity(
    (SELECT id FROM _test_ws),
    'task'::public.entity_type, 'Conflict entity', '{"priority":"high"}'::jsonb, 'conflict-key-001'
  )$$,
  '22023'
);

RESET ROLE;
SELECT set_config('request.jwt.claim.sub', '', true);

-- Original row remains unchanged
SELECT results_eq(
  $$SELECT properties->>'priority' FROM public.entities WHERE name = 'Conflict entity'$$,
  $$VALUES ('low')$$
);

-- =========================================================================
-- 8. IDEMPOTENCY: KEYLESS CALLS ARE DISTINCT
-- =========================================================================

SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000001', true);
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_ws_id uuid;
  v_id1 uuid;
  v_id2 uuid;
BEGIN
  SELECT id INTO v_ws_id FROM _test_ws;
  v_id1 := public.create_entity(v_ws_id, 'task'::public.entity_type, 'No key entity', '{}'::jsonb, NULL);
  v_id2 := public.create_entity(v_ws_id, 'task'::public.entity_type, 'No key entity', '{}'::jsonb, NULL);
  IF v_id1 = v_id2 THEN
    RAISE EXCEPTION 'Keyless calls must return different UUIDs but got %', v_id1;
  END IF;
END;
$$;

RESET ROLE;
SELECT set_config('request.jwt.claim.sub', '', true);

SELECT results_eq(
  $$SELECT count(*)::int FROM public.entities WHERE name = 'No key entity'$$,
  $$VALUES (2)$$
);

-- =========================================================================
-- 9. IDEMPOTENCY: CASE-SENSITIVE KEYS ARE DISTINCT
-- =========================================================================

SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000001', true);
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_ws_id uuid;
  v_id1 uuid;
  v_id2 uuid;
BEGIN
  SELECT id INTO v_ws_id FROM _test_ws;
  v_id1 := public.create_entity(v_ws_id, 'task'::public.entity_type, 'Case entity A', '{}'::jsonb, 'Key-ABC');
  v_id2 := public.create_entity(v_ws_id, 'task'::public.entity_type, 'Case entity B', '{}'::jsonb, 'key-abc');
  IF v_id1 = v_id2 THEN
    RAISE EXCEPTION 'Case-different keys must be distinct but got %', v_id1;
  END IF;
END;
$$;

RESET ROLE;
SELECT set_config('request.jwt.claim.sub', '', true);

-- =========================================================================
-- 10. IDEMPOTENCY: ACCEPTABLE KEY CHARACTERS
-- =========================================================================

-- Boundary character '!'
SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000001', true);
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_ws_id uuid;
BEGIN
  SELECT id INTO v_ws_id FROM _test_ws;
  PERFORM public.create_entity(v_ws_id, 'task'::public.entity_type, 'bang key', '{}'::jsonb, '!');
END;
$$;
RESET ROLE;
SELECT set_config('request.jwt.claim.sub', '', true);

SELECT results_eq(
  $$SELECT count(*)::int FROM public.entities WHERE name = 'bang key'$$,
  $$VALUES (1)$$
);

-- Boundary character '~'
SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000001', true);
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_ws_id uuid;
BEGIN
  SELECT id INTO v_ws_id FROM _test_ws;
  PERFORM public.create_entity(v_ws_id, 'task'::public.entity_type, 'tilde key', '{}'::jsonb, '~');
END;
$$;
RESET ROLE;
SELECT set_config('request.jwt.claim.sub', '', true);

SELECT results_eq(
  $$SELECT count(*)::int FROM public.entities WHERE name = 'tilde key'$$,
  $$VALUES (1)$$
);

-- 256-char printable ASCII key
SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000001', true);
SET LOCAL ROLE authenticated;

DO $$
DECLARE
  v_ws_id uuid;
  v_long_key text;
BEGIN
  SELECT id INTO v_ws_id FROM _test_ws;
  v_long_key := repeat('A', 256);
  PERFORM public.create_entity(v_ws_id, 'task'::public.entity_type, '256 char key', '{}'::jsonb, v_long_key);
END;
$$;
RESET ROLE;
SELECT set_config('request.jwt.claim.sub', '', true);

SELECT results_eq(
  $$SELECT count(*)::int FROM public.entities WHERE name = '256 char key'$$,
  $$VALUES (1)$$
);

-- 257-char key must be rejected
SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000001', true);
SET LOCAL ROLE authenticated;

SELECT throws_ok(
  $$SELECT public.create_entity(
    (SELECT id FROM _test_ws),
    'task'::public.entity_type, 'too long', '{}'::jsonb, repeat('A', 257)
  )$$,
  '22023'
);

RESET ROLE;
SELECT set_config('request.jwt.claim.sub', '', true);

-- =========================================================================
-- 11. SAME KEY, DIFFERENT WORKSPACE = INDEPENDENT
-- =========================================================================

DO $$
DECLARE
  v_ws1_id uuid;
  v_ws2_id uuid;
  v_id1 uuid;
  v_id2 uuid;
BEGIN
  SELECT id INTO v_ws1_id FROM public.workspaces
    WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000001';
  SELECT id INTO v_ws2_id FROM public.workspaces
    WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000002';

  PERFORM set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000001', true);
  SET LOCAL ROLE authenticated;
  v_id1 := public.create_entity(v_ws1_id, 'task'::public.entity_type, 'cross-ws', '{}'::jsonb, 'cross-ws-key');
  RESET ROLE;
  PERFORM set_config('request.jwt.claim.sub', '', true);

  PERFORM set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000002', true);
  SET LOCAL ROLE authenticated;
  v_id2 := public.create_entity(v_ws2_id, 'task'::public.entity_type, 'cross-ws', '{}'::jsonb, 'cross-ws-key');
  RESET ROLE;
  PERFORM set_config('request.jwt.claim.sub', '', true);

  IF v_id1 = v_id2 THEN
    RAISE EXCEPTION 'Cross-workspace keys must be independent';
  END IF;
END;
$$;

-- =========================================================================
-- 12. AUTHORIZATION: NON-MEMBER REJECTION
-- =========================================================================

-- Create a third user who is NOT a member of any workspace.
INSERT INTO auth.users (id, email, raw_user_meta_data, instance_id, aud, role, email_confirmed_at, encrypted_password)
VALUES
  ('a0000000-0000-0000-0000-000000000003', 'eve@example.com',
   '{"full_name": "Eve Outsider"}', '00000000-0000-0000-0000-000000000000',
   'authenticated', 'authenticated', now(), '');

-- Eve (not a member of Alice's workspace) cannot call create_entity there.
SELECT set_config('request.jwt.claim.sub', 'a0000000-0000-0000-0000-000000000003', true);
SET LOCAL ROLE authenticated;

SELECT throws_ok(
  $$SELECT public.create_entity(
    (SELECT id FROM public.workspaces WHERE personal_owner_id = 'a0000000-0000-0000-0000-000000000001'),
    'task'::public.entity_type, 'eve hack', '{}'::jsonb
  )$$,
  '42501'
);

RESET ROLE;
SELECT set_config('request.jwt.claim.sub', '', true);

-- =========================================================================
-- Cleanup temp table (will be rolled back anyway)
-- =========================================================================
DROP TABLE IF EXISTS _test_ws;

-- =========================================================================
-- Finish
-- =========================================================================
SELECT * FROM finish();
ROLLBACK;
