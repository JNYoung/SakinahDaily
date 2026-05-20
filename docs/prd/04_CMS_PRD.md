# CMS PRD — Content Management MVP v0.1

## 1. CMS 目标

CMS 用来管理 Quran ayah references、Dua、Dhikr、Reflection、Daily Session、Notification Templates 和 Audio Assets。核心目标是让宗教内容可追踪、可审核、可发布、可回滚。

## 2. CMS 角色

| 角色 | 权限 |
|---|---|
| Admin | 全权限 |
| Content Editor | 创建和编辑 draft |
| Translator | 编辑 translation 字段 |
| Religious Reviewer | 审核宗教内容，批准/拒绝 |
| Audio Producer | 上传和标记音频资产 |
| QA Viewer | 只读检查 published 内容 |

## 3. 内容状态流

```text
draft → in_review → approved → published → archived
```

字段：

```text
status: draft | in_review | approved | published | archived
review_status: pending | approved | rejected
published_at
version
reviewed_by
reviewed_at
```

客户端只显示：

```text
status = published
review_status = approved
```

## 4. 内容集合

### audio_assets

用途：管理 Quran recitation、Dua guide、Reflection、Dhikr guide 等音频。

关键字段：

```text
id
asset_type: quran_recitation | dua | reflection | dhikr | ambience
storage_path
public_url
reciter_name
voice_gender
locale
duration_seconds
license_status
bgm_allowed
quran_safe
status
review_status
```

规则：

- Quran recitation: `bgm_allowed=false`。
- Quran recitation: `quran_safe=true`。
- 普通 TTS 不可标记为 Quran recitation。

### quran_ayahs

```text
id
surah_number
ayah_start
ayah_end
arabic_text
translation_en
translation_id
translation_ar_optional
theme_tags
source_label
recitation_audio_asset_id
status
review_status
```

### duas

```text
id
category
arabic
transliteration
translation_en
translation_id
translation_ar
source_label
source_type: quran | hadith | hisnul_muslim | scholar_reviewed
arabic_audio_asset_id
meaning_audio_asset_id
tts_allowed
bgm_allowed
gender_relevance
women_ibadah_safe
status
review_status
```

### dhikrs

```text
id
arabic
transliteration
translation_en
translation_id
translation_ar
recommended_count
category
source_label
audio_asset_id
status
review_status
```

### reflections

```text
id
title_en/title_id/title_ar
body_en/body_id/body_ar
related_ayah_id
related_dua_id
locale_audio_asset_id
tts_allowed
bgm_allowed
status
review_status
```

### daily_sessions

```text
id
title_en/title_id/title_ar
subtitle_en/subtitle_id/subtitle_ar
duration_minutes
mood_tags
gender_mode
life_mode
default_locale
status
review_status
```

### daily_session_steps

```text
id
session_id
sort_order
step_type: intention | quran_ayah | reflection | dua | dhikr | completion
content_ref_type
content_ref_id
duration_seconds
```

### notification_templates

```text
id
type: prayer | daily_dua | sleep | friday | ramadan | women_ibadah
title_en/title_id/title_ar
body_en/body_id/body_ar
locale
status
review_status
```

## 5. 本地化规则

- Arabic、Bahasa Indonesia、English 是 P0。
- 每条内容必须至少有 English + one target locale，MVP seed 可简化。
- Arabic UI 文案和 Quran Arabic text 分开管理。
- Transliteration 字段不等于 translation。

## 6. 宗教审核规则

- Quran ayah 必须有 surah/ayah reference。
- Dua 必须有 source_label。
- 若来源存在学派差异，content editor 不能写绝对化 fatwa 风格文案。
- Women’s Ibadah 内容必须由 reviewer 标记 `women_ibadah_safe=true`。
- 审核人和审核时间必须留痕。

## 7. 音频审核规则

- Quran recitation 音频必须有 license_status。
- 不允许把 ambient/bgm 混入 Quran recitation。
- Reflection 可使用 TTS，但必须标记。
- Dua Arabic 发音音频应优先真人或审核过的音频。

## 8. CMS 验收

- 能创建一条 Daily Session。
- 能把 session 由 draft 推进到 published。
- 客户端只能读取 published + approved。
- 能上传 audio asset 并关联到 Quran/Dua/Reflection。
- 未审核内容不会被 API 返回给 App。
