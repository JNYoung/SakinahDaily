# Sakinah Daily Docs Index

版本：MVP v0.1  
当前目标：用文档驱动 Codex 分阶段实现产品、客户端、服务端、CMS 和 SCM 工作流。

## 1. 文档分层

### PRD 文档

| 文件 | 责任 |
|---|---|
| `docs/prd/01_PRODUCT_PRD.md` | 产品定位、用户、MVP 范围、用户旅程、指标、风险 |
| `docs/prd/02_CLIENT_PRD.md` | Flutter 客户端模块、页面、状态、音频、推送、本地化 |
| `docs/prd/03_SERVER_PRD.md` | 服务端、Auth、API、数据、Storage、Edge Functions、隐私 |
| `docs/prd/04_CMS_PRD.md` | 内容 CMS、审核流、角色、集合、发布、翻译、音频资产 |
| `docs/prd/05_SCM_PRD.md` | Source Control / Codex 协作 / 分支 / PR / CI / 交付节奏 |

### 设计文档

| 文件 | 责任 |
|---|---|
| `docs/design/01_DESIGN_SYSTEM.md` | 视觉原则、颜色、字体、组件、RTL、动效、可访问性 |
| `docs/design/02_SCREEN_SPECS.md` | 关键页面线框、页面状态、组件需求 |
| `docs/design/design_tokens.json` | 可被客户端引用的基础设计 token |

### 产品研究文档

| 文件 | 责任 |
|---|---|
| `docs/research/01_COMPETITOR_FEATURE_GAP_PRIORITY.md` | 竞品功能研究、Sakinah 功能缺口与优先级 |

### 技术与内容文档

| 文件 | 责任 |
|---|---|
| `docs/architecture/01_TECH_ARCHITECTURE.md` | 总体技术架构、模块、数据流、目录结构 |
| `docs/architecture/02_DATA_MODELS.md` | 客户端模型、CMS 表结构、JSON 示例 |
| `docs/content/01_CONTENT_GUIDELINES.md` | Quran/Dua/Dhikr/Reflection 内容策略与宗教安全；包含 `scripts/export_reviewed_content_pack_readiness.sh` 的 reviewed content pack readiness packet 上线前门禁 |
| `docs/content/02_DAILY_PUSH_CONTENT_SYSTEM.md` | 每日推送内容模型、选择规则、安全约束 |
| `docs/content/03_SOURCE_CORPUS_INGESTION.md` | Quran/Tanzil/QuranEnc 语料导入与校验策略 |
| `docs/cms/supabase_schema.sql` | MVP 级别 Supabase/Postgres schema 草案 |
| `docs/cms/02_PUSH_CONTENT_SCHEMA.sql` | Daily push content CMS schema 草案 |
| `docs/cms/03_AGENT_SERVICE_SCHEMA.sql` | Content Agent service schema 草案 |
| `docs/cms/04_SOURCE_CORPUS_SCHEMA.sql` | Source corpus schema 草案 |
| `docs/cms/05_CLIENT_CONTENT_DELIVERY_SCHEMA.sql` | Client content delivery/cache schema 草案 |
| `docs/client/01_CONTENT_DELIVERY_CACHE_STRATEGY.md` | 客户端内容 manifest、bundle、cache 策略 |
| `docs/client/02_CLIENT_CONTENT_MODELS.md` | 客户端内容投递模型 |
| `docs/client/03_CLIENT_SYNC_FLOWS.md` | 客户端同步与缺内容恢复流程 |
| `docs/client/04_CLIENT_CONTENT_CACHE_IMPLEMENTATION.md` | 客户端持久内容缓存实现 |
| `docs/client/05_REMOTE_CONTENT_API_INTEGRATION.md` | 远程内容 API 配置、manifest/bundle 合约、安全回退 |
| `docs/client/06_NOTIFICATION_TAP_QIBLA_SAVED.md` | 通知点击、Qibla 和本地 Saved Items 实现 |
| `docs/client/07_NOTIFICATION_ROUTER_QURAN_MANUAL_LOCATION.md` | 通知实际路由、Quran 入口和手动位置页实现 |
| `docs/client/08_SESSION_PROGRESS_HISTORY.md` | Daily Session 进度、完成页和本地历史实现 |
| `docs/client/09_WOMEN_MODE_CONTENT_POLICY.md` | Women’s Mode 本地内容推荐与隐私策略 |
| `docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md` | Prayer / Session / Quran / Dua 产品侧需求进度与缺口 |
| `docs/privacy/01_PRIVACY_DATA_INVENTORY.md` | 客户端隐私数据清单草案 |
| `docs/privacy/02_PRIVACY_POLICY_DRAFT.md` | 隐私政策草案，供 legal/store review |
| `docs/privacy/03_APP_STORE_PRIVACY_LABEL_DRAFT.md` | App Store privacy label 草案 |
| `docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md` | Google Play Data Safety 草案 |
| `docs/privacy/05_PERMISSION_COPY.md` | 权限与同意说明文案草案 |
| `docs/privacy/06_SDK_AND_API_INVENTORY.md` | SDK/API 隐私清单草案 |
| `docs/privacy/07_GOOGLE_ANALYTICS_EVENT_PLAN.md` | Google Analytics 事件白名单、敏感字段过滤、`scripts/export_google_analytics_debugview_packet.sh` DebugView QA 包和未来 SDK 接入门禁 |
| `docs/release/01_RELEASE_READINESS_CHECKLIST.md` | 客户端 release readiness 总清单，含 reviewed content pack readiness packet、Android OEM reminder observation packet、Google Play 和 analytics 门禁 |
| `docs/release/02_ANDROID_RELEASE_CHECKLIST.md` | Android 包名、签名、权限、构建清单和 `scripts/export_android_oem_reminder_observation_packet.sh` 长窗口提醒观察包 |
| `docs/release/03_IOS_RELEASE_CHECKLIST.md` | iOS bundle、签名、隐私和截图清单 |
| `docs/release/04_STORE_METADATA_DRAFT.md` | App Store / Google Play metadata 草案 |
| `docs/release/05_SCREENSHOT_PLAN.md` | Store 截图计划和后续自动化 key |
| `docs/release/06_PERMISSION_AND_DATA_SAFETY_REVIEW.md` | 权限与 data safety 一致性复核 |
| `docs/release/07_BUILD_FLAVORS_AND_DART_DEFINE.md` | dev/staging/prod dart-define 配置 |
| `docs/release/08_VERSION_AND_RELEASE_NOTES.md` | 版本号、构建号与 release notes 候选 |
| `docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md` | Google Play 封闭测试群组、测试链接、反馈、`scripts/export_google_play_closed_test_setup_packet.sh` 设置证据包和 12/14 天准备包 |
| `docs/release/10_ANDROID_UPLOAD_SIGNING_SETUP.md` | Android upload keystore 生成、保管和 Play 上传签名准备 |
| `docs/release/11_PLAY_PUBLIC_LINKS_AND_FEEDBACK.md` | Google Play 隐私政策 URL 与测试反馈入口托管准备 |
| `docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md` | Google Play 封闭测试 12/14 天证据日志、反馈主题和 Production access 答案草稿 |
| `docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md` | Google Play Console 提交包、App content、商店列表、闭测 release、`scripts/export_google_play_upload_packet.sh` 上传证据包、`scripts/export_google_play_closed_test_setup_packet.sh` 闭测设置证据包和人工确认 gate |
| `docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md` | Google Play Production access 回答草稿、证据链接、严格模式 gate，以及 `scripts/export_google_play_production_access_packet.sh` 本地证据包导出 |
| `docs/release/15_PUBLIC_LINKS_HOSTING_PACKET.md` | Google Play 隐私政策和测试反馈公开链接静态托管包、严格公网 URL gate |
| `docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md` | Google Play 封闭测试上线当天 checklist、群组优先分享顺序、tester link 复核、`scripts/verify_google_play_closed_test_launch_day.sh` 和 Day 0 / Day 1 操作员包 `scripts/export_google_play_day0_day1_operator_packet.sh` |
| `docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md` | Google Play 封闭测试留存观察计划、D1/D3/D7/D14 反馈主题、可选 DebugView QA packet、Day 0 / Day 1 操作员包、Production access 反馈证据模板和 `scripts/export_google_play_closed_test_retention_packet.sh` |
| `docs/release/18_PUSH_MODULE_COMPLETION_AUDIT.md` | 推送/本地提醒模块完成度审计、打点覆盖矩阵、隐私黑名单和 `scripts/export_push_module_completion_audit.sh` |
| `docs/testing/01_ACCEPTANCE_CHECKLIST.md` | 验收清单、QA、beta 观察项 |

