-- MVP documentation schema for push content.
create table if not exists source_items (
  id text primary key,
  status text not null,
  review_status text not null,
  cluster_id text not null,
  ritual_moment text not null,
  cycle_sensitive_hidden boolean not null default false
);
