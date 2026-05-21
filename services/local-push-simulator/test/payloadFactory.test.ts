import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  clearQueuedMessages,
  getQueuedMessages,
  previewPush,
  sendPush,
} from '../src/payloadFactory';

const baseRequest = {
  language: 'en',
  type: 'daily_session',
  contentId: 'session_morning_ease',
  clusterId: 'calm_through_dhikr',
  ritualMoment: 'morning',
  womenIbadahSafeRequired: true,
  permissionState: 'granted',
} as const;

test('generates English daily_session payload', () => {
  const result = previewPush(baseRequest);

  assert.equal(result.accepted, true);
  assert.equal(result.payload?.title, 'Begin softly');
  assert.equal(result.payload?.data.type, 'daily_session');
  assert.equal(result.payload?.data.contentId, 'session_morning_ease');
});

test('generates Indonesian daily_session payload', () => {
  const result = previewPush({ ...baseRequest, language: 'id' });

  assert.equal(result.accepted, true);
  assert.equal(result.payload?.title, 'Mulai dengan lembut');
  assert.equal(result.payload?.languageCode, 'id');
});

test('generates Arabic daily_session payload', () => {
  const result = previewPush({ ...baseRequest, language: 'ar' });

  assert.equal(result.accepted, true);
  assert.equal(result.payload?.title, 'ابدأ برفق');
  assert.equal(result.payload?.languageCode, 'ar');
});

test('blocks women/cycle-sensitive lock-screen text', () => {
  const result = previewPush({
    ...baseRequest,
    titleOverride: 'Cycle check-in',
    bodyOverride: 'Your period support reminder is ready.',
  });

  assert.equal(result.accepted, false);
  assert.ok(result.flags.includes('cycle_sensitive_lock_screen_copy'));
});

test('blocks missing content ID', () => {
  const result = previewPush({ ...baseRequest, contentId: 'missing' });

  assert.equal(result.accepted, false);
  assert.ok(result.flags.includes('missing_content'));
});

test('blocks guaranteed outcome claim', () => {
  const result = previewPush({
    ...baseRequest,
    bodyOverride: 'This will definitely fix your day.',
  });

  assert.equal(result.accepted, false);
  assert.ok(result.flags.includes('guaranteed_outcome_claim'));
});

test('blocks shaming tone', () => {
  const result = previewPush({
    ...baseRequest,
    bodyOverride: 'Do not be lazy with remembrance.',
  });

  assert.equal(result.accepted, false);
  assert.ok(result.flags.includes('shaming_tone'));
});

test('blocks fatwa-like claim', () => {
  const result = previewPush({
    ...baseRequest,
    bodyOverride: 'The ruling is haram for you.',
  });

  assert.equal(result.accepted, false);
  assert.ok(result.flags.includes('fatwa_like_claim'));
});

test('stores sent messages in queue', () => {
  clearQueuedMessages();

  const result = sendPush(baseRequest);

  assert.equal(result.accepted, true);
  assert.equal(result.queue?.size, 1);
  assert.equal(getQueuedMessages().length, 1);
});

test('clears queue', () => {
  sendPush(baseRequest);

  const result = clearQueuedMessages();

  assert.deepEqual(result, { cleared: true });
  assert.equal(getQueuedMessages().length, 0);
});
