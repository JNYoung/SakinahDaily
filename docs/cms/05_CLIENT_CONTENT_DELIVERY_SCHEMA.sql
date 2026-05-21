-- MVP documentation schema for published content bundles.
create table if not exists content_bundles (
  id text primary key,
  schema_version integer not null,
  sha256 text not null,
  status text not null,
  review_status text not null,
  published_at timestamptz
);
