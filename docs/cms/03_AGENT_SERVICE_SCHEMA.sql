-- MVP documentation schema for content agent runs.
create table if not exists agent_runs (
  run_id text primary key,
  run_type text not null,
  status text not null,
  created_at timestamptz not null default now()
);
