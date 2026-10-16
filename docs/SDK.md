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
| `CAFile` | Writable string, empty | Optional trusted PEM CA bundle with libcurl. Delphi rejects nonempty values and uses the Windows certificate store. Verification stays enabled. |

`Free` releases only the owned transport. Clients are synchronous; use one per worker and do not modify properties concurrently. `AssinafyVersion`, `AssinafyProductionURL` and `AssinafySandboxURL` are public string constants. `TAssinafyAuth` is the resource authentication enumeration: public, API, signer, signer-or-API and bearer-only.

## Identity verification resources

`GetIdentityVerificationStatus(SignerAccessCode)` and `StartIdentityVerification(SignerAccessCode, Body)` send only a nonempty signer code. Starting requires explicit biometric consent (`{"consent":true}`). The returned capture URL is a bearer credential; preserve its fragment and keep it out of logs and browser storage. The application obtains consent and follows the server's `can_start` state. See the complete [status](API.md#getidentityverificationstatus) and [session](API.md#startidentityverification) contracts.

`GetSignerIdentityReview(DocumentID, AssignmentID, SignerID)`, `DownloadSignerIdentityReviewImage(DocumentID, AssignmentID, SignerID, Name)` and `DecideSignerIdentityReview(DocumentID, AssignmentID, SignerID, Body)` require workspace credentials. The download returns exact image/PDF bytes, available only during an open review; preserve `Cache-Control: no-store`. Decisions use `Approved` or `Rejected` and an optional nullable note. Rejection cancels the document and notifies its recipients. The [resource reference](API.md#getsigneridentityreview) defines all evidence, statuses and errors; the [signing flow](../README.md#verificação-biométrica-e-análise-de-identidade) explains session expiry and certification holds. These methods have the same response/body ownership as every resource call.

## TAssinafyResponse

`Create` allocates an empty response and its case-insensitive header list. `Free` frees the header list and parsed JSON tree.

| Member | Meaning |
| --- | --- |
| `StatusCode: Integer` | HTTP response status. |
| `Headers: TStringList` | HTTP `name: value` lines. Names use `:` as the separator. |
| `Body: RawByteString` | Entire wire body after transport decoding, preserving binary bytes. |
| `JSON: TJSONData` | Borrowed parsed root, or nil for empty/binary responses. |
| `Data: TJSONData` | Borrowed envelope `data`, or JSON root for flat responses. |
| `ParseJSON` | Parses one strict UTF-8 JSON value; replaces existing JSON; empty body produces nil. Rejects duplicate keys, trailing data, raw control characters and nesting beyond 512 containers. Invalid JSON raises `EAssinafyProtocolError`. Free Pascal 3.2.2 discards escaped NUL (`\u0000`), so the SDK rejects that escape instead of changing values; literal escaped backslashes are preserved. `Body` retains the original bytes. |
| `Header(Name): string` | Finds a header case-insensitively and trims surrounding whitespace. Missing headers yield an empty string. |
| `SaveToStream(Destination)` | Writes exact body bytes at the stream’s current position. A nil destination is rejected. Does not close the stream. |

`Data` can be null, an object, an array or the OAuth root. Check the documented schema before casting it. To retain JSON after freeing a response, call `Clone` on the desired node and own that clone.

## JSON compatibility

`AssinafyJson` aliases `TJSONData`, `TJSONObject` and `TJSONArray` to native `fpjson` classes with Free Pascal, and to `TJSONValue`, `TJSONObject` and `TJSONArray` from `System.JSON` with Delphi. It does not wrap JSON nodes or introduce a second ownership model. Existing Free Pascal callers can continue using native constructors and accessors. Shared applications import `AssinafyJson` and use the following helpers; Delphi callers may also use native `System.JSON` methods.

| Helper | Request and result |
| --- | --- |
| `JSONObj(Values: array of const): TJSONObject` | Alternating string names and values; creates a caller-owned object. Converts strings using their declared code page. Supports strings, booleans, integers through Int64, floating-point values, nil as explicit null and native JSON children. Child nodes become owned by the object as they are added. Duplicate names are rejected before constructing or attaching the rejected value; that child stays caller-owned. Children already attached before any later constructor error are freed with the partial object. |
| `JSONArr(Values: array of const): TJSONArray` | Creates a caller-owned array from the same scalar/JSON values. Child nodes become owned by the array. |
| `JSONAdd(Obj: TJSONObject; Name: string; Value: TJSONData/string/Boolean)` | Adds one property, preserving empty strings. A JSON child becomes owned by the object after a successful addition. Duplicate names are rejected; an unattached child remains caller-owned on rejection. |
| `JSONAdd(Arr: TJSONArray; Value: TJSONData)` | Adds a child and transfers ownership to the array. |
| `JSONFind(Value: TJSONData; Path: string): TJSONData` | Returns a borrowed child for a dotted path, or nil for an absent path/root. Object property names in paths must not contain dots. |
| `JSONText(Value: TJSONData): UTF8String` | Serializes a nonnil JSON value to UTF-8 text, preserving booleans, explicit nulls and native number representation. |
| `JSONString(Value: TJSONData): UTF8String` | Returns string content; rejects non-string/nil values. Returns code-page-aware UTF-8 text on both compilers; retain `UTF8String` or convert explicitly to `UnicodeString` for a UI. |
| `JSONInteger(Value: TJSONData): Int64` | Reads a JSON number as a signed 64-bit integer without conversion through floating point. Fractional or out-of-range values are invalid. |
| `JSONBoolean(Value: TJSONData): Boolean` | Reads a JSON boolean; rejects other types/nil. |
| `JSONKind(Value: TJSONData): TJSONType` | Returns `jtNumber`, `jtString`, `jtBoolean`, `jtNull`, `jtArray`, `jtObject`, or `jtUnknown` for nil/unknown values. |
| `JSONGet(Obj: TJSONObject; Name, DefaultValue: string): UTF8String` | Returns the string at the named path or the supplied default when absent; rejects a present non-string value. |
| `ParseJSONStrict(Bytes: RawByteString): TJSONData` | Returns a caller-owned native JSON tree, or nil for an empty body. Rejects invalid UTF-8, duplicate decoded names, trailing data, comments, trailing commas, malformed numbers/escapes and nesting beyond 512 containers. Raw NUL and active Unicode NUL escapes are rejected consistently across compilers. Encoding and active NUL-escape errors raise `EAssinafyJSONEncodingError` and `EAssinafyJSONNulError`, both derived from `EConvertError`. Other parser errors propagate to direct callers; `TAssinafyResponse.ParseJSON` converts them into protocol errors with response context. |

Create integer/floating/null properties through `JSONObj` or the compiler's native JSON classes. `JSONAdd` overloads intentionally cover string, boolean and child nodes. All nonnil arguments to scalar/serialization helpers must have the documented type. Free only top-level owned objects; do not separately free children attached to their parent.

## Delphi transport

`TAssinafyDefaultTransport` names `TAssinafyCurlTransport` with Free Pascal and `TAssinafyNetTransport` with Delphi. The latter implementation targets Delphi 12+ on Windows Win32/Win64 and remains experimental until its Windows build and runtime checks pass.

`TAssinafyNetTransport.Execute(Request): TAssinafyResponse` uses `THTTPClient` directly. It disables redirects/cookies, selects TLS 1.2/1.3 and preserves Windows certificate-chain/hostname verification. `CAFile` is rejected before transfer; install trusted authorities through the Windows certificate store. There is no certificate-validation bypass. A per-request deadline cancels the native request at `TimeoutMS`; native connection and response timeouts also use that value. Direct transport callers may set zero to disable the deadline and native timeouts; negative values are invalid. Client methods continue to require a positive timeout. Automatic content decompression is disabled, preserving encoded body bytes as on libcurl. The deadline includes the upload and response transfer after the file snapshot is loaded. A complete Content-Length response survives a cancellation race; a truncated body is rejected, including encoded bodies. If the deadline fires and completion cannot be established for chunked/close-delimited bodies, `EAssinafyProtocolError` retains HTTP status and received bytes for reconciliation instead of returning partial data as success. Deadline cancellation reports `HTTP transfer exceeded TimeoutMS`. Timeout outcomes remain indeterminate for mutations.

Both transports use the same 25 MiB file snapshot loader. Delphi writes multipart framing and binary bytes to a memory stream, retaining the file-field name, filename and supplied MIME type; signature images use raw bytes. Budget up to 50 MiB per multipart upload, plus buffered responses. HTTP response bodies are copied from a memory stream without text decoding; response headers and non-2xx statuses reach the shared client error handling. Clients own default transports and borrow supplied ones on both compilers.

The Delphi package project is [AssinafySDK.dproj](../delphi/AssinafySDK.dproj). [check.ps1](../delphi/check.ps1) rebuilds both test programs and examples and compiles README snippets. It requires a matching OpenSSL 3 runtime directory and explicit permission for the temporary local test certificate. The test certificate is removed in a finally block. Abrupt process termination during that test can require removing the generated certificate manually; use an isolated Windows test environment.

## Errors

`EAssinafyError` is the SDK exception base. `EAssinafyInputError`, `EAssinafyTransportError` and `EAssinafyProtocolError` distinguish input, transport/native-library and response validation failures. `EAssinafyProtocolError.Create(MessageText, Response = nil)` copies `StatusCode` and raw `ResponseBody` when a response is supplied; otherwise they are zero and empty. A `2xx` protocol error preserves the server's successful HTTP result, even if JSON decoding or token validation failed. Reconcile mutations before retrying. OAuth response bodies can contain usable access or rotated refresh tokens; inspect them securely and never automatically repeat a code exchange or refresh after a successful HTTP response. The error owns its copied values, so callers do not manage an attached response object.

`EAssinafyAPIError.Create(Response)` copies HTTP `StatusCode`, the OAuth `ErrorCode`, raw `ResponseBody`, `RetryAfter` (`Retry-After` seconds on `429`), `Authenticate` (`WWW-Authenticate`) and the `X-Rate-Limit-Limit`, `X-Rate-Limit-Remaining` and `X-Rate-Limit-Reset` values as `RateLimitLimit`, `RateLimitRemaining` and `RateLimitReset` (empty when absent); freeing the response does not invalidate these fields. Its message contains the server’s message or OAuth error description. SDK resource calls raise it automatically for non-2xx responses.

## Transports and request utilities

`TAssinafyTransport.Execute(Request): TAssinafyResponse` is the abstract transport boundary. It borrows a `TAssinafyRequest` for the duration of the call and returns a newly allocated response. Custom transports must preserve status, body bytes and response headers. They must not retain borrowed header pointers or swallow failures.

`TAssinafyCurlTransport.Execute` uses libcurl’s easy/MIME APIs, HTTPS verification, TLS 1.2 minimum, transfer timeouts, disabled redirects and optional CA files. Document/logo uploads use multipart `file`; signature images use raw PNG bytes. It reads each upload once into a bounded snapshot of at most 25 MiB; multipart bytes are copied into libcurl’s MIME storage. Budget up to 50 MiB of temporary upload memory per concurrent worker, in addition to buffered responses. The transmitted bytes remain unchanged if the source path is replaced after loading. HTTP results are returned to the client, which parses JSON and raises API errors. C callbacks handle stream failures without unwinding Pascal exceptions through C frames.

`TAssinafyRequest` contains `Method`, `URL`, borrowed `Headers`, raw `Body`, upload `FileName`/`FileField`/`ContentType`, `TimeoutMS` and `CAFile`. Both native transports validate header names as HTTP tokens and reject control characters in values/content types before transfer, permitting horizontal tabs and empty values. A nil header collection is rejected. Direct transport calls accept zero `TimeoutMS` for no timeout and reject negative values. Resource code builds this record; ordinary applications use named client methods with a positive timeout.

`UploadAccountLogo(AccountID, FileName, ContentType = 'application/octet-stream')` accepts an optional file-part content type such as `image/png` or `image/jpeg`. Blank types and NUL/CR/LF are rejected before transport. The server validates the image bytes and workspace permissions.

JSON response bytes are validated with a UTF-8 decode/encode round trip before strict parsing. Validation uses temporary decoding buffers; binary downloads are not decoded. macOS builds load Free Pascal's native `fpwidestring` Unicode manager and `cpall` code-page tables; other Unix builds use `cwstring`. These units are included with Free Pascal and loaded by `AssinafyJson`. Use `{$IFDEF FPC}{$codepage utf8}{$ENDIF}` in shared UTF-8 sources. With Delphi, save sources with a UTF-8 BOM or set the compiler's Code page option to `65001` (`--codepage:65001`); the supplied package and verification command set this option. Keep Unicode text in `UTF8String`/`UnicodeString` until converting it for a UI. `fpjson` string values use `UTF8String`.

- `RequireValue(Value, Name)` rejects blank required values and NUL/CR/LF control characters.
- `PercentEncode(Value: UTF8String)` converts code-page-aware caller strings to UTF-8, then encodes bytes using RFC 3986 unreserved characters and uppercase percent escapes.
- `EncodeQuery(Query)` encodes decoded `name=value` entries, retaining duplicates and empty values. Nil yields an empty query. Bare unnamed entries are invalid.
- `TrimURLTrailingSlash(Value)` removes trailing `/` characters independently of the operating system; empty values stay empty. It does not parse or validate a URL.

`AssinafyURI.ParseAssinafyURI(Value: string): TAssinafyURI` adapts the compiler's URI parser for client/OAuth validation. The record contains `Protocol`, `Host`, `UserName`, `Password`, `Params` (query), `Bookmark` (fragment), `Origin` (scheme, host and port, without credentials, path, query or fragment) and integer `Port`. It does not perform HTTPS, credentials or environment validation; client/OAuth methods apply those checks. Explicit numeric ports must contain decimal digits and be between 0 and 65535. Empty ports normalize to the scheme default, including bracketed IPv6 URLs; validation precedes native port conversion. Native URI parsing/conversion failures raise `EAssinafyInputError`; unrelated failures such as allocation errors propagate. Applications normally use the client constructor instead of this adapter.

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
- `Base64Encode(Value: RawByteString): string` returns canonical standard base64 without line breaks.
- `Base64URL(Value): string` produces unpadded URL-safe base64.
- `StrictBase64Decode(Value): RawByteString` accepts canonical padded standard base64; malformed values raise `EAssinafyInputError`.

Native crypto loading is synchronized. Linux loads `libcrypto.so.3`; macOS loads `libcrypto.3.dylib`; Windows loads the matching OpenSSL 3 DLL. Ensure the native library’s architecture matches the executable and configure the operating system’s library search path at deployment. With Homebrew’s keg-only OpenSSL on macOS, set `DYLD_LIBRARY_PATH` to `$(brew --prefix openssl@3)/lib` in the process environment before using OAuth or webhook verification; see the [installation commands](../README.md#requisitos-e-instalação).

Delphi loads the matching OpenSSL DLL from the executable directory using `LoadLibraryEx` with the DLL directory and default system search directories for dependencies. Place its dependent DLLs beside it. Crypto uses explicit ANSI C pointers and native-width size types; loading is protected by `TCriticalSection`.
