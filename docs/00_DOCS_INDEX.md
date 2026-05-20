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

### 技术与内容文档

| 文件 | 责任 |
|---|---|
| `docs/architecture/01_TECH_ARCHITECTURE.md` | 总体技术架构、模块、数据流、目录结构 |
| `docs/architecture/02_DATA_MODELS.md` | 客户端模型、CMS 表结构、JSON 示例 |
| `docs/content/01_CONTENT_GUIDELINES.md` | Quran/Dua/Dhikr/Reflection 内容策略与宗教安全 |
| `docs/content/02_DAILY_PUSH_CONTENT_SYSTEM.md` | Daily push source items、候选选择、cooldown、women mode lock-screen safety |
| `docs/cms/supabase_schema.sql` | MVP 级别 Supabase/Postgres schema 草案 |
| `docs/cms/02_PUSH_CONTENT_SCHEMA.sql` | Daily push 内容表结构草案 |
| `docs/cms/03_AGENT_SERVICE_SCHEMA.sql` | Content Agent run/candidate/review 表结构草案 |
| `docs/agent/01_CONTENT_AGENT_SERVICE_PRD.md` | Content Agent Service 产品与实现边界 |
| `docs/agent/02_AGENT_WORKFLOWS.md` | Content Agent weekly preproduction workflow |
| `docs/agent/03_AGENT_OUTPUT_SCHEMAS.md` | Agent run/candidate/review packet 输出契约 |
| `docs/agent/04_AGENT_PROMPTS.md` | Content Agent prompts 与安全提示词 |
| `docs/agent/05_AGENT_SERVICE_OPENAPI.yaml` | Content Agent HTTP endpoint 草案 |
| `docs/agent/06_EVAL_AND_GUARDRAILS.md` | Guardrail 测试与评估规则 |
| `docs/testing/01_ACCEPTANCE_CHECKLIST.md` | 验收清单、QA、beta 观察项 |

### Codex 文档

| 文件 | 责任 |
|---|---|
| `AGENTS.md` | Agent 工作规则 |
| `docs/codex/00_CODEX_CONTEXT.md` | Codex 项目总上下文 |
| `docs/codex/01_CODEX_MILESTONES.md` | 可逐个执行的 milestone prompt |
| `docs/prompts/sakinah_all_prompts_today_afternoon.md` | 从 prompt archive 提取的完整项目执行 prompt 汇总 |
| `docs/prompts/08_CONTENT_AGENT_SERVICE_CODEX_PROMPT.md` | Content Agent Service Codex Prompt 单独归档 |

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
12. 实现 Daily Push Content foundation。
13. 实现 Content Agent Service foundation。

## 3. 文档维护规则

- 每个 milestone 合并后，更新对应 PRD 的状态。
- 如果产品范围变化，先改 PRD，再让 Codex 执行。
- 不允许 Codex 自行扩大 MVP 范围。
- 所有宗教内容相关改动必须同时更新 `docs/content/01_CONTENT_GUIDELINES.md` 或 CMS 审核要求。
