# Acceptance Checklist — MVP v0.1

## 1. Product acceptance

- [ ] 用户可以完成 onboarding。
- [ ] 用户可以在 Home 第一屏看到下一次礼拜、地点、计算方式和提醒状态。
- [ ] 用户可以查看 Fajr / Dhuhr / Asr / Maghrib / Isha 全天时间。
- [ ] 用户可以选择 preset 或手动 prayer location。
- [ ] 用户可以开启/关闭本地 prayer reminders。
- [ ] 用户可以管理每日 session reminder。
- [ ] 用户可以可选完成 Daily Session。
- [ ] App 不像工具堆叠，而像 daily prayer companion。

## 2. Religious safety

- [ ] Quran recitation 不使用 TTS。
- [ ] Quran recitation 无 BGM。
- [ ] Dua detail 显示 source。
- [ ] Dua detail 显示 review status。
- [ ] Remote CMS 默认关闭；如开启则仅显示 published + approved。
- [ ] Reflection 不提供 fatwa 风格结论。

## 3. Localization

- [ ] English 可用。
- [ ] Bahasa Indonesia 可用。
- [ ] Arabic 可用。
- [ ] Arabic RTL 生效。
- [ ] 关键按钮没有硬编码英文。
- [ ] 印尼语使用 Doa / Dzikir / Shalat / Kiblat。

## 4. Privacy

- [ ] v0.1 不请求 GPS/location permission。
- [ ] 支持 preset/manual location。
- [ ] Women’s Ibadah Mode 默认本地存储。
- [ ] 不上传 menstruating/postpartum/pregnancy 状态。
- [ ] 隐私页面说明 location 和 women mode 数据用途。

## 5. Audio

- [ ] 上架主路径没有 no-op audio CTA。
- [ ] Quran step 禁止 BGM。
- [ ] Audio failure 有 fallback 文本。

## 6. Notifications

- [ ] Prayer reminders 可开启/关闭。
- [ ] Daily reminder 可开启/关闭。
- [ ] 权限拒绝不影响 App 使用。
- [ ] 推送文案温柔克制。

## 7. Engineering

- [ ] `flutter analyze` 通过。
- [ ] `flutter test` 通过。
- [ ] 目录结构符合 PRD。
- [ ] 每个 feature 模块边界清楚。
- [ ] Seed fallback 可用。
- [ ] 不存在 service role key 泄漏。

## 8. Beta observation

观察用户：

- [ ] 是否理解这是 daily prayer companion。
- [ ] 是否觉得内容可信。
- [ ] 是否愿意每天打开。
- [ ] 是否觉得推送打扰。
- [ ] 阿语用户是否觉得 RTL 和文案自然。
- [ ] 印尼用户是否觉得本地化自然。
