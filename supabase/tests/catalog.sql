-- pgTAP catalog tests for Core Foundation (Supabase CLI 2.109.1 pgTAP)
-- Uses ::name casts for all pgTAP catalog functions
-- Falls back to ok() + catalog queries where pgTAP functions are limited

BEGIN;
SELECT no_plan();

-- =========================================================================
-- Schemas
-- =========================================================================
SELECT has_schema('public'::name);
SELECT has_schema('private'::name);

-- =========================================================================
-- Enum types
-- =========================================================================
SELECT has_type('entity_type'::name);
SELECT has_type('membership_role'::name);
SELECT has_type('workspace_type'::name);

SELECT results_eq(
  $$SELECT unnest(enum_range(null::public.entity_type))::text ORDER BY 1$$,
  $$VALUES ('client'),('decision'),('document'),('meeting'),
           ('process'),('project'),('report'),('task')
    ORDER BY 1$$
);

SELECT results_eq(
  $$SELECT unnest(enum_range(null::public.membership_role))::text ORDER BY 1$$,
  $$VALUES ('admin'),('member'),('owner'),('viewer') ORDER BY 1$$
);

SELECT results_eq(
  $$SELECT unnest(enum_range(null::public.workspace_type))::text ORDER BY 1$$,
  $$VALUES ('organization'),('personal'),('team') ORDER BY 1$$
);

-- =========================================================================
-- Tables
-- =========================================================================
SELECT has_table('public'::name, 'profiles'::name);
SELECT has_table('public'::name, 'workspaces'::name);
SELECT has_table('public'::name, 'memberships'::name);
SELECT has_table('public'::name, 'domain_mappings'::name);
SELECT has_table('public'::name, 'workspace_settings'::name);
SELECT has_table('public'::name, 'entities'::name);
SELECT has_table('public'::name, 'entity_properties'::name);
SELECT has_table('public'::name, 'relationships'::name);

-- =========================================================================
-- domain_mappings
-- =========================================================================
SELECT has_column('public'::name, 'domain_mappings'::name, 'id'::name, ''::text);
SELECT has_column('public'::name, 'domain_mappings'::name, 'workspace_id'::name, ''::text);
SELECT has_column('public'::name, 'domain_mappings'::name, 'host'::name, ''::text);
SELECT has_column('public'::name, 'domain_mappings'::name, 'status'::name, ''::text);
SELECT col_is_pk('public'::name, 'domain_mappings'::name, ARRAY['id']::name[]);
SELECT col_is_unique('public'::name, 'domain_mappings'::name, ARRAY['host']::name[]);
SELECT col_not_null('public'::name, 'domain_mappings'::name, 'host'::name, ''::text);
SELECT col_not_null('public'::name, 'domain_mappings'::name, 'workspace_id'::name, ''::text);
SELECT col_not_null('public'::name, 'domain_mappings'::name, 'status'::name, ''::text);

SELECT ok(
  (SELECT count(*) = 1 FROM pg_catalog.pg_constraint
   WHERE conrelid = 'public.domain_mappings'::regclass
     AND confrelid = 'public.workspaces'::regclass
     AND contype = 'f'),
  'domain_mappings.workspace_id -> workspaces(id) FK'
);

SELECT has_index('public'::name, 'domain_mappings'::name, 'idx_domain_mappings_workspace_status'::name,
  ARRAY['workspace_id', 'status']::name[]);

-- =========================================================================
-- workspace_settings
-- =========================================================================
SELECT has_column('public'::name, 'workspace_settings'::name, 'workspace_id'::name, ''::text);
SELECT has_column('public'::name, 'workspace_settings'::name, 'presentation'::name, ''::text);
SELECT col_is_pk('public'::name, 'workspace_settings'::name, ARRAY['workspace_id']::name[]);
SELECT col_not_null('public'::name, 'workspace_settings'::name, 'presentation'::name, ''::text);

SELECT ok(
  (SELECT count(*) = 1 FROM pg_catalog.pg_constraint
   WHERE conrelid = 'public.workspace_settings'::regclass
     AND confrelid = 'public.workspaces'::regclass
     AND contype = 'f'),
  'workspace_settings.workspace_id -> workspaces(id) FK'
);

