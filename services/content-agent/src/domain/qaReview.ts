import type {
  AgentContentCandidate,
  AutomatedCheck,
  SourceItem,
} from "./schemas.js";

const supportedLanguages = new Set(["en", "id", "ar"]);

const guardPatterns: Array<{
  check: string;
  flag: string;
  patterns: RegExp[];
}> = [
  {
    check: "women_cycle_sensitive_lock_screen",
    flag: "cycle_sensitive_lock_screen",
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
    check: "guaranteed_outcome_claim",
    flag: "guaranteed_outcome_claim",
    patterns: [
      /guaranteed/i,
      /will definitely/i,
      /always be accepted/i,
      /Allah must/i,
    ],
  },
  {
    check: "shaming_tone",
    flag: "shaming_tone",
    patterns: [/lazy/i, /not enough faith/i, /sinful for resting/i],
  },
  {
    check: "fatwa_like_claim",
    flag: "fatwa_like_claim",
    patterns: [/fatwa/i, /ruling is/i, /haram for you/i, /halal for you/i],
  },
];

export function runCandidateQa(
  candidate: AgentContentCandidate,
  source: SourceItem | undefined,
): { riskFlags: string[]; automatedChecks: AutomatedCheck[] } {
  const checks: AutomatedCheck[] = [];
  const riskFlags: string[] = [];
  const title = stringValue(candidate.payload.lockScreenTitle);
  const body = stringValue(candidate.payload.lockScreenBody);
  const copy = `${title} ${body} ${JSON.stringify(candidate.payload)}`;

  record(
    checks,
    riskFlags,
    "source_reference_present",
    Boolean(candidate.sourceItemId || candidate.payload.sourceItemId),
    "missing_source_reference",
  );
  record(
    checks,
    riskFlags,
    "source_exists",
    Boolean(source),
    "invented_source_id",
  );
  record(
    checks,
    riskFlags,
    "source_is_approved",
    !source ||
      (source.status === "published" && source.reviewStatus === "approved"),
    "source_not_approved",
  );
  record(
    checks,
    riskFlags,
    "supported_language",
    supportedLanguages.has(candidate.language),
    "unsupported_language",
  );
  record(
    checks,
    riskFlags,
    "lock_screen_length",
    title.length <= 48 && body.length <= 120,
    "lock_screen_length",
  );
  record(
    checks,
    riskFlags,
    "full_quran_text_lock_screen",
    arabicLetterCount(body) <= 120,
    "full_quran_text_lock_screen",
  );
  record(
    checks,
    riskFlags,
    "auto_publish_attempt",
    !hasPublishedOrApprovedMarker(candidate),
    "auto_publish_attempt",
  );
  record(
    checks,
    riskFlags,
    "fcm_apns_send_attempt",
    !hasPushSendAttempt(candidate),
    "fcm_apns_send_attempt",
  );
  record(
    checks,
    riskFlags,
    "generated_quran_marker",
    !hasGeneratedQuranMarker(candidate, copy),
    "generated_quran_marker",
  );
  record(
    checks,
    riskFlags,
    "generated_hadith_marker",
    !hasGeneratedHadithMarker(candidate, copy),
    "generated_hadith_marker",
  );

  for (const guard of guardPatterns) {
    record(
      checks,
      riskFlags,
      guard.check,
      !guard.patterns.some((pattern) => pattern.test(copy)),
      guard.flag,
    );
  }

  return { riskFlags: [...new Set(riskFlags)], automatedChecks: checks };
}

function record(
  checks: AutomatedCheck[],
  riskFlags: string[],
  check: string,
  passed: boolean,
  flag: string,
): void {
  checks.push({ check, passed, flag: passed ? undefined : flag });
  if (!passed) {
    riskFlags.push(flag);
  }
}

function stringValue(value: unknown): string {
  return typeof value === "string" ? value : "";
}

function arabicLetterCount(value: string): number {
  return Array.from(value).filter((char) => /[\u0600-\u06FF]/u.test(char))
    .length;
}

function hasPublishedOrApprovedMarker(
  candidate: AgentContentCandidate,
): boolean {
  const values = [
    candidate.payload.cmsStatus,
    candidate.payload.status,
    candidate.payload.reviewStatus,
    candidate.reviewStatus,
  ].map((value) => String(value ?? "").toLowerCase());
  return values.includes("published") || values.includes("approved");
}

function hasPushSendAttempt(candidate: AgentContentCandidate): boolean {
  return Boolean(
    candidate.payload.sendFcm ||
    candidate.payload.sendFCM ||
    candidate.payload.sendApns ||
    candidate.payload.sendAPNs ||
    candidate.payload.fcmPayload ||
    candidate.payload.apnsPayload,
  );
}

function hasGeneratedQuranMarker(
  candidate: AgentContentCandidate,
  copy: string,
): boolean {
  return Boolean(
    candidate.payload.generatedQuranText ||
    /\[generated_quran\]/i.test(copy) ||
    /generated quran/i.test(copy) ||
    /generated qur'?an/i.test(copy),
  );
}

function hasGeneratedHadithMarker(
  candidate: AgentContentCandidate,
  copy: string,
): boolean {
  return Boolean(
    candidate.payload.generatedHadithText ||
    /\[generated_hadith\]/i.test(copy) ||
    /generated hadith/i.test(copy),
  );
}
