import {
  evaluateLockScreenCopy,
  hasFullQuranLikeLockScreenBody,
} from './privacyGuards';
import { findSeedContent, normalizeLanguage } from './seedContent';

export interface PushPreviewRequest {
  language?: string;
  type?: string;
  contentId?: string;
  clusterId?: string;
  ritualMoment?: string;
  womenIbadahSafeRequired?: boolean;
  permissionState?: 'granted' | 'denied' | 'unknown';
  titleOverride?: string;
  bodyOverride?: string;
}

export interface LocalPushPayload {
  id: string;
  type: string;
  contentId: string;
  clusterId?: string;
  bundleHint?: string;
  languageCode: string;
  title: string;
  body: string;
  data: Record<string, string>;
  lockScreenSafe: boolean;
}

export interface PushPreviewResult {
  accepted: boolean;
  payload?: LocalPushPayload;
  flags: string[];
}

export interface PushSendResult extends PushPreviewResult {
  queue?: {
    size: number;
  };
}

const queuedMessages: LocalPushPayload[] = [];

export function previewPush(input: PushPreviewRequest): PushPreviewResult {
  const flags: string[] = [];
  const language = normalizeLanguage(input.language);
  const type = input.type ?? '';
  const contentId = input.contentId ?? '';
  const seed = findSeedContent(type, contentId);

  if (!seed) {
    flags.push('missing_content');
  }

  const title = input.titleOverride ?? seed?.title[language] ?? '';
  const body = input.bodyOverride ?? seed?.body[language] ?? '';
  flags.push(...evaluateLockScreenCopy(title, body));
  if (hasFullQuranLikeLockScreenBody(body)) {
    flags.push('full_quran_lock_screen_body');
  }
  if (input.womenIbadahSafeRequired && seed && !seed.lockScreenSafe) {
    flags.push('lock_screen_not_safe');
  }

  if (flags.length > 0 || !seed) {
    return {
      accepted: false,
      flags: [...new Set(flags)],
    };
  }

  const payload = createPayload({
    type,
    contentId,
    clusterId: input.clusterId ?? seed.clusterId,
    bundleHint: seed.bundleHint,
    language,
    title,
    body,
    lockScreenSafe: seed.lockScreenSafe,
  });

  return {
    accepted: true,
    payload,
    flags: [],
  };
}

export function sendPush(input: PushPreviewRequest): PushSendResult {
  const result = previewPush(input);
  if (!result.accepted || !result.payload) {
    return result;
  }
  queuedMessages.push(result.payload);
  return {
    ...result,
    queue: {
      size: queuedMessages.length,
    },
  };
}

export function getQueuedMessages(): LocalPushPayload[] {
  return [...queuedMessages];
}

export function clearQueuedMessages() {
  queuedMessages.splice(0, queuedMessages.length);
  return { cleared: true };
}

function createPayload(input: {
  type: string;
  contentId: string;
  clusterId: string;
  bundleHint: string;
  language: string;
  title: string;
  body: string;
  lockScreenSafe: boolean;
}): LocalPushPayload {
  const id = [
    'local_push',
    input.type,
    input.contentId,
    input.language,
  ].join('_');
  return {
    id,
    type: input.type,
    contentId: input.contentId,
    clusterId: input.clusterId,
    bundleHint: input.bundleHint,
    languageCode: input.language,
    title: input.title,
    body: input.body,
    lockScreenSafe: input.lockScreenSafe,
    data: {
      type: input.type,
      contentId: input.contentId,
      clusterId: input.clusterId,
      bundleHint: input.bundleHint,
    },
  };
}