### Agent Service 文档

| 文件 | 责任 |
|---|---|
| `docs/agent/01_CONTENT_AGENT_SERVICE_PRD.md` | Content Agent Service PRD |
| `docs/agent/02_AGENT_WORKFLOWS.md` | Agent run、review、QA、promote 工作流 |
| `docs/agent/03_AGENT_OUTPUT_SCHEMAS.md` | Agent structured output schema |
| `docs/agent/04_AGENT_PROMPTS.md` | Agent prompts 与约束 |
| `docs/agent/05_AGENT_SERVICE_OPENAPI.yaml` | Agent Service REST API 草案 |
| `docs/agent/06_EVAL_AND_GUARDRAILS.md` | Eval、guardrails、自动化测试策略 |
| `docs/agent/07_AGENT_REVIEW_QUEUE_IMPLEMENTATION.md` | Content Agent review queue、QA、draft promotion 实现 |

### Job 交接文档

| 文件 | 责任 |
|---|---|
| `docs/jobs/2026-05-21_completed_work_and_next_steps.md` | 当前已完成工作、验证门禁、下一步推进 |

### Codex 文档

| 文件 | 责任 |
|---|---|
| `AGENTS.md` | Agent 工作规则 |
| `docs/codex/00_CODEX_CONTEXT.md` | Codex 项目总上下文 |
| `docs/codex/01_CODEX_MILESTONES.md` | 可逐个执行的 milestone prompt |

## 2. 推荐执行顺序

1. 让 Codex 初始化 Flutter foundation。
2. 让 Codex 建立数据模型与 seed content。
3. 建立设计系统组件。
4. 实现 onboarding。
5. 实现 Home。
6. 实现 prayer time 与 local notification。
7. 实现 Daily Session flow。
8. 实现 Dua / Dhikr library。
9. 实现 Settings 与 Women’s Ibadah Mode。
10. 接 CMS API。
11. 加 analytics stub 与 QA checklist。
12. 按 `docs/jobs/` 的最新交接记录继续推进 UI 重构、Quran 语料、缓存、Agent 测试、release readiness 和 store readiness。

## 3. 文档维护规则

- 每个 milestone 合并后，更新对应 PRD 的状态。
- 如果产品范围变化，先改 PRD，再让 Codex 执行。
- 不允许 Codex 自行扩大 MVP 范围。
- 所有宗教内容相关改动必须同时更新 `docs/content/01_CONTENT_GUIDELINES.md` 或 CMS 审核要求。
