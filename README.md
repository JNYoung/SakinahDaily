# SakinahDaily

Sakinah Daily 是一个面向中东与印尼用户的 Islamic daily calm app，核心体验是每天 5–12 分钟的 Quran listening、Dua、Dhikr、Prayer reminders 和 gender-aware worship routines。

本仓库的 MVP 原则：

> 先做一个高完成度的每日助祷陪伴 App，不做完整 Quran super-app，也不做普通冥想 App。

## MVP 核心体验

用户完成 onboarding 后进入 Home：

1. 看到下一次礼拜倒计时。
2. 看到 Today's Sakinah Daily Session。
3. 开始一个 5–12 分钟 session。
4. 完成 Intention → Quran Audio → Reflection → Guided Dua → Dhikr Counter → Completion。
5. 可浏览 Dua / Dhikr library，保存内容，配置推送和 Women’s Ibadah Mode。

## 关键产品规则

- Quran Arabic recitation 不能使用普通 TTS。
- Quran recitation 下永远不播放 BGM。
- Dua / Dhikr / Reflection 必须显示来源、审核状态或 CMS 发布状态。
- Arabic UI 必须从第一天支持 RTL。
- Women’s Ibadah Mode 默认本地隐私存储，不做成医学化 period tracker。
- MVP 不做 AI Fatwa、宗教问答、社区、UGC、广告、复杂付费墙。

## 文档入口

| 文档 | 用途 |
|---|---|
| `docs/00_DOCS_INDEX.md` | 文档地图与执行顺序 |
| `docs/prd/01_PRODUCT_PRD.md` | 产品 PRD |
| `docs/prd/02_CLIENT_PRD.md` | 客户端 PRD |
| `docs/prd/03_SERVER_PRD.md` | 服务端 PRD |
| `docs/prd/04_CMS_PRD.md` | CMS PRD |
| `docs/prd/05_SCM_PRD.md` | SCM / Repo / Codex 协作 PRD |
| `docs/design/01_DESIGN_SYSTEM.md` | 设计系统 |
| `docs/design/02_SCREEN_SPECS.md` | 页面规格和线框 |
| `docs/architecture/01_TECH_ARCHITECTURE.md` | 技术架构 |
| `docs/content/01_CONTENT_GUIDELINES.md` | 内容与宗教安全规范 |
| `docs/codex/00_CODEX_CONTEXT.md` | Codex 总上下文 |
| `docs/codex/01_CODEX_MILESTONES.md` | Codex 分阶段执行任务 |
| `docs/testing/01_ACCEPTANCE_CHECKLIST.md` | MVP 验收清单 |

## 推荐技术栈

- Client: Flutter + Dart
- State: Riverpod
- Routing: go_router
- Localization: Flutter l10n / ARB / RTL
- Audio: just_audio
- Prayer calculation: adhan_dart 或等价库
- Local notifications: flutter_local_notifications
- Backend: Supabase Postgres/Auth/Storage/Edge Functions
- CMS: Directus
- Server push: Firebase Cloud Messaging

## Codex 使用方式

先让 Codex 阅读：

```text
AGENTS.md
README.md
docs/00_DOCS_INDEX.md
docs/codex/00_CODEX_CONTEXT.md
docs/codex/01_CODEX_MILESTONES.md
```

然后每次只执行一个 milestone，完成后 review diff，再继续下一步。
