# Acceptance Checklist — MVP v0.1

## 1. Product acceptance

- [x] 用户可以完成 onboarding。
- [x] 用户完成 onboarding 后，后续启动会从 Splash 回到 Home，不会重复强制
  走 onboarding。
- [x] 用户可以在 Home 第一屏看到下一次礼拜、地点、计算方式和提醒状态。
- [x] 用户可以查看 Fajr / Dhuhr / Asr / Maghrib / Isha 全天时间。
- [x] 用户可以从 Prayer 页上下文动作进入 Qibla 方向页。
- [x] 用户可以选择 preset 或手动 prayer location。
- [x] 用户可以开启/关闭本地 prayer reminders。
- [x] 用户可以在 Prayer 页本地标记今日五次礼拜完成状态，五次完成后看到本地完成态，并在 Home 看到今日完成数和本地周进度。
- [x] 用户可以从 Home 本地进度卡继续或复核 prayer check-in，并回到 Prayer 页。
- [x] 用户可以管理每日 session reminder。
- [x] 用户可以可选完成 Daily Session。
- [x] 用户保存内容后可以从 Home 的本地继续入口返回。
- [x] 配置闭测反馈渠道后，Home 可进入 Closed testing guide；Guide 顶部会
  根据本地 sent marker 提示下一条 Day 1 / Day 3 / Day 7 / Day 14
  待发反馈，全部完成后显示 all sent 状态。
- [x] App 不像工具堆叠，而像 daily prayer companion。
- [x] 本地 e2e 总闸脚本 `scripts/verify_local_e2e.sh` 可无人值守运行测试、analyzer、
  Play 模板门禁、Google Play closed-test setup packet、Google Analytics DebugView QA packet、
  Day 0 / Day 1 operator packet、内容 readiness、Android OEM reminder observation packet
  和 Android launch smoke；脚本支持 `full` / `ci` / `fast profile` / `release`
  四种 profile，已经单独跑过 `flutter test` 与 `dart analyze` 后可用
  `SAKINAH_E2E_PROFILE=fast` 避免重复测试和证据包导出。
- [x] Google Play closed-test setup packet 可导出 Google Group、Closed testing
  track、Testing feedback、release artifact、tester links 和外部 blocker
  模板；strict mode 需要 completed CSV evidence 且不能包含 `TBD`、
  `pending_play_console_action`、`record_manually` 或 tester personal data。
- [x] Day 0 / Day 1 operator packet 的 completed-evidence mode 要求填写
  aggregate status 和 Day 1 feedback CSV evidence，模板 `TBD`/placeholder
  不能通过 completed gate。
- [x] GitHub Actions workflow `.github/workflows/local-e2e.yml` 可在 PR 上运行
  本地 e2e 门禁的 CI 版本；PR 模板要求填写命令、测试和产品约束。

## 2. Religious safety

- [x] Quran recitation 不使用 TTS。
- [x] Quran recitation 无 BGM。
- [x] Dua detail 显示 source。
- [x] Dua detail 显示 review status。
- [x] Remote CMS 默认关闭；如开启则仅显示 published + approved。
- [x] Reflection 不提供 fatwa 风格结论。

## 3. Localization

- [x] English 可用。
- [x] Bahasa Indonesia 可用。
- [x] Arabic 可用。
- [x] Arabic RTL 生效。
- [x] 关键按钮没有硬编码英文。
- [x] 印尼语使用 Doa / Dzikir / Shalat / Kiblat。

## 4. Privacy

- [x] v0.1 不请求 GPS/location permission。
- [x] 支持 preset/manual location。
- [x] Women’s Ibadah Mode 默认本地存储。
- [x] 不上传 menstruating/postpartum/pregnancy 状态。
- [x] 隐私页面说明 location 和 women mode 数据用途。

## 5. Audio

- [x] 上架主路径没有 no-op audio CTA。
- [x] Quran step 禁止 BGM。
- [x] Audio failure 有 fallback 文本。

## 6. Notifications

- [x] Prayer reminders 可开启/关闭。
- [x] Daily reminder 可开启/关闭。
- [x] 权限拒绝不影响 App 使用。
- [x] 推送文案温柔克制。
- [x] Android OEM reminder observation packet 可导出 8h / 24h / reboot /
  battery policy / notification permission state 长窗口观察模板和 device
  environment snapshot，且不记录 tester personal data。
- [x] Push module completion audit packet 可导出本地 prayer reminders、本地
  Daily Session reminders、tap routing、权限、dev smoke control 和
  analytics coverage 矩阵，并明确 Remote FCM/APNs 不属于 v0.1 完成范围。
- [x] 推送 tap outcome 打点覆盖 opened、malformed payload、missing content 和
  unhandled 等粗粒度结果，不上传 raw payload、route、content ID 或锁屏正文。
- [x] Push module completion audit strict mode 需要 completed permission QA、
  real-device smoke、DebugView event review 和 OEM owner CSV evidence，模板
  占位行不能通过 strict gate；DebugView evidence 必须覆盖 12 个本地
  push/reminder 事件，不能只验证通知打开事件。

## 7. Engineering

- [ ] `flutter analyze` 通过。
- [x] `flutter test` 通过。
- [x] 目录结构符合 PRD。
- [x] 每个 feature 模块边界清楚。
- [x] Seed fallback 可用。
- [x] 不存在 service role key 泄漏。

## 8. Beta observation

观察用户：

- [ ] 是否理解这是 daily prayer companion。
- [ ] 是否觉得内容可信。
- [ ] 是否愿意每天打开。
- [ ] 是否觉得推送打扰。
- [ ] 阿语用户是否觉得 RTL 和文案自然。
- [ ] 印尼用户是否觉得本地化自然。
