# Screen Specs & Wireframes — MVP v0.1

## 1. Onboarding

### Welcome

```text
Sakinah Daily

A peaceful companion for Quran, Dua, Dhikr, and prayer reminders.

[ Get Started ]
```

### Language

```text
Choose your language

[ English ]
[ Bahasa Indonesia ]
[ العربية ]
```

### Location

```text
Set your prayer location

We use your location only to calculate prayer times and Qibla direction.

[ Use my location ]
[ Choose manually ]
```

### Personalization

```text
Personalize your daily worship

This helps us suggest more relevant duas, reminders, and routines.

[ Male ]
[ Female ]
[ Prefer not to say ]
```

### Audio Preference

```text
Choose your audio style

[ Pure Quran recitation ]
[ Voice guidance only ]
[ Nature ambience for reflections ]
[ No background sound ]
```

## 2. Home

```text
┌───────────────────────────────┐
│ Assalamu alaikum, Aisha        │
│ 12 Ramadan · Tuesday           │
│                               │
│ Dhuhr in 1h 24m                │
│ [ Prayer Times ]               │
├───────────────────────────────┤
│ Today’s Sakinah                │
│                               │
│ Calm Before Work               │
│ 7 min · Ayah · Dua · Dhikr     │
│                               │
│ [ Start ]                      │
├───────────────────────────────┤
│ Quick Actions                  │
│ [ Quran ] [ Dua ]              │
│ [ Dhikr ] [ Qibla ]            │
├───────────────────────────────┤
│ Tonight                        │
│ Sleep with Ayat al-Kursi       │
│ 5 min · Voice only             │
│ [ Save ]                       │
└───────────────────────────────┘
```

状态：

- Loading。
- Seed content fallback。
- No location set。
- Notification permission not requested。

## 3. Daily Session

### Step 1 Intention

```text
Calm Before Work
Step 1 of 5

What are you seeking today?

[ Peace ]
[ Focus ]
[ Strength ]
[ Forgiveness ]

[ Continue ]
```

### Step 2 Quran Listening

```text
Listen
Step 2 of 5

[ Arabic Ayah ]

Recited by: Mishary Rashid

[ Play Button ]

Translation
...

[ Repeat ] [ Save ]
```

Required UI label:

```text
No background sound under Quran recitation
```

### Step 3 Reflection

```text
Reflect
Step 3 of 5

This ayah reminds us...

[ Listen ]
[ Read ]
```

### Step 4 Guided Dua

```text
Make Dua
Step 4 of 5

اللهم اشرح لي صدري ويسر لي أمري

Allahumma ishrah li sadri wa yassir li amri

O Allah, expand my chest and ease my task.

Source: Quran 20:25–26 · Reviewed

[ Listen ] [ Repeat Slowly ]
```

### Step 5 Dhikr

```text
Dhikr
Step 5 of 5

Astaghfirullah

17 / 33

[ Tap Circle ]

[ Auto pace ] [ Silent mode ]
```

### Completion

```text
You completed today’s Sakinah.

May your heart find peace today.

[ Save this session ]
[ Set reminder ]
[ Back home ]
```

## 4. Dua Detail

```text
Dua for Ease

اللهم اشرح لي صدري ويسر لي أمري

Allahumma ishrah li sadri wa yassir li amri

O Allah, expand my chest and ease my task.

Source: Quran 20:25–26
Reviewed

[ Play ] [ Repeat ] [ Save ]
```

## 5. Women’s Ibadah Mode

```text
Women’s Ibadah Mode

Today’s mode

[ Normal ]
[ Menstruating ]
[ Postpartum ]
[ Pregnancy ]
[ Prefer not to track ]

During this mode, we can show more Dua, Dhikr, and reflection reminders.

Your data stays private on this device.

[ Save ]
```

文案禁区：

- 不写 “you cannot pray” 这种粗暴提醒。
- 不把它叫做 Period Tracker。
- 不使用医学化/羞辱性图标。

## 6. Settings

```text
Settings

Language
Prayer location
Prayer calculation method
Audio preferences
Notifications
Women’s Ibadah Mode
Privacy
Content sources
About
```
