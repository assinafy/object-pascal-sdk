# Assinafy Object Pascal SDK

A native Object Pascal client for the [Assinafy API v1](https://api.assinafy.com.br/v1/docs), covering all 106 published REST operations. Use it from a Free Pascal service or a Lazarus application to manage documents, signers, signature requests, templates, fields, tags, workspaces and webhooks.

The SDK supports API keys, bearer tokens, signer access codes, OAuth2 authorization code flow with mandatory S256 PKCE, and Standard Webhooks signature verification. JSON payloads retain the API’s field names, optional fields, nulls and future additions.

## Start here

The normal document flow is:

1. Choose the sandbox and authenticate your service, or connect a customer’s workspace with OAuth.
2. Upload a PDF and save the document ID.
3. Create or select the signers and save their IDs.
4. Choose Email, WhatsApp or DigitalCertificate verification and estimate the cost.
5. Request signatures and give signers their returned signing URLs.
6. Receive signed webhook deliveries or retrieve document status.
7. Download the completed document and its certificate or PAdES artifact.

The sections below follow this flow. [API reference](docs/API.md) documents every SDK resource method with its full request/response schemas, payload shapes, parameters, authentication and error responses. [Payload schemas](docs/SCHEMAS.md) defines every shared response model. [SDK reference](docs/SDK.md) documents constructors, response ownership, transports and OAuth/crypto/webhook helpers. The [OpenAPI contract](docs/openapi.json) is included for tooling and offline use.

## Requirements and installation

- **Free Pascal 3.2.2**, the [current official stable release](https://www.freepascal.org/download.html). Free Pascal publishes stable releases rather than an LTS channel. Lazarus projects using this compiler can include these units. This package uses Free Pascal’s FCL and is not a Delphi package.
- FCL JSON/base64 units and the Free Pascal `libcurl` bindings.
- **libcurl 7.56 or newer**, with HTTPS enabled, a trusted CA store, and TLS 1.2 or newer.
- **OpenSSL 3 libcrypto** for PKCE, random state values and webhook signatures. HTTP TLS uses libcurl’s configured TLS backend. Install maintained releases of the native libraries through your operating system.
- Python 3.9 or newer and OpenSSL’s command-line tool for development checks.

Clone the repository and add `src` to your compiler’s unit and include paths:

```sh
git clone https://github.com/assinafy/object-pascal-sdk.git
cd object-pascal-sdk
fpc -Fu./src -Fi./src -FU./build -FE./build your_program.pas
```

Create `build` first with `mkdir -p build`. In Lazarus, add `src` to **Project Options → Compiler Options → Paths → Other unit files** and **Include files**. Use `Assinafy` and `AssinafyHttp` in your application. Console programs on Unix should place `cthreads` first in `uses` when using threads.

On Ubuntu/Debian, install the compiler units and native development libraries:

```sh
sudo apt-get install fp-compiler fp-units-fcl fp-units-net libcurl4-openssl-dev libssl-dev
```

On macOS:

```sh
brew install fpc openssl@3
export DYLD_LIBRARY_PATH="$(brew --prefix openssl@3)/lib"
```

Linux and macOS are the CI targets. Windows requires matching Free Pascal units, a libcurl import library/runtime, a CA store and an OpenSSL 3 runtime matching the executable’s architecture; Windows builds have not been qualified by this project.

## Configure an environment

| Setting | Sandbox | Production |
| --- | --- | --- |
| API base URL | `https://sandbox.assinafy.com.br/v1` | `https://api.assinafy.com.br/v1` |
| Application | `https://app-sandbox.assinafy.com.br` | `https://app.assinafy.com.br` |
| OAuth issuer | `https://auth-sandbox.assinafy.com.br` | `https://auth.assinafy.com.br` |

Create an API key in the application’s account settings and note the workspace ID. Keep API keys and confidential OAuth secrets on a server you control. For software shipped to customers, connect their workspace through OAuth and store tokens in the operating system’s secure credential storage or in your service’s encrypted credential store.

The SDK takes credentials explicitly. The runnable examples read these environment variables; they do not load `.env` files automatically:

| Variable | Purpose |
| --- | --- |
| `ASSINAFY_API_KEY` | Workspace API key sent in `X-Api-Key`. |
| `ASSINAFY_ACCOUNT_ID` | Default workspace ID for account-scoped calls. |
| `ASSINAFY_BASE_URL` | Complete API URL ending in `/v1`. |
| `ASSINAFY_ACCESS_TOKEN` | Access token sent in `Authorization: Bearer`. Takes precedence over the API key. |
| `ASSINAFY_CLIENT_ID` | Registered OAuth application’s public identifier. |
| `ASSINAFY_CLIENT_SECRET` | Confidential OAuth application secret; omit for public applications. |
| `ASSINAFY_REDIRECT_URI` | Exactly registered HTTPS callback URL. |
| `ASSINAFY_OAUTH_ISSUER` | Issuer from protected-resource discovery. |
| `ASSINAFY_OAUTH_RESOURCE` | Optional resource indicator from discovery. |

[.env.example](.env.example) contains empty credential values and reserved example domains. Keep local credential files ignored. Secrets and personal contact details do not belong in source control or documentation.

## Authenticate and read a workspace

```pascal
uses
  SysUtils, Assinafy, AssinafyHttp;

var
  Client: TAssinafyClient;
  Response: TAssinafyResponse;
begin
  Client := TAssinafyClient.Create(
    GetEnvironmentVariable('ASSINAFY_API_KEY'),
    GetEnvironmentVariable('ASSINAFY_ACCOUNT_ID'),
    AssinafySandboxURL);
  try
    Response := Client.GetAccount('');
    try
      WriteLn(Response.Data.AsJSON);
    finally
      Response.Free;
    end;
  finally
    Client.Free;
  end;
```

An empty account argument uses the constructor’s workspace ID. Every other path ID must be supplied. With a bearer token, set `Client.AccessToken`. Public methods omit workspace credentials; signer methods send only their signer access code. A client supplied with an external transport borrows that transport; otherwise it owns its default libcurl transport. Use one client per worker/thread and do not change its credentials concurrently.

Every call returns a response you own. `Response.JSON` contains the entire response, and `Response.Data` borrows the envelope’s `data`. Flat OAuth responses are returned intact through both properties. Free the response after reading either property. The SDK borrows request bodies and query lists; free them yourself. `TJSONObject.Add` and `TJSONArray.Add` take ownership of child JSON values.

Typical JSON responses:

```json
{
  "status": 200,
  "message": "Success",
  "data": {"id": "workspace-id", "name": "Example Workspace"}
}
```

## Upload a document

```pascal
Response := Client.UploadDocument('', 'contract.pdf');
try
  DocumentID := Response.Data.FindPath('id').AsString;
finally
  Response.Free;
end;
```

The API takes a multipart `file` containing PDF bytes; the SDK streams the file through libcurl’s MIME API. The published limits are 25 MB and 2,000 pages. Upload processing is asynchronous. A virtual signature request can be created in `uploaded`, `metadata_processing` or `metadata_ready`. A request collecting fields must wait until `metadata_ready`, because its placements reference processed pages. Check `GetDocument` or subscribe to `document_metadata_ready`; stop on processing failure rather than polling indefinitely.

The response’s document includes `id`, `name`, `status`, `pages`, `artifacts`, tags and timestamps. Full fields and nullability are in [Document](docs/SCHEMAS.md#document).

## Create or select signers

```pascal
SignerBody := TJSONObject.Create([
  'full_name', 'Example Signer',
  'email', 'signer@example.com'
]);
try
  Response := Client.CreateSigner('', SignerBody);
  try
    SignerID := Response.Data.FindPath('id').AsString;
  finally
    Response.Free;
  end;
finally
  SignerBody.Free;
end;
```

Use `ListSigners` with a search query to reuse an existing signer. Additional signer fields include `whatsapp_phone_number` in E.164 format and `government_id` for CPF/CNPJ. `UpdateSigner` sends only your supplied fields. Signer IDs belong to their workspace; retain the workspace ID with each record.

## Estimate and request signatures

Build one assignment body and use it for estimation and creation:

```pascal
AssignmentBody := TJSONObject.Create(['method', 'virtual']);
try
  Signers := TJSONArray.Create;
  AssignmentBody.Add('signers', Signers);
  Signers.Add(TJSONObject.Create([
    'id', SignerID,
    'verification_method', 'Email'
  ]));
  AssignmentBody.Add('message', 'Please review and sign');
  Response := Client.EstimateAssignmentCost(DocumentID, AssignmentBody);
  try
    WriteLn(Response.Data.AsJSON);
  finally
    Response.Free;
  end;
  Response := Client.CreateAssignment(DocumentID, AssignmentBody);
  try
    WriteLn(Response.Data.AsJSON);
  finally
    Response.Free;
  end;
finally
  AssignmentBody.Free;
end;
```

The request uses `signers: [{"id": "signer-id"}]`. It can also include `entries`, `message`, `expires_at` and `copy_receivers`. Explicit expiration must be at least one hour ahead. `method: collect` places fields using page IDs, field IDs, signer IDs and display settings. See [CreateAssignment](docs/API.md#createassignment) for the complete request and [Assignment](docs/SCHEMAS.md#assignment) for the full response.

The assignment response includes its ID, signers, summary, items and `signing_urls`. Send each returned URL only to its intended signer. `step` defines signing order: all signers must specify contiguous steps starting at 1 when you use sequencing; signers in a shared step work in parallel. Later steps receive invitations when the previous step finishes.

### Email, WhatsApp and A1/A3 certificates

| Verification | Notification | Preparation |
| --- | --- | --- |
| `Email` | `Email` | Signer has an email; email OTP is required before signing. |
| `Whatsapp` | `Whatsapp` | Signer has an E.164 WhatsApp number; account has a paid subscription. |
| `DigitalCertificate` | `Email` or `Whatsapp` | Account has the Digital Certificate feature; signer has the required CPF/CNPJ; each certificate signer is alone in its signing step. |

`notification_methods` takes exactly one entry. Omit verification and notification to default to Email, or send one side and let the API infer the matching side. The server rejects incompatible pairings. Use estimation responses for current prices and feature entitlements.

A certificate request is ordinary assignment JSON:

```json
{
  "method": "virtual",
  "signers": [{
    "id": "certificate-signer-id",
    "verification_method": "DigitalCertificate",
    "notification_methods": ["Email"],
    "step": 1
  }]
}
```

Assinafy’s signing page uses the signer’s ICP-Brasil A1/A3 certificate through its Web PKI browser extension. A CPF requires the corresponding person’s certificate; a CNPJ requires an e-CNPJ for that company. The SDK creates and follows these requests and retrieves the resulting PAdES document. Device certificates and private keys remain with the signer. The published specification mentions certificate start/complete routes but does not define their request/response contract; use the returned signing URL for that ceremony.

Signer-facing REST methods support one-time access codes, OTP verification, data confirmation, terms, field submission, rejection and signature PNGs. They are documented in [API reference](docs/API.md). A signer code is sensitive; avoid logging signing URLs and query strings. DigitalCertificate signers must complete the certificate ceremony rather than submit the ordinary `SignAssignmentItems` request.

## Follow completion and download artifacts

`GetDocument` retrieves status. `ListDocumentActivities`, `ListAssignments` and `ListWhatsAppNotifications` provide the published activity and notification views. Use `EstimateResendCost` before `ResendSignatureRequest`; resending may consume credits. `ResetAssignmentExpiration` requires the documented expiration JSON. Handle rejection and expiration as terminal states in your application.

After signing and certification, inspect the document’s `artifacts` before downloading. Artifact names include `original`, `certificated`, `certificate-page`, `pades` and `bundle`. Availability depends on document state and signing method. Use `pades` for the version retaining ICP-Brasil signatures; certification can flatten those signatures in the `certificated` PDF.

```pascal
Response := Client.DownloadDocumentArtifact(DocumentID, 'certificated');
try
  Output := TFileStream.Create('signed-contract.pdf', fmCreate);
  try
    Response.SaveToStream(Output);
  finally
    Output.Free;
  end;
finally
  Response.Free;
end;
```

Download responses retain raw bytes and their content type. The SDK buffers responses in memory; budget memory for document size and simultaneous downloads. Open the destination after the request succeeds so an HTTP error cannot truncate an existing file. For crash-safe replacement, write a temporary file and rename it in your application.

## Connect customer workspaces with OAuth

Register a **Public** application for distributed software, or a **Confidential** application for a controlled backend, in the Assinafy application. Register the exact HTTPS redirect URI and the maximum permissions the application may request. A public application has a public `client_id` and uses PKCE; a confidential application also sends its secret during token requests. IDs that look like hashes are still public identifiers.

The SDK accepts your application’s registration. A product can use a hosted HTTPS callback with a local relay or an admin-pasted code, as the CLI and WordPress integration do, while keeping the verifier on the initiating device. The host application receives the callback and supplies its decoded query values to the SDK.

1. Read `Client.GetOAuthResourceMetadata` at the API origin. It returns `resource`, `authorization_servers`, `scopes_supported` and `bearer_methods_supported` without an envelope. The authorization server publishes `/.well-known/oauth-authorization-server` with its authorization, token, revocation and userinfo URLs. Keep environments aligned.
2. Generate a fresh PKCE pair and state. Store the verifier, state and expected issuer with the initiating user’s session.
3. Redirect the browser to `AuthorizationURL`; PKCE uses SHA-256 and `S256` for every application.
4. At your registered callback, call `ValidateOAuthCallback` with the decoded query values and stored state/issuer. Consume the saved session transaction once. Reject mismatched state, issuer, duplicate parameters and authorization errors.
5. Exchange the returned code immediately with `ExchangeCode`. Codes expire after 60 seconds and can be used once.
6. Persist the returned credentials securely. Assign the access token to `Client.AccessToken` and call `ListMyAccounts`; save the selected workspace’s `data[0].id` with the connection.
7. Serialize refreshes per connection, persist each new refresh token before using the access token, and revoke the current token on disconnect.

```pascal
Config.ClientID := GetEnvironmentVariable('ASSINAFY_CLIENT_ID');
Config.RedirectURI := 'https://app.example.com/oauth/callback';
Config.Scopes := 'account:read documents:read documents:write offline_access';
Config.Issuer := 'https://auth-sandbox.assinafy.com.br';
Config.Resource := 'https://sandbox.assinafy.com.br';
PKCE := GeneratePKCE;
State := GenerateState;
URL := AuthorizationURL(Config, State, PKCE.Verifier);
// Store PKCE.Verifier and State in the initiating user's session, then redirect.
```

At the callback:

```pascal
Code := ValidateOAuthCallback(CallbackQuery, SavedState, Config.Issuer);
Response := ExchangeCode(Client, Config, Code, SavedVerifier);
try
  // Persist the response securely before using its credentials.
  Client.AccessToken := Response.Data.FindPath('access_token').AsString;
finally
  Response.Free;
end;
```

The flat token response is:

```json
{
  "access_token": "access-token",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "account:read documents:read documents:write",
  "refresh_token": "new-refresh-token",
  "id_token": "signed-id-token"
}
```

`refresh_token` requires `offline_access`; `id_token` requires `openid`. Read the scopes actually returned. Tokens cover one workspace. OAuth cannot access billing, credential administration, account lifecycle or webhook signing secrets. A `403` scope challenge identifies a missing permission; reconnect with that permission instead of retrying. For OIDC, validate the ID token’s signature and `iss`, `aud`, `exp`, `nonce` using an OIDC implementation before treating it as identity; the SDK transports tokens and provides `GetOAuthUserInfo` but does not validate JWTs.

```pascal
Response := RefreshToken(Client, Config, CurrentRefreshToken);
try
  // Atomically persist Response.Data.refresh_token before using access_token.
finally
  Response.Free;
end;
Response := RevokeToken(Client, Config, LatestStoredToken, 'refresh_token');
Response.Free;
```

Refresh tokens rotate. Reusing a retired token ends the connection. A timeout can mean the server already rotated it; re-read saved state and reconnect when the result is indeterminate. The SDK sends each request once and leaves refresh locking, durable storage and scheduling to your application.

[examples/oauth_connect.pas](examples/oauth_connect.pas) demonstrates browser authorization and callback exchange while keeping the verifier in memory. It does not persist credentials. Build it with `make examples` and run `build/oauth_connect` after configuring the application registration.

## Receive signed webhooks

Use `CreateWebhookEndpoint` to register a delivery URL, contact email and events. Paid plans allow up to three endpoints; the server enforces the workspace’s actual entitlement. `ListWebhookEndpoints`, `GetWebhookEndpoint`, `UpdateWebhookEndpoint` and `DeleteWebhookEndpoint` manage individual endpoints. The older subscription methods remain available.

```json
{
  "url": "https://app.example.com/assinafy/webhook",
  "email": "webhooks@example.com",
  "events": ["document_ready", "signer_rejected_document"],
  "name": "Signing events",
  "is_active": true,
  "signing_enabled": true
}
```

Retrieve the endpoint secret through `GetWebhookEndpointSigningSecret` using an API key or permitted user token; OAuth applications cannot read it. Store it securely. Secret rotation invalidates the old secret immediately, so coordinate `RotateWebhookEndpointSigningSecret` with your receiver.

Verify before parsing JSON or accepting any event:

```pascal
if not VerifyWebhookHeaders(EndpointSecret, RequestHeaders, RawRequestBody) then
  raise Exception.Create('Invalid webhook delivery');
```

`RequestHeaders` is a list of HTTP `name: value` lines or `name=value` pairs. Header names are case-insensitive. The verifier uses the raw body bytes, `webhook-id`, `webhook-timestamp`, a base64-decoded `whsec_` key and HMAC-SHA256. It accepts a matching `v1` signature among multiple entries, compares in constant time and enforces a five-minute clock window. Keep your server clock synchronized. Duplicate IDs/timestamps, missing headers, malformed keys, altered bodies and stale deliveries fail verification.

Persist and deduplicate valid events by `webhook-id`, enqueue processing and return `2xx` promptly. Each endpoint is delivered independently. The body contains `id`, `event`, `message`, `payload`, `origin`, `created_at`, `subject`, `object` and `account_id`; subject/object are polymorphic resource objects. [WebhookEvent](docs/SCHEMAS.md#webhookevent) defines the complete envelope. Do not depend on ordering between `assignment_created` and `document_metadata_ready`.

Use `ListWebhookEventTypes` for the catalog, `ListWebhookDeliveries` for delivery results, and `RetryWebhookDelivery` for an explicit retry. Delivery retries can produce the same event again, so deduplication must remain effective.

## Templates, fields and tags

`ListTemplates` retrieves reusable templates. `EstimateDocumentFromTemplateCost` and `CreateDocumentFromTemplate` estimate and create a document using its template ID, role-to-signer mappings and field values. The API reference includes every nested field; use the template’s returned roles/pages rather than inventing identifiers. The current specification publishes template listing and document creation, with no template CRUD contract.

`ListFields`, `CreateField`, `GetField`, `UpdateField`, `DeleteField`, `ValidateFieldValue`, `ValidateMultipleFieldValues` and `ListFieldTypes` manage field definitions and server-side value validation. These field validations are separate from a signer’s Email/WhatsApp identity verification.

`ListTags`, `CreateTag`, `UpdateTag` and `DeleteTag` manage workspace tags. `ListDocumentTags`, `ReplaceDocumentTags`, `AttachDocumentTags` and `DetachDocumentTag` associate them with documents. Omitting an optional JSON property preserves it on partial updates; explicit `TJSONNull` clears nullable values where the API permits it.

## Pagination, errors and networking

List methods accept the documented query parameters as a `TStrings` of `name=value` pairs:

```pascal
Query := TStringList.Create;
try
  Query.Add('page=1');
  Query.Add('per-page=100');
  Query.Add('search=Example');
  Response := Client.ListDocuments('', Query);
  try
    WriteLn(Response.Data.AsJSON);
    WriteLn(Response.Header('X-Pagination-Page-Count'));
  finally
    Response.Free;
  end;
finally
  Query.Free;
end;
```

Pagination headers are `X-Pagination-Current-Page`, `X-Pagination-Total-Count`, `X-Pagination-Page-Count` and `X-Pagination-Per-Page`. Maximum `per-page` is 100. Preserve response headers for rate limiting: `X-Rate-Limit-Limit`, `X-Rate-Limit-Remaining`, `X-Rate-Limit-Reset` and `Retry-After`.

| Exception | Meaning |
| --- | --- |
| `EAssinafyInputError` | Required input, URL, credential, file or security validation failed before sending. |
| `EAssinafyTransportError` | DNS, connection, TLS, timeout or native crypto failure. The request may already have reached the server. |
| `EAssinafyProtocolError` | Successful JSON response could not be decoded. |
| `EAssinafyAPIError` | Non-2xx HTTP response, including OAuth errors. Read `StatusCode`, `ErrorCode`, `ResponseBody`, `RetryAfter` and `Authenticate`. |

Ordinary filesystem exceptions can arise when reading an upload or writing a destination. Error bodies can contain personal data; apply your application’s redaction policy before logging them. The SDK does not log credentials, payloads or signing URLs.

`Client.TimeoutMS` defaults to 30,000 milliseconds and limits connection and overall transfer time. `Client.CAFile` optionally selects a trusted PEM CA bundle. Certificate and hostname verification are always enabled, TLS requires version 1.2 or newer, and redirects are rejected so credentials cannot follow them. API URLs require HTTPS; HTTP is accepted only for explicit loopback testing. System proxy settings follow libcurl’s normal behavior.

There are no automatic retries. A `429` carries the server’s delay; apply bounded retries for safe operations in your application. Before repeating any mutation, establish whether the first request succeeded. Token codes and refresh tokens require particular care because they are single-use.

## Build and test

```sh
make check
```

This verifies generated files against the bundled contract, checks every operation/document link and source hygiene, compiles with warnings treated as errors, runs all 106 method checks plus response/security/helper tests, exercises real local HTTP/multipart/binary/TLS behavior, and compiles both examples. Tests enable range, overflow, I/O, assertion and heap checks. CI runs on Linux and macOS. The local HTTP tests need permission to bind loopback ports.

Live sandbox checks use explicitly supplied environment credentials:

```sh
make live
```

By default these perform read operations, OAuth discovery and an invalid-client OAuth contract check. Set `ASSINAFY_TEST_MUTATIONS=1` and `ASSINAFY_TEST_PDF` to a local PDF to exercise isolated document, signer and tag creation, updates, estimation, binary retrieval and cleanup. The test removes only resources it created; it does not send invitations. A successful OAuth consent/refresh cycle needs a registered application and user authorization. End-to-end Email/WhatsApp OTP and A1/A3 signing need a consenting signer, access to their channel and, for certificates, their device. Unit and HTTP contract tests cover SDK requests independently of these requirements.

## Maintaining the API contract

Download the current [OpenAPI document](https://api.assinafy.com.br/v1/docs/openapi.json), preserve all operations and schemas, and normalize example contact addresses to reserved domains before updating `docs/openapi.json`. Run `python3 scripts/generate.py`, inspect the generated resource methods/payload references and run `make check`. The generator keeps methods, per-method checks and documentation consistent. Keep `VERSION`, `AssinafyVersion`, release notes and tags aligned. Release tags use `vMAJOR.MINOR.PATCH`; this initial minor release is `v0.1.0`.

Local agent instructions live in ignored `AGENTS.md` and `CLAUDE.md`. Product documentation and release notes describe behavior, contracts and usage.
