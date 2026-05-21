-- MVP documentation schema for Quran source corpus.
create table if not exists quran_verses (
  verse_key text primary key,
  surah integer not null,
  ayah integer not null,
  arabic_text text not null,
  provider text not null,
  version text not null,
  checksum text not null
);
