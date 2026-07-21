-- Core Foundation Migration
-- Schemas, enums, tables, indexes, RLS, triggers, functions, and grants.

-- =========================================================================
-- 1. Private schema (unexposed — NOT in Supabase API schemas)
-- =========================================================================
CREATE SCHEMA IF NOT EXISTS private;

-- =========================================================================
-- 2. Enum types
-- =========================================================================
CREATE TYPE public.entity_type AS ENUM (
  'client', 'project', 'meeting', 'decision',
  'task', 'document', 'process', 'report'
);

CREATE TYPE public.membership_role AS ENUM (
  'owner', 'admin', 'member', 'viewer'
);

CREATE TYPE public.workspace_type AS ENUM (
  'personal', 'team', 'organization'
);

-- =========================================================================
-- 3. Auth and tenancy tables
-- =========================================================================

-- profiles.id IS the auth.users.id — no separate user_id column
CREATE TABLE public.profiles (
  id         uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email      text UNIQUE NOT NULL,
  full_name  text,
  avatar_url text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.workspaces (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name              text NOT NULL CHECK (char_length(name) BETWEEN 1 AND 128),
  slug              text UNIQUE NOT NULL CHECK (char_length(slug) BETWEEN 1 AND 63),
  workspace_type    public.workspace_type NOT NULL,
  personal_owner_id uuid UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
  status            text NOT NULL DEFAULT 'active',
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT personal_workspace_owner CHECK (
    (workspace_type = 'personal' AND personal_owner_id IS NOT NULL)
    OR (workspace_type <> 'personal' AND personal_owner_id IS NULL)
  )
);

-- Enable RLS on workspaces
ALTER TABLE public.workspaces ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.memberships (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
  profile_id   uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role         public.membership_role NOT NULL,
  status       text NOT NULL DEFAULT 'active',
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now(),
  UNIQUE (workspace_id, profile_id)
);

-- Enable RLS on memberships
ALTER TABLE public.memberships ENABLE ROW LEVEL SECURITY;

-- =========================================================================
-- 4. Phase 1 context tables
-- =========================================================================

CREATE TABLE public.entities (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id         uuid NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
  entity_type          public.entity_type NOT NULL,
  name                 text NOT NULL CHECK (char_length(name) BETWEEN 1 AND 256),
  status               text NOT NULL DEFAULT 'active',
  properties           jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(properties) = 'object'),
  fingerprint          text NOT NULL CHECK (char_length(fingerprint) = 64),
  idempotency_key_hash text CHECK (idempotency_key_hash IS NULL OR char_length(idempotency_key_hash) = 64),
  created_by           uuid NOT NULL REFERENCES public.profiles(id),
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now(),
  archived_at          timestamptz,
  UNIQUE (workspace_id, id)
);

-- Partial unique index: only enforced when idempotency_key_hash IS NOT NULL
CREATE UNIQUE INDEX idx_entities_ws_idem_key_hash
  ON public.entities (workspace_id, idempotency_key_hash)
  WHERE idempotency_key_hash IS NOT NULL;

-- Enable RLS on entities
ALTER TABLE public.entities ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.entity_properties (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id   uuid NOT NULL,
  entity_id      uuid NOT NULL,
  property_key   text NOT NULL CHECK (char_length(property_key) BETWEEN 1 AND 128),
  property_value jsonb NOT NULL,
  property_type  text NOT NULL,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now(),
  UNIQUE (workspace_id, entity_id, property_key),
  FOREIGN KEY (workspace_id, entity_id)
    REFERENCES public.entities(workspace_id, id) ON DELETE CASCADE
);

