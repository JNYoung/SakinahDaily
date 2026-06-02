# Server PRD — Backend MVP v0.1

## 1. 服务端目标

服务端负责用户偏好、内容读取、音频资产、基础同步和后续推送能力。MVP 阶段允许客户端先用 seed data，服务端和 CMS 在后续 milestone 接入。

## 2. 推荐架构

| 模块 | 技术 |
|---|---|
| Database | Supabase Postgres |
| Auth | Supabase Auth，MVP 支持匿名/可选登录 |
| Storage | Supabase Storage，用于 audio assets 和 images |
| Edge Functions | 后续做推荐、发布同步、push job |
| Push | FCM，用于服务端内容推送；local prayer reminder 由客户端处理 |
| CMS | Directus，负责内容编辑/审核/发布 |

## 3. 服务端职责

### P0

- 提供城市搜索/常用城市库，返回经纬度、时区和 prayer calculation method。
- 提供 prayer-ready location resolution；时区单独不能作为礼拜时间计算输入。
- 提供 published + approved 内容读取。
- 保存非敏感用户偏好，若用户登录。
- 保存收藏内容，若用户登录。
- 提供音频资产 URL/metadata。
- 提供 API health check。

### P1

- 用户云同步。
- Server-triggered daily dua push。
- Ramadan plan。
- Premium subscription integration。

## 4. 不应由服务端存储的 MVP 数据

除非未来有明确 consent flow，以下数据 MVP 默认不上传：

- Menstruating/Postpartum/Pregnancy current state。
- 精细化宗教行为轨迹。
- 未脱敏的位置历史。

## 5. API 设计

MVP 可直接通过 Supabase client / Directus API 读取，也可以后续封装 BFF。

### Content API

```text
GET /content/daily-sessions?locale=id&date=YYYY-MM-DD
GET /content/duas?locale=id&category=morning
GET /content/duas/:id?locale=id
GET /content/dhikrs?locale=id
GET /content/audio-assets/:id
```

响应必须只包含：

```text
status = published
review_status = approved
```

### Location API

```text
GET /locations/cities?query=jakarta&country=ID&locale=id
GET /locations/cities/:city_id
POST /locations/resolve
GET /locations/timezones?country=ID
```

`/locations/resolve` 必须返回经纬度、时区和计算法。仅返回 timezone
不足以计算礼拜时间。

### MVP Backend BFF

当前仓库新增 `services/backend-api` 作为本地可测 BFF 骨架：

```text
GET /health
GET /manifest
GET /bundles/:bundle_id.json
GET /detail-bundle?bundle_hint=:content_id
POST /push/preview
```

该项目暂不连接生产 Supabase、Directus、FCM 或 APNs；它先稳定客户端和后续
服务端之间的 API 合约。

### User API

```text
GET /me/preferences
PATCH /me/preferences
GET /me/saved-items
POST /me/saved-items
DELETE /me/saved-items/:id
```

## 6. 数据安全

- 使用 Row Level Security。
- 用户只能读取/写入自己的 private data。
- Published content 可公开读取。
- Draft/in_review 内容仅 CMS 角色读取。
- Storage audio assets 可以公开或 signed URL，取决于授权协议。

## 7. 环境变量

```text
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
DIRECTUS_URL=
DIRECTUS_STATIC_TOKEN=
FCM_SERVER_KEY_OR_SERVICE_ACCOUNT=
```

注意：客户端只允许使用 anon key，不允许把 service role 放进 App。

## 8. 服务端验收

- 数据库 schema 可创建。
- Published content 能被客户端读取。
- Draft/in_review 内容不会出现在客户端。
- Audio asset metadata 可读取。
- 用户收藏可写入/读取，且 RLS 限制正确。
- 敏感 women mode 数据没有服务端上传路径。
