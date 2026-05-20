# Product PRD — Sakinah Daily MVP v0.1

## 1. 产品定位

Sakinah Daily 是一个面向中东与印尼穆斯林用户的每日助祷陪伴 App。产品将 Quran listening、Dua、Dhikr、Prayer reminders 和 gender-aware worship routines 做成一个类似 calm app 的日常 worship experience。

一句话：

> A peaceful Quran, Dua, and Dhikr companion for daily worship.

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

MVP 需要让用户完成以下事情：

1. 选择语言：Arabic、Bahasa Indonesia、English。
2. 设置地区/位置，用于 prayer time。
3. 可选选择 gender mode：male / female / prefer not to say。
4. 进入 Home，看到下一次礼拜倒计时和 Today's Sakinah。
5. 完成一个 Daily Session。
6. 浏览 Dua / Dhikr library。
7. 保存喜欢的 Dua 或 session。
8. 配置推送提醒。
9. 使用 Women’s Ibadah Mode，且默认本地隐私存储。

## 5. MVP 范围

### P0 必须做

| 模块 | 需求 |
|---|---|
| Onboarding | 语言、位置、gender mode、audio preference |
| Home | 下一次礼拜、今日 session、快捷入口 |
| Daily Session | Intention → Quran Audio → Reflection → Dua → Dhikr → Completion |
| Prayer | Prayer time、下一次礼拜倒计时、本地提醒 |
| Dua Library | 分类、详情、阿文、音译、翻译、来源、收藏 |
| Dhikr | 手动计数、目标次数、完成反馈 |
| Audio | Quran approved audio asset、普通引导音频、无 BGM 规则 |
| Settings | 语言、地区、计算方式、音频、通知、隐私 |
| Women’s Ibadah Mode | Normal / Menstruating / Postpartum / Pregnancy / Prefer not to track |
| CMS integration | 先 seed data，后接 published + approved 内容 |

### P1 Beta 后再做

- Ramadan plan。
- 多 reciter。
- 离线音频下载。
- Premium subscription。
- 更完整 Qibla UI。
- 用户云同步。
- 高级个性化推荐。

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
3. 设置 location。
4. 选择 optional gender mode。
5. 选择 audio preference。
6. 进入 Home。
7. 开始第一次 Daily Session。
8. 完成后询问是否设置每日提醒。

### Journey 2：日常使用

1. 用户收到 morning / prayer / sleep reminder。
2. 打开 Home。
3. 看到下一次礼拜倒计时。
4. 开始 Today's Sakinah。
5. 完成 session。
6. 保存 Dua 或设置明天提醒。

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
│   ├── Today’s Sakinah
│   └── Quick Actions
├── Daily Session
├── Quran Listening
├── Dua Library
├── Dhikr
├── Prayer
├── Settings
└── Women’s Ibadah Mode
```

## 8. 北极星指标

> Weekly Completed Worship Sessions

每周完成的 Daily Session 数量。

## 9. 关键指标

| 指标 | 说明 |
|---|---|
| Onboarding Completion Rate | 是否完成首次配置 |
| Daily Session Start Rate | 是否开始核心体验 |
| Daily Session Completion Rate | 是否完成 session |
| D1 / D7 Retention | 是否形成初步习惯 |
| Prayer Reminder Opt-in Rate | 是否愿意接收提醒 |
| Push Open Rate | 推送文案是否有效 |
| Audio Completion Rate | 音频体验是否舒服 |
| Saved Dua Count | 内容是否有价值 |
| Women’s Mode Activation | 女性模式是否被接受 |

## 10. 主要风险

| 风险 | 应对 |
|---|---|
| 宗教内容错误 | CMS 审核流、来源字段、approved 状态 |
| 音乐争议 | Quran 无 BGM，默认 conservative mode |
| 性别设计冒犯 | 不强制性别，不粉色化，不医学化 |
| 中东/印尼差异 | 三语言、本地词汇、RTL、地区 prayer method |
| MVP 膨胀 | Codex milestone 必须小步执行 |

## 11. 成功标准

MVP 成功不是“功能很多”，而是：

- 用户能顺利完成一次 Daily Session。
- 用户愿意打开 prayer reminder。
- 用户觉得内容可信、安静、不冒犯。
- Arabic RTL 和 Bahasa Indonesia 文案都不像临时翻译。
- App 不像普通工具堆叠，而像 daily worship companion。
