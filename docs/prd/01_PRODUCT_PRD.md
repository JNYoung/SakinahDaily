# Product PRD — Sakinah Daily MVP v0.1

## 0. v0.1 上架收敛决策

当前 v0.1 的上架目的收敛为：

> A daily prayer companion that helps users see prayer times, set local
> reminders, and keep one optional short daily worship session.

上架主路径只包含 Home、Prayer、Session、Settings。Quran、Dua、Dhikr、
Qibla、Saved Items、Women’s Ibadah Mode 和 CMS 能保留为 secondary/deep
surfaces，但不能再阻塞 v0.1 上架，除非它们影响宗教安全、隐私、通知、RTL
或商店合规。

v0.1 明确采用：

- Manual/preset prayer location only；不请求 GPS/location 权限。
- Local prayer reminders；不接 FCM/APNs production push。
- Seed-reviewed minimum content only；不要求 staging CMS。
- Text-first/session-safe Quran handling；不要求 licensed audio 才能上架，但
  不允许可见 no-op audio CTA。
- Analytics 默认关闭且需用户 opt-in、no crash SDK、no ads、no account、no
  subscription。

## 1. 产品定位

Sakinah Daily 是一个面向中东与印尼穆斯林用户的每日助祷陪伴 App。产品将 Quran listening、Dua、Dhikr、Prayer reminders 和 gender-aware worship routines 做成一个类似 calm app 的日常 worship experience。

一句话：

> A peaceful daily prayer and reminder companion for Muslim worship.

中文内部描述：

> 每天一段经文、一句 Dua、一段 Dhikr、一个安静的音频仪式。

## 2. 目标市场

### Middle East

- Arabic-first。
- RTL 必须自然。
- 音频默认保守：Quran 无 BGM。
- 用户对内容可信度、来源和宗教准确性高度敏感。
- UI 需要高级、安静、可信。

### Indonesia

- Bahasa Indonesia-first。
- Android 体验重要。
- 本地语言应使用 Doa / Dzikir / Shalat / Kiblat 等常用表达。
- 用户更容易接受温柔的 daily routine、sleep dhikr、Ramadan plan。

## 3. 用户画像

### Persona A：印尼年轻女性

- 年龄：18–32。
- 城市：Jakarta、Bandung、Surabaya。
- 需求：睡前安静、晨间 Dua、Dzikir、女性友好 worship 支持。
- 敏感点：经期相关内容必须隐私友好，不要羞辱或医学化。

### Persona B：海湾国家男性上班族

- 年龄：25–45。
- 城市：Riyadh、Dubai、Doha、Kuwait City。
- 需求：礼拜提醒、工作间隙 5 分钟 calm reset、Jumu’ah preparation。
- 敏感点：不喜欢过度娱乐化或普通冥想感。

### Persona C：学生

- 年龄：15–25。
- 需求：考试前 Dua、学习专注、焦虑缓解、自律。
- 敏感点：希望简单、快速、语言友好。

### Persona D：Ramadan 高峰用户

- 年龄：全阶段。
- 需求：Suhoor/Iftar/Taraweeh/Last 10 nights/每日 Quran + Dua plan。
- MVP 中仅预留扩展，不在 v0.1 做完整 Ramadan plan。

## 4. 产品目标

v0.1 上架 MVP 需要让用户完成以下事情：

1. 选择语言：Arabic、Bahasa Indonesia、English。
2. 选择 preset 或手动输入地区/位置，用于 prayer time。
3. 进入 Home，第一眼看到下一次礼拜、地点、计算方式和提醒状态。
4. 查看全天 Fajr / Dhuhr / Asr / Maghrib / Isha 时间。
5. 配置本地礼拜提醒和每日 session reminder。
6. 可选完成一个短 Daily Session。
7. 在 Settings 中管理语言、位置、计算方式、通知和隐私。

## 5. MVP 范围

### P0 必须做

| 模块 | 需求 |
|---|---|
| Onboarding | 语言、manual/preset 位置、通知说明；gender/audio preference 可保留但不是主卖点 |
| Home | Prayer-first：下一次礼拜、地点、计算方式、提醒状态、Prayer/Reminder CTA |
| Prayer | 全天礼拜时间、下一次礼拜卡片、本地提醒入口、手动位置入口 |
| Notifications | 本地礼拜提醒、每日 session reminder、拒绝权限不影响使用 |
| Daily Session | 可选短 session；不能出现 Quran BGM/TTS 或无效 audio CTA |
| Settings | 语言、地区、计算方式、通知、隐私、删除本地数据 |
| Privacy | 不请求 GPS；位置和 women mode 默认本地；无 ads/tracking SDK；analytics 默认关闭且需审核启用 |

