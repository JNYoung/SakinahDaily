# Permission Copy

Status: Draft for legal/store review.

## Notifications

In-app explanation:

> Sakinah schedules local prayer reminders only after permission. Women's mode
> reminders stay privacy-safe on the lock screen.

Store/review note: notification reminders are local where possible. Sensitive
Women's Ibadah Mode status must not appear in lock-screen copy. When Women's
Mode is enabled, reminder text should stay generic and avoid menstruation,
postpartum, cycle, or similar private terms.

## Prayer Location

In-app explanation:

> Sakinah uses your device location only to calculate prayer times and Qibla.
> If permission is denied, you can enter the location manually.

Privacy note:

> Requested while using the app. Not used for background tracking or remote
> sync.

Qibla explanation:

> Qibla uses your selected prayer location. No compass or background location
> is required.

Fallback note:

> Location permission was denied. Enter location manually instead.

Store/review note: v0.1 uses foreground coarse device location for prayer time
and Qibla setup. It does not use fine/background location, compass, or sensor
permissions. Any future fine/background location scope requires a separate
consent screen and updated store declarations.

## Remote Content

In-app explanation:

> Remote content requests may include language, market, app version, and schema
> version so the client can load approved published bundles.

Store/review note: do not describe remote requests as anonymous unless server
logging and retention have been reviewed.

## Women's Ibadah Mode

In-app explanation:

> Women's Ibadah Mode is designed local-first. Exact status is not sent with
> remote content requests.

Recommendation explanation:

> Women's Mode can adjust Home and Daily Session suggestions on this device.
> Your exact mode stays local.

Store/review note: treat any future transmission as sensitive information and
require a fresh privacy review.
