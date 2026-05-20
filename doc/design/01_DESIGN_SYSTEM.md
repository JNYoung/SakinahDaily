# Design System — Sakinah Daily MVP v0.1

## 1. 设计关键词

```text
Sakinah
Noor
Calm
Sacred
Soft
Trustworthy
```

视觉应该像“夜晚清真寺外的一束柔光”：安静、克制、可信、有精神性。不能像普通工具 App，也不能像西式瑜伽冥想 App。

## 2. 设计原则

1. **Audio-first**：页面服务于听、跟读、计数，而不是堆功能。
2. **Sacred clarity**：Quran 和 Dua 内容要庄重、来源明确。
3. **Quiet density**：留白多、元素少、层级清楚。
4. **RTL native**：Arabic 不是翻译补丁，而是完整 RTL 体验。
5. **Privacy warmth**：女性模式要温柔、尊重、隐私友好。
6. **No loud gamification**：可以有完成反馈，但不要排行榜/游戏感。

## 3. 色彩

| Token | Hex | 用途 |
|---|---|---|
| Deep Emerald | `#0E3B2E` | 主品牌色、按钮、重点文本 |
| Midnight Navy | `#101B2D` | 深色模式背景、睡前体验 |
| Sand Gold | `#C9A45C` | 点缀、图标、高亮 |
| Ivory | `#F7F2E8` | 浅色背景 |
| Sage Green | `#AABFA3` | 柔和状态、女性模式辅助 |
| Warm Taupe | `#B8A897` | 次级文本、边框、卡片阴影 |
| Ink | `#1F2623` | 浅色主文本 |
| Soft White | `#FFFDF7` | 卡片背景 |

## 4. 深色模式

```text
Background: #101B2D
Surface: #18263A
Primary text: #F7F2E8
Secondary text: #B8A897
Accent: #C9A45C
```

深色模式是 P0，因为 Daily Session 和睡前 Dhikr 是核心场景。

## 5. 字体

### English / Bahasa Indonesia

推荐方向：

```text
Inter
Manrope
Nunito Sans
```

### Arabic UI

推荐方向：

```text
Noto Sans Arabic
IBM Plex Sans Arabic
```

### Quran Arabic

Quran Arabic 不等于 UI Arabic。需要单独选择适合经文展示的字体，并确认授权。MVP 可先用系统安全字体或明确授权字体。

## 6. 圆角和间距

| Token | Value |
|---|---:|
| radius.sm | 8 |
| radius.md | 16 |
| radius.lg | 24 |
| radius.xl | 32 |
| spacing.xs | 4 |
| spacing.sm | 8 |
| spacing.md | 16 |
| spacing.lg | 24 |
| spacing.xl | 32 |

## 7. 核心组件

### PrimaryButton

- 高 52–56。
- 圆角 16–24。
- 支持 loading / disabled。
- RTL icon position 自动反转。

### AppCard

- 大圆角。
- 柔和阴影或边框。
- 支持 light/dark。

### PrayerCountdownPill

显示：

```text
Dhuhr in 1h 24m
```

### DailySessionCard

内容：

- Label: Today’s Sakinah。
- Title。
- Duration。
- Steps：Ayah · Reflection · Dua · Dhikr。
- CTA：Start。

### AudioPlayerBar

- 大播放按钮。
- 进度条。
- 当前音频标题。
- Reciter / voice label。
- Quran step 显示 `Voice only / No background sound`。

### SourceChip

用于 Dua / Quran / Reflection 下方：

```text
Source: Quran 20:25–26
Reviewed
```

### DhikrCounterCircle

- 中央大圆。
- Tap +1。
- 显示 `17 / 33`。
- 完成时柔和动画。

## 8. 动效

- 进入 Daily Session：轻微 fade + upward motion。
- Dhikr tap：非常轻的 scale。
- Completion：柔和光晕，不要烟花/夸张庆祝。
- Prayer countdown：不需要实时大动画。

## 9. 可访问性

- 支持大字号。
- 对比度足够。
- 按钮触摸区域 ≥ 44px。
- 音频控件可被 screen reader 读出。
- 阿语 RTL 下阅读顺序正确。

## 10. 设计禁区

- 不要粉色化女性模式。
- 不要在 Quran 文字后放复杂纹理。
- 不要把 Quran ayah 放在可裁切背景图上。
- 不要使用过度娱乐化 icon。
- 不要用“Unlock your faith”这类商业化文案。