### P0 保留但不作为上架主入口

| 模块 | v0.1 处理 |
|---|---|
| Quran | 仅保留 session/deep route 需要的安全展示；不做完整 reader |
| Dua Library | 可通过 deep route 保留；不在 Home/bottom nav 作为主入口 |
| Dhikr | 可通过 session/deep route 保留；不在 Home/bottom nav 作为主入口 |
| Qibla | 保留基于 selected prayer location 的静态方向；不请求 compass/GPS |
| Women’s Ibadah Mode | 保留隐私安全实现；不作为上架核心宣传 |
| CMS integration | 远程内容默认关闭；不阻塞 v0.1 |

### P1 Beta 后再做

- Ramadan plan。
- 多 reciter。
- 离线音频下载。
- Premium subscription。
- 更完整 Qibla UI。
- 用户云同步。
- 高级个性化推荐。
- Device location permission flow。
- Per-prayer advanced offsets、quiet hours、OEM battery guidance。
- Reviewed expanded Dua/Dhikr/Quran packs。

### P2 不进 MVP

- AI Fatwa / AI religious Q&A。
- Quran recitation correction。
- 社区/评论/UGC。
- 广告。
- 完整 Tafsir system。
- Quran Arabic TTS。

## 6. 核心用户旅程

### Journey 1：首次使用

1. Welcome。
2. 选择语言。
3. 选择 preset 或手动设置 prayer location。
4. 进入 Home，看到下一次礼拜和提醒状态。
5. 打开 Prayer 查看全天时间。
6. 开启本地礼拜提醒。
7. 可选开始第一次 Daily Session。

### Journey 2：日常使用

1. 用户收到 prayer reminder。
2. 打开 Home。
3. 看到下一次礼拜倒计时。
4. 打开 Prayer 查看全天时间或调整提醒。
5. 可选开始 Today's Sakinah。

### Journey 3：Women’s Ibadah Mode

1. 用户进入 Settings。
2. 选择 Women’s Ibadah Mode。
3. 设置当前模式。
4. App 调整 daily session 与提醒文案。
5. 数据默认存储在本地。

## 7. 信息架构

```text
App
├── Onboarding
├── Home
│   ├── Next Prayer
│   ├── Prayer reminder status
│   ├── Prayer / Reminder CTAs
│   └── Today’s Sakinah (secondary)
├── Prayer
├── Daily Session
├── Settings
│   ├── Notification Settings
│   ├── Prayer Location
│   └── Privacy Center
└── Secondary deep routes: Quran, Dua, Dhikr, Qibla, Women’s Ibadah Mode
```

## 8. 北极星指标

> Weekly Active Prayer Reminder Users

每周打开礼拜时间或启用/保留礼拜提醒的用户数。Daily Session completion
是辅助指标，不再是 v0.1 上架北极星。

## 9. 关键指标

| 指标 | 说明 |
|---|---|
| Onboarding Completion Rate | 是否完成首次配置 |
| Prayer View Rate | 是否打开 prayer time 主页面 |
| Prayer Reminder Opt-in Rate | 是否愿意接收礼拜提醒 |
| D1 / D7 Retention | 是否形成初步习惯 |
| Push Open Rate | 推送文案是否有效 |
| Daily Session Start Rate | 是否使用可选短 session |
| Settings Completion Rate | 是否完成位置、算法、通知配置 |

## 10. 主要风险

| 风险 | 应对 |
|---|---|
| 宗教内容错误 | CMS 审核流、来源字段、approved 状态 |
| 音乐争议 | Quran 无 BGM，默认 conservative mode |
| 性别设计冒犯 | 不强制性别，不粉色化，不医学化 |
| 中东/印尼差异 | 三语言、本地词汇、RTL、地区 prayer method |
| MVP 膨胀 | Codex milestone 必须小步执行 |
| 祷告提醒不可靠 | 先做 manual/preset location + 本地通知 + 真机 QA，不引入 GPS/FCM |

## 11. 成功标准

MVP 成功不是“功能很多”，而是：

- 用户能顺利看到下一次礼拜和全天礼拜时间。
- 用户愿意打开 prayer reminder，拒绝权限时 App 仍可用。
- 用户觉得内容可信、安静、不冒犯。
- Arabic RTL 和 Bahasa Indonesia 文案都不像临时翻译。
- App 不像普通工具堆叠，而像 daily prayer companion。