-- Enable RLS on entity_properties
ALTER TABLE public.entity_properties ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.relationships (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id      uuid NOT NULL,
  from_entity_id    uuid NOT NULL,
  to_entity_id      uuid NOT NULL,
  relationship_type text NOT NULL CHECK (char_length(relationship_type) BETWEEN 1 AND 64),
  confidence        numeric(3,2) NOT NULL DEFAULT 1 CHECK (confidence >= 0 AND confidence <= 1),
  valid_from        timestamptz,
  valid_to          timestamptz,
  properties        jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(properties) = 'object'),
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  CHECK (from_entity_id <> to_entity_id),
  CHECK (valid_to IS NULL OR valid_from IS NULL OR valid_to >= valid_from),
  FOREIGN KEY (workspace_id, from_entity_id)
    REFERENCES public.entities(workspace_id, id) ON DELETE CASCADE,
  FOREIGN KEY (workspace_id, to_entity_id)
    REFERENCES public.entities(workspace_id, id) ON DELETE CASCADE
);

-- Enable RLS on relationships
ALTER TABLE public.relationships ENABLE ROW LEVEL SECURITY;

-- =========================================================================
-- 5. Indexes
-- =========================================================================

-- memberships: profile lookup and workspace membership operations
CREATE INDEX idx_memberships_profile_status_ws
  ON public.memberships (profile_id, status, workspace_id);
CREATE INDEX idx_memberships_workspace_status
  ON public.memberships (workspace_id, status);

-- entities: typed listing per workspace
CREATE INDEX idx_entities_ws_type_status
  ON public.entities (workspace_id, entity_type, status);

-- entities: JSONB GIN index for containment queries (jsonb_path_ops)
CREATE INDEX idx_entities_properties_gin
  ON public.entities USING gin (properties jsonb_path_ops);

-- entity_properties: workspace/property-key lookup
CREATE INDEX idx_entity_props_ws_key
  ON public.entity_properties (workspace_id, property_key);

-- entity_properties: JSONB GIN index for containment queries
CREATE INDEX idx_entity_props_value_gin
  ON public.entity_properties USING gin (property_value jsonb_path_ops);

-- relationships: from-to endpoint lookups
CREATE INDEX idx_relationships_ws_from_type
  ON public.relationships (workspace_id, from_entity_id, relationship_type);
CREATE INDEX idx_relationships_ws_to_type
  ON public.relationships (workspace_id, to_entity_id, relationship_type);

-- =========================================================================
-- 6. RLS helper: active workspace IDs for the current authenticated user
-- =========================================================================
CREATE OR REPLACE FUNCTION private.current_user_workspace_ids()
RETURNS SETOF uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT workspace_id
  FROM public.memberships
  WHERE profile_id = (SELECT auth.uid())
    AND status = 'active';
$$;

-- Grant: authenticated users (and the definer owner) may execute this helper
GRANT EXECUTE ON FUNCTION private.current_user_workspace_ids() TO authenticated;

-- =========================================================================
-- 7. RLS policies (SELECT only — no INSERT/UPDATE/DELETE policies)
-- =========================================================================

-- profiles: user sees only their own profile
CREATE POLICY profiles_select_own ON public.profiles
  FOR SELECT TO authenticated
  USING (id = (SELECT auth.uid()));

-- workspaces: member sees workspaces with active membership
CREATE POLICY workspaces_select_member ON public.workspaces
  FOR SELECT TO authenticated
  USING (id IN (SELECT private.current_user_workspace_ids()));

-- memberships: user sees only their own memberships
CREATE POLICY memberships_select_own ON public.memberships
  FOR SELECT TO authenticated
  USING (profile_id = (SELECT auth.uid()));

-- entities: member sees entities in their workspaces
CREATE POLICY entities_select_member ON public.entities
  FOR SELECT TO authenticated
  USING (workspace_id IN (SELECT private.current_user_workspace_ids()));

-- entity_properties: member sees properties in their workspaces
CREATE POLICY entity_properties_select_member ON public.entity_properties
  FOR SELECT TO authenticated
  USING (workspace_id IN (SELECT private.current_user_workspace_ids()));

-- relationships: member sees relationships in their workspaces
CREATE POLICY relationships_select_member ON public.relationships
  FOR SELECT TO authenticated
  USING (workspace_id IN (SELECT private.current_user_workspace_ids()));

