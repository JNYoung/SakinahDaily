# SCM PRD — Source Control, Codex Workflow & Delivery MVP v0.1

## 1. 目标

SCM 文档用于管理仓库结构、分支策略、Codex 执行方式、PR 审核、CI、文档版本和发布节奏。

## 2. 分支策略

```text
main                  稳定主分支
feature/m01-foundation
feature/m02-models-seed
feature/m03-design-system
feature/m04-onboarding
feature/m05-prayer
feature/m06-home
feature/m07-daily-session
feature/m08-dua-dhikr
feature/m09-settings-women
feature/m10-cms-integration
```

规则：

- Codex 每次只处理一个 milestone 分支。
- 合并前必须 review diff。
- 不允许一个 PR 同时做多个 milestone。
- 文档变更和代码变更可以在同一 PR，但要在 PR summary 里说明。

## 3. PR 模板

见 `.github/PULL_REQUEST_TEMPLATE.md`。

PR 必须包含：

- Summary。
- Files changed。
- Screenshots if UI changed。
- Commands run。
- Tests / analyzer result。
- Product constraints checklist。

## 4. Commit 规范

建议：

```text
feat: add Flutter app foundation
feat(onboarding): add language selection
fix(audio): prevent bgm during quran playback
docs(prd): update client requirements
chore: add l10n config
```

## 5. CI 建议

MVP 第一阶段：

```text
flutter pub get
dart analyze
flutter test
scripts/verify_local_e2e.sh
```

GitHub Actions:

- `.github/workflows/local-e2e.yml` runs on `pull_request` and pushes to
  `main`.
- The workflow installs stable Flutter, runs `flutter pub get`, then delegates
  to `scripts/verify_local_e2e.sh`.
- CI skips Android launch smoke and release signing by default because GitHub
  hosted runners do not have the local device, upload keystore, or Play Console
  state.
- Android launch smoke and signed release gates remain local/CI-secret gates
  before Play upload.

后续：

```text
flutter test --coverage
integration_test
build apk
build ios --no-codesign
```

## 6. Codex 执行规则

每个任务 prompt 都应包含：

1. 目标。
2. 只做哪些文件/模块。
3. 明确不要做什么。
4. 验收标准。
5. 要运行的命令。

不要让 Codex 一次性“实现整个 MVP”。

## 7. 文档驱动流程

1. 修改 PRD。
2. 生成/调整 Codex milestone prompt。
3. Codex 执行。
4. Review diff。
5. 更新 docs/testing。
6. 合并。

## 8. 风险控制

| 风险 | 控制 |
|---|---|
| Codex 扩大范围 | milestone prompt 明确 non-goals |
| 宗教内容被自动生成 | seed content 只作为样例，CMS 审核后替换 |
| UI 忽略 RTL | milestone 1 就验证 Arabic RTL |
| 音频规则遗漏 | audio service 层强制 quran_no_bgm |
| PR 太大 | 每个 PR 只做一个 milestone |
