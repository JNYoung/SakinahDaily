# Agent Output Schemas

## AgentRun

```json
{
  "runId": "run_...",
  "runType": "weekly_preproduction",
  "status": "completed",
  "createdAt": "2026-05-20T00:00:00.000Z",
  "candidates": []
}
```

## AgentCandidate

```json
{
  "candidateId": "run_..._candidate_1",
  "runId": "run_...",
  "clusterId": "ease",
  "sourceItemId": "source_ease_en",
  "language": "en",
  "lockScreenTitle": "Begin softly",
  "lockScreenBody": "A short Sakinah moment is ready for your day.",
  "status": "needs_human_review",
  "safetyFlags": []
}
```

## ReviewPacket

```json
{
  "run": {},
  "candidates": []
}
```
