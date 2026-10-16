# Changelog

## [0.4.0] - 2026-10-16

- Add signer identity-verification status and consent-based session creation for `IdDocumentFaceMatchBasic`.
- Add workspace identity-review retrieval, binary evidence downloads and approval/rejection decisions.
- Add webhook endpoint deletion by exact URL and an optional URL filter to `ListWebhookEndpoints`.
- Include all 112 published operations, identity-verification schemas and 23 webhook event payloads in the generated reference.
- Preserve endpoint-specific descriptions on referenced response schemas.
- Print only the assignment ID in the workflow example, keeping signing URLs out of console output.

## [0.3.1] - 2026-10-12

- **Behavior change (security):** `ListSignerDocuments` and `SearchSignerDocuments` now require a nonempty `SignerAccessCode` and send only that code. Previously an empty code silently fell back to the workspace API key or bearer token. Signatures are unchanged.
- Add `ListSignerDocumentsAsWorkspace` and `SearchSignerDocumentsAsWorkspace` for explicit API key or bearer token access to the signer document routes.
- Expose `X-Rate-Limit-Limit`, `X-Rate-Limit-Remaining` and `X-Rate-Limit-Reset` on `EAssinafyAPIError` as `RateLimitLimit`, `RateLimitRemaining` and `RateLimitReset`, next to `RetryAfter`.
- Document the `send-token` body (`channel: "email"` and `recipient`, both required) and clearing an assignment expiration by sending `expires_at: null`.
- Refresh the bundled API contract from the published OpenAPI document.

## 0.3.0 — 2026-10-09

- Add experimental Delphi 12+ Windows source integration and runtime-package projects, sharing all 106 resource methods with Free Pascal.
- Add native JSON aliases and shared construction/access helpers with strict cross-compiler JSON validation.
- Add a Windows HTTP transport with OS certificate verification, bounded uploads and overall-transfer cancellation.
- Provide Windows build commands and shared JSON, HTTP/TLS and example checks.
- Limit JSON response nesting to 512 containers and reject duplicate object-constructor names before allocating the rejected value.
- Preserve status and bytes when Delphi cancellation leaves response completion indeterminate; verify encoded response lengths without automatic decompression.
- Reject negative native-transport timeouts, malformed HTTP headers and out-of-range URI ports; preserve zero as unlimited for direct transport calls.

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
