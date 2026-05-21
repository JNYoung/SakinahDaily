-- MVP documentation schema for Quran source corpus import payloads.
-- The ingestion scripts generate JSONL payloads for these tables but do not
-- connect to Supabase, Directus, or any live CMS.

create table if not exists source_corpus_providers (
  provider_id text primary key,
  provider_name text not null,
  attribution text not null
);

create table if not exists source_corpus_versions (
  source_corpus_version_id text primary key,
  provider_id text not null references source_corpus_providers(provider_id),
  version text not null,
  attribution text not null
);

create table if not exists quran_verses (
  verse_key text primary key,
  surah integer not null,
  ayah integer not null,
  arabic_text text not null,
  provider_id text not null references source_corpus_providers(provider_id),
  source_corpus_version_id text not null references source_corpus_versions(source_corpus_version_id),
  checksum text not null
);

create table if not exists quran_verse_translations (
  verse_key text not null references quran_verses(verse_key),
  language text not null,
  text text not null,
  provider_id text not null references source_corpus_providers(provider_id),
  source_corpus_version_id text not null references source_corpus_versions(source_corpus_version_id),
  attribution text not null,
  primary key (verse_key, language, source_corpus_version_id)
);

create table if not exists quran_verse_tafsirs (
  verse_key text not null references quran_verses(verse_key),
  language text not null,
  text text not null,
  provider_id text not null references source_corpus_providers(provider_id),
  source_corpus_version_id text not null references source_corpus_versions(source_corpus_version_id),
  attribution text not null,
  primary key (verse_key, language, source_corpus_version_id)
);
