# SDK types and helpers

The [API reference](API.md) defines every resource method. This document defines the shared types and helper functions used with those methods.

## TAssinafyClient

`Create(AAPIKey = ''; AAccountID = ''; ABaseURL = AssinafyProductionURL; Transport = nil)` configures a connection. Choose API-key authentication with both `AAPIKey` and `AAccountID`, or create without an API key and set `AccessToken` for OAuth. An API key requires a workspace ID; configuring an access token on an API-key client raises `EAssinafyInputError`. For OAuth, discover the authorized workspace with `ListMyAccounts` and pass its ID to account-scoped methods. `ABaseURL` must be HTTPS and end in `/v1`, with no embedded credentials/query/fragment; loopback HTTP is permitted for tests. No network call occurs during construction. Omitted transports are owned by the client; supplied transports are borrowed.

| Property | Type/default | Behavior |
| --- | --- | --- |
| `APIKey` | Read-only string | Constructor credential for API-key calls. |
| `AccountID` | Read-only string | Used by resource methods passed an empty account ID. |
| `BaseURL` | Read-only string | Complete API URL ending in `/v1`. |
| `AccessToken` | Writable string, empty | Sends bearer authentication. Rejects a nonempty token if an API key is configured and rejects NUL/CR/LF in the token. |
| `TimeoutMS` | Writable integer, `30000` | Positive connection and overall-transfer limit, including upload and server response time. Increase before large uploads on slow connections; a timeout does not prove the server rejected a mutation. |
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
| `ParseJSON` | Parses one strict UTF-8 JSON value; replaces existing JSON; empty body produces nil. Rejects duplicate keys, trailing data and raw control characters. Invalid JSON raises `EAssinafyProtocolError`. Free Pascal 3.2.2 discards escaped NUL (`\u0000`), so the SDK rejects that escape instead of changing values; literal escaped backslashes are preserved. `Body` retains the original bytes. |
| `Header(Name): string` | Finds a header case-insensitively and trims surrounding whitespace. Missing headers yield an empty string. |
| `SaveToStream(Destination)` | Writes exact body bytes at the stream’s current position. A nil destination is rejected. Does not close the stream. |

`Data` can be null, an object, an array or the OAuth root. Check the documented schema before casting it. To retain JSON after freeing a response, call `Clone` on the desired node and own that clone.

## Errors

`EAssinafyError` is the SDK exception base. `EAssinafyInputError`, `EAssinafyTransportError` and `EAssinafyProtocolError` distinguish input, transport/native-library and response validation failures. `EAssinafyProtocolError.Create(MessageText, Response = nil)` copies `StatusCode` and raw `ResponseBody` when a response is supplied; otherwise they are zero and empty. A `2xx` protocol error preserves the server's successful HTTP result, even if JSON decoding or token validation failed. Reconcile mutations before retrying. OAuth response bodies can contain usable access or rotated refresh tokens; inspect them securely and never automatically repeat a code exchange or refresh after a successful HTTP response. The error owns its copied values, so callers do not manage an attached response object.

`EAssinafyAPIError.Create(Response)` copies HTTP `StatusCode`, the OAuth `ErrorCode`, raw `ResponseBody`, `RetryAfter` and `Authenticate` (`WWW-Authenticate`); freeing the response does not invalidate these fields. Its message contains the server’s message or OAuth error description. SDK resource calls raise it automatically for non-2xx responses.

## Transports and request utilities

`TAssinafyTransport.Execute(Request): TAssinafyResponse` is the abstract transport boundary. It borrows a `TAssinafyRequest` for the duration of the call and returns a newly allocated response. Custom transports must preserve status, body bytes and response headers. They must not retain borrowed header pointers or swallow failures.

`TAssinafyCurlTransport.Execute` uses libcurl’s easy/MIME APIs, HTTPS verification, TLS 1.2 minimum, transfer timeouts, disabled redirects and optional CA files. Document/logo uploads use multipart `file`; signature images use raw PNG bytes. It reads each upload once into a bounded snapshot of at most 25 MiB; multipart bytes are copied into libcurl’s MIME storage. Budget up to 50 MiB of temporary upload memory per concurrent worker, in addition to buffered responses. The transmitted bytes remain unchanged if the source path is replaced after loading. HTTP results are returned to the client, which parses JSON and raises API errors. C callbacks handle stream failures without unwinding Pascal exceptions through C frames.

`TAssinafyRequest` contains `Method`, `URL`, borrowed `Headers`, raw `Body`, upload `FileName`/`FileField`/`ContentType`, `TimeoutMS` and `CAFile`. Resource code builds this record; ordinary applications use named client methods.

`UploadAccountLogo(AccountID, FileName, ContentType = 'application/octet-stream')` accepts an optional file-part content type such as `image/png` or `image/jpeg`. Blank types and NUL/CR/LF are rejected before transport. The server validates the image bytes and workspace permissions.