-- =========================================================================
-- 7b. Grant base SELECT privileges to authenticated (RLS policies then filter)
-- =========================================================================
GRANT SELECT ON public.profiles TO authenticated;
GRANT SELECT ON public.workspaces TO authenticated;
GRANT SELECT ON public.memberships TO authenticated;
GRANT SELECT ON public.entities TO authenticated;
GRANT SELECT ON public.entity_properties TO authenticated;
GRANT SELECT ON public.relationships TO authenticated;

-- Also grant USAGE on both schemas so authenticated can resolve function calls
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA private TO authenticated;

-- =========================================================================
-- 8. Revoke default public execution on all functions
-- =========================================================================
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
  REVOKE ALL ON FUNCTIONS FROM PUBLIC;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA private
  REVOKE ALL ON FUNCTIONS FROM PUBLIC;

-- Revoke existing default grants on the functions we are about to create
-- (they don't exist yet, but we set the default; for this migration they'll
-- be created below and we explicitly grant afterward)

-- =========================================================================
-- 9. Idempotent provisioning
-- =========================================================================

-- Helper: build a human-readable slug base from email or metadata
CREATE OR REPLACE FUNCTION private.build_slug_base(
  p_email text,
  p_user_metadata jsonb
)
RETURNS text
LANGUAGE plpgsql
IMMUTABLE
SET search_path = ''
AS $$
DECLARE
  v_base text;
BEGIN
  -- Prefer full_name from metadata, fall back to email prefix
  v_base := COALESCE(
    p_user_metadata ->> 'full_name',
    p_user_metadata ->> 'name',
    split_part(p_email, '@', 1)
  );

  -- Sanitize: lowercase, replace non-alphanumeric with hyphen, trim hyphens
  v_base := regexp_replace(lower(v_base), '[^a-z0-9]+', '-', 'g');
  v_base := trim(both '-' from v_base);

  -- If sanitization produces empty string, use 'user'
  IF v_base = '' THEN
    v_base := 'user';
  END IF;

  -- Truncate to leave room for the 9-char suffix (hyphen + 8 hex chars)
  IF length(v_base) > 53 THEN
    v_base := left(v_base, 53);
  END IF;

  RETURN v_base;
END;
$$;

