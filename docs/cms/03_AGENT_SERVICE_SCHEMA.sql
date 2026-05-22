-- MVP documentation schema for content agent review queues.
-- This is a planning schema. Review RLS, indexes, and service credentials
-- before applying it to any Supabase/Postgres environment.

create table if not exists agent_runs (
  run_id text primary key,
  run_type text not null check (run_type in (
    'weekly_preproduction',
    'cluster_production',
    'qa_only'
  )),
  status text not null check (status in (
    'queued',
    'running',
    'completed',
    'completed_with_warnings',
    'failed',
    'cancelled'
  )),
  request_payload jsonb not null default '{}'::jsonb,
  summary text not null default '',
  warnings jsonb not null default '[]'::jsonb,
  error_message text,
  dry_run boolean not null default true,
  created_by text not null default 'local',
  created_at timestamptz not null default now(),
  started_at timestamptz,
  completed_at timestamptz
);

create table if not exists agent_content_candidates (
  candidate_id text primary key,
  run_id text not null references agent_runs(run_id) on delete cascade,
  candidate_type text not null,
  source_item_id text not null,
  cluster_id text not null,
  language text not null,
  target_market text not null default 'global',
  ritual_moment text not null,
  payload jsonb not null default '{}'::jsonb,
  risk_flags jsonb not null default '[]'::jsonb,
  automated_checks jsonb not null default '[]'::jsonb,
  review_status text not null check (review_status in (
    'agent_draft',
    'agent_rejected',
    'needs_human_review',
    'promoted_to_cms_draft',
    'discarded'
  )),
  cms_target_table text,
  cms_target_id text,
  agent_version text not null,
  prompt_version text not null,
  model_name text not null,
  schema_version integer not null,
  input_hash text not null,
  output_hash text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists agent_review_packets (
  id text primary key,
  run_id text not null references agent_runs(run_id) on delete cascade,
  title text not null,
  summary text not null,
  packet_payload jsonb not null default '{}'::jsonb,
  reviewer_checklist jsonb not null default '[]'::jsonb,
  status text not null default 'needs_human_review',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists agent_feedback_events (
  id text primary key,
  candidate_id text not null references agent_content_candidates(candidate_id) on delete cascade,
  reviewer_role text not null,
  decision text not null,
  reason text not null default '',
  edited_payload jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_agent_content_candidates_run_id
  on agent_content_candidates(run_id);

create index if not exists idx_agent_content_candidates_review_status
  on agent_content_candidates(review_status);

create index if not exists idx_agent_feedback_events_candidate_id
  on agent_feedback_events(candidate_id);