-- =========================================================================
-- profiles
-- =========================================================================
SELECT has_column('public'::name, 'profiles'::name, 'id'::name, ''::text);
SELECT has_column('public'::name, 'profiles'::name, 'email'::name, ''::text);
SELECT has_column('public'::name, 'profiles'::name, 'full_name'::name, ''::text);
SELECT has_column('public'::name, 'profiles'::name, 'avatar_url'::name, ''::text);
SELECT has_column('public'::name, 'profiles'::name, 'created_at'::name, ''::text);
SELECT has_column('public'::name, 'profiles'::name, 'updated_at'::name, ''::text);

-- Column types via catalog (col_type_is has issues with built-in types in this pgTAP)
SELECT ok(
  (SELECT data_type = 'uuid' FROM information_schema.columns
   WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'id'),
  'profiles.id is uuid'
);
SELECT ok(
  (SELECT data_type = 'text' FROM information_schema.columns
   WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'email'),
  'profiles.email is text'
);

SELECT col_is_pk('public'::name, 'profiles'::name, ARRAY['id']::name[]);
SELECT col_not_null('public'::name, 'profiles'::name, 'email'::name, ''::text);
SELECT col_is_unique('public'::name, 'profiles'::name, ARRAY['email']::name[]);

-- profiles.id references auth.users(id)
SELECT ok(
  (SELECT count(*) = 1 FROM pg_catalog.pg_constraint
   WHERE conrelid = 'public.profiles'::regclass
     AND confrelid = 'auth.users'::regclass
     AND contype = 'f'),
  'profiles.id -> auth.users(id) FK'
);

-- NEGATIVE: no user_id column
SELECT hasnt_column('public'::name, 'profiles'::name, 'user_id'::name, ''::text);

-- =========================================================================
-- workspaces
-- =========================================================================
SELECT has_column('public'::name, 'workspaces'::name, 'id'::name, ''::text);
SELECT has_column('public'::name, 'workspaces'::name, 'name'::name, ''::text);
SELECT has_column('public'::name, 'workspaces'::name, 'slug'::name, ''::text);
SELECT has_column('public'::name, 'workspaces'::name, 'workspace_type'::name, ''::text);
SELECT has_column('public'::name, 'workspaces'::name, 'personal_owner_id'::name, ''::text);
SELECT has_column('public'::name, 'workspaces'::name, 'status'::name, ''::text);
SELECT has_column('public'::name, 'workspaces'::name, 'created_at'::name, ''::text);
SELECT has_column('public'::name, 'workspaces'::name, 'updated_at'::name, ''::text);

SELECT col_is_pk('public'::name, 'workspaces'::name, ARRAY['id']::name[]);
SELECT col_not_null('public'::name, 'workspaces'::name, 'name'::name, ''::text);
SELECT col_not_null('public'::name, 'workspaces'::name, 'slug'::name, ''::text);
SELECT col_not_null('public'::name, 'workspaces'::name, 'status'::name, ''::text);
SELECT col_is_unique('public'::name, 'workspaces'::name, ARRAY['slug']::name[]);

-- =========================================================================
-- memberships
-- =========================================================================
SELECT has_column('public'::name, 'memberships'::name, 'id'::name, ''::text);
SELECT has_column('public'::name, 'memberships'::name, 'workspace_id'::name, ''::text);
SELECT has_column('public'::name, 'memberships'::name, 'profile_id'::name, ''::text);
SELECT has_column('public'::name, 'memberships'::name, 'role'::name, ''::text);
SELECT has_column('public'::name, 'memberships'::name, 'status'::name, ''::text);
SELECT has_column('public'::name, 'memberships'::name, 'created_at'::name, ''::text);
SELECT has_column('public'::name, 'memberships'::name, 'updated_at'::name, ''::text);

