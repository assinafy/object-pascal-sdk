# Changelog

## 0.2.1 — 2026-10-09

- Use Free Pascal's native Unicode manager on macOS to preserve legacy code-page text during UTF-8 conversion.

## 0.2.0 — 2026-10-09

- Require a workspace ID with API-key authentication and reject combining an API key with an OAuth access token.
- Preserve HTTP status and response bytes in protocol errors, including rejected OAuth token responses.
- Validate UTF-8 JSON responses and encode query values and webhook identifiers as UTF-8.
- Send uploads from a bounded 25 MiB snapshot and allow explicit PNG/JPEG content types for workspace logos.
- Validate OAuth resource origins and environment selection; handle webhook header values containing colons or equals signs.
- Provide a complete Brazilian Portuguese document-signing workflow, authentication guidance and compilable examples.

## 0.1.0 — 2026-10-09

- Add a Free Pascal client for all 106 published Assinafy API v1 operations.
- Support API keys, bearer tokens, signer access codes, JSON payloads and binary uploads and downloads.
- Add OAuth authorization code flow with S256 PKCE, callback validation, token refresh and revocation.
- Add Standard Webhooks signature verification, endpoint management and signing-secret rotation.
- Document document creation, signing, templates, validation, OAuth connections and webhook delivery.
