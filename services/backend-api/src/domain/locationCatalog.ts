export type LocaleCode = "en" | "id" | "ar";

export interface CitySearchRequest {
  query?: string;
  country?: string;
  locale?: string;
  limit?: number;
}

export interface LocationResolveRequest {
  cityId?: string;
  latitude?: number;
  longitude?: number;
  timezone?: string;
  locale?: string;
}

export interface Coordinates {
  latitude: number;
  longitude: number;
}

export interface CityCatalogEntry {
  id: string;
  label: string;
  countryCode: string;
  countryName: string;
  coordinates: Coordinates;
  timezone: string;
  prayerCalculationMethod: string;
  source: "mvp_curated_city_catalog";
  aliases: string[];
}

type CityRecord = {
  id: string;
  names: Record<LocaleCode, string>;
  countryCode: string;
  countryNames: Record<LocaleCode, string>;
  latitude: number;
  longitude: number;
  timezone: string;
  prayerCalculationMethod: string;
  aliases: string[];
  rank: number;
};

const cityCatalog: CityRecord[] = [
  city({
    id: "sa-makkah",
    names: { en: "Makkah", id: "Makkah", ar: "مكة" },
    countryCode: "SA",
    countryNames: { en: "Saudi Arabia", id: "Arab Saudi", ar: "السعودية" },
    latitude: 21.3891,
    longitude: 39.8579,
    timezone: "Asia/Riyadh",
    prayerCalculationMethod: "umm_al_qura",
    aliases: ["mecca", "makkah al mukarramah", "مكة المكرمة"],
    rank: 1,
  }),
  city({
    id: "sa-madinah",
    names: { en: "Madinah", id: "Madinah", ar: "المدينة المنورة" },
    countryCode: "SA",
    countryNames: { en: "Saudi Arabia", id: "Arab Saudi", ar: "السعودية" },
    latitude: 24.5247,
    longitude: 39.5692,
    timezone: "Asia/Riyadh",
    prayerCalculationMethod: "umm_al_qura",
    aliases: ["medina", "al madinah", "المدينة"],
    rank: 2,
  }),
  city({
    id: "sa-riyadh",
    names: { en: "Riyadh", id: "Riyadh", ar: "الرياض" },
    countryCode: "SA",
    countryNames: { en: "Saudi Arabia", id: "Arab Saudi", ar: "السعودية" },
    latitude: 24.7136,
    longitude: 46.6753,
    timezone: "Asia/Riyadh",
    prayerCalculationMethod: "umm_al_qura",
    aliases: ["riyad", "الرياض"],
    rank: 3,
  }),
  city({
    id: "sa-jeddah",
    names: { en: "Jeddah", id: "Jeddah", ar: "جدة" },
    countryCode: "SA",
    countryNames: { en: "Saudi Arabia", id: "Arab Saudi", ar: "السعودية" },
    latitude: 21.4858,
    longitude: 39.1925,
    timezone: "Asia/Riyadh",
    prayerCalculationMethod: "umm_al_qura",
    aliases: ["jiddah", "جدة"],
    rank: 4,
  }),
  city({
    id: "id-jakarta",
    names: { en: "Jakarta", id: "Jakarta", ar: "جاكرتا" },
    countryCode: "ID",
    countryNames: { en: "Indonesia", id: "Indonesia", ar: "إندونيسيا" },
    latitude: -6.2088,
    longitude: 106.8456,
    timezone: "Asia/Jakarta",
    prayerCalculationMethod: "indonesia",
    aliases: ["dki jakarta", "jakarta raya"],
    rank: 5,
  }),
  city({
    id: "id-bandung",
    names: { en: "Bandung", id: "Bandung", ar: "باندونغ" },
    countryCode: "ID",
    countryNames: { en: "Indonesia", id: "Indonesia", ar: "إندونيسيا" },
    latitude: -6.9175,
    longitude: 107.6191,
    timezone: "Asia/Jakarta",
    prayerCalculationMethod: "indonesia",
    aliases: ["kota bandung"],
    rank: 6,
  }),
  city({
    id: "id-surabaya",
    names: { en: "Surabaya", id: "Surabaya", ar: "سورابايا" },
    countryCode: "ID",
    countryNames: { en: "Indonesia", id: "Indonesia", ar: "إندونيسيا" },
    latitude: -7.2575,
    longitude: 112.7521,
    timezone: "Asia/Jakarta",
    prayerCalculationMethod: "indonesia",
    aliases: ["kota surabaya"],
    rank: 7,
  }),
  city({
    id: "id-makassar",
    names: { en: "Makassar", id: "Makassar", ar: "ماكاسار" },
    countryCode: "ID",
    countryNames: { en: "Indonesia", id: "Indonesia", ar: "إندونيسيا" },
    latitude: -5.1477,
    longitude: 119.4327,
    timezone: "Asia/Makassar",
    prayerCalculationMethod: "indonesia",
    aliases: ["ujung pandang"],
    rank: 8,
  }),
  city({
    id: "id-jayapura",
    names: { en: "Jayapura", id: "Jayapura", ar: "جايابورا" },
    countryCode: "ID",
    countryNames: { en: "Indonesia", id: "Indonesia", ar: "إندونيسيا" },
    latitude: -2.5916,
    longitude: 140.669,
    timezone: "Asia/Jayapura",
    prayerCalculationMethod: "indonesia",
    aliases: ["kota jayapura"],
    rank: 9,
  }),
  city({
    id: "ae-dubai",
    names: { en: "Dubai", id: "Dubai", ar: "دبي" },
    countryCode: "AE",
    countryNames: {
      en: "United Arab Emirates",
      id: "Uni Emirat Arab",
      ar: "الإمارات",
    },
    latitude: 25.2048,
    longitude: 55.2708,
    timezone: "Asia/Dubai",
    prayerCalculationMethod: "muslim_world_league",
    aliases: ["دبي"],
    rank: 10,
  }),
  city({
    id: "ae-abu-dhabi",
    names: { en: "Abu Dhabi", id: "Abu Dhabi", ar: "أبوظبي" },
    countryCode: "AE",
    countryNames: {
      en: "United Arab Emirates",
      id: "Uni Emirat Arab",
      ar: "الإمارات",
    },
    latitude: 24.4539,
    longitude: 54.3773,
    timezone: "Asia/Dubai",
    prayerCalculationMethod: "muslim_world_league",
    aliases: ["abu dhabi", "abudhabi", "أبو ظبي"],
    rank: 11,
  }),
  city({
    id: "qa-doha",
    names: { en: "Doha", id: "Doha", ar: "الدوحة" },
    countryCode: "QA",
    countryNames: { en: "Qatar", id: "Qatar", ar: "قطر" },
    latitude: 25.2854,
    longitude: 51.531,
    timezone: "Asia/Qatar",
    prayerCalculationMethod: "muslim_world_league",
    aliases: ["الدوحة"],
    rank: 12,
  }),
  city({
    id: "kw-kuwait-city",
    names: {
      en: "Kuwait City",
      id: "Kota Kuwait",
      ar: "مدينة الكويت",
    },
    countryCode: "KW",
    countryNames: { en: "Kuwait", id: "Kuwait", ar: "الكويت" },
    latitude: 29.3759,
    longitude: 47.9774,
    timezone: "Asia/Kuwait",
    prayerCalculationMethod: "muslim_world_league",
    aliases: ["kuwait", "مدينة الكويت"],
    rank: 13,
  }),
  city({
    id: "eg-cairo",
    names: { en: "Cairo", id: "Kairo", ar: "القاهرة" },
    countryCode: "EG",
    countryNames: { en: "Egypt", id: "Mesir", ar: "مصر" },
    latitude: 30.0444,
    longitude: 31.2357,
    timezone: "Africa/Cairo",
    prayerCalculationMethod: "egyptian",
    aliases: ["القاهرة", "al qahirah"],
    rank: 14,
  }),
];

