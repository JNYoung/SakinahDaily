-- MVP documentation schema for daily push content.
create table if not exists source_items (
  id text primary key,
  cluster_id text not null,
  ritual_moment text not null,
  status text not null check (status in ('draft', 'published', 'archived')),
  review_status text not null check (review_status in ('draft', 'in_review', 'approved', 'rejected')),
  language text not null,
  text text not null,
  cycle_sensitive_hidden boolean not null default false,
  source_label text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists push_templates (
  id text primary key,
  ritual_moment text not null,
  language text not null,
  title text not null,
  body text not null,
  status text not null check (status in ('draft', 'published', 'archived')),
  review_status text not null check (review_status in ('draft', 'in_review', 'approved', 'rejected')),
  cycle_sensitive_hidden boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
