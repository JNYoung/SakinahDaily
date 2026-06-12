# Client PRD — Flutter App MVP v0.1

## 1. 客户端目标

构建一个 Flutter 移动端 MVP，支持 Arabic / Bahasa Indonesia / English。
v0.1 上架目标收敛为每日祷告 companion：Home、Prayer、Session、Settings
是主路径；Dua、Dhikr、Quran、Qibla、Saved Items 和 Women’s Ibadah Mode
可以保留为 secondary/deep surfaces，但不能作为当前上架阻塞。

## 2. 技术约束

| 项 | 选择 |
|---|---|
| Framework | Flutter + Dart |
| State | Riverpod |
| Router | go_router |
| Localization | Flutter l10n + ARB |
| Audio | just_audio |
| Notifications | flutter_local_notifications |
| Prayer times | adhan_dart 或等价库 |
| Storage | shared_preferences / hive / flutter_secure_storage，视数据敏感度区分 |
| CMS Client | Supabase client 或 Directus REST client |

## 3. 目录结构

```text
lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   ├── theme.dart
│   └── localization.dart
├── core/
│   ├── config/
│   ├── constants/
│   ├── errors/
│   ├── services/
│   └── utils/
├── features/
│   ├── onboarding/
│   ├── home/
│   ├── prayer/
│   ├── daily_session/
│   ├── dua/
│   ├── dhikr/
│   ├── audio/
│   ├── settings/
│   └── women_ibadah/
├── shared/
│   ├── models/
│   ├── widgets/
│   └── repositories/
└── main.dart
```

## 4. 页面与路由

| Route | 页面 | MVP 状态 |
|---|---|---|
| `/onboarding` | OnboardingFlow | P0 |
| `/home` | HomeScreen | P0 |
| `/prayer` | PrayerScreen | P0 |
| `/settings/notifications` | NotificationSettingsScreen | P0 |
| `/settings/prayer-location` | ManualPrayerLocationScreen | P0 |
| `/settings` | SettingsScreen | P0 |
| `/daily-session/:id` | DailySessionScreen | P0 secondary |
| `/dua` | DuaLibraryScreen | Secondary |
| `/dua/:id` | DuaDetailScreen | Secondary |
| `/dhikr` | DhikrScreen | Secondary |
| `/quran` | QuranScreen | Secondary |
| `/qibla` | QiblaScreen | Secondary |
| `/settings/women-ibadah` | WomenIbadahModeScreen | Secondary privacy-safe |

## 5. Onboarding 需求

### Step 1 Welcome

- 展示产品定位。
- CTA：Get Started / Mulai / ابدأ الآن。

### Step 2 Language

- English。
- Bahasa Indonesia。
- العربية。
- 切换阿语后 UI 方向为 RTL。

### Step 3 Location

- 说明用途：仅用于 prayer time 和 Qibla。
- v0.1 上架 baseline 使用 manual/preset location。
- 不请求 GPS/location permission；device location flow 延后到 P1。

### Step 4 Personalization

- Male。
- Female。
- Prefer not to say。
- 不可强制。

### Step 5 Audio Preference

- Pure Quran recitation。
- Voice guidance only。
- Nature ambience for non-Quran。
- No background sound。
- 默认：Quran pure + voice guidance only。

### Step 6 First Session

- 显示首次 Daily Session ready。
- 进入 Home 或直接开始。

## 6. Home 需求

Home 是核心入口，不能做成工具列表。

必备元素：

- Greeting。
- Hijri/Gregorian date，可先 mock Hijri。
- Next prayer countdown / time。
- Prayer location、calculation method、reminder status。
- Primary CTA：View prayer times。
- Secondary CTA：Manage reminders。
- Today's Sakinah card 作为 secondary。
- 不在 Home 放 Quran / Dua / Dhikr / Qibla 工具宫格。

状态：

| 状态 | 行为 |
|---|---|
| 有 CMS 内容 | 展示 published session |
| 无 CMS 内容 | 使用 seed session |
| Prayer 计算失败 | 展示手动设置入口 |
| 未授权位置 | v0.1 不请求位置权限；用 manual/preset location |

## 7. Daily Session 需求

### 步骤

1. Intention。
2. Quran Listening。
3. Reflection。
4. Guided Dua。
5. Dhikr Counter。
6. Completion。

### 关键规则

- Quran step 不允许 BGM。
- Quran step 不使用 TTS。
- Dua step 必须显示 Arabic、transliteration、translation、source。
- Reflection 可使用 TTS 或真人音频。
- Dhikr counter 支持手动点击计数。

### Session State

```text
not_started
in_progress
completed
saved
```

### Completion

完成页显示：

- 完成反馈。
- Save session。
- Set reminder。
- Return home。

## 8. Dua Library 需求

### 分类

- Morning。
- Evening。
- Before sleep。
- Anxiety。
- Gratitude。
- Forgiveness。
- Travel。
- Study / Work。
- Ramadan placeholder。
- Women’s Ibadah。