export function findCities(request: CitySearchRequest = {}): CityCatalogEntry[] {
  const locale = normalizeLocale(request.locale);
  const query = normalizeQuery(request.query);
  const country = request.country?.trim().toUpperCase();
  const limit = clampLimit(request.limit);

  return cityCatalog
    .filter((entry) => !country || entry.countryCode === country)
    .filter((entry) => query.length === 0 || matchesQuery(entry, query))
    .sort((a, b) => scoreCity(b, query) - scoreCity(a, query) || a.rank - b.rank)
    .slice(0, limit)
    .map((entry) => toApiCity(entry, locale));
}

export function getCityById(
  cityId: string,
  locale?: string,
): CityCatalogEntry | undefined {
  const entry = cityCatalog.find((city) => city.id === cityId);
  return entry ? toApiCity(entry, normalizeLocale(locale)) : undefined;
}

export function resolveLocation(request: LocationResolveRequest):
  | (CityCatalogEntry & {
      resolution: "city_id" | "nearest_city";
      distanceKm?: number;
    })
  | { error: string; message: string } {
  const locale = normalizeLocale(request.locale);
  if (request.cityId) {
    const city = getCityById(request.cityId, locale);
    if (!city) {
      return {
        error: "city_not_found",
        message: "City was not found in the MVP location catalog.",
      };
    }
    return { ...city, resolution: "city_id" };
  }

  if (
    typeof request.latitude === "number" &&
    Number.isFinite(request.latitude) &&
    typeof request.longitude === "number" &&
    Number.isFinite(request.longitude)
  ) {
    const nearest = nearestCity({
      latitude: request.latitude,
      longitude: request.longitude,
    });
    return {
      ...toApiCity(nearest.city, locale),
      resolution: "nearest_city",
      distanceKm: Number(nearest.distanceKm.toFixed(1)),
    };
  }

  if (request.timezone) {
    return {
      error: "coordinates_required",
      message:
        "Prayer times need city coordinates plus timezone; timezone alone is not enough.",
    };
  }

  return {
    error: "location_required",
    message: "Provide cityId or latitude and longitude.",
  };
}

