-- Host → workspace mappings and public presentation settings (WU1b).
-- Writes are privileged/server-only; authenticated receives SELECT under RLS.
-- App host resolution wiring lands in WU3.

-- =========================================================================
-- 1. domain_mappings
-- =========================================================================
CREATE TABLE public.domain_mappings (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
  host         text NOT NULL,
  status       text NOT NULL DEFAULT 'active',
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT domain_mappings_host_unique UNIQUE (host),
  CONSTRAINT domain_mappings_host_normalized CHECK (
    host = lower(host)
    AND char_length(host) BETWEEN 1 AND 253
    AND host !~ '[:/\\@?#]'
    AND host ~ '^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$'
  )
);

CREATE INDEX idx_domain_mappings_workspace_status
  ON public.domain_mappings (workspace_id, status);

ALTER TABLE public.domain_mappings ENABLE ROW LEVEL SECURITY;

CREATE POLICY domain_mappings_select_member ON public.domain_mappings
  FOR SELECT TO authenticated
  USING (workspace_id IN (SELECT private.current_user_workspace_ids()));

GRANT SELECT ON public.domain_mappings TO authenticated;

-- =========================================================================
-- 2. workspace_settings
-- =========================================================================
CREATE TABLE public.workspace_settings (
  workspace_id uuid PRIMARY KEY REFERENCES public.workspaces(id) ON DELETE CASCADE,
  presentation jsonb NOT NULL DEFAULT '{}'::jsonb
    CHECK (jsonb_typeof(presentation) = 'object'),
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.workspace_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY workspace_settings_select_member ON public.workspace_settings
  FOR SELECT TO authenticated
  USING (workspace_id IN (SELECT private.current_user_workspace_ids()));

GRANT SELECT ON public.workspace_settings TO authenticated;