### Dua Detail

必须显示：

- Arabic。
- Transliteration。
- Translation based on locale。
- Source。
- Review status。
- Audio controls。
- Favorite button。

## 9. Dhikr 需求

- Dhikr list。
- Manual counter。
- Target counts：33 / 99 / custom。
- Silent mode。
- Completion feedback。
- 不做游戏化排行榜。

## 10. Prayer 需求

P0：

- Prayer times for current/manual location。
- Next prayer countdown。
- Calculation method setting。
- Local notification schedule。

P1：

- Qibla polished compass。
- Hijri date calculation tuning。
- Regional default presets。

## 11. Settings 需求

- Language。
- Region / location。
- Prayer calculation method。
- Audio preference。
- Notification schedule。
- Privacy。
- Women’s Ibadah Mode。
- Content source / about。

## 12. Women’s Ibadah Mode 需求

状态：

- Normal。
- Menstruating。
- Postpartum。
- Pregnancy。
- Prefer not to track。

规则：

- 默认 local-only。
- 不上传敏感状态。
- 不显示羞辱性或判断性文案。
- Menstruating/Postpartum 时可以把 prayer reminder 调整成 Dua/Dhikr reminder，具体解释交给内容审核。

## 13. 本地化

ARB 文件：

```text
lib/l10n/app_en.arb
lib/l10n/app_id.arb
lib/l10n/app_ar.arb
```

注意：

- Arabic 页面必须支持 RTL。
- 不使用硬编码英文。
- 印尼语优先使用 Doa / Dzikir / Shalat / Kiblat。
- 日期、数字、排版要可扩展。

## 14. 音频规则

音频类型：

| 类型 | TTS | BGM | 备注 |
|---|---:|---:|---|
| Quran Arabic recitation | 否 | 否 | approved audio asset only |
| Quran translation | 可 | 可选自然声 | 不压过人声 |
| Reflection | 可 | 可 | 可用 TTS |
| Dua Arabic | 谨慎 | 不建议 | 优先真人/审核音频 |
| Dua meaning | 可 | 可 | 可 TTS |
| Dhikr guide | 可 | 可选节奏声 | 支持 silent mode |

## 15. Analytics events

先做 interface/stub，避免阻塞。事件名需要保持 Google Analytics 兼容：

```text
onboarding_started
onboarding_completed
language_selected
location_method_selected
gender_mode_selected
audio_preference_selected
home_viewed
prayer_viewed
prayer_reminder_changed
daily_session_started
daily_session_step_viewed
daily_session_completed
dua_viewed
dua_saved
dhikr_started
dhikr_completed
women_ibadah_mode_changed
closed_test_prompt_copied
closed_test_prompt_marked_sent
```

Analytics SDK 接入前必须经过隐私审核。当前实现只允许白名单事件和非敏感
枚举/ID 参数；不得上传经文/dua/reflection 文本、反馈文本、坐标、tester
identity 或 Women's Ibadah Mode exact status。

## 16. 客户端验收

- App 可启动。
- 三语言可切换。
- Arabic RTL 生效。
- Home 有 seed Daily Session。
- Daily Session 可完整走完。
- Dua Detail 显示来源和 review status。
- Quran step 不播放 BGM。
- Women’s Ibadah Mode 本地保存。
- Analyzer 和基础测试通过。

## 17. 当前产品进度（2026-05-30）

详细进度与缺口见
`docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md`。当前结论：

| 链路 | 当前状态 | Beta/Store 前主要缺口 |
|---|---|---|
| Prayer | 手动/预设位置、礼拜时间、通知开关、冷启动通知路由已具备 MVP 骨架 | 是否做 device location 的范围决策、per-prayer 提醒配置、真实设备权限 QA |
| Daily Session | seed session 可端到端完成，进度/完成历史本地保存，完成页 Set daily reminder CTA 可用，Settings 可管理每日 session 提醒时间，冷启动可进 session | 更多 reviewed session 内容、真实设备通知 QA、授权音频资产与 hash 校验 |
| Quran | 本地 approved seed ayah 入口、有限 browse/search、详情前后导航、`/quran/:verseKey` 和冷启动进 verse 可用 | approved corpus 导入、生产来源替换、licensed reciter/offline audio |
| Dua / Dhikr | library/detail/save/source/review status、分类筛选/搜索、Dhikr counter、冷启动进 dua detail 可用 | Listen/Repeat audio 行为、更多 reviewed CMS 内容、剩余 PRD 分类覆盖 |

当前 v0.1 最需要产品决策的三件事：

1. Prayer location 是继续以 manual/preset 作为 release baseline，还是补
   device location permission flow。
2. 内容是 seed-only beta，还是接入 reviewed staging CMS content pack。
3. 音频按钮是明确延期，还是进入 licensed audio asset ingestion milestone。
