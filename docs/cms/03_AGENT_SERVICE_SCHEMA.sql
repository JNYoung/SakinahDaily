-- MVP documentation schema for content agent runs and candidates.
create table if not exists agent_runs (
  run_id text primary key,
  run_type text not null,
  status text not null,
  created_at timestamptz not null default now()
);

create table if not exists agent_candidates (
  candidate_id text primary key,
  run_id text not null references agent_runs(run_id),
  cluster_id text not null,
  source_item_id text not null,
  language text not null,
  lock_screen_title text not null,
  lock_screen_body text not null,
  status text not null default 'needs_human_review',
  safety_flags jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);
