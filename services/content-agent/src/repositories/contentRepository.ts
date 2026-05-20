import type { SourceItem } from "../domain/schemas.js";

export class ContentRepository {
  private readonly sources: SourceItem[];

  constructor(sources = seedSources) {
    this.sources = sources;
  }

  listSourceItems(): SourceItem[] {
    return [...this.sources];
  }

  getSourceItem(id: string): SourceItem | undefined {
    return this.sources.find((source) => source.id === id);
  }
}

export const seedSources: SourceItem[] = [
  {
    id: "source_ease_en",
    clusterId: "ease",
    ritualMoment: "morning",
    status: "published",
    reviewStatus: "approved",
    language: "en",
    text: "A calm reminder that hardship is held with ease.",
    sourceLabel: "Quran 94:5",
    sourceUrl: "https://quran.com/94/5",
    contentKind: "reminder"
  },
  {
    id: "source_ease_id",
    clusterId: "ease",
    ritualMoment: "morning",
    status: "published",
    reviewStatus: "approved",
    language: "id",
    text: "Pengingat lembut bahwa kesulitan bersama kemudahan.",
    sourceLabel: "Quran 94:5",
    sourceUrl: "https://quran.com/94/5",
    contentKind: "reminder"
  },
  {
    id: "dua_open_chest_en",
    clusterId: "dua-open-chest",
    ritualMoment: "morning",
    status: "published",
    reviewStatus: "approved",
    language: "en",
    text: "A sourced dua for focus and ease before work or study.",
    sourceLabel: "Quran 20:25-28",
    sourceUrl: "https://quran.com/20/25-28",
    contentKind: "dua",
    arabicText: "رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي يَفْقَهُوا قَوْلِي",
    transliteration: "Rabbi ishrah li sadri wa yassir li amri wahlul uqdatan min lisani yafqahu qawli",
    meaningSummary: "My Lord, open my chest, ease my task, and make my speech understood."
  },
  {
    id: "dua_goodness_en",
    clusterId: "dua-goodness",
    ritualMoment: "morning",
    status: "published",
    reviewStatus: "approved",
    language: "en",
    text: "A sourced dua asking for good in this life and the next.",
    sourceLabel: "Quran 2:201",
    sourceUrl: "https://quran.com/2/201",
    contentKind: "dua",
    arabicText: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
    transliteration: "Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina adhaban-nar",
    meaningSummary: "Our Lord, grant us good in this world and the Hereafter, and protect us from the Fire."
  },
  {
    id: "dua_forgiveness_en",
    clusterId: "dua-forgiveness",
    ritualMoment: "evening",
    status: "published",
    reviewStatus: "approved",
    language: "en",
    text: "A sourced dua for mercy and forgiveness at the end of the day.",
    sourceLabel: "Quran 7:23",
    sourceUrl: "https://quran.com/7/23",
    contentKind: "dua",
    arabicText: "رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ",
    transliteration: "Rabbana zalamna anfusana wa in lam taghfir lana wa tarhamna lanakunanna minal-khasirin",
    meaningSummary: "Our Lord, we have wronged ourselves; if You do not forgive and have mercy on us, we are lost."
  },
  {
    id: "dua_distress_en",
    clusterId: "dua-distress",
    ritualMoment: "evening",
    status: "published",
    reviewStatus: "approved",
    language: "en",
    text: "A sourced dua for returning to Allah during distress.",
    sourceLabel: "Quran 21:87",
    sourceUrl: "https://quran.com/21/87",
    contentKind: "dua",
    arabicText: "لَا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ",
    transliteration: "La ilaha illa anta subhanaka inni kuntu minaz-zalimin",
    meaningSummary: "There is no deity but You; glory be to You. I was among those who wronged themselves."
  },
  {
    id: "dua_prayer_family_en",
    clusterId: "dua-prayer-family",
    ritualMoment: "after_prayer",
    status: "published",
    reviewStatus: "approved",
    language: "en",
    text: "A sourced dua for steadfast prayer and family worship.",
    sourceLabel: "Quran 14:40",
    sourceUrl: "https://quran.com/14/40",
    contentKind: "dua",
    arabicText: "رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي رَبَّنَا وَتَقَبَّلْ دُعَاءِ",
    transliteration: "Rabbi ij'alni muqimas-salati wa min dhurriyyati rabbana wa taqabbal du'a",
    meaningSummary: "My Lord, make me and my descendants steadfast in prayer, and accept my supplication."
  },
  {
    id: "source_gratitude_en",
    clusterId: "gratitude",
    ritualMoment: "after_prayer",
    status: "published",
    reviewStatus: "approved",
    language: "en",
    text: "A short gratitude moment after prayer.",
    sourceLabel: "Reviewed editorial source",
    contentKind: "reflection"
  },
  {
    id: "source_private_rest_en",
    clusterId: "private-rest",
    ritualMoment: "evening",
    status: "published",
    reviewStatus: "approved",
    language: "en",
    text: "Private worship rest copy for sensitive days.",
    sourceLabel: "Reviewed women ibadah source",
    contentKind: "reflection",
    cycleSensitiveHidden: true
  }
];
