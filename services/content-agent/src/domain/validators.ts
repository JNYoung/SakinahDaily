import type { AgentCandidate, SourceItem } from "./schemas.js";

export const lockScreenTitleMax = 48;
export const lockScreenBodyMax = 120;

const cycleSensitiveTerms = [
  "menstruating",
  "menstruation",
  "period",
  "cycle",
  "postpartum",
  "nifas",
  "haidh",
  "hayd"
];

const guaranteedClaims = [
  "guaranteed",
  "will definitely",
  "always be accepted",
  "allah must",
  "you will be forgiven"
];

const shamingTerms = [
  "lazy",
  "sinful for resting",
  "not enough faith",
  "bad muslim"
];

const fatwaTerms = [
  "fatwa",
  "ruling is",
  "haram for you",
  "halal for you",
  "obligatory for you"
];

export function validateApprovedSource(source: SourceItem | undefined): string[] {
  if (!source) {
    return ["source_missing"];
  }
  if (source.status !== "published" || source.reviewStatus !== "approved") {
    return ["source_not_approved"];
  }
  return [];
}

export function validateCandidate(
  candidate: AgentCandidate,
  options = { allowQuranOnLockScreen: false }
): string[] {
  const flags: string[] = [];
  const copy = `${candidate.lockScreenTitle} ${candidate.lockScreenBody}`.toLowerCase();

  if (
    candidate.lockScreenTitle.length > lockScreenTitleMax ||
    candidate.lockScreenBody.length > lockScreenBodyMax
  ) {
    flags.push("lock_screen_length");
  }
  if (cycleSensitiveTerms.some((term) => copy.includes(term))) {
    flags.push("cycle_sensitive_lock_screen");
  }
  if (!options.allowQuranOnLockScreen && looksLikeFullArabicQuranText(candidate.lockScreenBody)) {
    flags.push("full_quran_text_lock_screen");
  }
  if (guaranteedClaims.some((term) => copy.includes(term))) {
    flags.push("guaranteed_outcome_claim");
  }
  if (shamingTerms.some((term) => copy.includes(term))) {
    flags.push("shaming_tone");
  }
  if (fatwaTerms.some((term) => copy.includes(term))) {
    flags.push("fatwa_like_claim");
  }

  return flags;
}

function looksLikeFullArabicQuranText(value: string): boolean {
  const arabicChars = [...value].filter((char) => /[\u0600-\u06FF]/.test(char));
  return arabicChars.length > 80;
}
