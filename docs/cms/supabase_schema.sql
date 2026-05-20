-- Sakinah Daily MVP v0.1 schema draft
-- This is a planning schema. Review before applying to production.

create table if not exists audio_assets (
  id text primary key,
  asset_type text not null check (asset_type in ('quran_recitation', 'dua', 'reflection', 'dhikr', 'ambience')),
  storage_path text,
  public_url text,
  reciter_name text,
  voice_gender text,
  locale text,
  duration_seconds int,
  license_status text default 'pending',
  bgm_allowed boolean not null default false,
  quran_safe boolean not null default false,
  status text not null default 'draft',
  review_status text not null default 'pending',
  reviewed_by uuid,
  reviewed_at timestamptz,
  published_at timestamptz,
  version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists quran_ayahs (
  id text primary key,
  surah_number int not null,
  ayah_start int not null,
  ayah_end int not null,
  arabic_text text not null,
  translation_en text,
  translation_id text,
  translation_ar text,
  source_label text not null,
  theme_tags text[] default '{}',
  recitation_audio_asset_id text references audio_assets(id),
  status text not null default 'draft',
  review_status text not null default 'pending',
  version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists duas (
  id text primary key,
  category text[] default '{}',
  arabic text not null,
  transliteration text,
  translation_en text,
  translation_id text,
  translation_ar text,
  source_label text not null,
  source_type text,
  arabic_audio_asset_id text references audio_assets(id),
  meaning_audio_asset_id text references audio_assets(id),
  tts_allowed boolean not null default true,
  bgm_allowed boolean not null default false,
  gender_relevance text[] default '{all}',
  women_ibadah_safe boolean not null default false,
  status text not null default 'draft',
  review_status text not null default 'pending',
  version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists dhikrs (
  id text primary key,
  arabic text not null,
  transliteration text,
  translation_en text,
  translation_id text,
  translation_ar text,
  recommended_count int default 33,
  category text[] default '{}',
  source_label text not null,
  audio_asset_id text references audio_assets(id),
  status text not null default 'draft',
  review_status text not null default 'pending',
  version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists reflections (
  id text primary key,
  title_en text,
  title_id text,
  title_ar text,
  body_en text,
  body_id text,
  body_ar text,
  related_ayah_id text references quran_ayahs(id),
  related_dua_id text references duas(id),
  audio_asset_id text references audio_assets(id),
  tts_allowed boolean not null default true,
  bgm_allowed boolean not null default true,
  status text not null default 'draft',
  review_status text not null default 'pending',
  version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists daily_sessions (
  id text primary key,
  title_en text,
  title_id text,
  title_ar text,
  subtitle_en text,
  subtitle_id text,
  subtitle_ar text,
  duration_minutes int,
  mood_tags text[] default '{}',
  gender_mode text[] default '{all}',
  life_mode text[] default '{}',
  status text not null default 'draft',
  review_status text not null default 'pending',
  version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists daily_session_steps (
  id uuid primary key default gen_random_uuid(),
  session_id text not null references daily_sessions(id) on delete cascade,
  sort_order int not null,
  step_type text not null check (step_type in ('intention', 'quran_ayah', 'reflection', 'dua', 'dhikr', 'completion')),
  content_ref_type text,
  content_ref_id text,
  duration_seconds int,
  created_at timestamptz not null default now()
);

create table if not exists notification_templates (
  id text primary key,
  type text not null,
  title_en text,
  body_en text,
  title_id text,
  body_id text,
  title_ar text,
  body_ar text,
  status text not null default 'draft',
  review_status text not null default 'pending',
  version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists user_profiles (
  id uuid primary key,
  locale text,
  country_code text,
  city text,
  gender_mode text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists user_saved_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  item_type text not null,
  item_id text not null,
  created_at timestamptz not null default now()
);

-- Recommended content read policy condition:
-- status = 'published' and review_status = 'approved'

create index if not exists idx_duas_published on duas(status, review_status);
create index if not exists idx_dhikrs_published on dhikrs(status, review_status);
create index if not exists idx_sessions_published on daily_sessions(status, review_status);
