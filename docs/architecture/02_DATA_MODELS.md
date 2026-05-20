# Data Models — MVP v0.1

## 1. Enums

```dart
enum LocaleCode { en, id, ar }
enum GenderMode { male, female, preferNotToSay }
enum WomenIbadahMode { normal, menstruating, postpartum, pregnancy, preferNotToTrack }
enum ContentStatus { draft, inReview, approved, published, archived }
enum ReviewStatus { pending, approved, rejected }
enum AudioType { quranRecitation, dua, reflection, dhikr, ambience }
enum DailySessionStepType { intention, quranAyah, reflection, dua, dhikr, completion }
```

## 2. AudioAsset

```json
{
  "id": "audio_quran_001",
  "asset_type": "quran_recitation",
  "storage_path": "quran/020_025_026.mp3",
  "public_url": null,
  "reciter_name": "TBD licensed reciter",
  "voice_gender": "male",
  "locale": "ar",
  "duration_seconds": 45,
  "license_status": "pending",
  "bgm_allowed": false,
  "quran_safe": true,
  "status": "published",
  "review_status": "approved"
}
```

## 3. QuranAyah

```json
{
  "id": "ayah_020_025_026",
  "surah_number": 20,
  "ayah_start": 25,
  "ayah_end": 26,
  "arabic_text": "رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي",
  "translation_en": "My Lord, expand for me my breast and ease for me my task.",
  "translation_id": "Ya Tuhanku, lapangkanlah dadaku dan mudahkanlah urusanku.",
  "source_label": "Quran 20:25–26",
  "recitation_audio_asset_id": "audio_quran_001",
  "status": "published",
  "review_status": "approved"
}
```

## 4. DuaItem

```json
{
  "id": "dua_ease_task_001",
  "category": ["work", "study", "stress"],
  "arabic": "اللهم اشرح لي صدري ويسر لي أمري",
  "transliteration": "Allahumma ishrah li sadri wa yassir li amri",
  "translation_en": "O Allah, expand my chest and ease my task.",
  "translation_id": "Ya Allah, lapangkanlah dadaku dan mudahkanlah urusanku.",
  "source_label": "Quran 20:25–26",
  "source_type": "quran",
  "tts_allowed": true,
  "bgm_allowed": false,
  "women_ibadah_safe": true,
  "status": "published",
  "review_status": "approved"
}
```

## 5. DhikrItem

```json
{
  "id": "dhikr_astaghfirullah_033",
  "arabic": "أستغفر الله",
  "transliteration": "Astaghfirullah",
  "translation_en": "I seek forgiveness from Allah.",
  "translation_id": "Aku memohon ampun kepada Allah.",
  "recommended_count": 33,
  "category": ["forgiveness", "calm"],
  "source_label": "Reviewed dhikr collection",
  "status": "published",
  "review_status": "approved"
}
```

## 6. DailySession

```json
{
  "id": "session_calm_before_work_001",
  "title_en": "Calm Before Work",
  "title_id": "Tenang Sebelum Bekerja",
  "title_ar": "سكينة قبل العمل",
  "duration_minutes": 7,
  "mood_tags": ["stress", "focus"],
  "gender_mode": ["all"],
  "life_mode": ["working", "student"],
  "steps": [
    {"type": "intention", "duration_seconds": 30},
    {"type": "quran_ayah", "content_id": "ayah_020_025_026"},
    {"type": "reflection", "content_id": "reflection_ease_task_001"},
    {"type": "dua", "content_id": "dua_ease_task_001"},
    {"type": "dhikr", "content_id": "dhikr_astaghfirullah_033"}
  ],
  "status": "published",
  "review_status": "approved"
}
```

## 7. UserPreferences

```json
{
  "locale": "id",
  "country_code": "ID",
  "city": "Jakarta",
  "location_mode": "manual",
  "gender_mode": "female",
  "audio_preference": "voice_only",
  "prayer_calculation_method": "kemenag_or_manual_preset",
  "notifications_enabled": true,
  "women_ibadah_mode": "menstruating"
}
```

注意：`women_ibadah_mode` 默认只在本地存储。
