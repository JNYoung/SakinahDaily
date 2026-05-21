export type SupportedLanguage = 'en' | 'id' | 'ar';
export type PushType = 'daily_session' | 'dua' | 'dhikr' | 'quran';

export type LocalizedCopy = Record<SupportedLanguage, string>;

export interface SeedContentItem {
  id: string;
  type: PushType;
  clusterId: string;
  bundleHint: string;
  title: LocalizedCopy;
  body: LocalizedCopy;
  lockScreenSafe: boolean;
}

export const seedContent: SeedContentItem[] = [
  {
    id: 'session_morning_ease',
    type: 'daily_session',
    clusterId: 'calm_through_dhikr',
    bundleHint: 'daily_session_detail_session_morning_ease',
    title: {
      en: 'Begin softly',
      id: 'Mulai dengan lembut',
      ar: 'ابدأ برفق',
    },
    body: {
      en: 'A short Sakinah session is ready.',
      id: 'Sesi Sakinah singkat sudah siap.',
      ar: 'جلسة سكينة قصيرة جاهزة.',
    },
    lockScreenSafe: true,
  },
  {
    id: 'dua_ease',
    type: 'dua',
    clusterId: 'calm_through_dhikr',
    bundleHint: 'dua_detail_dua_ease',
    title: {
      en: 'A gentle dua',
      id: 'Doa yang lembut',
      ar: 'دعاء لطيف',
    },
    body: {
      en: 'Your saved dua is ready.',
      id: 'Doa tersimpan sudah siap.',
      ar: 'دعاؤك المحفوظ جاهز.',
    },
    lockScreenSafe: true,
  },
];

export function findSeedContent(type: string, contentId: string) {
  return seedContent.find((item) => item.type === type && item.id === contentId);
}

export function normalizeLanguage(language: unknown): SupportedLanguage {
  if (language === 'id' || language === 'ar') {
    return language;
  }
  return 'en';
}
