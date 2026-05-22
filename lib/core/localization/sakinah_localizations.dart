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
      'prayerLocation': 'Prayer location',
      'prayerMethod': 'Prayer method',
      'prayerReminders': 'Prayer reminders',
      'prayerReminderSubtitle': 'Permission is requested after explanation.',
      'notificationPermissionTitle': 'Enable prayer reminders?',
      'notificationPermissionBody':
          "Sakinah schedules local prayer reminders only after permission. Women's mode reminders stay privacy-safe on the lock screen.",
      'notificationPermissionAllow': 'Enable reminders',
      'notificationPermissionNotNow': 'Not now',
      'notificationPermissionDenied':
          'Notifications are off. You can enable them from system settings.',
      'notificationScheduled': 'Local prayer reminders are scheduled.',
      'womenModeSubtitle':
          'Local-only by default. Sensitive reminder copy stays private.',
      'privacy': 'Privacy',
      'privacySubtitle': "Women's mode data is not sent remotely in MVP.",
      'privacyCenterTitle': 'Privacy Center',
      'dataInventoryTitle': 'Data inventory',
      'dataInventoryBody':
          'This inventory describes MVP client data and where it is stored.',
      'dataOnDeviceTitle': 'Data we keep on this device',
      'dataCanLeaveDeviceTitle': 'Data that can leave this device',
      'localOnlyData':
          'Most preferences, prayer settings, women’s mode, and content cache stay on this device.',
      'leavesDeviceData':
          'Remote content requests may include language, market, app version, and schema version.',
      'womenModePrivacyTitle': "Women's Ibadah Mode privacy",
      'womenModePrivacyBody':
          'Women’s Ibadah Mode is designed local-first. Exact status is not sent with remote content requests.',
      'prayerLocationPrivacyTitle': 'Prayer location privacy',
      'prayerLocationPrivacyBody':
          'Prayer location uses manual or preset choices by default for prayer time calculation.',
      'notificationPrivacyTitle': 'Notifications privacy',
      'notificationPrivacyBody':
          'Prayer reminders are scheduled locally where possible, and sensitive women’s mode copy stays off the lock screen.',
      'remoteContentPrivacyTitle': 'Remote content cache',
      'remoteContentPrivacyBody':
          'Approved content bundles can be cached on this device. Remote content requests may include language, market, app version, and schema version.',
      'deleteLocalDataTitle': 'Delete local data',
      'deleteLocalDataBody':
          'Reset app preferences, women’s mode state, local content cache, and scheduled reminders on this device.',
      'deleteLocalDataKeepsSeed':
          'Bundled seed content and app files are kept. This does not contact a remote service.',
      'deleteLocalDataConfirm': 'Delete local data',
      'deleteLocalDataDeleting': 'Deleting...',
      'deleteLocalDataDialogTitle': 'Confirm local reset',
      'deleteLocalDataDialogBody':
          'This clears local preferences, cached bundles, and scheduled reminders on this device.',
      'deleteLocalDataCancel': 'Cancel',
      'deleteLocalDataSuccess':
          'Local data has been reset on this device.',
      'storePrivacyDraftTitle': 'Store data safety summary',
      'storePrivacyDraftBody':
          'Draft store declarations are documented for review before submission.',
      'privacyPolicyDraftTitle': 'Privacy policy draft',
      'privacyPolicyDraftBody':
          'A draft privacy policy exists for legal and store review.',
      'storageLocalDevice': 'Local device',
      'storageRemoteOptional': 'Remote request',
      'storageNotCollected': 'Not collected',
      'sensitivityLow': 'Low sensitivity',
      'sensitivityMedium': 'Medium sensitivity',
      'sensitivityHigh': 'High sensitivity',
      'localOnlyShort': 'Local only',
      'leavesDeviceShort': 'Leaves device',
      'userCanDeleteShort': 'User can delete',
      'privacyDataLanguagePreference': 'Language preference',
      'privacyDataLanguagePreferenceNotes':
          'Stored locally and used to choose app language and content language.',
      'privacyDataGenderModePreference': 'Gender mode preference',
      'privacyDataGenderModePreferenceNotes':
          'Stored locally for client personalization in MVP.',
      'privacyDataAudioPreference': 'Audio preference',
      'privacyDataAudioPreferenceNotes':
          'Stored locally to choose recitation-only, guidance, or text-first behavior.',
      'privacyDataPrayerSettings': 'Prayer settings',
      'privacyDataPrayerSettingsNotes':
          'Stored locally for prayer time method and calculation settings.',
      'privacyDataPrayerLocationPreset': 'Prayer location preset',
      'privacyDataPrayerLocationPresetNotes':
          'Stored locally by default as a manual or preset location choice.',
      'privacyDataNotificationEnabledState': 'Notification enabled state',
      'privacyDataNotificationEnabledStateNotes':
          'Stored locally to remember whether prayer reminders are enabled.',
      'privacyDataWomenModeState': "Women's Ibadah Mode state",
      'privacyDataWomenModeStateNotes':
          'High sensitivity. Designed local-first and not sent to remote content APIs.',
      'privacyDataLocalContentManifest': 'Local content manifest',
      'privacyDataLocalContentManifestNotes':
          'Stored locally to know which approved bundles are active.',
      'privacyDataLocalContentBundles': 'Local content bundles',
      'privacyDataLocalContentBundlesNotes':
          'Stored locally after hash, schema, published, and approved checks.',
      'privacyDataLocalRevokedContentIds': 'Local revoked content IDs',
      'privacyDataLocalRevokedContentIdsNotes':
          'Stored locally so revoked content is hidden from the client.',
      'privacyDataLocalPushDebug': 'Local push payload debug data',
      'privacyDataLocalPushDebugNotes':
          'No persistent client-side debug queue is collected in MVP.',
      'privacyDataAudioPlaybackState': 'Audio playback state',
      'privacyDataAudioPlaybackStateNotes':
          'No persistent playback history is collected in MVP.',
      'privacyDataRemoteContentApiConfig': 'Remote content API config state',
      'privacyDataRemoteContentApiConfigNotes':
          'Provider and endpoint configuration may exist locally; tokens are never displayed in Privacy Center.',
      'privacyDataRemoteContentRequestMetadata':
          'Remote content request metadata',
      'remoteContentRequestMetadataNotes':
          'Requests may include language, market, app version, and schema version only.',
      'privacyDataFutureAnalyticsCrash': 'Future analytics or crash reporting',
      'privacyDataFutureAnalyticsCrashNotes':
          'No analytics or crash-reporting SDK is implemented in MVP.',
      'privacyDataAccountData': 'Account data',
      'privacyDataAccountDataNotes': 'Account login is not implemented in MVP.',
      'privacyDataPaymentsSubscriptions': 'Payments and subscriptions',
      'privacyDataPaymentsSubscriptionsNotes':
          'Payments and subscriptions are not implemented in MVP.',
      'privacyDataAdsTracking': 'Ads or tracking',
      'privacyDataAdsTrackingNotes':
          'Ads, tracking, and ATT prompts are not implemented in MVP.',
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
      'modePreferNotToTrack': 'Prefer not to track',
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
      'pauseRecitation': 'Pause recitation',
      'textOnlyFallback': 'Text-only fallback',
      'audioUnavailable': 'Audio unavailable',
      'approvedReciter': 'approved reciter',
      'approvedReciterLabel': 'Approved reciter',
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
      'prayerLocation': 'Lokasi shalat',
      'prayerMethod': 'Metode shalat',
      'prayerReminders': 'Pengingat shalat',
      'prayerReminderSubtitle': 'Izin diminta setelah penjelasan.',
      'notificationPermissionTitle': 'Aktifkan pengingat shalat?',
      'notificationPermissionBody':
          'Sakinah menjadwalkan pengingat shalat lokal hanya setelah izin. Pengingat mode perempuan tetap aman untuk layar terkunci.',
      'notificationPermissionAllow': 'Aktifkan pengingat',
      'notificationPermissionNotNow': 'Nanti saja',
      'notificationPermissionDenied':
          'Notifikasi mati. Anda dapat mengaktifkannya dari pengaturan sistem.',
      'notificationScheduled': 'Pengingat shalat lokal telah dijadwalkan.',
      'womenModeSubtitle':
          'Lokal secara default. Salinan pengingat sensitif tetap privat.',
      'privacy': 'Privasi',
      'privacySubtitle': 'Data mode perempuan tidak dikirim jarak jauh di MVP.',
      'privacyCenterTitle': 'Pusat Privasi',
      'dataInventoryTitle': 'Inventaris data',
      'dataInventoryBody':
          'Inventaris ini menjelaskan data klien MVP dan lokasi penyimpanannya.',
      'dataOnDeviceTitle': 'Data yang disimpan di perangkat ini',
      'dataCanLeaveDeviceTitle': 'Data yang dapat keluar dari perangkat ini',
      'localOnlyData':
          'Sebagian besar preferensi, pengaturan shalat, mode perempuan, dan cache konten tetap di perangkat ini.',
      'leavesDeviceData':
          'Permintaan konten jarak jauh dapat menyertakan bahasa, pasar, versi aplikasi, dan versi skema.',
      'womenModePrivacyTitle': 'Privasi Mode Ibadah Perempuan',
      'womenModePrivacyBody':
          'Mode Ibadah Perempuan dirancang lokal terlebih dahulu. Status persis tidak dikirim dengan permintaan konten jarak jauh.',
      'prayerLocationPrivacyTitle': 'Privasi lokasi shalat',
      'prayerLocationPrivacyBody':
          'Lokasi shalat memakai pilihan manual atau preset secara default untuk perhitungan waktu shalat.',
      'notificationPrivacyTitle': 'Privasi notifikasi',
      'notificationPrivacyBody':
          'Pengingat shalat dijadwalkan lokal bila memungkinkan, dan teks sensitif mode perempuan tidak tampil di layar terkunci.',
      'remoteContentPrivacyTitle': 'Cache konten jarak jauh',
      'remoteContentPrivacyBody':
          'Bundle konten yang disetujui dapat disimpan di perangkat ini. Permintaan konten jarak jauh dapat menyertakan bahasa, pasar, versi aplikasi, dan versi skema.',
      'deleteLocalDataTitle': 'Hapus data lokal',
      'deleteLocalDataBody':
          'Reset preferensi aplikasi, status mode perempuan, cache konten lokal, dan pengingat terjadwal di perangkat ini.',
      'deleteLocalDataKeepsSeed':
          'Konten seed bawaan dan file aplikasi tetap ada. Ini tidak menghubungi layanan jarak jauh.',
      'deleteLocalDataConfirm': 'Hapus data lokal',
      'deleteLocalDataDeleting': 'Menghapus...',
      'deleteLocalDataDialogTitle': 'Konfirmasi reset lokal',
      'deleteLocalDataDialogBody':
          'Ini menghapus preferensi lokal, bundle cache, dan pengingat terjadwal di perangkat ini.',
      'deleteLocalDataCancel': 'Batal',
      'deleteLocalDataSuccess':
          'Data lokal telah direset di perangkat ini.',
      'storePrivacyDraftTitle': 'Ringkasan keamanan data toko',
      'storePrivacyDraftBody':
          'Draf deklarasi toko didokumentasikan untuk ditinjau sebelum pengajuan.',
      'privacyPolicyDraftTitle': 'Draf kebijakan privasi',
      'privacyPolicyDraftBody':
          'Draf kebijakan privasi tersedia untuk peninjauan legal dan toko.',
      'storageLocalDevice': 'Perangkat lokal',
      'storageRemoteOptional': 'Permintaan jarak jauh',
      'storageNotCollected': 'Tidak dikumpulkan',
      'sensitivityLow': 'Sensitivitas rendah',
      'sensitivityMedium': 'Sensitivitas sedang',
      'sensitivityHigh': 'Sensitivitas tinggi',
      'localOnlyShort': 'Lokal saja',
      'leavesDeviceShort': 'Keluar perangkat',
      'userCanDeleteShort': 'Dapat dihapus pengguna',
      'privacyDataLanguagePreference': 'Preferensi bahasa',
      'privacyDataLanguagePreferenceNotes':
          'Disimpan lokal dan dipakai untuk memilih bahasa aplikasi dan konten.',
      'privacyDataGenderModePreference': 'Preferensi mode gender',
      'privacyDataGenderModePreferenceNotes':
          'Disimpan lokal untuk personalisasi klien di MVP.',
      'privacyDataAudioPreference': 'Preferensi audio',
      'privacyDataAudioPreferenceNotes':
          'Disimpan lokal untuk memilih tilawah saja, panduan, atau teks dahulu.',
      'privacyDataPrayerSettings': 'Pengaturan shalat',
      'privacyDataPrayerSettingsNotes':
          'Disimpan lokal untuk metode dan pengaturan perhitungan waktu shalat.',
      'privacyDataPrayerLocationPreset': 'Preset lokasi shalat',
      'privacyDataPrayerLocationPresetNotes':
          'Disimpan lokal secara default sebagai pilihan lokasi manual atau preset.',
      'privacyDataNotificationEnabledState': 'Status notifikasi aktif',
      'privacyDataNotificationEnabledStateNotes':
          'Disimpan lokal untuk mengingat apakah pengingat shalat aktif.',
      'privacyDataWomenModeState': 'Status Mode Ibadah Perempuan',
      'privacyDataWomenModeStateNotes':
          'Sensitivitas tinggi. Dirancang lokal terlebih dahulu dan tidak dikirim ke API konten jarak jauh.',
      'privacyDataLocalContentManifest': 'Manifest konten lokal',
      'privacyDataLocalContentManifestNotes':
          'Disimpan lokal untuk mengetahui bundle yang aktif dan disetujui.',
      'privacyDataLocalContentBundles': 'Bundle konten lokal',
      'privacyDataLocalContentBundlesNotes':
          'Disimpan lokal setelah pemeriksaan hash, skema, published, dan approved.',
      'privacyDataLocalRevokedContentIds': 'ID konten dicabut lokal',
      'privacyDataLocalRevokedContentIdsNotes':
          'Disimpan lokal agar konten yang dicabut disembunyikan dari klien.',
      'privacyDataLocalPushDebug': 'Data debug payload push lokal',
      'privacyDataLocalPushDebugNotes':
          'Tidak ada antrean debug klien yang persisten di MVP.',
      'privacyDataAudioPlaybackState': 'Status pemutaran audio',
      'privacyDataAudioPlaybackStateNotes':
          'Riwayat pemutaran persisten tidak dikumpulkan di MVP.',
      'privacyDataRemoteContentApiConfig': 'Status konfigurasi API konten',
      'privacyDataRemoteContentApiConfigNotes':
          'Konfigurasi provider dan endpoint dapat ada secara lokal; token tidak pernah ditampilkan di Pusat Privasi.',
      'privacyDataRemoteContentRequestMetadata':
          'Metadata permintaan konten jarak jauh',
      'remoteContentRequestMetadataNotes':
          'Permintaan hanya dapat menyertakan bahasa, pasar, versi aplikasi, dan versi skema.',
      'privacyDataFutureAnalyticsCrash': 'Analitik atau crash reporting nanti',
      'privacyDataFutureAnalyticsCrashNotes':
          'Tidak ada SDK analitik atau crash reporting yang diterapkan di MVP.',
      'privacyDataAccountData': 'Data akun',
      'privacyDataAccountDataNotes': 'Login akun belum diterapkan di MVP.',
      'privacyDataPaymentsSubscriptions': 'Pembayaran dan langganan',
      'privacyDataPaymentsSubscriptionsNotes':
          'Pembayaran dan langganan belum diterapkan di MVP.',
      'privacyDataAdsTracking': 'Iklan atau pelacakan',
      'privacyDataAdsTrackingNotes':
          'Iklan, pelacakan, dan prompt ATT belum diterapkan di MVP.',
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
      'modePreferNotToTrack': 'Tidak dilacak',
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
      'pauseRecitation': 'Jeda tilawah',
      'textOnlyFallback': 'Fallback teks saja',
      'audioUnavailable': 'Audio tidak tersedia',
      'approvedReciter': 'qari yang disetujui',
      'approvedReciterLabel': 'Qari yang disetujui',
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
      'prayerLocation': 'موقع الصلاة',
      'prayerMethod': 'طريقة الصلاة',
      'prayerReminders': 'تذكيرات الصلاة',
      'prayerReminderSubtitle': 'يطلب الإذن بعد الشرح.',
      'notificationPermissionTitle': 'تفعيل تذكيرات الصلاة؟',
      'notificationPermissionBody':
          'تجدول سكينة تذكيرات صلاة محلية بعد الإذن فقط. تبقى تذكيرات وضع النساء آمنة على شاشة القفل.',
      'notificationPermissionAllow': 'تفعيل التذكيرات',
      'notificationPermissionNotNow': 'ليس الآن',
      'notificationPermissionDenied':
          'الإشعارات متوقفة. يمكنك تفعيلها من إعدادات النظام.',
      'notificationScheduled': 'تم جدولة تذكيرات الصلاة المحلية.',
      'womenModeSubtitle': 'محلي افتراضيا. تبقى نصوص التذكير الحساسة خاصة.',
      'privacy': 'الخصوصية',
      'privacySubtitle': 'لا ترسل بيانات وضع النساء عن بعد في نسخة MVP.',
      'privacyCenterTitle': 'مركز الخصوصية',
      'dataInventoryTitle': 'قائمة البيانات',
      'dataInventoryBody':
          'تصف هذه القائمة بيانات العميل في نسخة MVP ومكان تخزينها.',
      'dataOnDeviceTitle': 'البيانات التي تبقى على هذا الجهاز',
      'dataCanLeaveDeviceTitle': 'البيانات التي قد تغادر هذا الجهاز',
      'localOnlyData':
          'تبقى معظم التفضيلات وإعدادات الصلاة ووضع النساء وذاكرة المحتوى على هذا الجهاز.',
      'leavesDeviceData':
          'قد تتضمن طلبات المحتوى اللغة والسوق وإصدار التطبيق وإصدار المخطط.',
      'womenModePrivacyTitle': 'خصوصية وضع عبادة النساء',
      'womenModePrivacyBody':
          'صمم وضع عبادة النساء ليكون محليا أولا. لا ترسل الحالة الدقيقة مع طلبات المحتوى عن بعد.',
      'prayerLocationPrivacyTitle': 'خصوصية موقع الصلاة',
      'prayerLocationPrivacyBody':
          'يستخدم موقع الصلاة اختيارات يدوية أو جاهزة افتراضيا لحساب أوقات الصلاة.',
      'notificationPrivacyTitle': 'خصوصية الإشعارات',
      'notificationPrivacyBody':
          'تجدول تذكيرات الصلاة محليا حيثما أمكن، وتبقى نصوص وضع النساء الحساسة خارج شاشة القفل.',
      'remoteContentPrivacyTitle': 'ذاكرة المحتوى عن بعد',
      'remoteContentPrivacyBody':
          'يمكن تخزين حزم المحتوى المعتمدة على هذا الجهاز. قد تتضمن طلبات المحتوى اللغة والسوق وإصدار التطبيق وإصدار المخطط.',
      'deleteLocalDataTitle': 'حذف البيانات المحلية',
      'deleteLocalDataBody':
          'إعادة ضبط تفضيلات التطبيق وحالة وضع النساء وذاكرة المحتوى المحلية والتذكيرات المجدولة على هذا الجهاز.',
      'deleteLocalDataKeepsSeed':
          'يبقى محتوى التطبيق المضمن وملفات التطبيق. لا يتصل هذا بخدمة عن بعد.',
      'deleteLocalDataConfirm': 'حذف البيانات المحلية',
      'deleteLocalDataDeleting': 'جار الحذف...',
      'deleteLocalDataDialogTitle': 'تأكيد إعادة الضبط المحلية',
      'deleteLocalDataDialogBody':
          'يمسح هذا التفضيلات المحلية والحزم المخزنة والتذكيرات المجدولة على هذا الجهاز.',
      'deleteLocalDataCancel': 'إلغاء',
      'deleteLocalDataSuccess': 'تمت إعادة ضبط البيانات المحلية على هذا الجهاز.',
      'storePrivacyDraftTitle': 'ملخص سلامة بيانات المتجر',
      'storePrivacyDraftBody':
          'تم توثيق مسودات إقرارات المتجر للمراجعة قبل الإرسال.',
      'privacyPolicyDraftTitle': 'مسودة سياسة الخصوصية',
      'privacyPolicyDraftBody':
          'توجد مسودة سياسة خصوصية للمراجعة القانونية ومراجعة المتجر.',
      'storageLocalDevice': 'الجهاز المحلي',
      'storageRemoteOptional': 'طلب عن بعد',
      'storageNotCollected': 'لا تجمع',
      'sensitivityLow': 'حساسية منخفضة',
      'sensitivityMedium': 'حساسية متوسطة',
      'sensitivityHigh': 'حساسية عالية',
      'localOnlyShort': 'محلي فقط',
      'leavesDeviceShort': 'يغادر الجهاز',
      'userCanDeleteShort': 'يمكن للمستخدم حذفه',
      'privacyDataLanguagePreference': 'تفضيل اللغة',
      'privacyDataLanguagePreferenceNotes':
          'يخزن محليا لاختيار لغة التطبيق ولغة المحتوى.',
      'privacyDataGenderModePreference': 'تفضيل وضع الجنس',
      'privacyDataGenderModePreferenceNotes':
          'يخزن محليا لتخصيص العميل في نسخة MVP.',
      'privacyDataAudioPreference': 'تفضيل الصوت',
      'privacyDataAudioPreferenceNotes':
          'يخزن محليا لاختيار التلاوة فقط أو الإرشاد أو النص أولا.',
      'privacyDataPrayerSettings': 'إعدادات الصلاة',
      'privacyDataPrayerSettingsNotes':
          'تخزن محليا لطريقة حساب أوقات الصلاة وإعداداتها.',
      'privacyDataPrayerLocationPreset': 'موقع الصلاة الجاهز',
      'privacyDataPrayerLocationPresetNotes':
          'يخزن محليا افتراضيا كاختيار يدوي أو جاهز للموقع.',
      'privacyDataNotificationEnabledState': 'حالة تفعيل الإشعارات',
      'privacyDataNotificationEnabledStateNotes':
          'تخزن محليا لتذكر ما إذا كانت تذكيرات الصلاة مفعلة.',
      'privacyDataWomenModeState': 'حالة وضع عبادة النساء',
      'privacyDataWomenModeStateNotes':
          'حساسية عالية. صممت محلية أولا ولا ترسل إلى واجهات المحتوى عن بعد.',
      'privacyDataLocalContentManifest': 'بيان المحتوى المحلي',
      'privacyDataLocalContentManifestNotes':
          'يخزن محليا لمعرفة الحزم المعتمدة النشطة.',
      'privacyDataLocalContentBundles': 'حزم المحتوى المحلية',
      'privacyDataLocalContentBundlesNotes':
          'تخزن محليا بعد فحص البصمة والمخطط والنشر والاعتماد.',
      'privacyDataLocalRevokedContentIds': 'معرفات المحتوى الملغى محليا',
      'privacyDataLocalRevokedContentIdsNotes':
          'تخزن محليا حتى يخفى المحتوى الملغى من العميل.',
      'privacyDataLocalPushDebug': 'بيانات تصحيح رسائل الدفع المحلية',
      'privacyDataLocalPushDebugNotes':
          'لا تجمع قائمة تصحيح مستمرة على العميل في نسخة MVP.',
      'privacyDataAudioPlaybackState': 'حالة تشغيل الصوت',
      'privacyDataAudioPlaybackStateNotes':
          'لا يجمع سجل تشغيل مستمر في نسخة MVP.',
      'privacyDataRemoteContentApiConfig': 'حالة إعداد واجهة المحتوى',
      'privacyDataRemoteContentApiConfigNotes':
          'قد توجد إعدادات المزود والنقطة محليا؛ لا تعرض الرموز في مركز الخصوصية.',
      'privacyDataRemoteContentRequestMetadata': 'بيانات طلب المحتوى عن بعد',
      'remoteContentRequestMetadataNotes':
          'قد تتضمن الطلبات اللغة والسوق وإصدار التطبيق وإصدار المخطط فقط.',
      'privacyDataFutureAnalyticsCrash': 'تحليلات أو تقارير أعطال مستقبلية',
      'privacyDataFutureAnalyticsCrashNotes':
          'لا توجد SDK للتحليلات أو تقارير الأعطال في نسخة MVP.',
      'privacyDataAccountData': 'بيانات الحساب',
      'privacyDataAccountDataNotes': 'تسجيل الدخول غير مطبق في نسخة MVP.',
      'privacyDataPaymentsSubscriptions': 'المدفوعات والاشتراكات',
      'privacyDataPaymentsSubscriptionsNotes':
          'المدفوعات والاشتراكات غير مطبقة في نسخة MVP.',
      'privacyDataAdsTracking': 'إعلانات أو تتبع',
      'privacyDataAdsTrackingNotes':
          'الإعلانات والتتبع ومطالبة ATT غير مطبقة في نسخة MVP.',
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
      'modePreferNotToTrack': 'أفضل عدم التتبع',
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
      'pauseRecitation': 'إيقاف التلاوة مؤقتا',
      'textOnlyFallback': 'الرجوع إلى النص فقط',
      'audioUnavailable': 'الصوت غير متاح',
      'approvedReciter': 'قارئ معتمد',
      'approvedReciterLabel': 'قارئ معتمد',
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
