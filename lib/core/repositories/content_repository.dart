import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/sakinah_models.dart';

class SeedContent {
  const SeedContent({
    required this.audioAssets,
    required this.quranAyahs,
    required this.duas,
    required this.dhikrs,
    required this.reflections,
    required this.sessions,
    required this.sourceItems,
    required this.pushTemplates,
  });

  final List<AudioAsset> audioAssets;
  final List<QuranAyah> quranAyahs;
  final List<DuaItem> duas;
  final List<DhikrItem> dhikrs;
  final List<ReflectionItem> reflections;
  final List<DailySession> sessions;
  final List<SourceItem> sourceItems;
  final List<PushTemplate> pushTemplates;

  factory SeedContent.fromJson(Map<String, dynamic> json) {
    return SeedContent(
      audioAssets: (json['audioAssets'] as List<dynamic>)
          .map((item) => AudioAsset.fromJson(item))
          .toList(),
      quranAyahs: (json['quranAyahs'] as List<dynamic>)
          .map((item) => QuranAyah.fromJson(item))
          .toList(),
      duas: (json['duas'] as List<dynamic>)
          .map((item) => DuaItem.fromJson(item))
          .toList(),
      dhikrs: (json['dhikrs'] as List<dynamic>)
          .map((item) => DhikrItem.fromJson(item))
          .toList(),
      reflections: (json['reflections'] as List<dynamic>)
          .map((item) => ReflectionItem.fromJson(item))
          .toList(),
      sessions: (json['sessions'] as List<dynamic>)
          .map((item) => DailySession.fromJson(item))
          .toList(),
      sourceItems: (json['sourceItems'] as List<dynamic>)
          .map((item) => SourceItem.fromJson(item))
          .toList(),
      pushTemplates: (json['pushTemplates'] as List<dynamic>)
          .map((item) => PushTemplate.fromJson(item))
          .toList(),
    );
  }

  static SeedContent demo() {
    return SeedContent.fromJson(jsonDecode(_demoJson) as Map<String, dynamic>);
  }
}

abstract class ContentRepository {
  List<DailySession> getDailySessions();
  DailySession? getDailySession(String id);
  List<DuaItem> getDuas();
  DuaItem? getDua(String id);
  List<DhikrItem> getDhikrs();
  DhikrItem? getDhikr(String id);
  List<QuranAyah> getQuranAyahs();
  QuranAyah? getQuranAyah(String verseKey);
  ReflectionItem? getReflection(String id);
  List<SourceItem> getSourceItems();
  List<PushTemplate> getPushTemplates();
  AudioAsset? getAudioAsset(String id);
}

class SeedContentRepository implements ContentRepository {
  SeedContentRepository(this.content);

  final SeedContent content;

  static Future<SeedContentRepository> loadFromAssets({
    AssetBundle? bundle,
  }) async {
    final raw = await (bundle ?? rootBundle).loadString(
      'assets/content/seed_content.json',
    );
    return SeedContentRepository(
      SeedContent.fromJson(jsonDecode(raw) as Map<String, dynamic>),
    );
  }

  @override
  List<DailySession> getDailySessions() {
    return content.sessions.where((session) => session.isApproved).toList();
  }

  @override
  DailySession? getDailySession(String id) {
    return getDailySessions().where((session) => session.id == id).firstOrNull;
  }

  @override
  List<DuaItem> getDuas() {
    return content.duas.where((dua) => dua.isApproved).toList();
  }

  @override
  DuaItem? getDua(String id) {
    return getDuas().where((dua) => dua.id == id).firstOrNull;
  }

  @override
  List<DhikrItem> getDhikrs() {
    return content.dhikrs.where((dhikr) => dhikr.isApproved).toList();
  }

  @override
  DhikrItem? getDhikr(String id) {
    return getDhikrs().where((dhikr) => dhikr.id == id).firstOrNull;
  }

  @override
  List<QuranAyah> getQuranAyahs() {
    return content.quranAyahs.where((ayah) => ayah.isApproved).toList();
  }

