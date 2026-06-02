export interface PushPreviewRequest {
  language?: string;
  type?: string;
  contentId?: string;
  clusterId?: string;
  ritualMoment?: string;
  womenIbadahSafeRequired?: boolean;
  permissionState?: "granted" | "denied" | "unknown";
  titleOverride?: string;
  bodyOverride?: string;
}

export interface LocalPushPayload {
  id: string;
  type: string;
  contentId: string;
  clusterId: string;
  bundleHint: string;
  languageCode: string;
  title: string;
  body: string;
  data: Record<string, string>;
  lockScreenSafe: boolean;
}

export interface PushPreviewResult {
  accepted: boolean;
  provider: "local_preview";
  sent: false;
  payload?: LocalPushPayload;
  flags: string[];
}

type PushSeed = {
  type: string;
  contentId: string;
  clusterId: string;
  bundleHint: string;
  lockScreenSafe: boolean;
  title: Record<string, string>;
  body: Record<string, string>;
};

const seedPushContent: PushSeed[] = [
  {
    type: "daily_session",
    contentId: "session_morning_ease",
    clusterId: "calm_through_dhikr",
    bundleHint: "session_morning_ease",
    lockScreenSafe: true,
    title: {
      en: "Your daily Sakinah session is ready",
      id: "Sesi Sakinah harian siap",
      ar: "جلسة سكينة اليومية جاهزة",
    },
    body: {
      en: "Take a quiet moment for today's guided session.",
      id: "Ambil waktu tenang untuk sesi terpandu hari ini.",
      ar: "خذي لحظة هادئة لجلسة اليوم الموجهة.",
    },
  },
  {
    type: "dua",
    contentId: "dua_ease_task_001",
    clusterId: "ease_and_focus",
    bundleHint: "dua_ease_task_001",
    lockScreenSafe: true,
    title: {
      en: "A short dua for ease",
      id: "Dua singkat untuk kemudahan",
      ar: "دعاء قصير للتيسير",
    },
    body: {
      en: "Open the app when you are ready to read the reviewed source.",
      id: "Buka aplikasi saat siap membaca sumber yang telah ditinjau.",
      ar: "افتحي التطبيق عندما تكونين مستعدة لقراءة المصدر المراجع.",
    },
  },
];

const guardPatterns: Array<{ flag: string; patterns: RegExp[] }> = [
  {
    flag: "cycle_sensitive_lock_screen_copy",
    patterns: [
      /menstruating/i,
      /menstruation/i,
      /period/i,
      /cycle/i,
      /postpartum/i,
      /nifas/i,
      /haidh/i,
      /الحيض/u,
      /النفاس/u,
    ],
  },
  {
    flag: "guaranteed_outcome_claim",
    patterns: [/guaranteed/i, /will definitely/i, /always be accepted/i],
  },
  {
    flag: "shaming_tone",
    patterns: [/lazy/i, /not enough faith/i, /sinful for resting/i],
  },
  {
    flag: "fatwa_like_claim",
    patterns: [/fatwa/i, /ruling is/i, /haram for you/i, /halal for you/i],
  },
];

export function previewPush(input: PushPreviewRequest): PushPreviewResult {
  const flags: string[] = [];
  const language = normalizeLanguage(input.language);
  const seed = findSeed(input.type, input.contentId);

  if (!seed) {
    flags.push("missing_content");
  }

  const title = input.titleOverride ?? seed?.title[language] ?? "";
  const body = input.bodyOverride ?? seed?.body[language] ?? "";
  flags.push(...evaluateLockScreenCopy(title, body));
  if (hasFullQuranLikeLockScreenBody(body)) {
    flags.push("full_quran_lock_screen_body");
  }
  if (input.womenIbadahSafeRequired && seed && !seed.lockScreenSafe) {
    flags.push("lock_screen_not_safe");
  }

  const uniqueFlags = [...new Set(flags)];
  if (uniqueFlags.length > 0 || !seed) {
    return {
      accepted: false,
      provider: "local_preview",
      sent: false,
      flags: uniqueFlags,
    };
  }

  const payload = createPayload({
    type: seed.type,
    contentId: seed.contentId,
    clusterId: input.clusterId ?? seed.clusterId,
    bundleHint: seed.bundleHint,
    language,
    title,
    body,
    lockScreenSafe: seed.lockScreenSafe,
  });

  return {
    accepted: true,
    provider: "local_preview",
    sent: false,
    payload,
    flags: [],
  };
}

function createPayload(input: {
  type: string;
  contentId: string;
  clusterId: string;
  bundleHint: string;
  language: "en" | "id" | "ar";
  title: string;
  body: string;
  lockScreenSafe: boolean;
}): LocalPushPayload {
  return {
    id: ["local_push", input.type, input.contentId, input.language].join("_"),
    type: input.type,
    contentId: input.contentId,
    clusterId: input.clusterId,
    bundleHint: input.bundleHint,
    languageCode: input.language,
    title: input.title,
    body: input.body,
    data: {
      type: input.type,
      contentId: input.contentId,
      clusterId: input.clusterId,
      bundleHint: input.bundleHint,
    },
    lockScreenSafe: input.lockScreenSafe,
  };
}

function findSeed(type?: string, contentId?: string): PushSeed | undefined {
  return seedPushContent.find(
    (seed) => seed.type === type && seed.contentId === contentId,
  );
}

function normalizeLanguage(language?: string): "en" | "id" | "ar" {
  if (language === "id" || language === "ar") {
    return language;
  }
  return "en";
}

function evaluateLockScreenCopy(title: string, body: string): string[] {
  const copy = `${title} ${body}`;
  return guardPatterns
    .filter((guard) => guard.patterns.some((pattern) => pattern.test(copy)))
    .map((guard) => guard.flag);
}

function hasFullQuranLikeLockScreenBody(body: string): boolean {
  const arabicLetterCount = Array.from(body).filter((char) =>
    /[\u0600-\u06FF]/u.test(char),
  ).length;
  return arabicLetterCount > 120;
}
