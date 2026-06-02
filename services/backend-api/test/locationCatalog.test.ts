import { describe, expect, it } from "vitest";
import {
  findCities,
  getCityById,
  resolveLocation,
  supportedTimeZones,
} from "../src/domain/locationCatalog.js";

describe("location catalog", () => {
  it("searches common cities with coordinates, timezone, and prayer method", () => {
    const results = findCities({
      query: "jakarta",
      locale: "id",
      limit: 5,
    });

    expect(results).toHaveLength(1);
    expect(results[0]).toMatchObject({
      id: "id-jakarta",
      label: "Jakarta",
      countryCode: "ID",
      timezone: "Asia/Jakarta",
      prayerCalculationMethod: "indonesia",
      source: "mvp_curated_city_catalog",
    });
    expect(results[0].coordinates).toEqual({
      latitude: -6.2088,
      longitude: 106.8456,
    });
  });

  it("filters by country and returns localized country names", () => {
    const results = findCities({ country: "SA", locale: "ar" });

    expect(results.map((city) => city.id)).toContain("sa-makkah");
    expect(results.find((city) => city.id === "sa-makkah")?.countryName).toBe(
      "السعودية",
    );
  });

  it("resolves city ids and nearest coordinates to a prayer-ready location", () => {
    expect(resolveLocation({ cityId: "ae-dubai" })).toMatchObject({
      id: "ae-dubai",
      timezone: "Asia/Dubai",
      prayerCalculationMethod: "muslim_world_league",
      resolution: "city_id",
    });

    expect(
      resolveLocation({ latitude: 24.47, longitude: 39.61 }),
    ).toMatchObject({
      id: "sa-madinah",
      timezone: "Asia/Riyadh",
      prayerCalculationMethod: "umm_al_qura",
      resolution: "nearest_city",
    });
  });

  it("does not treat timezone-only input as prayer-ready", () => {
    expect(resolveLocation({ timezone: "Asia/Jakarta" })).toEqual({
      error: "coordinates_required",
      message:
        "Prayer times need city coordinates plus timezone; timezone alone is not enough.",
    });
  });

  it("lists supported timezones from the city catalog", () => {
    expect(supportedTimeZones("ID")).toEqual([
      "Asia/Jakarta",
      "Asia/Makassar",
      "Asia/Jayapura",
    ]);
  });
});
