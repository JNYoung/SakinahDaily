import 'package:flutter/material.dart';

class SakinahLocalizations {
  const SakinahLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('id'),
    Locale('ar'),
  ];

  static const delegate = _SakinahLocalizationsDelegate();

  static SakinahLocalizations of(BuildContext context) {
    return Localizations.of<SakinahLocalizations>(
      context,
      SakinahLocalizations,
    )!;
  }

  static const _values = {
    'en': {
      'appTitle': 'Sakinah Daily',
      'onboardingTitle': 'Begin with calm worship',
      'onboardingSubtitle':
          'Choose your language and preferences for a quiet daily companion.',
      'language': 'Language',
      'genderMode': 'Personalization',
      'genderMale': 'Male',
      'genderFemale': 'Female',
      'genderPreferNotToSay': 'Prefer not to say',
      'audioPreference': 'Audio preference',
      'audioRecitationOnly': 'Recitation only',
      'audioQuietGuidance': 'Quiet guidance',
      'audioTextFirst': 'Text first',
      'prayerReminderConsent':
          'Prayer reminders ask permission only after this explanation.',
      'continueLabel': 'Continue',
      'homeGreeting': 'Assalamu alaikum',
      'homeFriend': 'Friend',
      'homeFemaleName': 'Aisha',
      'homeDateLabel': 'Tuesday · 12 Ramadan',
      'nextPrayer': 'Next prayer',
      'todaySession': "Today's Sakinah Session",
      'sessionSubtitleMeta': '7 min · Ayah · Reflection · Dua · Dhikr',
      'quickActions': 'Quick Actions',
      'startSession': 'Start session',
      'start': 'Start',
      'voiceOnly': 'Voice only',
      'home': 'Home',
      'quran': 'Quran',
      'qibla': 'Qibla',
      'tonight': 'Tonight',
      'sleepAyatKursi': 'Sleep with Ayat al-Kursi',
      'sleepSessionDescription':
          "A quiet 5-minute session with pure Qur'an recitation and soft guidance.",
      'saveTonight': 'Save tonight',
      'dua': 'Dua',
      'dhikr': 'Dhikr',
      'settings': 'Settings',
      'prayer': 'Prayer',
      'prayerMethod': 'Prayer method',
      'prayerReminders': 'Prayer reminders',
      'prayerReminderSubtitle': 'Permission is requested after explanation.',
      'womenModeSubtitle':
          'Local-only by default. Sensitive reminder copy stays private.',
      'privacy': 'Privacy',
      'privacySubtitle': "Women's mode data is not sent remotely in MVP.",
      'source': 'Source',
      'reviewed': 'Reviewed',
      'approvedContent': 'approved content',
      'draftContent': 'draft content',
      'inReviewContent': 'in review content',
      'rejectedContent': 'rejected content',
      'womenMode': "Women's Ibadah Mode",
      'womenModeDescription': 'Adjust reminders with privacy and respect.',
      'todaysMode': "Today's mode",
      'modeNormal': 'Normal',
      'modeMenstruating': 'Menstruating',
      'modePostpartum': 'Postpartum',
      'modePregnancy': 'Pregnancy',
      'dataStaysLocal': 'Data stays local by default',
      'recommendedNow': 'Recommended now',
      'gentleWorshipMoment': 'A gentle worship moment',
      'womenRecommendedDescription':
          'Dua · Dhikr · Reflection reminders without direct prayer prompts.',
      'reminderBehavior': 'Reminder behavior',
      'reminderBehaviorDescription':
          'Prayer alerts can be paused or replaced with Dua and Dhikr moments.',
      'duaUnavailable': 'Dua unavailable.',
      'makeDua': 'Make Dua',
      'duaContext': 'For focus · Before work or study',
      'saved': 'Saved',
      'arabicLabel': 'Arabic',
      'transliteration': 'Transliteration',
      'meaning': 'Meaning',
      'listen': 'Listen',
      'repeatSlowly': 'Repeat slowly',
      'session': 'Session',
      'sessionUnavailable': 'Session unavailable.',
      'next': 'Next',
      'finish': 'Finish',
      'playRecitation': 'Play recitation',
      'approvedReciter': 'approved reciter',
      'quranSafetyTitle': "Qur'an Safety",
      'quranSafetyDescription':
          "No background sound is played under Qur'an recitation.",
      'completionFallback':
          'Pause, breathe, and keep this act for Allah alone.',
      'backgroundSoundAllowed': 'Background sound allowed',
      'noBackgroundMusic': 'No background music under Quran recitation',
      'timeIn': 'in',
      'hourShort': 'h',
      'minuteShort': 'm',
      'prayerFajr': 'Fajr',
      'prayerDhuhr': 'Dhuhr',
      'prayerAsr': 'Asr',
      'prayerMaghrib': 'Maghrib',
      'prayerIsha': 'Isha',
    },
    'id': {
      'appTitle': 'Sakinah Daily',
      'onboardingTitle': 'Mulai dengan ibadah yang tenang',
      'onboardingSubtitle':
          'Pilih bahasa dan preferensi untuk pendamping harian yang lembut.',
      'language': 'Bahasa',
      'genderMode': 'Personalisasi',
      'genderMale': 'Laki-laki',
      'genderFemale': 'Perempuan',
      'genderPreferNotToSay': 'Tidak ingin menjawab',
      'audioPreference': 'Preferensi audio',
      'audioRecitationOnly': 'Tilawah saja',
      'audioQuietGuidance': 'Panduan lembut',
      'audioTextFirst': 'Utamakan teks',
      'prayerReminderConsent':
          'Pengingat shalat meminta izin hanya setelah penjelasan ini.',
      'continueLabel': 'Lanjut',
      'homeGreeting': 'Assalamu alaikum',
      'homeFriend': 'Sahabat',
      'homeFemaleName': 'Aisyah',
      'homeDateLabel': 'Selasa · 12 Ramadan',
      'nextPrayer': 'Shalat berikutnya',
      'todaySession': 'Sesi Sakinah Hari Ini',
      'sessionSubtitleMeta': '7 menit · Ayat · Refleksi · Doa · Dzikir',
      'quickActions': 'Aksi Cepat',
      'startSession': 'Mulai sesi',
      'start': 'Mulai',
      'voiceOnly': 'Suara saja',
      'home': 'Beranda',
      'quran': 'Quran',
      'qibla': 'Kiblat',
      'tonight': 'Malam ini',
      'sleepAyatKursi': 'Tidur dengan Ayat Kursi',
      'sleepSessionDescription':
          "Sesi tenang 5 menit dengan tilawah Qur'an murni dan panduan lembut.",
      'saveTonight': 'Simpan malam ini',
      'dua': 'Doa',
      'dhikr': 'Dzikir',
      'settings': 'Pengaturan',
      'prayer': 'Shalat',
      'prayerMethod': 'Metode shalat',
      'prayerReminders': 'Pengingat shalat',
      'prayerReminderSubtitle': 'Izin diminta setelah penjelasan.',
      'womenModeSubtitle':
          'Lokal secara default. Salinan pengingat sensitif tetap privat.',
      'privacy': 'Privasi',
      'privacySubtitle': 'Data mode perempuan tidak dikirim jarak jauh di MVP.',
      'source': 'Sumber',
      'reviewed': 'Ditinjau',
      'approvedContent': 'konten disetujui',
      'draftContent': 'konten draf',
      'inReviewContent': 'konten sedang ditinjau',
      'rejectedContent': 'konten ditolak',
      'womenMode': 'Mode Ibadah Perempuan',
      'womenModeDescription': 'Atur pengingat dengan privasi dan penghormatan.',
      'todaysMode': 'Mode hari ini',
      'modeNormal': 'Normal',
      'modeMenstruating': 'Menstruasi',
      'modePostpartum': 'Nifas',
      'modePregnancy': 'Kehamilan',
      'dataStaysLocal': 'Data tetap lokal secara default',
      'recommendedNow': 'Direkomendasikan sekarang',
      'gentleWorshipMoment': 'Momen ibadah yang lembut',
      'womenRecommendedDescription':
          'Pengingat doa · dzikir · refleksi tanpa ajakan shalat langsung.',
      'reminderBehavior': 'Perilaku pengingat',
      'reminderBehaviorDescription':
          'Peringatan shalat dapat dijeda atau diganti dengan momen doa dan dzikir.',
      'duaUnavailable': 'Doa tidak tersedia.',
      'makeDua': 'Berdoa',
      'duaContext': 'Untuk fokus · Sebelum bekerja atau belajar',
      'saved': 'Tersimpan',
      'arabicLabel': 'Arab',
      'transliteration': 'Transliterasi',
      'meaning': 'Makna',
      'listen': 'Dengarkan',
      'repeatSlowly': 'Ulangi perlahan',
      'session': 'Sesi',
      'sessionUnavailable': 'Sesi tidak tersedia.',
      'next': 'Berikutnya',
      'finish': 'Selesai',
      'playRecitation': 'Putar tilawah',
      'approvedReciter': 'qari yang disetujui',
      'quranSafetyTitle': 'Keamanan Qur’an',
      'quranSafetyDescription':
          'Tidak ada suara latar di bawah tilawah Qur’an.',
      'completionFallback':
          'Berhenti sejenak, bernapas, dan jaga amal ini hanya untuk Allah.',
      'backgroundSoundAllowed': 'Suara latar diizinkan',
      'noBackgroundMusic': 'Tidak ada musik latar di bawah tilawah Quran',
      'timeIn': 'dalam',
      'hourShort': 'j',
      'minuteShort': 'm',
      'prayerFajr': 'Subuh',
      'prayerDhuhr': 'Zuhur',
      'prayerAsr': 'Asar',
      'prayerMaghrib': 'Magrib',
      'prayerIsha': 'Isya',
    },
    'ar': {
      'appTitle': 'سكينة يومية',
      'onboardingTitle': 'ابدأ بعبادة هادئة',
      'onboardingSubtitle': 'اختر اللغة والتفضيلات لرفيق يومي مطمئن.',
      'language': 'اللغة',
      'genderMode': 'التخصيص',
      'genderMale': 'ذكر',
      'genderFemale': 'أنثى',
      'genderPreferNotToSay': 'أفضل عدم الإجابة',
      'audioPreference': 'تفضيل الصوت',
      'audioRecitationOnly': 'التلاوة فقط',
      'audioQuietGuidance': 'إرشاد هادئ',
      'audioTextFirst': 'النص أولا',
      'prayerReminderConsent': 'تطلب تذكيرات الصلاة الإذن بعد هذا الشرح فقط.',
      'continueLabel': 'متابعة',
      'homeGreeting': 'السلام عليكم',
      'homeFriend': 'رفيق',
      'homeFemaleName': 'عائشة',
      'homeDateLabel': 'الثلاثاء · 12 رمضان',
      'nextPrayer': 'الصلاة التالية',
      'todaySession': 'جلسة السكينة اليوم',
      'sessionSubtitleMeta': '7 دقائق · آية · تأمل · دعاء · ذكر',
      'quickActions': 'إجراءات سريعة',
      'startSession': 'ابدأ الجلسة',
      'start': 'ابدأ',
      'voiceOnly': 'الصوت فقط',
      'home': 'الرئيسية',
      'quran': 'القرآن',
      'qibla': 'القبلة',
      'tonight': 'الليلة',
      'sleepAyatKursi': 'نم مع آية الكرسي',
      'sleepSessionDescription':
          'جلسة هادئة من 5 دقائق مع تلاوة قرآن صافية وإرشاد لطيف.',
      'saveTonight': 'احفظ لليلة',
      'dua': 'الدعاء',
      'dhikr': 'الذكر',
      'settings': 'الإعدادات',
      'prayer': 'الصلاة',
      'prayerMethod': 'طريقة الصلاة',
      'prayerReminders': 'تذكيرات الصلاة',
      'prayerReminderSubtitle': 'يطلب الإذن بعد الشرح.',
      'womenModeSubtitle': 'محلي افتراضيا. تبقى نصوص التذكير الحساسة خاصة.',
      'privacy': 'الخصوصية',
      'privacySubtitle': 'لا ترسل بيانات وضع النساء عن بعد في نسخة MVP.',
      'source': 'المصدر',
      'reviewed': 'مراجعة',
      'approvedContent': 'محتوى معتمد',
      'draftContent': 'محتوى مسودة',
      'inReviewContent': 'محتوى قيد المراجعة',
      'rejectedContent': 'محتوى مرفوض',
      'womenMode': 'وضع عبادة النساء',
      'womenModeDescription': 'اضبطي التذكيرات بخصوصية واحترام.',
      'todaysMode': 'وضع اليوم',
      'modeNormal': 'عادي',
      'modeMenstruating': 'الحيض',
      'modePostpartum': 'النفاس',
      'modePregnancy': 'الحمل',
      'dataStaysLocal': 'تبقى البيانات محلية افتراضيا',
      'recommendedNow': 'موصى به الآن',
      'gentleWorshipMoment': 'لحظة عبادة لطيفة',
      'womenRecommendedDescription':
          'تذكيرات دعاء · ذكر · تأمل بدون دعوات مباشرة للصلاة.',
      'reminderBehavior': 'سلوك التذكيرات',
      'reminderBehaviorDescription':
          'يمكن إيقاف تنبيهات الصلاة أو استبدالها بلحظات دعاء وذكر.',
      'duaUnavailable': 'الدعاء غير متاح.',
      'makeDua': 'الدعاء',
      'duaContext': 'للتركيز · قبل العمل أو الدراسة',
      'saved': 'محفوظ',
      'arabicLabel': 'العربية',
      'transliteration': 'النقل الصوتي',
      'meaning': 'المعنى',
      'listen': 'استمع',
      'repeatSlowly': 'كرر ببطء',
      'session': 'الجلسة',
      'sessionUnavailable': 'الجلسة غير متاحة.',
      'next': 'التالي',
      'finish': 'إنهاء',
      'playRecitation': 'تشغيل التلاوة',
      'approvedReciter': 'قارئ معتمد',
      'quranSafetyTitle': 'سلامة القرآن',
      'quranSafetyDescription': 'لا يتم تشغيل صوت خلفي تحت تلاوة القرآن.',
      'completionFallback': 'توقف وتنفس واجعل هذا العمل لله وحده.',
      'backgroundSoundAllowed': 'الصوت الخلفي مسموح',
      'noBackgroundMusic': 'لا موسيقى خلفية تحت تلاوة القرآن',
      'timeIn': 'بعد',
      'hourShort': 'س',
      'minuteShort': 'د',
      'prayerFajr': 'الفجر',
      'prayerDhuhr': 'الظهر',
      'prayerAsr': 'العصر',
      'prayerMaghrib': 'المغرب',
      'prayerIsha': 'العشاء',
    },
  };

  String t(String key) {
    return _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;
  }

  String prayerName(String name) {
    return switch (name) {
      'Fajr' => t('prayerFajr'),
      'Dhuhr' => t('prayerDhuhr'),
      'Asr' => t('prayerAsr'),
      'Maghrib' => t('prayerMaghrib'),
      'Isha' => t('prayerIsha'),
      _ => name,
    };
  }

  String prayerCountdown(String name, int hours, int minutes) {
    return '${prayerName(name)} ${t('timeIn')} $hours${t('hourShort')} $minutes${t('minuteShort')}';
  }

  String quranVerseLabel(String verseKey) {
    return '${t('quran')} $verseKey';
  }

  String recitedBy(String reciterName) {
    return switch (locale.languageCode) {
      'id' => 'Dilantunkan oleh $reciterName',
      'ar' => 'تلاوة $reciterName',
      _ => 'Recited by $reciterName',
    };
  }

  String stepProgress(int current, int total, String stepTitle) {
    return switch (locale.languageCode) {
      'id' => 'Langkah $current dari $total · $stepTitle',
      'ar' => 'الخطوة $current من $total · $stepTitle',
      _ => 'Step $current of $total · $stepTitle',
    };
  }

  String reviewContentLabel(String reviewStatus) {
    return switch (reviewStatus) {
      'approved' => t('approvedContent'),
      'draft' => t('draftContent'),
      'inReview' => t('inReviewContent'),
      'rejected' => t('rejectedContent'),
      _ => reviewStatus,
    };
  }
}

class _SakinahLocalizationsDelegate
    extends LocalizationsDelegate<SakinahLocalizations> {
  const _SakinahLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return SakinahLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<SakinahLocalizations> load(Locale locale) async {
    return SakinahLocalizations(locale);
  }

  @override
  bool shouldReload(_SakinahLocalizationsDelegate old) => false;
}