SELECT col_is_pk('public'::name, 'memberships'::name, ARRAY['id']::name[]);
SELECT col_not_null('public'::name, 'memberships'::name, 'status'::name, ''::text);
SELECT col_is_unique('public'::name, 'memberships'::name, ARRAY['workspace_id', 'profile_id']::name[]);

-- =========================================================================
-- entities
-- =========================================================================
SELECT has_column('public'::name, 'entities'::name, 'id'::name, ''::text);
SELECT has_column('public'::name, 'entities'::name, 'workspace_id'::name, ''::text);
SELECT has_column('public'::name, 'entities'::name, 'entity_type'::name, ''::text);
SELECT has_column('public'::name, 'entities'::name, 'name'::name, ''::text);
SELECT has_column('public'::name, 'entities'::name, 'status'::name, ''::text);
SELECT has_column('public'::name, 'entities'::name, 'properties'::name, ''::text);
SELECT has_column('public'::name, 'entities'::name, 'fingerprint'::name, ''::text);
SELECT has_column('public'::name, 'entities'::name, 'idempotency_key_hash'::name, ''::text);
SELECT has_column('public'::name, 'entities'::name, 'created_by'::name, ''::text);
SELECT has_column('public'::name, 'entities'::name, 'created_at'::name, ''::text);
SELECT has_column('public'::name, 'entities'::name, 'updated_at'::name, ''::text);
SELECT has_column('public'::name, 'entities'::name, 'archived_at'::name, ''::text);

SELECT col_is_pk('public'::name, 'entities'::name, ARRAY['id']::name[]);
SELECT col_not_null('public'::name, 'entities'::name, 'name'::name, ''::text);
SELECT col_not_null('public'::name, 'entities'::name, 'status'::name, ''::text);
SELECT col_not_null('public'::name, 'entities'::name, 'fingerprint'::name, ''::text);
SELECT col_is_unique('public'::name, 'entities'::name, ARRAY['workspace_id', 'id']::name[]);

-- entities JSONB check constraint
SELECT ok(
  (SELECT count(*) = 1 FROM pg_catalog.pg_constraint
   WHERE conrelid = 'public.entities'::regclass AND contype = 'c'
     AND pg_get_constraintdef(oid) LIKE '%jsonb_typeof(properties)%'),
  'entities.properties has JSONB object check'
);

-- =========================================================================
-- entity_properties
-- =========================================================================
SELECT has_column('public'::name, 'entity_properties'::name, 'id'::name, ''::text);
SELECT has_column('public'::name, 'entity_properties'::name, 'workspace_id'::name, ''::text);
SELECT has_column('public'::name, 'entity_properties'::name, 'entity_id'::name, ''::text);
SELECT has_column('public'::name, 'entity_properties'::name, 'property_key'::name, ''::text);
SELECT has_column('public'::name, 'entity_properties'::name, 'property_value'::name, ''::text);
SELECT has_column('public'::name, 'entity_properties'::name, 'property_type'::name, ''::text);
SELECT has_column('public'::name, 'entity_properties'::name, 'created_at'::name, ''::text);
SELECT has_column('public'::name, 'entity_properties'::name, 'updated_at'::name, ''::text);

SELECT col_is_pk('public'::name, 'entity_properties'::name, ARRAY['id']::name[]);
SELECT col_not_null('public'::name, 'entity_properties'::name, 'property_key'::name, ''::text);
SELECT col_not_null('public'::name, 'entity_properties'::name, 'property_type'::name, ''::text);
SELECT col_is_unique('public'::name, 'entity_properties'::name, ARRAY['workspace_id', 'entity_id', 'property_key']::name[]);

-- NEGATIVE: no source_id
SELECT hasnt_column('public'::name, 'entity_properties'::name, 'source_id'::name, ''::text);

