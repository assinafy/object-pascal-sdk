# Assinafy Object Pascal SDK

Cliente nativo em Object Pascal para a [API Assinafy v1](https://api.assinafy.com.br/v1/docs), com suporte às 112 operações REST publicadas. Use o SDK em serviços Free Pascal ou aplicações Lazarus para gerenciar documentos, signatários, solicitações de assinatura, modelos, campos, etiquetas, espaços de trabalho e webhooks.

Este guia acompanha um documento do envio do PDF até a assinatura e o download dos arquivos finais. A [referência da API](docs/API.md) documenta cada método com os esquemas completos de requisição e resposta, exemplos de estrutura, parâmetros, autenticação e erros. Os [esquemas de dados](docs/SCHEMAS.md) definem os modelos compartilhados; a [referência do SDK](docs/SDK.md) explica tipos, gerenciamento de memória, transportes e funções auxiliares. O [contrato OpenAPI](docs/openapi.json) está disponível para ferramentas e consulta offline.

## Sumário

- [Requisitos e instalação](#requisitos-e-instalação)
- [Ambientes e configuração](#ambientes-e-configuração)
- [Escolha da autenticação](#escolha-da-autenticação)
- [Fluxo completo do documento](#fluxo-completo-do-documento)
- [Aplicativos de marketplace e OAuth2](#aplicativos-de-marketplace-e-oauth2)
- [Webhooks assinados](#webhooks-assinados)
- [Modelos, campos e etiquetas](#modelos-campos-e-etiquetas)
- [Respostas, paginação e erros](#respostas-paginação-e-erros)
- [Testes e desenvolvimento](#testes-e-desenvolvimento)
- [Licença](#licença)

## Requisitos e instalação

- **Free Pascal 3.2.2**, a [versão estável oficial atual](https://www.freepascal.org/download.html). O Free Pascal publica versões estáveis e não possui um canal LTS separado. Projetos Lazarus que usam esse compilador podem incluir as unidades do SDK. Essa configuração utiliza a FCL do Free Pascal.
- Unidades JSON/base64 da FCL e as interfaces `libcurl` do Free Pascal.
- **libcurl 7.56 ou superior**, com HTTPS habilitado, certificados de autoridades certificadoras confiáveis e TLS 1.2 ou superior.
- **OpenSSL 3 libcrypto** para PKCE, geração aleatória de estado e assinaturas de webhooks. O TLS das requisições HTTP usa a implementação configurada na libcurl. Instale versões mantidas dessas bibliotecas pelo gerenciador de pacotes do sistema operacional.
- Python 3.9 ou superior e a ferramenta de linha de comando do OpenSSL para executar as verificações de desenvolvimento.

Clone o repositório e adicione `src` aos caminhos de unidades e arquivos de inclusão do compilador:

```sh
git clone https://github.com/assinafy/object-pascal-sdk.git
cd object-pascal-sdk
mkdir -p build
fpc -Fu./src -Fi./src -FU./build -FE./build seu_programa.pas
```

No Lazarus, adicione `src` em **Project Options → Compiler Options → Paths → Other unit files** e **Include files**. Inclua `Assinafy` e `AssinafyHttp` na aplicação. Programas de console em Unix que usam threads devem colocar `cthreads` primeiro na cláusula `uses`.

No Ubuntu/Debian, instale as unidades do compilador e as bibliotecas nativas de desenvolvimento:

```sh
sudo apt-get install fp-compiler fp-units-fcl fp-units-net libcurl4-openssl-dev libssl-dev
```

No macOS:

```sh
brew install fpc openssl@3
export DYLD_LIBRARY_PATH="$(brew --prefix openssl@3)/lib"
```

O processo da aplicação precisa localizar `libcrypto.3.dylib` para utilizar OAuth e verificar assinaturas de webhooks. Com o OpenSSL instalado pelo Homebrew, configure `DYLD_LIBRARY_PATH` antes de iniciar a aplicação, inclusive quando ela for executada fora do terminal.

A integração contínua executa os testes em Linux e macOS. No Windows, são necessárias unidades Free Pascal compatíveis, biblioteca de importação e runtime da libcurl, certificados de autoridades confiáveis e runtime OpenSSL 3 com a mesma arquitetura do executável. As compilações Windows ainda não foram validadas neste projeto.

### Delphi no Windows

A implementação Delphi é **experimental**: os alvos previstos são Delphi 12 ou superior, Win32 e Win64, e a compilação e os testes nesse compilador ainda precisam ser executados. O mesmo código mantém as 112 operações e utiliza `System.JSON` e `System.Net.HttpClient`; Delphi não depende de libcurl. O TLS usa o armazenamento de certificados do Windows, com TLS 1.2/1.3 e redirecionamentos desabilitados.

O [Delphi Community Edition](https://www.embarcadero.com/products/delphi/starter) fornece o compilador para usuários elegíveis. Consulte os [requisitos de licença](https://www.embarcadero.com/products/delphi/starter/faq). A instalação requer Windows; Free Pascal em modo Delphi não substitui essa ferramenta para validar compatibilidade.

Para consumir os fontes:

1. Adicione a pasta `src` aos caminhos **Search path** e **Include file search path** do projeto, ou ao **Library path** em **Tools → Options → Language → Delphi**. Mantenha os caminhos de compilação Win32 e Win64 separados.
2. Para fontes UTF-8 sem BOM, defina [**Delphi Compiler → Compiling → Code page**](https://docwiki.embarcadero.com/RADStudio/Athens/en/Compiling) como `65001` ou use `--codepage:65001` na linha de comando. O pacote e o comando de verificação já usam essa configuração.
3. Inclua `Assinafy`, `AssinafyHttp` e `AssinafyJson`. Os exemplos deste guia usam os auxiliares JSON compartilhados. Aplicações Free Pascal existentes podem continuar usando `fpjson`; aplicações Delphi também podem fornecer valores nativos de `System.JSON`.
4. Para OAuth e webhooks, coloque o OpenSSL 3 e suas DLLs dependentes ao lado do executável: `libcrypto-3.dll` em Win32 ou `libcrypto-3-x64.dll` em Win64. A arquitetura precisa corresponder à aplicação. A chave de API não exige operações criptográficas locais.
5. Compile [delphi/AssinafySDK.dproj](delphi/AssinafySDK.dproj) quando precisar de um pacote de runtime. O uso direto dos fontes não exige instalar um pacote no IDE.

`CAFile` permanece disponível no transporte Free Pascal. No transporte Delphi, um valor não vazio gera `EAssinafyInputError`: configure as autoridades confiáveis no Windows. O SDK preserva a validação de cadeia e hostname do sistema operacional.

Para executar a verificação Delphi em uma máquina Windows isolada, abra o terminal configurado pelo RAD Studio, instale Python e disponibilize o executável `openssl`. Execute, ajustando a pasta do runtime e a plataforma:

```powershell
.\delphi\check.ps1 -Platform Win32 -CryptoDirectory C:\OpenSSL-Win32\bin -TrustTestCertificate
.\delphi\check.ps1 -Platform Win64 -CryptoDirectory C:\OpenSSL-Win64\bin -TrustTestCertificate
```

O comando reconstrói o pacote, os testes e os exemplos; confere as 112 operações; executa os testes de JSON, autenticação, OAuth, webhooks, HTTP e TLS; e compila os trechos Pascal do README. `-TrustTestCertificate` permite confiar temporariamente no certificado local gerado para o teste de TLS, no armazenamento **CurrentUser → Root**. O comando remove esse certificado ao concluir, inclusive quando um teste falha. Um segundo certificado permanece não confiável para verificar a rejeição; o teste também verifica hostname incorreto, redirecionamentos e timeout durante uma resposta contínua. Não execute esse teste interrompendo o processo durante a alteração temporária do armazenamento.

## Ambientes e configuração

| Configuração | Sandbox | Produção |
| --- | --- | --- |
| URL base da API | `https://sandbox.assinafy.com.br/v1` | `https://api.assinafy.com.br/v1` |
| Aplicação | `https://app-sandbox.assinafy.com.br` | `https://app.assinafy.com.br` |
| Emissor OAuth | `https://auth-sandbox.assinafy.com.br` | `https://auth.assinafy.com.br` |

Use credenciais próprias de cada ambiente. URLs da API exigem HTTPS e terminam em `/v1`. HTTP é aceito somente para testes locais em loopback. Mantenha a API, o emissor OAuth e a aplicação registrada no mesmo ambiente.

O SDK recebe as credenciais explicitamente. Os exemplos executáveis leem as variáveis abaixo diretamente do ambiente; configure apenas as variáveis do modo de autenticação escolhido:

| Variável | Finalidade |
| --- | --- |
| `ASSINAFY_BASE_URL` | URL completa da API, terminada em `/v1`. |
| `ASSINAFY_API_KEY` | Chave de API para integração direta. Use com `ASSINAFY_ACCOUNT_ID`. |
| `ASSINAFY_ACCOUNT_ID` | Identificador do espaço de trabalho para integração direta. No fluxo OAuth, o exemplo obtém esse identificador pela API. |
| `ASSINAFY_ACCESS_TOKEN` | Token de acesso obtido pelo OAuth. Use sem chave de API. |
| `ASSINAFY_CLIENT_ID` | Identificador público da aplicação OAuth registrada. |
| `ASSINAFY_CLIENT_SECRET` | Segredo da aplicação OAuth confidencial; omita em aplicações públicas. |
| `ASSINAFY_REDIRECT_URI` | URL HTTPS de retorno, exatamente como registrada. |
| `ASSINAFY_OAUTH_ISSUER` | Emissor obtido pela descoberta do recurso protegido. |
| `ASSINAFY_OAUTH_RESOURCE` | Indicador opcional de recurso obtido pela descoberta. |

Consulte [.env.example](.env.example) para os nomes das configurações e URLs de exemplo. Os dois programas executáveis usam o sandbox quando `ASSINAFY_BASE_URL` não está definida. Armazene as credenciais em um cofre de segredos adequado ao ambiente da aplicação.

## Escolha da autenticação

Escolha **um** dos dois modos para a integração:

| Modo | Configuração | Uso |
| --- | --- | --- |
| Chave de API + ID do espaço de trabalho | `AAPIKey` e `AAccountID` no construtor; cabeçalho `X-Api-Key`. | Automatizar o seu próprio espaço de trabalho em um serviço sob seu controle. |
| OAuth2 | Cliente sem chave de API; `AccessToken` obtido após consentimento; cabeçalho `Authorization: Bearer`. | Conectar o espaço de trabalho de um cliente ao seu aplicativo com as permissões autorizadas por ele. |

Uma chave de API exige o ID do espaço de trabalho. OAuth não exige chave de API: o usuário escolhe o espaço de trabalho durante o consentimento, e `ListMyAccounts` retorna seu identificador. Esse ID é usado nos caminhos das operações da conta. O SDK rejeita a configuração simultânea de chave de API e token Bearer; use clientes separados para conexões diferentes.

### Integração direta

Crie uma chave de API nas configurações da conta e anote o ID do espaço de trabalho:

```pascal
program ConsultarConta;

{$IFDEF FPC}{$mode objfpc}{$H+}{$ENDIF}
{$IFDEF FPC}{$codepage utf8}{$ENDIF}

uses
  {$ifdef unix}cthreads,{$endif}
  SysUtils, AssinafyJson, Assinafy, AssinafyHttp;

var
  Client: TAssinafyClient;
  Response: TAssinafyResponse;
  AccountID: string;
begin
  AccountID := GetEnvironmentVariable('ASSINAFY_ACCOUNT_ID');
  Client := TAssinafyClient.Create(
    GetEnvironmentVariable('ASSINAFY_API_KEY'),
    AccountID,
    AssinafySandboxURL);
  try
    Response := Client.GetAccount(AccountID);
    try
      WriteLn(JSONText(Response.Data));
    finally
      Response.Free;
    end;
  finally
    Client.Free;
  end;
end.
```

Um argumento de conta vazio, como em `Client.GetAccount('')`, usa o identificador informado ao construtor. Os demais identificadores de caminho são obrigatórios. Mantenha a chave de API em um servidor sob seu controle.

### Conexão OAuth2

Após concluir o [consentimento OAuth](#aplicativos-de-marketplace-e-oauth2), utilize somente o token de acesso retornado:

```pascal
Client := TAssinafyClient.Create('', '', AssinafySandboxURL);
Client.AccessToken := SavedAccessToken;
Response := Client.ListMyAccounts;
try
  AccountID := JSONString(JSONFind(TJSONArray(Response.Data).Items[0], 'id'));
finally
  Response.Free;
end;
// Salve AccountID junto dos tokens e use-o nas operações da conta.
Response := Client.GetAccount(AccountID);
Response.Free;
```

Cada token OAuth corresponde ao espaço de trabalho autorizado. Salve o ID retornado junto da conexão. O exemplo pressupõe a resposta documentada com o espaço de trabalho autorizado; trate respostas inesperadas na aplicação. Proteja os tokens no cofre de credenciais do sistema operacional ou em um armazenamento criptografado do serviço.

Operações públicas e operações do signatário podem usar um cliente sem credenciais da conta. Métodos públicos não enviam chave de API ou token; métodos de signatário enviam apenas seu código de acesso e rejeitam um código vazio antes da requisição. `ListSignerDocuments` e `SearchSignerDocuments` exigem o código; para consultar as mesmas rotas com a chave de API ou o token OAuth, use `ListSignerDocumentsAsWorkspace` e `SearchSignerDocumentsAsWorkspace`. Os métodos de login e gerenciamento de sessão de usuário também permanecem disponíveis na [referência da API](docs/API.md), com autenticação e permissões próprias.

## Fluxo completo do documento

Com `Client` autenticado e `AccountID` definido pelo modo escolhido, siga estas etapas:

1. Envie o PDF e salve o identificador do documento.
2. Crie ou reutilize os signatários e salve seus identificadores.
3. Escolha a verificação, estime o custo e solicite as assinaturas.
4. Disponibilize as URLs aos respectivos signatários para que concluam a assinatura.
5. Acompanhe a conclusão por webhook ou consulta de estado e baixe os arquivos finais.

Os trechos abaixo usam as unidades `Classes`, `SysUtils`, `AssinafyJson`, `Assinafy` e `AssinafyHttp`. Inclua também `AssinafyOAuth` para as funções OAuth e `AssinafyWebhooks` para verificar entregas. Os programas completos estão em [examples](examples).

### 1. Enviar o PDF

```pascal
Client.TimeoutMS := 180000;
Response := Client.UploadDocument(AccountID, 'contrato.pdf');
try
  DocumentID := JSONString(JSONFind(Response.Data, 'id'));
finally
  Response.Free;
end;
```

A API recebe os bytes do PDF no campo multipart `file`; o SDK envia o arquivo pela API MIME da libcurl. Os limites publicados são 25 MB e 2.000 páginas. O processamento é assíncrono. Uma solicitação de assinatura virtual pode ser criada nos estados `uploaded`, `metadata_processing` ou `metadata_ready`. Solicitações que coletam campos precisam aguardar `metadata_ready`, pois o posicionamento depende das páginas processadas. Consulte `GetDocument` ou assine o evento `document_metadata_ready`; interrompa a espera se o processamento falhar.

O documento retornado inclui `id`, `name`, `status`, `pages`, `artifacts`, etiquetas e datas. Os campos completos e seus valores nulos permitidos estão em [Document](docs/SCHEMAS.md#document).

Cada arquivo de envio é lido uma única vez para um buffer limitado a 25 MiB. Os bytes enviados não mudam se o caminho do arquivo for substituído depois da leitura. Envios multipart podem utilizar até 50 MiB de memória temporária por processo de trabalho, além das respostas recebidas; dimensione a quantidade de envios simultâneos.

O timeout padrão de 30 segundos limita a transferência inteira, incluindo a resposta do servidor. Ajuste `TimeoutMS` antes do envio conforme o tamanho do arquivo, a velocidade da conexão e o tempo de processamento; o exemplo permite três minutos. Um timeout não confirma que o envio falhou no servidor: consulte o estado antes de repetir uma operação de criação.

### 2. Criar ou reutilizar signatários

```pascal
SignerBody := JSONObj([
  'full_name', 'Signatário de exemplo',
  'email', 'signer@example.com'
]);
try
  Response := Client.CreateSigner(AccountID, SignerBody);
  try
    SignerID := JSONString(JSONFind(Response.Data, 'id'));
  finally
    Response.Free;
  end;
finally
  SignerBody.Free;
end;
```

Use `ListSigners` com um parâmetro de busca para reutilizar um signatário existente. Os campos adicionais incluem `whatsapp_phone_number` no formato E.164 e `government_id` para CPF/CNPJ. `UpdateSigner` envia somente os campos fornecidos. Os identificadores de signatário pertencem ao respectivo espaço de trabalho; salve o identificador da conta junto de cada registro.

### 3. Estimar o custo e solicitar assinaturas

Monte um único corpo de requisição para a estimativa e a criação:

```pascal
AssignmentBody := JSONObj(['method', 'virtual']);
try
  Signers := TJSONArray.Create;
  JSONAdd(AssignmentBody, 'signers', Signers);
  JSONAdd(Signers, JSONObj([
    'id', SignerID,
    'verification_method', 'Email',
    'notification_methods', JSONArr(['Email'])
  ]));
  JSONAdd(AssignmentBody, 'message', 'Por favor, revise e assine');
  Response := Client.EstimateAssignmentCost(DocumentID, AssignmentBody);
  try
    if not JSONBoolean(JSONFind(Response.Data, 'has_sufficient_resources')) then
      raise Exception.Create('Recursos insuficientes para solicitar assinaturas');
  finally
    Response.Free;
  end;
  Response := Client.CreateAssignment(DocumentID, AssignmentBody);
  try
    WriteLn(JSONString(JSONFind(Response.Data, 'id')));
  finally
    Response.Free;
  end;
finally
  AssignmentBody.Free;
end;
```

A requisição usa `signers: [{"id": "signer-id"}]`. Também pode incluir `entries`, `message`, `expires_at` e `copy_receivers`. Uma expiração explícita deve estar pelo menos uma hora no futuro. `method: collect` posiciona campos usando identificadores de página, campo e signatário, além das configurações de exibição. Consulte [CreateAssignment](docs/API.md#createassignment) para a requisição completa e [Assignment](docs/SCHEMAS.md#assignment) para a resposta completa.

A estimativa informa `has_sufficient_resources`, `blocking_reason`, saldo e detalhamento dos custos. Confirme os recursos antes da criação. A resposta da solicitação inclui seu identificador, signatários, resumo, itens e `signing_urls`. Envie cada URL somente ao signatário correspondente. `step` define a ordem das assinaturas: ao usar etapas, todos os signatários precisam informar uma sequência contínua iniciada em 1; signatários da mesma etapa assinam em paralelo. As etapas seguintes recebem convites quando a anterior termina.

#### E-mail, WhatsApp, biometria e certificados A1/A3

| Verificação | Notificação | Preparação |
| --- | --- | --- |
| `Email` | `Email` | O signatário possui e-mail; um código de uso único é exigido antes da assinatura. |
| `Whatsapp` | `Whatsapp` | O signatário possui número WhatsApp em E.164; a conta possui assinatura paga. |
| `DigitalCertificate` | `Email` ou `Whatsapp` | A conta possui o recurso de certificado digital; o signatário possui o CPF/CNPJ exigido e fica sozinho em sua etapa de assinatura. |
| `IdDocumentFaceMatchBasic` | `Email` ou `Whatsapp` | A conta possui o recurso de documento de identidade e comparação facial; o signatário possui CPF válido em `government_id` e consente com o tratamento biométrico. |

`notification_methods` aceita exatamente uma entrada. Omita verificação e notificação para usar e-mail como padrão, ou informe uma delas para que a API deduza a outra. O servidor rejeita combinações incompatíveis. Consulte as estimativas para obter preços atuais e verificar os recursos habilitados para a conta.

Uma solicitação com certificado usa o mesmo formato JSON de criação:

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

A página de assinatura da Assinafy utiliza o certificado ICP-Brasil A1/A3 do signatário pela extensão Web PKI do navegador. A1 e A3 usam o mesmo valor `DigitalCertificate`; o que muda é o armazenamento da chave privada no dispositivo. Um CPF exige o certificado da pessoa correspondente; um CNPJ exige o e-CNPJ da empresa. O SDK cria e acompanha essas solicitações e obtém o documento PAdES resultante. Os certificados e as chaves privadas permanecem com o signatário. A especificação publicada menciona rotas de início e conclusão da assinatura com certificado, mas não define seus contratos de requisição e resposta; use a URL de assinatura retornada para concluir esse processo.

Para biometria, use `IdDocumentFaceMatchBasic` no mesmo campo `verification_method`. A verificação utiliza o documento de identidade, uma foto do signatário com o documento e uma prova de vida no provedor. Consulte a estimativa antes de criar a solicitação: o recurso depende da conta e tem custo por signatário, além da notificação escolhida.

#### Verificação biométrica e análise de identidade

A página de assinatura conduz a captura biométrica. Em uma experiência própria, consulte `GetIdentityVerificationStatus` com o código do signatário. Inicie a captura somente quando `can_start` for verdadeiro e após obter consentimento explícito:

```pascal
// Execute somente depois de obter o consentimento explícito do signatário.
VerificationBody := JSONObj(['consent', True]);
try
  Response := SignerClient.StartIdentityVerification(SignerAccessCode, VerificationBody);
  try
    URL := JSONString(JSONFind(Response.Data, 'url'));
    // Redirecione o signatário para URL sem alterar seu fragmento #t=.
  finally
    Response.Free;
  end;
finally
  VerificationBody.Free;
end;
```

A URL retornada é uma credencial: abra-a integralmente, incluindo o fragmento, sem registrá-la ou persistir no navegador. Só existe uma sessão ativa por signatário. Uma sessão `Expired` pode ser substituída; `Pending`, `InReview`, `Approved`, `Declined` e `Abandoned` não podem ser reiniciadas. Uma verificação recusada ou abandonada exige um novo processo com outro documento e atribuição. Reenviar a notificação não substitui a sessão, e o reinício de uma sessão expirada não cobra novamente a verificação.

Com `InReview`, o signatário pode confirmar seus dados e assinar enquanto a conta analisa a identidade. Após todas as assinaturas, `pending_identity_review` indica que a certificação aguarda essa análise. Use `GetSignerIdentityReview` com credenciais da conta para consultar os motivos e `DownloadSignerIdentityReviewImage` para obter somente as imagens enumeradas em `images`. Os bytes podem ser JPEG, PNG ou PDF e só ficam disponíveis enquanto a análise está aberta; preserve `Cache-Control: no-store` e não persista essas imagens.

`DecideSignerIdentityReview` recebe `{"decision":"Approved","note":null}` ou `{"decision":"Rejected","note":"Motivo interno"}`. Aprovar libera a certificação quando não restam assinaturas ou análises pendentes. Rejeitar cancela o documento e notifica signatários e destinatários de cópia; a nota não é mostrada ao signatário. Os eventos `signer_identity_verified`, `signer_identity_verification_failed` e `signer_identity_review_required/approved/rejected` permitem acompanhar essas transições. Os [contratos completos](docs/API.md#getidentityverificationstatus) incluem estados, evidências, decisões e erros.

### 4. Concluir o fluxo do signatário

A página de assinatura retornada em `signing_urls` conduz o signatário pela verificação de identidade, confirmação de dados, termos e assinatura. Para uma experiência própria, use os métodos REST do signatário com os códigos recebidos pelo canal de entrega:

```pascal
SignerClient := TAssinafyClient.Create('', '', AssinafySandboxURL);
try
  Response := SignerClient.GetCurrentSigner(SignerAccessCode);
  Response.Free;
  VerificationBody := JSONObj(['verification-code', VerificationCode]);
  try
    Response := SignerClient.VerifySignerCode(SignerAccessCode, VerificationBody);
    Response.Free;
  finally
    VerificationBody.Free;
  end;
  // Confirme os dados e os termos antes de concluir a assinatura.
finally
  SignerClient.Free;
end;
```

`ConfirmSignerData` confirma os dados de cada documento e `AcceptTerms` registra a aceitação dos termos. Consulte a atribuição antes de enviar os campos exigidos por `SignAssignmentItems`, ou use `SignMultipleDocuments` para documentos com método virtual. Os parâmetros e os corpos completos de cada operação estão na [referência da API](docs/API.md). A consulta da atribuição registra sua visualização pelo signatário; use-a durante o fluxo de assinatura.

Os métodos também permitem rejeição e envio de imagens PNG de assinatura. `SendAccessTokenForPublicDocument` reenvia o código por e-mail com `{"channel": "email", "recipient": "signer@example.com"}` (ambos obrigatórios). Trate o código de acesso e o código OTP como credenciais e evite registrar URLs de assinatura ou seus parâmetros. `VerifySignerCode` aplica-se à verificação por e-mail ou WhatsApp; `IdDocumentFaceMatchBasic` utiliza o fluxo biométrico descrito acima. Signatários `DigitalCertificate` concluem o processo com certificado na página de assinatura; `SignAssignmentItems` não substitui esse processo.

### 5. Acompanhar a conclusão e baixar arquivos

`GetDocument` consulta o estado do documento. `ListDocumentActivities`, `ListAssignments` e `ListWhatsAppNotifications` mostram atividades, solicitações e notificações. Use `EstimateResendCost` antes de `ResendSignatureRequest`, pois o reenvio pode consumir créditos. `ResetAssignmentExpiration` exige o campo `expires_at`: envie uma data ISO 8601 pelo menos uma hora no futuro, ou `null` para remover a expiração (`JSONObj(['expires_at', nil])`). Trate rejeição e expiração como estados finais na aplicação.

Após a assinatura e a certificação, consulte `artifacts` antes de baixar os arquivos. Os nomes disponíveis incluem `original`, `certificated`, `certificate-page`, `pades` e `bundle`. A disponibilidade depende do estado do documento e do método de assinatura. Use `pades` para manter as assinaturas ICP-Brasil; a certificação pode convertê-las em conteúdo estático no PDF `certificated`.

```pascal
Response := Client.DownloadDocumentArtifact(DocumentID, 'certificated');
try
  Output := TFileStream.Create('contrato-assinado.pdf', fmCreate);
  try
    Response.SaveToStream(Output);
  finally
    Output.Free;
  end;
finally
  Response.Free;
end;
```

As respostas de download preservam os bytes e o tipo de conteúdo. O SDK mantém as respostas em memória; considere o tamanho dos documentos e a quantidade de downloads simultâneos. Abra o arquivo de destino após a requisição ter sucesso para impedir que um erro HTTP sobrescreva um arquivo existente. Para substituir um arquivo com segurança em caso de interrupção, grave em um arquivo temporário e renomeie-o na aplicação.

[examples/workflow.pas](examples/workflow.pas) reúne envio do PDF, criação do signatário, estimativa e solicitação. Compile com `make examples` e execute `build/workflow contrato.pdf signer@example.com`. Configure chave de API e ID do espaço de trabalho **ou** um token OAuth. O exemplo descobre o espaço de trabalho quando utiliza OAuth. Executá-lo cria recursos e envia uma solicitação de assinatura ao destinatário informado.

## Aplicativos de marketplace e OAuth2

Use OAuth para conectar os espaços de trabalho dos clientes ao seu produto. Registre a aplicação na Assinafy em **Integrações → Apps OAuth → Novo aplicativo**, com a URI HTTPS exata de retorno e as permissões máximas que poderá solicitar. Escolha **Aplicação web ou móvel (Public)** para software distribuído ou **Aplicação no servidor (Confidential)** para um serviço sob seu controle. O cadastro é feito pelo painel, não pela API. A disponibilidade do cadastro depende do ambiente; mantenha a aplicação, o consentimento e os endpoints de token no mesmo ambiente.

O `client_id` identifica publicamente sua aplicação. Mesmo que pareça um hash, ele não é uma chave de API nem um token de acesso. Aplicações públicas usam PKCE sem segredo de cliente; aplicações confidenciais também enviam `client_secret` nas requisições de token. A chave de API e o ID do espaço de trabalho da integração direta não são usados para autorizar a aplicação OAuth.

1. Consulte `Client.GetOAuthResourceMetadata` na origem da API. A resposta contém `resource`, `authorization_servers`, `scopes_supported` e `bearer_methods_supported`, sem envelope. O servidor de autorização publica `/.well-known/oauth-authorization-server` com suas URLs de autorização, token, revogação e informações do usuário. Use os endereços do mesmo ambiente.
2. Gere um novo par PKCE e um estado aleatório. Salve o verificador, o estado e o emissor esperado na sessão do usuário que iniciou o fluxo.
3. Redirecione o navegador para `AuthorizationURL`; todas as aplicações usam PKCE com SHA-256 e `S256`.
4. Na URL de retorno registrada, chame `ValidateOAuthCallback` com os parâmetros decodificados e o estado/emissor salvos. Consuma a transação da sessão uma única vez. Rejeite divergências de estado ou emissor, parâmetros duplicados e erros de autorização.
5. Troque o código imediatamente com `ExchangeCode`. Os códigos expiram após 60 segundos e só podem ser usados uma vez.
6. Salve as credenciais retornadas com segurança. Atribua o token de acesso a um cliente sem chave de API, chame `ListMyAccounts` e salve o ID do espaço de trabalho autorizado junto da conexão.
7. Execute renovações sequencialmente por conexão, persista cada novo token de renovação antes de usar o token de acesso e revogue o token atual ao desconectar.

```pascal
OAuthClient := TAssinafyClient.Create('', '', AssinafySandboxURL);
Config.ClientID := GetEnvironmentVariable('ASSINAFY_CLIENT_ID');
Config.ClientSecret := GetEnvironmentVariable('ASSINAFY_CLIENT_SECRET');
Config.RedirectURI := 'https://app.example.com/oauth/callback';
Config.Scopes := 'account:read documents:read documents:write offline_access';
Config.Issuer := 'https://auth-sandbox.assinafy.com.br';
Config.Resource := 'https://sandbox.assinafy.com.br';
PKCE := GeneratePKCE;
State := GenerateState;
URL := AuthorizationURL(Config, State, PKCE.Verifier);
// Salve PKCE.Verifier e State na sessão do usuário antes do redirecionamento.
```

Deixe `ASSINAFY_CLIENT_SECRET` vazia para aplicações públicas; configure-a somente para aplicações confidenciais.

Na URL de retorno:

```pascal
Code := ValidateOAuthCallback(CallbackQuery, SavedState, Config.Issuer);
Response := ExchangeCode(OAuthClient, Config, Code, SavedVerifier);
try
  // Salve a resposta com segurança antes de utilizar as credenciais.
  OAuthClient.AccessToken := JSONString(JSONFind(Response.Data, 'access_token'));
finally
  Response.Free;
end;
```

A resposta de token não possui envelope:

```json
{
  "access_token": "token-de-acesso",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "account:read documents:read documents:write",
  "refresh_token": "novo-token-de-renovacao",
  "id_token": "token-de-identidade-assinado"
}
```

`refresh_token` exige `offline_access`; `id_token` exige `openid`. Consulte os escopos efetivamente retornados. Cada token abrange um espaço de trabalho. OAuth não permite acesso a cobrança, administração de credenciais, criação/exclusão de contas ou segredos de assinatura de webhooks. Uma resposta `403` com indicação de escopo identifica uma permissão ausente; reconecte com essa permissão. Para OIDC, valide a assinatura do token de identidade e os campos `iss`, `aud`, `exp` e `nonce` com uma implementação OIDC antes de utilizá-lo como identidade. O SDK transporta os tokens e oferece `GetOAuthUserInfo`, mas não valida JWTs.

```pascal
Response := RefreshToken(OAuthClient, Config, CurrentRefreshToken);
try
  // Persista Response.Data.refresh_token atomicamente antes de usar access_token.
finally
  Response.Free;
end;
Response := RevokeToken(OAuthClient, Config, LatestStoredToken, 'refresh_token');
Response.Free;
```

Os tokens de renovação são rotacionados. Reutilizar um token antigo encerra a conexão. Um timeout pode ocorrer depois de o servidor já ter rotacionado o token; consulte novamente o estado salvo e reconecte se o resultado for incerto. O SDK envia cada requisição uma única vez. A aplicação controla a exclusão mútua das renovações, o armazenamento durável e o agendamento.

[examples/oauth_connect.pas](examples/oauth_connect.pas) demonstra a autorização no navegador e a troca do código, mantendo o verificador em memória. O exemplo não persiste credenciais. Compile com `make examples` e execute `build/oauth_connect` após configurar o registro da aplicação. O SDK não abre um servidor de retorno; sua aplicação recebe a resposta HTTPS e fornece os parâmetros decodificados ao exemplo. Libere `OAuthClient` ao encerrar a conexão na aplicação.

O helper `RefreshToken` exige um token de renovação substituto não vazio. Se a resposta omitir esse token, retornar `null` ou falhar em outra validação, `EAssinafyProtocolError` preserva `StatusCode` e `ResponseBody`, inclusive eventuais tokens utilizáveis. Examine a resposta com segurança e reconecte quando necessário; o token anterior pode já ter sido consumido. O método REST `ExchangeOAuthToken` disponibiliza diretamente o contrato publicado, que permite token de renovação ausente ou nulo.

`ExchangeCode` e `RefreshToken` verificam se a origem do recurso configurado coincide com a API, incluindo protocolo, host e porta efetiva. Combinações explícitas de emissor sandbox com API de produção, ou o inverso, são rejeitadas antes do envio.

## Webhooks assinados

Use `CreateWebhookEndpoint` para cadastrar a URL de entrega, o e-mail de contato e os eventos. Planos pagos permitem até três endpoints; o servidor aplica os limites efetivos do espaço de trabalho. `ListWebhookEndpoints`, `GetWebhookEndpoint`, `UpdateWebhookEndpoint` e `DeleteWebhookEndpoint` gerenciam cada endpoint. Os métodos anteriores de inscrição em webhooks também continuam disponíveis.

```json
{
  "url": "https://app.example.com/assinafy/webhook",
  "email": "webhooks@example.com",
  "events": ["document_ready", "signer_rejected_document"],
  "name": "Eventos de assinatura",
  "is_active": true,
  "signing_enabled": true
}
```

Quando `signing_enabled` é verdadeiro, `CreateWebhookEndpoint` retorna o segredo em `Response.Data.secret`, inclusive para aplicações OAuth. Salve-o com segurança nesse momento; listagens e consultas do endpoint não o retornam. `GetWebhookEndpointSigningSecret` permite recuperá-lo usando chave de API ou token de usuário autorizado, mas aplicações OAuth não podem consultá-lo: se perderem o segredo, precisam excluir o endpoint e criá-lo novamente. A rotação invalida o segredo anterior imediatamente; coordene `RotateWebhookEndpointSigningSecret` com o receptor das entregas.

`ListWebhookEndpoints` aceita um `Query` opcional com `url` para localizar a URL exata registrada. `DeleteWebhookEndpointByURL` recebe o mesmo parâmetro obrigatório em `Query` e libera o slot do endpoint. Passe a URL completa como valor decodificado, incluindo sua query string; o SDK faz a codificação. A exclusão retorna `404` quando não existe correspondência, e exige `webhooks:write` em conexões OAuth.

Verifique a assinatura antes de interpretar o JSON ou aceitar qualquer evento:

```pascal
if not VerifyWebhookHeaders(EndpointSecret, RequestHeaders, RawRequestBody) then
  raise Exception.Create('Entrega de webhook inválida');
```

`RequestHeaders` aceita linhas HTTP `nome: valor` ou pares `nome=valor`. Os nomes dos cabeçalhos não diferenciam maiúsculas e minúsculas. A verificação usa os bytes originais do corpo, `webhook-id`, `webhook-timestamp`, uma chave `whsec_` decodificada de base64 e HMAC-SHA256. Aceita uma assinatura `v1` válida entre múltiplas entradas, compara em tempo constante e exige uma diferença máxima de cinco minutos entre o horário da entrega e o relógio local. Mantenha o relógio do servidor sincronizado. Identificadores ou timestamps duplicados, cabeçalhos ausentes, chaves malformadas, corpos alterados e entregas fora da janela são rejeitados.

Persista os eventos válidos e elimine duplicatas por `webhook-id`, encaminhe o processamento para uma fila e retorne `2xx` rapidamente. Cada endpoint recebe entregas independentes. O corpo contém `id`, `event`, `message`, `payload`, `origin`, `created_at`, `subject`, `object` e `account_id`; `subject` e `object` podem representar diferentes tipos de recurso. [WebhookEvent](docs/SCHEMAS.md#webhookevent) define o envelope completo; a [referência de entregas](docs/API.md#webhook-deliveries) inclui cabeçalhos e exemplos completos dos 23 eventos. Não dependa de uma ordem fixa entre `assignment_created` e `document_metadata_ready`.

Use `ListWebhookEventTypes` para o catálogo de eventos, `ListWebhookDeliveries` para os resultados das entregas e `RetryWebhookDelivery` para solicitar uma nova tentativa. Reenvios podem entregar o mesmo evento novamente; mantenha a eliminação de duplicatas ativa.

## Modelos, campos e etiquetas

`ListTemplates` consulta modelos reutilizáveis. `EstimateDocumentFromTemplateCost` e `CreateDocumentFromTemplate` estimam o custo e criam um documento com o identificador do modelo, o vínculo entre papéis e signatários e os valores dos campos. A referência da API inclui todos os campos aninhados; utilize os papéis e páginas retornados pelo modelo. A especificação atual publica a listagem de modelos e a criação de documentos a partir deles, sem um contrato de criação, alteração ou exclusão de modelos.

`ListFields`, `CreateField`, `GetField`, `UpdateField`, `DeleteField`, `ValidateFieldValue`, `ValidateMultipleFieldValues` e `ListFieldTypes` gerenciam definições de campos e validações de valores no servidor. Essas validações de campos são independentes da verificação de identidade por e-mail ou WhatsApp.

`ListTags`, `CreateTag`, `UpdateTag` e `DeleteTag` gerenciam etiquetas do espaço de trabalho. `ListDocumentTags`, `ReplaceDocumentTags`, `AttachDocumentTags` e `DetachDocumentTag` associam etiquetas aos documentos. Omitir uma propriedade JSON opcional preserva seu valor em atualizações parciais; `TJSONNull` explícito limpa valores que aceitam nulo quando a API permite.

Para atualizar a imagem do espaço de trabalho, `UploadAccountLogo(AccountID, 'logo.png', 'image/png')` permite informar o tipo de conteúdo da parte multipart. Use `image/jpeg` para JPEG; omitir o terceiro argumento utiliza `application/octet-stream`. A API valida os bytes do arquivo e as permissões da conta.

## Respostas, paginação e erros

Cada chamada retorna uma resposta que deve ser liberada pela aplicação. `Response.JSON` contém a resposta inteira, enquanto `Response.Data` referencia o campo `data` do envelope. Respostas OAuth sem envelope ficam disponíveis integralmente nas duas propriedades. Libere a resposta após consultar essas propriedades. Os corpos de requisição e listas de parâmetros também devem ser liberados pela aplicação. `TJSONObject.Add` e `TJSONArray.Add` assumem a responsabilidade de liberar os valores JSON filhos adicionados.

Os bytes JSON recebidos precisam formar UTF-8 válido. Em fontes compartilhados UTF-8, use `{$IFDEF FPC}{$codepage utf8}{$ENDIF}`. No Delphi, salve com BOM UTF-8 ou configure a página de código `65001` no compilador; os valores de texto do `fpjson` usam `UTF8String`, enquanto o Delphi usa `UnicodeString` em `System.JSON`. `AssinafyJson` serializa os corpos em UTF-8 em ambos os compiladores. Preserve a codificação declarada das strings ao receber texto da aplicação para que consultas sejam convertidas corretamente para UTF-8.

Exemplo de resposta JSON:

```json
{
  "status": 200,
  "message": "Success",
  "data": {"id": "workspace-id", "name": "Espaço de trabalho de exemplo"}
}
```

Um transporte externo permanece sob responsabilidade de quem o forneceu; o cliente gerencia seu transporte libcurl padrão. Use um cliente por processo de trabalho ou thread e evite alterar suas credenciais simultaneamente. Os dados JSON preservam os nomes dos campos da API, valores nulos, campos opcionais e futuras adições.

Os métodos de listagem recebem os parâmetros documentados em um `TStrings` com pares `nome=valor`:

```pascal
Query := TStringList.Create;
try
  Query.Add('page=1');
  Query.Add('per-page=100');
  Query.Add('search=Exemplo');
  Response := Client.ListDocuments(AccountID, Query);
  try
    WriteLn(JSONText(Response.Data));
    WriteLn(Response.Header('X-Pagination-Page-Count'));
  finally
    Response.Free;
  end;
finally
  Query.Free;
end;
```

Os cabeçalhos de paginação são `X-Pagination-Current-Page`, `X-Pagination-Total-Count`, `X-Pagination-Page-Count` e `X-Pagination-Per-Page`. O máximo de `per-page` é 100. Preserve os cabeçalhos de limite de requisições: `X-Rate-Limit-Limit`, `X-Rate-Limit-Remaining`, `X-Rate-Limit-Reset` e `Retry-After`.

| Exceção | Significado |
| --- | --- |
| `EAssinafyInputError` | Falha de validação de entrada obrigatória, URL, credencial, arquivo ou segurança antes do envio. |
| `EAssinafyTransportError` | Falha de DNS, conexão, TLS, timeout ou criptografia nativa. A requisição pode já ter chegado ao servidor. |
| `EAssinafyProtocolError` | Uma resposta JSON não pôde ser decodificada ou uma resposta OAuth não passou pela validação. `StatusCode` e `ResponseBody` preservam o resultado HTTP e os bytes recebidos. |
| `EAssinafyAPIError` | Resposta HTTP fora de `2xx`, incluindo erros OAuth. Consulte `StatusCode`, `ErrorCode`, `ResponseBody`, `RetryAfter`, `Authenticate`, `RateLimitLimit`, `RateLimitRemaining` e `RateLimitReset`. |

Exceções comuns do sistema de arquivos podem ocorrer ao ler um arquivo para envio ou gravar o destino. Corpos de erro podem conter dados pessoais; aplique a política de ocultação de dados sensíveis da aplicação antes de registrá-los. O SDK não registra credenciais, corpos de requisição ou URLs de assinatura.

Um erro de protocolo com `StatusCode` em `2xx` indica que o servidor respondeu com sucesso, mesmo que o SDK não consiga interpretar a resposta. Use `ResponseBody` para recuperar identificadores ou reconciliar o estado; repetir uma criação automaticamente pode duplicar recursos. Esse corpo também pode conter tokens OAuth e deve receber a mesma proteção das credenciais.

`Client.TimeoutMS` tem valor padrão de 30.000 milissegundos e limita a conexão e a duração total da transferência. `Client.CAFile` permite selecionar um arquivo PEM com autoridades certificadoras confiáveis. A verificação do certificado e do nome do servidor permanece habilitada, o TLS exige versão 1.2 ou superior e redirecionamentos são rejeitados para impedir o encaminhamento de credenciais. As configurações de proxy seguem o comportamento normal da libcurl.

O SDK não repete requisições automaticamente. Uma resposta `429` informa o intervalo definido pelo servidor; aplique tentativas limitadas em operações seguras na aplicação. Antes de repetir uma alteração, verifique se a primeira requisição teve sucesso. Códigos de autorização e tokens de renovação exigem cuidado especial por serem de uso único.

## Testes e desenvolvimento

```sh
make check
```

O comando verifica os arquivos gerados contra o contrato incluído, a cobertura das operações, os links de documentação e a consistência dos arquivos. Compila tratando avisos como erros, executa as verificações dos 112 métodos e os testes de respostas, segurança e funções auxiliares, exercita requisições HTTP reais locais com multipart, dados binários e TLS, e compila os dois exemplos. Também compila os trechos Pascal deste guia e verifica a sintaxe dos exemplos JSON e shell, sem executá-los. Os testes ativam verificações de faixa, overflow, entrada/saída, asserções e memória. A integração contínua executa em Linux e macOS. Os testes HTTP locais precisam de permissão para abrir portas de loopback.

As verificações Python também testam falhas de contrato com otimização ativada (`python3 -O`), validam a autenticação independentemente dos testes gerados e rejeitam parâmetros ou formatos de envio incompatíveis.

Para verificações no sandbox, forneça a chave de API e o ID do espaço de trabalho pelas variáveis de ambiente:

```sh
make live
```

Por padrão, o comando executa operações de leitura, descoberta OAuth e uma verificação do erro de cliente OAuth inválido. Defina `ASSINAFY_TEST_MUTATIONS=1` e `ASSINAFY_TEST_PDF` com o caminho de um PDF local para exercitar a criação isolada de documento, signatário e etiqueta, alterações, estimativa de custo, download binário e limpeza. O teste exclui apenas os recursos que criou e não envia convites. Um ciclo OAuth completo de consentimento e renovação exige uma aplicação registrada e autorização do usuário. A verificação completa de códigos OTP por e-mail/WhatsApp e de assinaturas A1/A3 exige um signatário que consinta, acesso ao canal correspondente e, para certificados, seu dispositivo. Os testes unitários e HTTP verificam as requisições do SDK independentemente desses requisitos.

Para atualizar o contrato, baixe o [documento OpenAPI atual](https://api.assinafy.com.br/v1/docs/openapi.json), preserve todas as operações e esquemas e substitua os endereços de contato dos exemplos por domínios reservados antes de atualizar `docs/openapi.json`. Execute `python3 scripts/generate.py`, confira os métodos e as referências de dados gerados e execute `make check`. O gerador mantém métodos, verificações por método e documentação consistentes. Mantenha `VERSION`, `AssinafyVersion`, notas de versão e tags alinhados. As tags seguem `vMAJOR.MINOR.PATCH`.

## Licença

Distribuído sob a [licença MIT](LICENSE).
