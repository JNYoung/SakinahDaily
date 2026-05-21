# Client Sync Flows

1. Load bundled seed manifest.
2. Refresh remote manifest when configured.
3. Download missing bundles to a temporary cache entry.
4. Validate hash, schema, status, and review status.
5. Commit cache transactionally.
6. Recover push deep links from cache first, then remote detail bundle, then fallback state.