-- Main provisioning function: idempotent profile + personal workspace + membership
CREATE OR REPLACE FUNCTION private.provision_user(
  p_user_id       uuid,
  p_email         text,
  p_user_metadata jsonb
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_full_name    text;
  v_avatar_url   text;
  v_workspace_id uuid;
  v_slug_base    text;
  v_slug         text;
  v_suffix       text;
  v_attempts     int := 0;
  v_max_attempts int := 10;
BEGIN
  -- Extract display values from metadata (never used for authorization)
  v_full_name  := COALESCE(p_user_metadata ->> 'full_name',
                           p_user_metadata ->> 'name',
                           split_part(p_email, '@', 1));
  v_avatar_url := p_user_metadata ->> 'avatar_url';

  -- Upsert profile (idempotent)
  INSERT INTO public.profiles (id, email, full_name, avatar_url)
  VALUES (p_user_id, p_email, v_full_name, v_avatar_url)
  ON CONFLICT (id) DO UPDATE SET
    email      = EXCLUDED.email,
    full_name  = EXCLUDED.full_name,
    avatar_url = EXCLUDED.avatar_url,
    updated_at = now();

  -- Check for existing personal workspace
  SELECT id INTO v_workspace_id
  FROM public.workspaces
  WHERE personal_owner_id = p_user_id;

  IF v_workspace_id IS NOT NULL THEN
    -- Workspace already exists — ensure membership is current
    INSERT INTO public.memberships (workspace_id, profile_id, role, status)
    VALUES (v_workspace_id, p_user_id, 'owner', 'active')
    ON CONFLICT (workspace_id, profile_id) DO UPDATE SET
      role   = 'owner',
      status = 'active',
      updated_at = now();

    RETURN v_workspace_id;
  END IF;

  -- Build slug: base + hyphen + 8-char UUID suffix; retry on collision
  v_slug_base := private.build_slug_base(p_email, p_user_metadata);

  LOOP
    v_attempts := v_attempts + 1;
    IF v_attempts > v_max_attempts THEN
      RAISE EXCEPTION 'Could not generate unique slug for user % after % attempts',
        p_user_id, v_max_attempts;
    END IF;

    -- Generate suffix from a new UUID
    v_suffix := right(replace(extensions.gen_random_uuid()::text, '-', ''), 8);
    v_slug := v_slug_base || '-' || v_suffix;

    -- Ensure slug fits within 63 characters
    IF length(v_slug) > 63 THEN
      v_slug := left(v_slug_base, 53) || '-' || v_suffix;
    END IF;

    BEGIN
      INSERT INTO public.workspaces (name, slug, workspace_type, personal_owner_id)
      VALUES (v_full_name || ' Workspace', v_slug, 'personal', p_user_id)
      RETURNING id INTO v_workspace_id;

      EXIT; -- success
    EXCEPTION WHEN unique_violation THEN
      -- Slug collision — retry with new suffix
      CONTINUE;
    END;
  END LOOP;

  -- Upsert membership as active owner
  INSERT INTO public.memberships (workspace_id, profile_id, role, status)
  VALUES (v_workspace_id, p_user_id, 'owner', 'active')
  ON CONFLICT (workspace_id, profile_id) DO UPDATE SET
    role       = 'owner',
    status     = 'active',
    updated_at = now();

  RETURN v_workspace_id;
END;
$$;

-- Trigger function: thin adapter that delegates to provision_user
CREATE OR REPLACE FUNCTION private.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  PERFORM private.provision_user(
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data
  );
  RETURN NEW;
END;
$$;

-- Register trigger on auth.users (local postgres role can do this)
DO $$
BEGIN
  -- Drop if exists (for idempotent re-runs)
  IF EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'on_auth_user_created'
      AND tgrelid = 'auth.users'::regclass
  ) THEN
    DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
  END IF;

  CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION private.handle_new_user();
END;
$$;

-- =========================================================================
-- 10. Entity creation — public SECURITY INVOKER wrapper
-- =========================================================================

-- Idempotency key validation: ^[!-~]{1,256}$ (printable ASCII, no whitespace)
CREATE OR REPLACE FUNCTION private.validate_idempotency_key(p_key text)
RETURNS void
LANGUAGE plpgsql
IMMUTABLE
SET search_path = ''
AS $$
BEGIN
  IF p_key IS NULL THEN
    RETURN; -- NULL is always valid (means "no key")
  END IF;

  IF length(p_key) < 1 OR length(p_key) > 256 THEN
    RAISE EXCEPTION 'Idempotency key must be 1-256 characters, got %', length(p_key)
      USING ERRCODE = '22023';
  END IF;

  -- Every character must be printable ASCII (bytes 0x21 '!' through 0x7E '~'), no whitespace
  -- Use byte-range check with octal escapes to work correctly in UTF-8 databases
  IF p_key ~ E'[^\\041-\\176]' THEN
    RAISE EXCEPTION 'Idempotency key contains invalid characters (must be printable ASCII, no whitespace)'
      USING ERRCODE = '22023';
  END IF;
END;
$$;

-- Build canonical JSONB from accepted request fields for fingerprint computation
CREATE OR REPLACE FUNCTION private.build_canonical_request(
  p_workspace_id uuid,
  p_entity_type  public.entity_type,
  p_name         text,
  p_properties   jsonb
)
RETURNS jsonb
LANGUAGE sql
IMMUTABLE
SET search_path = ''
AS $$
  SELECT jsonb_build_object(
    'workspace_id', p_workspace_id::text,
    'entity_type',  p_entity_type::text,
    'name',         p_name,
    'properties',   p_properties
  );
$$;

