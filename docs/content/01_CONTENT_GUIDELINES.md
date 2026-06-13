# Content Guidelines — Quran, Dua, Dhikr & Reflection

## 1. 内容原则

1. 内容可信比内容数量更重要。
2. Quran、Dua、Dhikr 必须有来源或审核标签。
3. 不用 AI 自动生成宗教结论。
4. 不在 MVP 做 fatwa 风格问答。
5. 对存在学派差异的事项，使用中性说明和来源标注。

Remote CMS content must stay hidden unless it is published and approved. The
client must also filter draft, in-review, rejected, unapproved, and revoked
items inside otherwise valid bundles.

## 2. Quran 内容

规则：

- Arabic Quran recitation 不使用普通 TTS。
- Quran recitation 使用 approved audio asset。
- Quran recitation 下不播放 BGM。
- Quran ayah 必须有 surah/ayah reference。
- Translation 必须标注版本/来源，MVP 可先用内部 placeholder，正式上线前必须解决授权。

## 3. Dua 内容

每条 Dua 至少包含：

- Arabic。
- Transliteration。
- Translation EN/ID/AR。
- Source label。
- Category。
- Review status。

优先内容来源类型：

- Quranic duas。
- Hisnul Muslim。
- Sahih hadith-based duas。
- Reviewed local scholar/editor content。

## 4. Dhikr 内容

- 推荐次数可为 33 / 99 / custom。
- 不做排行榜。
- 不把 Dhikr 设计成游戏刷分。
- 支持 silent mode。

## 5. Reflection 内容

Reflection 是生活化解释，不是 fatwa。

客户端 Daily Session 的 Reflection step 必须显示 no-fatwa 安全提示，说明
reflection 只是温柔提醒，不是 fatwa 或宗教裁决。

语气：

- 温柔。
- 简短。
- 不说教。
- 不制造 guilt。
- 不用医学/心理治疗承诺。

示例：

```text
This ayah reminds us that ease begins when the heart returns to Allah.
Take a breath, make dua, and let the next small step be enough for now.
```

## 6. Women’s Ibadah 内容

规则：

- 不说 “you cannot pray now” 这种直接羞辱/判断文案。
- 使用 “Dua · Dhikr · Reflection” 作为替代 worship moment。
- 不把 women mode 做成 medical period tracker。
- 状态默认 local-only。
- 内容必须由 reviewer 标记 `women_ibadah_safe=true`。

示例推送：

```text
A gentle worship moment is ready for you.
Dua · Dhikr · Reflection
```

印尼语：

```text
Momen ibadah yang lembut sudah siap untukmu.
Doa · Dzikir · Renungan
```

阿语：

```text
لحظة عبادة هادئة جاهزة لك.
دعاء · ذكر · تأمل
```

## 7. Audio / BGM 规则

| 内容 | BGM |
|---|---|
| Quran recitation | 禁止 |
| Dua Arabic | 默认禁用或极谨慎 |
| Dua meaning | 可选自然声 |
| Reflection | 可选自然声/soft ambient |
| Dhikr | 可选节奏提示或 silent |
| Sleep session | 可选自然声，但不能覆盖 Quran |

## 8. 首批内容包

MVP 建议 80–120 条内容。

### Morning

- 起床后 Dua。
- Fajr 后 reflection。
- 感恩 Dhikr。
- 工作/学习前 Dua。

### Evening

- Maghrib 后感恩。
- 睡前 Dhikr。
- Ayat al-Kursi listening placeholder。
- Al-Falaq / An-Nas placeholder。

### Stress & Calm

- 焦虑时。
- 生气时。
- 工作压力。
- 迷茫时。
- 请求 ease。

### Women’s Ibadah

- 经期可用 Dua/Dhikr/reflection。
- 产后恢复期灵修。
- 母亲相关 Dua。
- 情绪低落时。

### Ramadan Placeholder

- Suhoor。
- Iftar。
- Forgiveness。
- Last 10 nights。

## 9. 上线前必须完成

- Quran text/translation 授权确认。
- Quran audio 授权确认。
- Reviewer 名单与审核流程。
- 对每条内容添加 source_label。
- 对每条内容添加 version 和 reviewed_at。

上线前内容包 readiness（reviewed content pack readiness packet）：

- 运行 `scripts/export_reviewed_content_pack_readiness.sh` 导出 reviewed
  content pack readiness packet；模板模式只生成现有 seed 盘点、Quran source
  placeholder count、audio rights 缺口和 beta pack checklist，不代表内容已经
  production-ready。
- 严格模式
  `SAKINAH_REQUIRE_REVIEWED_CONTENT_PACK_READY=true` 只能在 Quran source
  placeholder 已替换、5-7 个 session、30-50 个 duas、20-30 个 dhikrs、
  10-20 个 Quran ayah references、licensed reciter audio rights/hash 和人工
  owner 全部确认后运行通过。
- 该 packet 不允许新增或生成宗教内容；新增 Quran/Dua/Dhikr/Reflection 必须走
  approved source、review status、version、reviewed date 和 privacy review。
