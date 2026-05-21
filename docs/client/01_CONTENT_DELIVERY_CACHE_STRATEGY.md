# Client Content Delivery Cache Strategy

The client starts from bundled seed content, optionally refreshes a remote manifest, validates bundle integrity, then updates cache transactionally.

Invalid bundles are discarded when:

- SHA-256 hash does not match.
- Schema version is unsupported.
- Content is not published and approved.
- Audio hash validation fails, in which case text-only fallback is used.