-- =========================================================================
-- relationships
-- =========================================================================
SELECT has_column('public'::name, 'relationships'::name, 'id'::name, ''::text);
SELECT has_column('public'::name, 'relationships'::name, 'workspace_id'::name, ''::text);
SELECT has_column('public'::name, 'relationships'::name, 'from_entity_id'::name, ''::text);
SELECT has_column('public'::name, 'relationships'::name, 'to_entity_id'::name, ''::text);
SELECT has_column('public'::name, 'relationships'::name, 'relationship_type'::name, ''::text);
SELECT has_column('public'::name, 'relationships'::name, 'confidence'::name, ''::text);
SELECT has_column('public'::name, 'relationships'::name, 'valid_from'::name, ''::text);
SELECT has_column('public'::name, 'relationships'::name, 'valid_to'::name, ''::text);
SELECT has_column('public'::name, 'relationships'::name, 'properties'::name, ''::text);
SELECT has_column('public'::name, 'relationships'::name, 'created_at'::name, ''::text);
SELECT has_column('public'::name, 'relationships'::name, 'updated_at'::name, ''::text);

SELECT col_is_pk('public'::name, 'relationships'::name, ARRAY['id']::name[]);
SELECT col_not_null('public'::name, 'relationships'::name, 'relationship_type'::name, ''::text);
SELECT hasnt_column('public'::name, 'relationships'::name, 'source_id'::name, ''::text);

-- =========================================================================
-- Composite FKs (via catalog)
-- =========================================================================
SELECT ok(
  (SELECT count(*) >= 1 FROM pg_catalog.pg_constraint
   WHERE conrelid = 'public.entity_properties'::regclass
     AND confrelid = 'public.entities'::regclass
     AND contype = 'f'),
  'entity_properties composite FK to entities'
);

-- =========================================================================
-- Indexes
-- =========================================================================
SELECT has_index('public'::name, 'memberships'::name, 'idx_memberships_profile_status_ws'::name,
  ARRAY['profile_id', 'status', 'workspace_id']::name[]);
SELECT has_index('public'::name, 'memberships'::name, 'idx_memberships_workspace_status'::name,
  ARRAY['workspace_id', 'status']::name[]);
SELECT has_index('public'::name, 'entities'::name, 'idx_entities_ws_type_status'::name,
  ARRAY['workspace_id', 'entity_type', 'status']::name[]);
SELECT has_index('public'::name, 'entities'::name, 'idx_entities_ws_idem_key_hash'::name,
  ARRAY['workspace_id', 'idempotency_key_hash']::name[]);
SELECT has_index('public'::name, 'entity_properties'::name, 'idx_entity_props_ws_key'::name,
  ARRAY['workspace_id', 'property_key']::name[]);
SELECT has_index('public'::name, 'relationships'::name, 'idx_relationships_ws_from_type'::name,
  ARRAY['workspace_id', 'from_entity_id', 'relationship_type']::name[]);
SELECT has_index('public'::name, 'relationships'::name, 'idx_relationships_ws_to_type'::name,
  ARRAY['workspace_id', 'to_entity_id', 'relationship_type']::name[]);

-- JSONB GIN indexes
SELECT index_is_type('public'::name, 'entities'::name, 'idx_entities_properties_gin'::name, 'gin'::name);
SELECT index_is_type('public'::name, 'entity_properties'::name, 'idx_entity_props_value_gin'::name, 'gin'::name);

-- =========================================================================
-- RLS policies (rls_enabled not in this pgTAP, use policies_are for existence)
-- =========================================================================
SELECT policies_are('public'::name, 'profiles'::name, ARRAY['profiles_select_own']::name[]);
SELECT policies_are('public'::name, 'workspaces'::name, ARRAY['workspaces_select_member']::name[]);
SELECT policies_are('public'::name, 'memberships'::name, ARRAY['memberships_select_own']::name[]);
SELECT policies_are('public'::name, 'domain_mappings'::name, ARRAY['domain_mappings_select_member']::name[]);
SELECT policies_are('public'::name, 'workspace_settings'::name, ARRAY['workspace_settings_select_member']::name[]);
SELECT policies_are('public'::name, 'entities'::name, ARRAY['entities_select_member']::name[]);
SELECT policies_are('public'::name, 'entity_properties'::name, ARRAY['entity_properties_select_member']::name[]);
SELECT policies_are('public'::name, 'relationships'::name, ARRAY['relationships_select_member']::name[]);

