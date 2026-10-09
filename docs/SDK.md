# SDK types and helpers

The [API reference](API.md) defines every resource method. This document defines the shared types and helper functions used with those methods.

## TAssinafyClient

`Create(AAPIKey = ''; AAccountID = ''; ABaseURL = AssinafyProductionURL; Transport = nil)` configures a workspace connection. API keys and default account IDs are strings. `ABaseURL` must be HTTPS and end in `/v1`, with no embedded credentials/query/fragment; loopback HTTP is permitted for tests. No network call occurs during construction. Omitted transports are owned by the client; supplied transports are borrowed.

| Property | Type/default | Behavior |
| --- | --- | --- |
| `APIKey` | Read-only string | Constructor credential for API-key calls. |
| `AccountID` | Read-only string | Used by resource methods passed an empty account ID. |
| `BaseURL` | Read-only string | Complete API URL ending in `/v1`. |
| `AccessToken` | Writable string, empty | Sends bearer authentication in preference to an API key. |
| `TimeoutMS` | Writable integer, `30000` | Positive connection and overall-transfer limit. |
| `CAFile` | Writable string, empty | Optional trusted PEM CA bundle; verification stays enabled. |

`Free` releases only the owned transport. Clients are synchronous; use one per worker and do not modify properties concurrently. `AssinafyVersion`, `AssinafyProductionURL` and `AssinafySandboxURL` are public string constants. `TAssinafyAuth` is the resource authentication enumeration: public, API, signer, signer-or-API and bearer-only.

## TAssinafyResponse

`Create` allocates an empty response and its case-insensitive header list. `Free` frees the header list and parsed JSON tree.

| Member | Meaning |
| --- | --- |
| `StatusCode: Integer` | HTTP response status. |
| `Headers: TStringList` | HTTP `name: value` lines. Names use `:` as the separator. |
| `Body: RawByteString` | Entire wire body after libcurl decoding, preserving binary bytes. |
| `JSON: TJSONData` | Borrowed parsed root, or nil for empty/binary responses. |
| `Data: TJSONData` | Borrowed envelope `data`, or JSON root for flat responses. |
| `ParseJSON` | Parses `Body` as UTF-8 JSON; replaces existing JSON; empty body produces nil. Invalid JSON raises `EAssinafyProtocolError`. |
| `Header(Name): string` | Finds a header case-insensitively and trims surrounding whitespace. Missing headers yield an empty string. |
| `SaveToStream(Destination)` | Writes exact body bytes at the stream’s current position. A nil destination is rejected. Does not close the stream. |

`Data` can be null, an object, an array or the OAuth root. Check the documented schema before casting it. To retain JSON after freeing a response, call `Clone` on the desired node and own that clone.

## Errors

`EAssinafyError` is the SDK exception base. `EAssinafyInputError`, `EAssinafyTransportError` and `EAssinafyProtocolError` distinguish input, transport/native-library and JSON decoding failures. `EAssinafyAPIError.Create(Response)` copies HTTP `StatusCode`, the OAuth `ErrorCode`, raw `ResponseBody`, `RetryAfter` and `Authenticate` (`WWW-Authenticate`); freeing the response does not invalidate these fields. Its message contains the server’s message or OAuth error description. SDK resource calls raise it automatically for non-2xx responses.

## Transports and request utilities

`TAssinafyTransport.Execute(Request): TAssinafyResponse` is the abstract transport boundary. It borrows a `TAssinafyRequest` for the duration of the call and returns a newly allocated response. Custom transports must preserve status, body bytes and response headers. They must not retain borrowed header pointers or swallow failures.

`TAssinafyCurlTransport.Execute` uses libcurl’s easy/MIME APIs, HTTPS verification, TLS 1.2 minimum, transfer timeouts, disabled redirects and optional CA files. Document/logo uploads use multipart `file`; signature images use raw PNG bytes. It loads files from `FileName` rather than shelling out. HTTP results are returned to the client, which parses JSON and raises API errors. C callbacks handle stream failures without unwinding Pascal exceptions through C frames.

`TAssinafyRequest` contains `Method`, `URL`, borrowed `Headers`, raw `Body`, upload `FileName`/`FileField`/`ContentType`, `TimeoutMS` and `CAFile`. Resource code builds this record; ordinary applications use named client methods.

- `RequireValue(Value, Name)` rejects blank required values and NUL/CR/LF control characters.
- `PercentEncode(Value)` encodes UTF-8 string bytes using RFC 3986 unreserved characters and uppercase percent escapes.
- `EncodeQuery(Query)` encodes decoded `name=value` entries, retaining duplicates and empty values. Nil yields an empty query. Bare unnamed entries are invalid.

## OAuth helpers

