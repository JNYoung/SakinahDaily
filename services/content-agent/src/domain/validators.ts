import type { AgentCandidate, SourceItem } from "./schemas.js";

const cycleSensitiveTerms = [
  "menstruating",
  "menstruation",
  "period",
  "cycle",
  "postpartum",
  "nifas",
  "haidh"
];

const guaranteedClaims = [
  "guaranteed",
  "will definitely",
  "always be accepted",
  "allah must"
];

const shamingTerms = ["lazy", "sinful for resting", "not enough faith"];
const fatwaTerms = ["fatwa", "ruling is", "haram for you", "halal for you"];

export function validateApprovedSource(source: SourceItem): string[] {
  const flags: string[] = [];
  if (source.status !== "published" || source.reviewStatus !== "approved") {
    flags.push("source_not_approved");
  }
  return flags;
}

export function validateCandidate(candidate: AgentCandidate, options = { allowQuranOnLockScreen: false }): string[] {
  const flags: string[] = [];
  const copy = `${candidate.lockScreenTitle} ${candidate.lockScreenBody}`.toLowerCase();

  if (candidate.lockScreenTitle.length > 48 || candidate.lockScreenBody.length > 120) {
    flags.push("lock_screen_length");
  }
  if (cycleSensitiveTerms.some((term) => copy.includes(term))) {
    flags.push("cycle_sensitive_lock_screen");
  }
  if (!options.allowQuranOnLockScreen && looksLikeFullArabicVerse(candidate.lockScreenBody)) {
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

function looksLikeFullArabicVerse(value: string): boolean {
  const arabicChars = [...value].filter((char) => /[\u0600-\u06FF]/.test(char));
  return arabicChars.length > 80;
}
