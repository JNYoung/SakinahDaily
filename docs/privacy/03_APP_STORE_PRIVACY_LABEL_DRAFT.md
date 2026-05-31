# App Store Privacy Label Draft

Status: Draft for legal/store review. Do not submit as final without review.

## Current MVP Candidate Notes

| Area | Draft interpretation | Review note |
|---|---|---|
| Local-only preferences | Candidate for Data Not Collected when not transmitted | Confirm Apple treatment of local-only settings |
| Prayer device/manual/preset location | Local-only in MVP | v0.1 uses foreground coarse device location with manual fallback; final Location label needs store/legal review |
| Women's Ibadah Mode state | Local-only high sensitivity | If ever transmitted, treat as Sensitive Info concern |
| Remote content request metadata | Potential Data Not Linked to User if logged without account | Confirm server/CDN logging behavior |
| Content cache | Local-only app data | Not user-submitted content |
| Notifications | Permission/capability, local scheduling where possible | Copy must avoid sensitive lock-screen text |
| Analytics/crash reporting | Not implemented | Do not declare until added and reviewed |
| Ads/tracking | Not implemented | No ATT prompt in MVP |
| Account/payment data | Not implemented | Reassess before adding login or subscription |

## Implementation Guardrails

- Do not claim final compliance from this draft.
- Do not claim "anonymous" for remote logs.
- Keep Women's Ibadah Mode exact status out of remote content requests.
- Keep prayer location out of remote content requests in MVP.
- Review privacy labels again before enabling any third-party telemetry SDK.