-- Authenticated must have SELECT but not INSERT on host-mapping tables
SELECT ok(
  has_table_privilege('authenticated', 'public.domain_mappings', 'SELECT')
  AND NOT has_table_privilege('authenticated', 'public.domain_mappings', 'INSERT')
  AND NOT has_table_privilege('authenticated', 'public.domain_mappings', 'UPDATE')
  AND NOT has_table_privilege('authenticated', 'public.domain_mappings', 'DELETE'),
  'authenticated SELECT-only on domain_mappings'
);
SELECT ok(
  has_table_privilege('authenticated', 'public.workspace_settings', 'SELECT')
  AND NOT has_table_privilege('authenticated', 'public.workspace_settings', 'INSERT')
  AND NOT has_table_privilege('authenticated', 'public.workspace_settings', 'UPDATE')
  AND NOT has_table_privilege('authenticated', 'public.workspace_settings', 'DELETE'),
  'authenticated SELECT-only on workspace_settings'
);

-- =========================================================================
-- Functions: existence (via catalog for custom-type args)
-- =========================================================================
SELECT ok(
  (SELECT count(*) = 1 FROM pg_proc p
   JOIN pg_namespace n ON p.pronamespace = n.oid
   WHERE n.nspname = 'private' AND p.proname = 'current_user_workspace_ids'),
  'private.current_user_workspace_ids() exists'
);

SELECT ok(
  (SELECT count(*) = 1 FROM pg_proc p
   JOIN pg_namespace n ON p.pronamespace = n.oid
   WHERE n.nspname = 'private' AND p.proname = 'provision_user'),
  'private.provision_user(uuid,text,jsonb) exists'
);

SELECT ok(
  (SELECT count(*) = 1 FROM pg_proc p
   JOIN pg_namespace n ON p.pronamespace = n.oid
   WHERE n.nspname = 'private' AND p.proname = 'handle_new_user'),
  'private.handle_new_user() exists'
);

SELECT ok(
  (SELECT count(*) = 1 FROM pg_proc p
   JOIN pg_namespace n ON p.pronamespace = n.oid
   WHERE n.nspname = 'private' AND p.proname = 'create_entity_impl'),
  'private.create_entity_impl(...) exists'
);

SELECT ok(
  (SELECT count(*) = 1 FROM pg_proc p
   JOIN pg_namespace n ON p.pronamespace = n.oid
   WHERE n.nspname = 'public' AND p.proname = 'create_entity'),
  'public.create_entity(...) exists'
);

-- =========================================================================
-- Function security (via catalog)
-- =========================================================================
SELECT ok(
  (SELECT p.prosecdef = true FROM pg_proc p
   JOIN pg_namespace n ON p.pronamespace = n.oid
   WHERE n.nspname = 'private' AND p.proname = 'current_user_workspace_ids'),
  'private.current_user_workspace_ids is SECURITY DEFINER'
);

SELECT ok(
  (SELECT p.prosecdef = true FROM pg_proc p
   JOIN pg_namespace n ON p.pronamespace = n.oid
   WHERE n.nspname = 'private' AND p.proname = 'provision_user'),
  'private.provision_user is SECURITY DEFINER'
);

SELECT ok(
  (SELECT p.prosecdef = true FROM pg_proc p
   JOIN pg_namespace n ON p.pronamespace = n.oid
   WHERE n.nspname = 'private' AND p.proname = 'handle_new_user'),
  'private.handle_new_user is SECURITY DEFINER'
);

SELECT ok(
  (SELECT p.prosecdef = false FROM pg_proc p
   JOIN pg_namespace n ON p.pronamespace = n.oid
   WHERE n.nspname = 'public' AND p.proname = 'create_entity'),
  'public.create_entity is SECURITY INVOKER'
);

-- NEGATIVE: no SECURITY DEFINER function in public schema
SELECT is_empty(
  $$SELECT p.proname
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
      AND p.prosecdef = true
      AND p.prokind = 'f'$$
);

-- =========================================================================
-- Finish
-- =========================================================================
SELECT * FROM finish();
ROLLBACK;