JSON response bytes are validated with a UTF-8 decode/encode round trip before strict parsing. Validation uses temporary decoding buffers; binary downloads are not decoded. Unix builds load the standard `cwstring` Unicode manager. Use `{$codepage utf8}` for UTF-8 Pascal source literals and keep Unicode text in `UTF8String`/`UnicodeString` until converting it for a UI. `fpjson` string values use `UTF8String`.

- `RequireValue(Value, Name)` rejects blank required values and NUL/CR/LF control characters.
- `PercentEncode(Value: UTF8String)` converts code-page-aware caller strings to UTF-8, then encodes bytes using RFC 3986 unreserved characters and uppercase percent escapes.
- `EncodeQuery(Query)` encodes decoded `name=value` entries, retaining duplicates and empty values. Nil yields an empty query. Bare unnamed entries are invalid.
- `TrimURLTrailingSlash(Value)` removes trailing `/` characters independently of the operating system; empty values stay empty. It does not parse or validate a URL.

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

Token request/response/error payloads are complete in [ExchangeOAuthToken](API.md#exchangeoauthtoken) and [RevokeOAuthToken](API.md#revokeoauthtoken). Authorization request and callback examples, rotation rules, token lifetimes, OAuth workspace restrictions and OIDC validation requirements are in [README](../README.md#aplicativos-de-marketplace-e-oauth2).

`ExchangeCode` and `RefreshToken` reject a configured resource whose scheme, host or effective port differs from the client's API origin. Explicit production/sandbox issuer mismatches are also rejected before transport. Resource paths do not affect the origin check; omit the optional resource when the application does not supply one.

The REST token schema permits a missing/null refresh token. The `RefreshToken` helper requires a nonempty replacement to support a continuing refresh connection. On missing/null refresh tokens or other token validation failures, its protocol error preserves the complete successful response, including any usable credentials. Applications must decide whether to continue with the returned access token or reconnect, and must not reuse the old refresh token blindly.

The helpers do not open a browser, host callbacks, persist secrets, schedule refreshes or validate ID-token signatures. These belong to the host application’s lifecycle and credential store.

## Webhook verification

`VerifyWebhook(Secret, MessageID, Timestamp, Signatures, RawBody, NowUnix, ToleranceSeconds = 300): Boolean` verifies a Standard Webhooks delivery at an explicit Unix time, suitable for deterministic checks. It requires a `whsec_` secret with canonical base64 content, a nonempty ID, a nonnegative decimal timestamp, a matching `v1,<base64>` HMAC-SHA256 signature and a timestamp within the tolerance. The signed bytes are `MessageID + '.' + Timestamp + '.' + RawBody`. Missing/malformed inputs return false; unavailable crypto raises a transport error and must fail the receiving request.

`VerifyWebhookHeaders(Secret, Headers, RawBody, ToleranceSeconds = 300): Boolean` reads case-insensitive `webhook-id`, `webhook-timestamp` and `webhook-signature` lines and uses the current system time. It supports `name: value` and `name=value`, merges signature headers and rejects duplicate ID/timestamp values. It borrows the headers/body; it does not parse JSON or persist deduplication state.

Header parsing splits at the first `:` or `=`, preserving separators inside values. The message ID and timestamp are encoded as UTF-8; raw body bytes are copied without code-page conversion before HMAC verification.

Use raw body bytes, verify first, deduplicate by the message ID, then enqueue processing. Endpoint creation, management and rotation payloads are in [API reference](API.md#listwebhookendpoints).

## Cryptographic utilities

`AssinafyCrypto` uses OpenSSL 3 provider APIs and secure random generation. All binary inputs/outputs use `RawByteString` so NUL bytes are retained.

- `SHA256(Value): RawByteString` returns the 32-byte digest.
- `HMACSHA256(Key, Value): RawByteString` returns a 32-byte keyed digest.
- `SecureRandom(Count): RawByteString` returns 1–1024 securely generated bytes; other counts are rejected.
- `ConstantTimeEqual(Left, Right): Boolean` compares equal-length buffers through `CRYPTO_memcmp`; unequal lengths return false.
- `Base64URL(Value): string` produces unpadded URL-safe base64.
- `StrictBase64Decode(Value): RawByteString` accepts canonical padded standard base64; malformed values raise `EAssinafyInputError`.

Native crypto loading is synchronized. Linux loads `libcrypto.so.3`; macOS loads `libcrypto.3.dylib`; Windows loads the matching OpenSSL 3 DLL. Ensure the native library’s architecture matches the executable and configure the operating system’s library search path at deployment. With Homebrew’s keg-only OpenSSL on macOS, set `DYLD_LIBRARY_PATH` to `$(brew --prefix openssl@3)/lib` in the process environment before using OAuth or webhook verification; see the [installation commands](../README.md#requisitos-e-instalação).
