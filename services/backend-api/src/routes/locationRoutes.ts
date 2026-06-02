import type { IncomingMessage, ServerResponse } from "node:http";
import {
  findCities,
  getCityById,
  resolveLocation,
  supportedTimeZones,
  type LocationResolveRequest,
} from "../domain/locationCatalog.js";
import { readJson, writeJson } from "./http.js";

export class LocationRoute {
  async handle(req: IncomingMessage, res: ServerResponse): Promise<boolean> {
    const url = new URL(req.url ?? "/", "http://local");

    if (req.method === "GET" && url.pathname === "/locations/cities") {
      writeJson(res, 200, {
        results: findCities({
          query: url.searchParams.get("query") ?? undefined,
          country: url.searchParams.get("country") ?? undefined,
          locale: url.searchParams.get("locale") ?? undefined,
          limit: optionalNumber(url.searchParams.get("limit")),
        }),
      });
      return true;
    }

    const cityMatch = url.pathname.match(/^\/locations\/cities\/([^/]+)$/);
    if (req.method === "GET" && cityMatch) {
      const city = getCityById(decodeURIComponent(cityMatch[1]), url.searchParams.get("locale") ?? undefined);
      writeJson(res, city ? 200 : 404, city ?? { error: "city_not_found" });
      return true;
    }

    if (req.method === "POST" && url.pathname === "/locations/resolve") {
      const resolved = resolveLocation(await readJson<LocationResolveRequest>(req));
      const status = "error" in resolved ? 422 : 200;
      writeJson(res, status, resolved);
      return true;
    }

    if (req.method === "GET" && url.pathname === "/locations/timezones") {
      writeJson(res, 200, {
        timezones: supportedTimeZones(url.searchParams.get("country") ?? undefined),
      });
      return true;
    }

    return false;
  }
}

function optionalNumber(value: string | null): number | undefined {
  if (value == null || value.trim().length === 0) {
    return undefined;
  }
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : undefined;
}