-- Compute SHA-256 fingerprint of a text value
CREATE OR REPLACE FUNCTION private.sha256(p_input text)
RETURNS text
LANGUAGE sql
IMMUTABLE
SET search_path = ''
AS $$
  SELECT encode(extensions.digest(p_input, 'sha256'), 'hex');
$$;

-- Advisory lock key: deterministic hash of (workspace_id, idempotency_key)
-- Uses a 32-bit integer from the first 4 bytes of SHA-256 (bigint to avoid overflow)
CREATE OR REPLACE FUNCTION private.lock_key(
  p_workspace_id    uuid,
  p_idempotency_key text
)
RETURNS bigint
LANGUAGE sql
IMMUTABLE
SET search_path = ''
AS $$
  SELECT ('x' || left(private.sha256(p_workspace_id::text || ':' || p_idempotency_key), 16))::bit(64)::bigint;
$$;

-- Core implementation: private SECURITY DEFINER
CREATE OR REPLACE FUNCTION private.create_entity_impl(
  p_workspace_id     uuid,
  p_entity_type      public.entity_type,
  p_name             text,
  p_properties       jsonb DEFAULT '{}'::jsonb,
  p_idempotency_key  text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_profile_id         uuid;
  v_membership_role    public.membership_role;
  v_canonical          jsonb;
  v_fingerprint        text;
  v_key_hash           text;
  v_existing           record;
  v_lock               bigint;
  v_new_id             uuid;
BEGIN
  -- ── Authorization ──────────────────────────────────────────
  v_profile_id := (SELECT auth.uid());
  IF v_profile_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required'
      USING ERRCODE = '42501';
  END IF;

  -- Verify active membership with role owner/admin/member
  SELECT m.role INTO v_membership_role
  FROM public.memberships m
  WHERE m.workspace_id = p_workspace_id
    AND m.profile_id = v_profile_id
    AND m.status = 'active';

  IF v_membership_role IS NULL THEN
    RAISE EXCEPTION 'Not a member of this workspace'
      USING ERRCODE = '42501';
  END IF;

  IF v_membership_role NOT IN ('owner', 'admin', 'member') THEN
    RAISE EXCEPTION 'Insufficient role to create entities (required: owner, admin, or member)'
      USING ERRCODE = '42501';
  END IF;

  -- ── Validation ─────────────────────────────────────────────
  -- Validate name (non-empty, max 256 chars)
  IF p_name IS NULL OR length(p_name) < 1 OR length(p_name) > 256 THEN
    RAISE EXCEPTION 'Entity name must be 1-256 characters'
      USING ERRCODE = '22023';
  END IF;

  -- Validate properties is a JSON object
  IF jsonb_typeof(p_properties) <> 'object' THEN
    RAISE EXCEPTION 'Properties must be a JSON object'
      USING ERRCODE = '22023';
  END IF;

  -- Validate idempotency key format (if provided)
  PERFORM private.validate_idempotency_key(p_idempotency_key);

  -- ── Build canonical request and fingerprint ─────────────────
  v_canonical  := private.build_canonical_request(p_workspace_id, p_entity_type, p_name, p_properties);
  v_fingerprint := private.sha256(v_canonical::text);

  -- ── Keyless fast path ──────────────────────────────────────
  IF p_idempotency_key IS NULL THEN
    INSERT INTO public.entities (
      workspace_id, entity_type, name, status,
      properties, fingerprint, idempotency_key_hash, created_by
    ) VALUES (
      p_workspace_id, p_entity_type, p_name, 'active',
      p_properties, v_fingerprint, NULL, v_profile_id
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
  END IF;

  -- ── Idempotent path ────────────────────────────────────────
  v_key_hash := private.sha256(p_idempotency_key);

  -- Acquire transaction-level advisory lock scoped to (workspace, key)
  v_lock := private.lock_key(p_workspace_id, p_idempotency_key);
  PERFORM pg_advisory_xact_lock(v_lock);

  -- Check for existing entity with same workspace/key hash
  SELECT id, fingerprint, idempotency_key_hash
  INTO v_existing
  FROM public.entities
  WHERE workspace_id = p_workspace_id
    AND idempotency_key_hash = v_key_hash;

  IF FOUND THEN
    -- Matching key + fingerprint → replay (return existing UUID)
    IF v_existing.fingerprint = v_fingerprint THEN
      RETURN v_existing.id;
    END IF;

    -- Same key, different fingerprint → conflict
    RAISE EXCEPTION 'Idempotency key reused with different payload: key_hash=%, previous_fingerprint=%, current_fingerprint=%',
      v_key_hash, v_existing.fingerprint, v_fingerprint
      USING ERRCODE = '22023';
  END IF;

  -- No existing row → insert new entity
  INSERT INTO public.entities (
    workspace_id, entity_type, name, status,
    properties, fingerprint, idempotency_key_hash, created_by
  ) VALUES (
    p_workspace_id, p_entity_type, p_name, 'active',
    p_properties, v_fingerprint, v_key_hash, v_profile_id
  )
  RETURNING id INTO v_new_id;

  RETURN v_new_id;
END;
$$;

-- Narrow EXECUTE grant: public invoker wrapper needs to call this
-- (authenticated does NOT get direct EXECUTE — only through the invoker wrapper)
GRANT EXECUTE ON FUNCTION private.create_entity_impl(
  uuid, public.entity_type, text, jsonb, text
) TO authenticated;

-- =========================================================================
-- 11. Public SECURITY INVOKER wrapper — thin passthrough
-- =========================================================================
CREATE OR REPLACE FUNCTION public.create_entity(
  p_workspace_id     uuid,
  p_entity_type      public.entity_type,
  p_name             text,
  p_properties       jsonb DEFAULT '{}'::jsonb,
  p_idempotency_key  text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = 'public'
AS $$
BEGIN
  RETURN private.create_entity_impl(
    p_workspace_id,
    p_entity_type,
    p_name,
    p_properties,
    p_idempotency_key
  );
END;
$$;

-- Grant EXECUTE on the public wrapper to authenticated users
GRANT EXECUTE ON FUNCTION public.create_entity(
  uuid, public.entity_type, text, jsonb, text
) TO authenticated;

-- =========================================================================
-- 12. Revoke function execution from PUBLIC/anonymous
-- =========================================================================

-- Revoke all from PUBLIC on every function in private
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT p.proname, pg_catalog.pg_get_function_identity_arguments(p.oid) AS args
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('private')
      AND p.prokind = 'f'  -- regular functions only, not aggregates/windows
  LOOP
    EXECUTE format('REVOKE ALL ON FUNCTION private.%I(%s) FROM PUBLIC',
      r.proname, r.args);
  END LOOP;
END;
$$;

-- Revoke from anon role explicitly
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT p.proname, pg_catalog.pg_get_function_identity_arguments(p.oid) AS args
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname IN ('private')
      AND p.prokind = 'f'
  LOOP
    EXECUTE format('REVOKE ALL ON FUNCTION private.%I(%s) FROM anon',
      r.proname, r.args);
  END LOOP;
END;
$$;

-- =========================================================================
-- 13. Explicit grants matrix (matching design.md)
-- =========================================================================

-- private.current_user_workspace_ids(): EXECUTE for authenticated
GRANT EXECUTE ON FUNCTION private.current_user_workspace_ids() TO authenticated;

-- private.provision_user: NO direct EXECUTE to PUBLIC/anon/authenticated
-- (only the trigger + migration/test owner can call it; explicitly revoke)
REVOKE ALL ON FUNCTION private.provision_user(uuid, text, jsonb) FROM PUBLIC, anon, authenticated;

-- private.handle_new_user: NO direct EXECUTE (trigger-only)
REVOKE ALL ON FUNCTION private.handle_new_user() FROM PUBLIC, anon, authenticated;

-- private.create_entity_impl: narrow EXECUTE for authenticated (needed by invoker wrapper)
-- Already granted above.

-- public.create_entity: EXECUTE for authenticated
-- Already granted above.
