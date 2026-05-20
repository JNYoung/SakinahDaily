# Technical Architecture — MVP v0.1

## 1. 总体架构

```text
Flutter App
  ├── Seed content fallback
  ├── Local preferences
  ├── Prayer calculation
  ├── Local notifications
  ├── Audio playback
  └── CMS/API client

Supabase
  ├── Postgres
  ├── Auth
  ├── Storage
  └── Edge Functions

Directus CMS
  ├── Content editing
  ├── Translation
  ├── Religious review
  ├── Publishing
  └── Audio asset management

FCM
  └── Server-triggered push later
```

## 2. 客户端模块

| 模块 | 责任 |
|---|---|
| app | App root, router, theme, l10n |
| core/services | storage, analytics, audio, notifications, prayer calculation |
| features/onboarding | 首次配置 |
| features/home | Home dashboard |
| features/prayer | prayer times, calculation method |
| features/daily_session | session flow |
| features/dua | dua library/detail |
| features/dhikr | counter/list |
| features/settings | preferences/privacy |
| features/women_ibadah | women mode |
| shared/models | typed data models |
| shared/repositories | content repository abstraction |

## 3. Repository Pattern

建议抽象：

```text
ContentRepository
  - SeedContentRepository
  - CmsContentRepository

UserPreferenceRepository
  - LocalPreferenceRepository
  - RemotePreferenceRepository later

AudioRepository
  - AssetAudioRepository
  - RemoteAudioRepository
```

MVP 先使用 seed，CMS 接入后保留 fallback。

## 4. 数据流

### Daily Session

```text
HomeScreen
  -> DailySessionRepository.getTodaySession(locale, genderMode, womenMode)
  -> DailySessionScreen
  -> AudioService for audio steps
  -> DhikrCounter state
  -> ProgressRepository.saveCompletion
```

### Prayer

```text
LocationPreference
  -> PrayerCalculationService
  -> PrayerSchedule
  -> LocalNotificationService.schedulePrayerReminders
```

### CMS

```text
Directus/Supabase API
  -> CmsContentRepository
  -> validate published + approved
  -> app models
  -> UI
```

## 5. 本地存储

| 数据 | Storage |
|---|---|
| language | shared_preferences |
| location choice | shared_preferences / secure if exact location stored |
| prayer method | shared_preferences |
| audio preference | shared_preferences |
| women ibadah mode | local-only; shared_preferences or encrypted local storage |
| saved items | local DB or remote if signed in |
| session progress | local DB |

## 6. 错误处理

- CMS failed → seed fallback。
- Audio failed → show retry and read text mode。
- Location denied → manual setup。
- Notification denied → keep app usable。
- RTL layout bug → milestone test/QA。

## 7. 安全与隐私

- 不在客户端存 service role key。
- 不上传 women mode 敏感状态。
- 不上传位置历史。
- 内容 API 只返回 published + approved。

## 8. P0 到 P1 演进

| P0 | P1 |
|---|---|
| Seed + CMS fallback | CMS primary + cache |
| Local saved items | Cloud sync |
| Local prayer notifications | Server push for content reminders |
| Basic analytics stub | Full analytics provider |
| Basic Qibla placeholder | Polished Qibla compass |