export function supportedTimeZones(country?: string): string[] {
  const countryCode = country?.trim().toUpperCase();
  const zones = cityCatalog
    .filter((entry) => !countryCode || entry.countryCode === countryCode)
    .map((entry) => entry.timezone);
  return [...new Set(zones)];
}

function city(entry: CityRecord): CityRecord {
  return entry;
}

function toApiCity(entry: CityRecord, locale: LocaleCode): CityCatalogEntry {
  return {
    id: entry.id,
    label: entry.names[locale] ?? entry.names.en,
    countryCode: entry.countryCode,
    countryName: entry.countryNames[locale] ?? entry.countryNames.en,
    coordinates: {
      latitude: entry.latitude,
      longitude: entry.longitude,
    },
    timezone: entry.timezone,
    prayerCalculationMethod: entry.prayerCalculationMethod,
    source: "mvp_curated_city_catalog",
    aliases: entry.aliases,
  };
}

function normalizeLocale(locale?: string): LocaleCode {
  if (locale === "id" || locale === "ar" || locale === "en") {
    return locale;
  }
  return "en";
}

function normalizeQuery(query?: string): string {
  return (query ?? "").trim().toLocaleLowerCase();
}

function clampLimit(limit?: number): number {
  if (!limit || !Number.isFinite(limit)) {
    return 20;
  }
  return Math.max(1, Math.min(Math.floor(limit), 50));
}

function matchesQuery(entry: CityRecord, query: string): boolean {
  return searchableTerms(entry).some((term) => term.includes(query));
}

function scoreCity(entry: CityRecord, query: string): number {
  if (query.length === 0) {
    return 0;
  }
  const terms = searchableTerms(entry);
  if (terms.some((term) => term === query)) {
    return 3;
  }
  if (terms.some((term) => term.startsWith(query))) {
    return 2;
  }
  if (terms.some((term) => term.includes(query))) {
    return 1;
  }
  return 0;
}

function searchableTerms(entry: CityRecord): string[] {
  return [
    entry.id,
    entry.countryCode,
    ...Object.values(entry.names),
    ...Object.values(entry.countryNames),
    ...entry.aliases,
  ].map((term) => term.toLocaleLowerCase());
}

function nearestCity(point: Coordinates): { city: CityRecord; distanceKm: number } {
  return cityCatalog
    .map((city) => ({
      city,
      distanceKm: distanceKm(point, {
        latitude: city.latitude,
        longitude: city.longitude,
      }),
    }))
    .sort((a, b) => a.distanceKm - b.distanceKm)[0];
}

function distanceKm(a: Coordinates, b: Coordinates): number {
  const earthRadiusKm = 6371;
  const dLat = radians(b.latitude - a.latitude);
  const dLon = radians(b.longitude - a.longitude);
  const lat1 = radians(a.latitude);
  const lat2 = radians(b.latitude);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon / 2) ** 2;
  return 2 * earthRadiusKm * Math.asin(Math.sqrt(h));
}

function radians(value: number): number {
  return (value * Math.PI) / 180;
}
