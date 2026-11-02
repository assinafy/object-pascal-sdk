# Assinafy Object Pascal SDK

Cliente nativo para as 118 operações publicadas da [API Assinafy v1](https://api.assinafy.com.br/v1/docs), compatível com Free Pascal/Lazarus e, experimentalmente, Delphi 12+ no Windows. A [referência da API](docs/API.md) contém cada método, parâmetro, payload, resposta, erro e modo de autenticação; [esquemas](docs/SCHEMAS.md), [tipos e helpers](docs/SDK.md) e o [OpenAPI](docs/openapi.json) completam a documentação.

## Requisitos e instalação

Free Pascal 3.2.2 é a versão estável oficial atual; o projeto não publica um canal LTS separado. O SDK usa FCL, libcurl com TLS 1.2+ e OpenSSL 3 `libcrypto`. Adicione `src` aos caminhos de unidades e includes:

```sh
git clone https://github.com/assinafy/object-pascal-sdk.git
cd object-pascal-sdk
mkdir -p build
fpc -Fu./src -Fi./src -FU./build -FE./build seu_programa.pas
```

Ubuntu/Debian: `sudo apt-get install fp-compiler fp-units-fcl fp-units-net libcurl4-openssl-dev libssl-dev`. macOS: `brew install fpc openssl@3` e inicie o processo com `DYLD_LIBRARY_PATH="$(brew --prefix openssl@3)/lib"`. Em programas Unix com threads, coloque `cthreads` primeiro no `uses`.

A integração Delphi usa `System.JSON`, `System.Net.HttpClient` e o armazenamento de certificados do Windows, sem libcurl, mas ainda precisa ser compilada e executada em Delphi 12+ Win32/Win64. Consulte [delphi/AssinafySDK.dproj](delphi/AssinafySDK.dproj) e [delphi/check.ps1](delphi/check.ps1). Não trate a compilação Free Pascal como validação do Delphi.

## Configuração e autenticação

| Modo | Configuração | Uso |
| --- | --- | --- |
| API key | `AAPIKey` + `AAccountID`; cabeçalho `X-Api-Key` | Automação do próprio workspace em servidor confiável. |
| OAuth2 | cliente sem API key; `AccessToken`; Bearer | Marketplace, SaaS, aplicativo móvel ou conexão de workspace de terceiro. |

Produção usa `https://api.assinafy.com.br/v1`; sandbox usa `https://sandbox.assinafy.com.br/v1`. Os exemplos leem `ASSINAFY_BASE_URL`, `ASSINAFY_API_KEY`, `ASSINAFY_ACCOUNT_ID` e `ASSINAFY_ACCESS_TOKEN`; [.env.example](.env.example) lista também as opções OAuth. Nunca combine API key e Bearer. Em OAuth, chame `ListMyAccounts` e salve o workspace autorizado junto dos tokens.

```pascal
Client := TAssinafyClient.Create(
  GetEnvironmentVariable('ASSINAFY_API_KEY'),
  GetEnvironmentVariable('ASSINAFY_ACCOUNT_ID'),
  AssinafySandboxURL);
Client.AccessToken := GetEnvironmentVariable('ASSINAFY_ACCESS_TOKEN');
```

Métodos públicos omitem credenciais. Métodos de signatário enviam somente o `signer-access-code`; use `ListSignerDocumentsAsWorkspace` e `SearchSignerDocumentsAsWorkspace` quando a mesma rota precisar de credenciais do workspace.

## Fluxo completo do documento

1. Envie um PDF de até 25 MiB/2.000 páginas e guarde seu ID. Uma atribuição `virtual` pode ser criada durante o processamento; `collect` exige `metadata_ready` para posicionar campos.
2. Crie ou reutilize signatários. Guarde seus IDs e informe CPF/CNPJ em `government_id` quando o método exigir.
3. Escolha verificação e notificação, estime o custo e confira `has_sufficient_resources`.
4. Crie a atribuição. Preserve etapas contíguas; entregue cada URL de assinatura apenas ao destinatário correto e nunca a registre em logs.
5. Acompanhe webhooks/estado até conclusão, rejeição ou expiração. Baixe os artefatos disponíveis; prefira `pades` para manter assinaturas ICP-Brasil.

```pascal
Client.TimeoutMS := 180000;
Response := Client.UploadDocument(AccountID, 'contrato.pdf');
try DocumentID := JSONString(JSONFind(Response.Data, 'id')); finally Response.Free; end;

SignerBody := JSONObj(['full_name', 'Example Signer', 'email', 'signer@example.com']);
try
  Response := Client.CreateSigner(AccountID, SignerBody);
  try SignerID := JSONString(JSONFind(Response.Data, 'id')); finally Response.Free; end;
finally SignerBody.Free; end;

AssignmentBody := JSONObj(['method', 'virtual']);
JSONAdd(AssignmentBody, 'signers', JSONArr([
  JSONObj(['id', SignerID, 'verification_method', 'Email',
    'notification_methods', JSONArr(['Email'])])
]));
try
  Response := Client.EstimateAssignmentCost(DocumentID, AssignmentBody);
  try
    if not JSONBoolean(JSONFind(Response.Data, 'has_sufficient_resources')) then
      raise EAssinafyInputError.Create('Recursos insuficientes');
  finally Response.Free; end;
  Response := Client.CreateAssignment(DocumentID, AssignmentBody);
  Response.Free;
finally AssignmentBody.Free; end;
```

[examples/workflow.pas](examples/workflow.pas) é o programa completo. Executá-lo cria recursos e envia uma solicitação ao endereço informado.

| Verificação | Notificação permitida | Requisitos principais |
| --- | --- | --- |
| `Email` | `Email` | Código enviado ao e-mail. |
| `Whatsapp` | `Whatsapp` | Plano pago e telefone WhatsApp. |
| `DigitalCertificate` | `Email` ou `Whatsapp` | Recurso habilitado, CPF/CNPJ, `virtual` e um signatário por etapa de certificado. |
| `IdDocumentFaceMatchBasic` | `Email` ou `Whatsapp` | Recurso habilitado, CPF válido e consentimento biométrico explícito. |

Envie exatamente um canal. A API pode inferi-lo quando omitido. A1/A3 ocorre na página de assinatura da Assinafy; o SDK não inventa nem transporta a cerimônia do dispositivo. `collect` com certificado é rejeitado antes da rede. Templates aceitam certificado somente quando não geram campos de signatário.

### Verificação biométrica e análise de identidade

`GetIdentityVerificationStatus` e `StartIdentityVerification` recebem apenas o código do signatário. Inicie com `{"consent":true}` somente após consentimento; siga `can_start`, preserve a URL inteira com fragmento e reinicie apenas sessões `Expired`. `InReview` permite assinatura enquanto a certificação aguarda e `pending_identity_review` não é falha terminal.

O workspace usa `GetSignerIdentityReview`, `DownloadSignerIdentityReviewImage` e `DecideSignerIdentityReview`. Evidências são temporárias e `no-store`. `Approved` libera o fluxo quando todos os requisitos terminam; `Rejected` cancela o documento e notifica os destinatários.

## Aplicativos de marketplace e OAuth2

Registre uma aplicação pública ou confidencial em **Integrações → Apps OAuth → Novo aplicativo**, com redirects HTTPS exatos e escopos mínimos. Aplicativos distribuídos/móveis são públicos e nunca armazenam `client_secret`.

1. Consulte `GetOAuthResourceMetadata`, use o emissor anunciado e mantenha API/emissor no mesmo ambiente.
2. Gere `state` e PKCE S256; salve estado, verifier, emissor e redirect na sessão local.
3. Abra `AuthorizationURL`, valide callback único com `ValidateOAuthCallback` e consuma o código uma vez.
4. Use `ExchangeCode`; salve tokens com o workspace de `ListMyAccounts`. `openid` pode retornar `id_token`, cuja assinatura e claims devem ser validadas pela aplicação.
5. Serialize `RefreshToken`, persista o refresh token rotacionado antes de usar o novo access token e nunca repita resultado incerto automaticamente. Use `RevokeToken` ao desconectar.

```pascal
PKCE := GeneratePKCE;
State := GenerateState;
URL := AuthorizationURL(Config, State, PKCE.Verifier);
Code := ValidateOAuthCallback(CallbackQuery, State, Config.Issuer);
Response := ExchangeCode(OAuthClient, Config, Code, PKCE.Verifier);
```

[examples/oauth_connect.pas](examples/oauth_connect.pas) demonstra PKCE e troca do código sem persistir credenciais. O SDK não abre navegador/callback, agenda refresh, armazena segredos nem valida JWT.

## Webhooks assinados

Salve o segredo retornado uma vez por `CreateWebhookEndpoint` ou ao habilitar assinatura em `UpdateWebhookEndpoint`; OAuth não recupera o segredo perdido, mas pode rotacioná-lo. Até três endpoints dependem do plano. `DeleteWebhookEndpointByURL` exige a URL exata.

```pascal
if not VerifyWebhookHeaders(EndpointSecret, RequestHeaders, RawRequestBody) then
  raise Exception.Create('Webhook inválido');
```

Verifique os bytes originais antes do JSON, rejeite timestamps fora de cinco minutos, deduplique `webhook-id`, enfileire o processamento e responda `2xx` rapidamente. Os 31 eventos, headers e payloads completos estão em [Webhook deliveries](docs/API.md#webhook-deliveries).

## Contratos, modelos e demais recursos

O SDK inclui documentos, contratos e termos, renovação/encerramento, relações entre contratos, templates, campos, etiquetas, usuários, sessões, MFA, preferências, workspaces, webhooks e artefatos. Não há modelos Pascal que descartem campos: requisições/respostas usam JSON nativo e preservam nulos, arrays, números e extensões futuras. Consulte [docs/API.md](docs/API.md) para os 118 métodos e [docs/SCHEMAS.md](docs/SCHEMAS.md) para os 49 modelos compartilhados.

## Respostas, erros e testes

Cada `TAssinafyResponse`, body JSON e query criados pelo chamador precisam de `Free`; a resposta possui o JSON decodificado. Clientes são síncronos e devem ser um por worker. O timeout padrão de 30 s cobre a transferência inteira; timeout de mutação é ambíguo. Não há retry automático. `EAssinafyAPIError` preserva status, body, código, `Retry-After`, desafio de escopo e rate limits; `EAssinafyProtocolError` preserva status/body quando uma resposta não pode ser interpretada.

```sh
make check
```

Esse comando verifica o contrato, compila com warnings como erros e executa testes das 118 operações, OAuth, criptografia, JSON, HTTP/TLS, multipart/binário e exemplos. `make live` exige credenciais sandbox; mutações isoladas usam `ASSINAFY_TEST_MUTATIONS=1` e `ASSINAFY_TEST_PDF`. Testes de consentimento OAuth, OTP, biometria e A1/A3 exigem pessoas/canais/dispositivos próprios e não devem ser simulados em produção.

## Licença

[MIT](LICENSE).