`TAssinafyPKCE` contains a private `Verifier` and its public SHA-256 `Challenge`. `TAssinafyOAuthConfig` contains `ClientID`, optional `ClientSecret`, exact HTTPS `RedirectURI`, space-separated `Scopes`, optional HTTPS `Issuer`, and optional `Resource`. An empty issuer uses `AssinafyOAuthIssuer` (`https://auth.assinafy.com.br`); choose the sandbox issuer explicitly when appropriate. `AssinafyOAuthResource` is the production API origin.

| Function | Inputs and result |
| --- | --- |
| `GeneratePKCE: TAssinafyPKCE` | Generates 32 cryptographically random bytes, a 43-character base64url verifier and its S256 challenge. |
| `GenerateState: string` | Generates 32 random bytes as unpadded base64url for CSRF state. |
| `PKCEChallenge(Verifier): string` | Validates 43–128 RFC 7636 characters and returns base64url SHA-256. |
| `AuthorizationURL(Config, State, Verifier, Nonce = ''): string` | Returns an encoded browser authorization URL with response type `code`, scopes, state and mandatory S256 PKCE. Does not make a request. The verifier is hashed and is never included in the URL. Optional nonce is passed through for OIDC. |
| `ValidateOAuthCallback(Query, ExpectedState, ExpectedIssuer = AssinafyOAuthIssuer): string` | Accepts already-decoded callback `name=value` pairs. Rejects duplicates, mismatched state/issuer and returned OAuth errors. Returns the authorization code. Does not consume a session or authorize anything; the application must consume the stored transaction once. |
| `ExchangeCode(Client, Config, Code, Verifier): TAssinafyResponse` | Sends one JSON authorization-code request to the client’s token endpoint. JSON is a published token-request format. Public clients omit secrets. Validates a nonempty string access token and Bearer token type. Caller owns the response. |
| `RefreshToken(Client, Config, Token): TAssinafyResponse` | Sends one JSON refresh request. Validates an access token, Bearer type and nonempty replacement refresh token. Returns the flat token response; caller must save the rotated refresh token atomically. |
| `RevokeToken(Client, Config, Token, TokenTypeHint = ''): TAssinafyResponse` | Sends one JSON revocation request. Optional hint is `access_token` or `refresh_token`. A successful response does not disclose whether a token existed. |

Token request/response/error payloads are complete in [ExchangeOAuthToken](API.md#exchangeoauthtoken) and [RevokeOAuthToken](API.md#revokeoauthtoken). Authorization request and callback examples, rotation rules, token lifetimes, OAuth workspace restrictions and OIDC validation requirements are in [README](../README.md#connect-customer-workspaces-with-oauth).

The helpers do not open a browser, host callbacks, persist secrets, schedule refreshes or validate ID-token signatures. These belong to the host application’s lifecycle and credential store.

## Webhook verification

`VerifyWebhook(Secret, MessageID, Timestamp, Signatures, RawBody, NowUnix, ToleranceSeconds = 300): Boolean` verifies a Standard Webhooks delivery at an explicit Unix time, suitable for deterministic checks. It requires a `whsec_` secret with canonical base64 content, a nonempty ID, a nonnegative decimal timestamp, a matching `v1,<base64>` HMAC-SHA256 signature and a timestamp within the tolerance. The signed bytes are `MessageID + '.' + Timestamp + '.' + RawBody`. Missing/malformed inputs return false; unavailable crypto raises a transport error and must fail the receiving request.

`VerifyWebhookHeaders(Secret, Headers, RawBody, ToleranceSeconds = 300): Boolean` reads case-insensitive `webhook-id`, `webhook-timestamp` and `webhook-signature` lines and uses the current system time. It supports `name: value` and `name=value`, merges signature headers and rejects duplicate ID/timestamp values. It borrows the headers/body; it does not parse JSON or persist deduplication state.

Use raw body bytes, verify first, deduplicate by the message ID, then enqueue processing. Endpoint creation, management and rotation payloads are in [API reference](API.md#listwebhookendpoints).

## Cryptographic utilities

`AssinafyCrypto` uses OpenSSL 3 provider APIs and secure random generation. All binary inputs/outputs use `RawByteString` so NUL bytes are retained.

- `SHA256(Value): RawByteString` returns the 32-byte digest.
- `HMACSHA256(Key, Value): RawByteString` returns a 32-byte keyed digest.
- `SecureRandom(Count): RawByteString` returns 1–1024 securely generated bytes; other counts are rejected.
- `ConstantTimeEqual(Left, Right): Boolean` compares equal-length buffers through `CRYPTO_memcmp`; unequal lengths return false.
- `Base64URL(Value): string` produces unpadded URL-safe base64.
- `StrictBase64Decode(Value): RawByteString` accepts canonical padded standard base64; malformed values raise `EAssinafyInputError`.

Native crypto loading is synchronized. Linux loads `libcrypto.so.3`; macOS loads `libcrypto.3.dylib`; Windows loads the matching OpenSSL 3 DLL. Ensure the native library’s architecture matches the executable and configure the operating system’s library search path at deployment.