  @override
  QuranAyah? getQuranAyah(String verseKey) {
    return getQuranAyahs()
        .where((ayah) => ayah.verseKey == verseKey)
        .firstOrNull;
  }

  @override
  ReflectionItem? getReflection(String id) {
    return content.reflections
        .where(
          (reflection) =>
              reflection.status == ContentStatus.published &&
              reflection.reviewStatus == ReviewStatus.approved &&
              reflection.id == id,
        )
        .firstOrNull;
  }

  @override
  List<SourceItem> getSourceItems() {
    return content.sourceItems.where((item) => item.isApproved).toList();
  }

  @override
  List<PushTemplate> getPushTemplates() {
    return content.pushTemplates
        .where((template) => template.isApproved)
        .toList();
  }

  @override
  AudioAsset? getAudioAsset(String id) {
    return content.audioAssets
        .where((audio) => audio.approved && audio.id == id)
        .firstOrNull;
  }
}

class CmsContentRepository extends SeedContentRepository {
  CmsContentRepository(super.content);
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

const _demoJson = r'''
{
  "audioAssets": [
    {
      "id": "audio_fatiha_minshawi",
      "reciterName": "Muhammad Siddiq al-Minshawi",
      "bgmAllowed": false,
      "approved": true,
      "url": "",
      "sha256": ""
    }
  ],
  "quranAyahs": [
    {
      "verseKey": "1:1",
      "surah": 1,
      "ayah": 1,
      "arabicText": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
      "translations": {
        "en": "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
        "id": "Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.",
        "ar": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
      },
      "source": "Quran 1:1 · Tanzil Arabic · Saheeh International EN · Kemenag RI ID",
      "status": "published",
      "reviewStatus": "approved",
      "audioAssetId": "audio_fatiha_minshawi"
    },
    {
      "verseKey": "94:5",
      "surah": 94,
      "ayah": 5,
      "arabicText": "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا",
      "translations": {
        "en": "For indeed, with hardship will be ease.",
        "id": "Maka sesungguhnya bersama kesulitan ada kemudahan.",
        "ar": "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا"
      },
      "source": "Quran 94:5 · Tanzil Arabic · Saheeh International EN · Kemenag RI ID",
      "status": "published",
      "reviewStatus": "approved",
      "audioAssetId": "audio_fatiha_minshawi"
    },
    {
      "verseKey": "13:28",
      "surah": 13,
      "ayah": 28,
      "arabicText": "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
      "translations": {
        "en": "Unquestionably, by the remembrance of Allah hearts are assured.",
        "id": "Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram.",
        "ar": "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ"
      },
      "source": "Quran 13:28 · Tanzil Arabic · Saheeh International EN · Kemenag RI ID",
      "status": "published",
      "reviewStatus": "approved",
      "audioAssetId": "audio_fatiha_minshawi"
    }
  ],
  "duas": [
    {
      "id": "dua_rabbana_atina",
      "category": "quranic",
      "arabicText": "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً",
      "transliteration": "Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanah",
      "translations": {
        "en": "Our Lord, give us good in this world and good in the Hereafter.",
        "id": "Ya Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat.",
        "ar": "دعاء لطلب الخير في الدنيا والآخرة."
      },
      "source": "Quran 2:201",
      "status": "published",
      "reviewStatus": "approved",
      "isCycleSensitive": false
    },
    {
      "id": "dua_guidance",
      "category": "morning",
      "arabicText": "اللَّهُمَّ اهْدِنِي وَسَدِّدْنِي",
      "transliteration": "Allahumma ihdini wa saddidni",
      "translations": {
        "en": "O Allah, guide me and keep me upright.",
        "id": "Ya Allah, bimbinglah aku dan luruskanlah aku.",
        "ar": "دعاء للهداية والسداد."
      },
      "source": "Sahih Muslim",
      "status": "published",
      "reviewStatus": "approved",
      "isCycleSensitive": false
    },
    {
      "id": "dua_heart",
      "category": "reflection",
      "arabicText": "يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ",
      "transliteration": "Ya muqallibal-qulub thabbit qalbi ala dinik",
      "translations": {
        "en": "O Turner of hearts, keep my heart firm upon Your religion.",
        "id": "Wahai Pembolak-balik hati, teguhkan hatiku di atas agama-Mu.",
        "ar": "دعاء للثبات."
      },
      "source": "Jami at-Tirmidhi",
      "status": "published",
      "reviewStatus": "approved",
      "isCycleSensitive": false
    },
    {
      "id": "dua_ease",
      "category": "difficulty",
      "arabicText": "اللَّهُمَّ لَا سَهْلَ إِلَّا مَا جَعَلْتَهُ سَهْلًا",
      "transliteration": "Allahumma la sahla illa ma ja'altahu sahla",
      "translations": {
        "en": "O Allah, nothing is easy except what You make easy.",
        "id": "Ya Allah, tidak ada yang mudah kecuali yang Engkau mudahkan.",
        "ar": "دعاء عند الصعوبة."
      },
      "source": "Ibn Hibban",
      "status": "published",
      "reviewStatus": "approved",
      "isCycleSensitive": false
    },
    {
      "id": "dua_rest",
      "category": "evening",
      "arabicText": "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا",
      "transliteration": "Bismika Allahumma amutu wa ahya",
      "translations": {
        "en": "In Your name, O Allah, I die and I live.",
        "id": "Dengan nama-Mu ya Allah, aku mati dan aku hidup.",
        "ar": "ذكر قبل النوم."
      },
      "source": "Sahih al-Bukhari",
      "status": "published",
      "reviewStatus": "approved",
      "isCycleSensitive": false
    }
  ],
  "dhikrs": [
    {
      "id": "dhikr_subhanallah",
      "category": "morning",
      "title": {"en": "Tasbih", "id": "Tasbih", "ar": "التسبيح"},
      "arabicText": "سُبْحَانَ اللَّهِ",
      "transliteration": "Subhanallah",
      "translations": {"en": "Glory be to Allah.", "id": "Mahasuci Allah.", "ar": "تنزيه الله."},
      "targetCount": 33,
      "source": "Sahih Muslim",
      "status": "published",
      "reviewStatus": "approved"
    },
    {
      "id": "dhikr_alhamdulillah",
      "category": "gratitude",
      "title": {"en": "Tahmid", "id": "Tahmid", "ar": "التحميد"},
      "arabicText": "الْحَمْدُ لِلَّهِ",
      "transliteration": "Alhamdulillah",
      "translations": {"en": "All praise is for Allah.", "id": "Segala puji bagi Allah.", "ar": "حمد الله."},
      "targetCount": 33,
      "source": "Sahih Muslim",
      "status": "published",
      "reviewStatus": "approved"
    },
    {
      "id": "dhikr_allahu_akbar",
      "category": "morning",
      "title": {"en": "Takbir", "id": "Takbir", "ar": "التكبير"},
      "arabicText": "اللَّهُ أَكْبَرُ",
      "transliteration": "Allahu akbar",
      "translations": {"en": "Allah is the Greatest.", "id": "Allah Mahabesar.", "ar": "تعظيم الله."},
      "targetCount": 34,
      "source": "Sahih Muslim",
      "status": "published",
      "reviewStatus": "approved"
    },
    {
      "id": "dhikr_istighfar",
      "category": "forgiveness",
      "title": {"en": "Istighfar", "id": "Istighfar", "ar": "الاستغفار"},
      "arabicText": "أَسْتَغْفِرُ اللَّهَ",
      "transliteration": "Astaghfirullah",
      "translations": {"en": "I seek Allah's forgiveness.", "id": "Aku memohon ampun kepada Allah.", "ar": "طلب المغفرة."},
      "targetCount": 33,
      "source": "Sahih Muslim",
      "status": "published",
      "reviewStatus": "approved"
    },
    {
      "id": "dhikr_lailaha",
      "category": "evening",
      "title": {"en": "Tahlil", "id": "Tahlil", "ar": "التهليل"},
      "arabicText": "لَا إِلَٰهَ إِلَّا اللَّهُ",
      "transliteration": "La ilaha illa Allah",
      "translations": {"en": "There is no deity except Allah.", "id": "Tidak ada Tuhan selain Allah.", "ar": "كلمة التوحيد."},
      "targetCount": 100,
      "source": "Sahih al-Bukhari",
      "status": "published",
      "reviewStatus": "approved"
    }
  ],
  "reflections": [
    {
      "id": "reflection_ease",
      "prompt": {"en": "Where did Allah place ease for you today?", "id": "Di mana Allah memberi kemudahan untukmu hari ini?", "ar": "أين وجدت اليسر اليوم؟"},
      "status": "published",
      "reviewStatus": "approved"
    }
  ],
  "sessions": [
    {
      "id": "session_morning_ease",
      "title": {"en": "Morning Ease", "id": "Ketenangan Pagi", "ar": "يسر الصباح"},
      "subtitle": {"en": "A short path through intention, Quran, Dua, and Dhikr.", "id": "Jalur singkat melalui niat, Quran, doa, dan dzikir.", "ar": "مسار قصير للنية والقرآن والدعاء والذكر."},
      "status": "published",
      "reviewStatus": "approved",
      "steps": [
        {"id": "intention", "type": "intention", "title": {"en": "Set intention", "id": "Tata niat", "ar": "استحضار النية"}},
        {"id": "quran", "type": "quran", "contentId": "94:5", "title": {"en": "Listen to Quran", "id": "Dengarkan Quran", "ar": "استماع القرآن"}},
        {"id": "reflection", "type": "reflection", "contentId": "reflection_ease", "title": {"en": "Reflect", "id": "Renungkan", "ar": "تأمل"}},
        {"id": "dua", "type": "dua", "contentId": "dua_ease", "title": {"en": "Make Dua", "id": "Berdoa", "ar": "الدعاء"}},
        {"id": "dhikr", "type": "dhikr", "contentId": "dhikr_subhanallah", "targetCount": 33, "title": {"en": "Dhikr counter", "id": "Penghitung dzikir", "ar": "عداد الذكر"}},
        {"id": "complete", "type": "completion", "title": {"en": "Complete", "id": "Selesai", "ar": "إتمام"}}
      ]
    }
  ],
  "sourceItems": [
    {
      "id": "source_ease",
      "clusterId": "ease",
      "ritualMoment": "morning",
      "status": "published",
      "reviewStatus": "approved",
      "cycleSensitiveHidden": false,
      "translations": {"en": "A calm reminder that hardship is held with ease.", "id": "Pengingat lembut bahwa kesulitan bersama kemudahan.", "ar": "تذكير هادئ بأن مع العسر يسرا."}
    },
    {
      "id": "source_private_rest",
      "clusterId": "rest",
      "ritualMoment": "evening",
      "status": "published",
      "reviewStatus": "approved",
      "cycleSensitiveHidden": true,
      "translations": {"en": "A private rest reminder for sensitive days.", "id": "Pengingat istirahat privat untuk hari sensitif.", "ar": "تذكير خاص بالراحة في الأيام الحساسة."}
    }
  ],
  "pushTemplates": [
    {
      "id": "push_morning_soft",
      "ritualMoment": "morning",
      "title": {"en": "Begin softly", "id": "Mulai dengan lembut", "ar": "ابدأ برفق"},
      "body": {"en": "A short Sakinah session is ready.", "id": "Sesi Sakinah singkat sudah siap.", "ar": "جلسة سكينة قصيرة جاهزة."},
      "status": "published",
      "reviewStatus": "approved",
      "cycleSensitiveHidden": false
    },
    {
      "id": "push_evening_private",
      "ritualMoment": "evening",
      "title": {"en": "A quiet evening", "id": "Malam yang tenang", "ar": "مساء هادئ"},
      "body": {"en": "Keep this reminder private and gentle.", "id": "Jaga pengingat ini tetap privat dan lembut.", "ar": "ليكن هذا التذكير خاصا ولطيفا."},
      "status": "published",
      "reviewStatus": "approved",
      "cycleSensitiveHidden": true
    }
  ]
}
''';
