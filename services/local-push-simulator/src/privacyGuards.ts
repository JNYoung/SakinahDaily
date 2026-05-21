const guardPatterns: Array<{ flag: string; patterns: RegExp[] }> = [
  {
    flag: 'cycle_sensitive_lock_screen_copy',
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
    flag: 'guaranteed_outcome_claim',
    patterns: [
      /guaranteed/i,
      /will definitely/i,
      /always be accepted/i,
      /Allah must/i,
    ],
  },
  {
    flag: 'shaming_tone',
    patterns: [
      /lazy/i,
      /not enough faith/i,
      /sinful for resting/i,
    ],
  },
  {
    flag: 'fatwa_like_claim',
    patterns: [
      /fatwa/i,
      /ruling is/i,
      /haram for you/i,
      /halal for you/i,
    ],
  },
];

export function evaluateLockScreenCopy(title: string, body: string): string[] {
  const copy = `${title} ${body}`;
  return guardPatterns
    .filter((guard) => guard.patterns.some((pattern) => pattern.test(copy)))
    .map((guard) => guard.flag);
}

export function hasFullQuranLikeLockScreenBody(body: string): boolean {
  const arabicLetterCount = Array.from(body).filter((char) =>
    /[\u0600-\u06FF]/u.test(char),
  ).length;
  return arabicLetterCount > 120;
}
