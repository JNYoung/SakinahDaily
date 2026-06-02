import { describe, expect, it } from "vitest";
import { previewPush } from "../src/domain/pushPreview.js";

describe("push preview", () => {
  it("creates preview-only payloads and never marks them as sent", () => {
    const result = previewPush({
      language: "ar",
      type: "daily_session",
      contentId: "session_morning_ease",
      permissionState: "granted",
    });

    expect(result).toMatchObject({
      accepted: true,
      provider: "local_preview",
      sent: false,
      payload: {
        contentId: "session_morning_ease",
        languageCode: "ar",
        data: {
          type: "daily_session",
          contentId: "session_morning_ease",
          bundleHint: "session_morning_ease",
        },
      },
    });
  });

  it("blocks missing content and unsafe lock-screen claims", () => {
    expect(
      previewPush({
        language: "en",
        type: "daily_session",
        contentId: "missing",
      }),
    ).toEqual({
      accepted: false,
      provider: "local_preview",
      sent: false,
      flags: ["missing_content"],
    });

    expect(
      previewPush({
        language: "en",
        type: "daily_session",
        contentId: "session_morning_ease",
        titleOverride: "Your dua will definitely be accepted",
      }),
    ).toEqual({
      accepted: false,
      provider: "local_preview",
      sent: false,
      flags: ["guaranteed_outcome_claim"],
    });
  });
});
