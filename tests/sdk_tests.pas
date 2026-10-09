program SDKTests;

{$mode objfpc}{$H+}{$ASSERTIONS ON}

uses
  {$ifdef unix}cthreads,{$endif}
  Classes, SysUtils, DateUtils, fpjson, base64, Assinafy, AssinafyHttp,
  AssinafyCrypto, AssinafyOAuth, AssinafyWebhooks;

type
  TFakeTransport = class(TAssinafyTransport)
  public
    LastMethod, LastURL, LastAuth, LastFile, LastContentType: string;
    LastBody: RawByteString;
    NextStatus, Calls: Integer;
    NextBody, NextContentType: string;
    function Execute(const Request: TAssinafyRequest): TAssinafyResponse; override;
  end;

var
  Checks: Integer = 0;
  Fake: TFakeTransport;
  Client: TAssinafyClient;
  Response: TAssinafyResponse;
  TestBody: TJSONData;
  TestQuery: TStringList;
  FixtureFile: string;

procedure Check(Condition: Boolean; const MessageText: string);
begin
  Inc(Checks);
  if not Condition then raise Exception.Create(MessageText);
end;

function TFakeTransport.Execute(const Request: TAssinafyRequest): TAssinafyResponse;
var
  HeaderLine: string;
begin
  Inc(Calls);
  LastMethod := Request.Method;
  LastURL := Request.URL;
  LastFile := Request.FileName;
  LastBody := Request.Body;
  LastContentType := Request.ContentType;
  LastAuth := 'public';
  for HeaderLine in Request.Headers do
  begin
    if Pos('X-Api-Key:', HeaderLine) = 1 then LastAuth := 'key';
    if Pos('Authorization:', HeaderLine) = 1 then
    begin
      Check(LastAuth <> 'key', 'Only one workspace credential can be sent');
      LastAuth := 'bearer';
    end;
  end;
  if Pos('signer-access-code=', LastURL) > 0 then
  begin
    Check(LastAuth = 'public', 'Signer calls must omit workspace credentials');
    LastAuth := 'signer';
  end;
  Result := TAssinafyResponse.Create;
  Result.StatusCode := NextStatus;
  Result.Body := NextBody;
  Result.Headers.Add('Content-Type: ' + NextContentType);
  Result.Headers.Add('Retry-After: 17');
  Result.Headers.Add('WWW-Authenticate: Bearer error="insufficient_scope"');
  Result.Headers.Add('X-Pagination-Total-Count: 150');
end;

procedure ExpectInputError(const Name: string; Action: Integer);
var
  Temp: TAssinafyClient;
  PriorCalls: Integer;
begin
  PriorCalls := Fake.Calls;
  try
    case Action of
      1: begin Temp := TAssinafyClient.Create('', '', 'http://api.example.com/v1'); Temp.Free; end;
      2: begin Response := Client.GetDocument(''); Response.Free; end;
      3: begin Response := Client.GetDocument('..'); Response.Free; end;
      4: begin Response := Client.CreateSigner('', nil); Response.Free; end;
      5: begin Response := Client.GetCurrentSigner(''); Response.Free; end;
      6: begin Response := Client.UploadDocument('', '/missing/sdk-file.pdf'); Response.Free; end;
      7: begin Client.AccessToken := 'token' + #13#10 + 'Injected: value'; Response := Client.GetUser; Response.Free; end;
      8: begin TestQuery.Clear; TestQuery.Add('access-token=secret'); Response := Client.ListDocuments('', TestQuery); Response.Free; end;
      9: begin Client.TimeoutMS := 0; Response := Client.GetUser; Response.Free; end;
      10: begin Temp := TAssinafyClient.Create('', '', 'https://user:password@api.example.com/v1'); Temp.Free; end;
      11: begin Temp := TAssinafyClient.Create('', '', 'https://api.example.com/v1?query=value'); Temp.Free; end;
    end;
    raise Exception.Create(Name + ': expected input error');
  except
    on E: EAssinafyInputError do Check(Fake.Calls = PriorCalls, Name + ': rejected before transport');
  end;
  Client.AccessToken := 'test-bearer';
  Client.TimeoutMS := 30000;
end;

procedure TestResponses;
const
  StatusCodes: array[0..6] of Integer = (400, 401, 403, 404, 415, 429, 500);
var
  Stream: TMemoryStream;
  OldClient: TAssinafyClient;
  Code: Integer;
begin
  Fake.NextBody := '{"status":200,"message":"ok","data":{"nullable":null,"enabled":false,"value":9007199254740993,"extra":"kept"}}';
  Response := Client.GetAccount('');
  try
    Check(Response.Data.FindPath('enabled').AsBoolean = False, 'JSON boolean preserved');
    Check(Response.Data.FindPath('nullable').JSONType = jtNull, 'JSON null preserved');
    Check(Response.Data.FindPath('value').AsInt64 = 9007199254740993, '64-bit integer preserved');
    Check(Response.Data.FindPath('extra').AsString = 'kept', 'Unknown response fields preserved');
    Check(Response.Header('x-pagination-total-count') = '150', 'Pagination headers exposed');
  finally
    Response.Free;
  end;
  Fake.NextBody := '{"access_token":"access","refresh_token":"refresh","token_type":"Bearer"}';
  Response := Client.ExchangeOAuthToken(TestBody);
  try Check(Response.Data = Response.JSON, 'Flat OAuth response preserved'); finally Response.Free; end;
  for Code in StatusCodes do
  begin
    Fake.NextStatus := Code;
    Fake.NextBody := '{"error":"invalid_grant","error_description":"Code expired"}';
    try
      Response := Client.ExchangeOAuthToken(TestBody);
      Response.Free;
      raise Exception.Create('Expected API error');
    except
      on E: EAssinafyAPIError do
      begin
        Check(E.StatusCode = Code, 'HTTP error status retained');
        Check(E.ErrorCode = 'invalid_grant', 'OAuth error code retained');
        Check(E.RetryAfter = '17', 'Retry delay retained');
        Check(Pos('insufficient_scope', E.Authenticate) > 0, 'Scope challenge retained');
        Check(E.ResponseBody = Fake.NextBody, 'Error payload retained');
      end;
    end;
  end;
  Fake.NextBody := '<html>unavailable</html>';
  Fake.NextStatus := 503;
  try
    Response := Client.GetUser;
    Response.Free;
    raise Exception.Create('Expected non-JSON API error');
  except on E: EAssinafyAPIError do Check(E.StatusCode = 503, 'Invalid JSON errors preserve HTTP status'); end;
  Fake.NextBody := '{"message":{"unexpected":"object"},"error":1}';
  try
    Response := Client.GetUser;
    Response.Free;
    raise Exception.Create('Expected API error');
  except on E: EAssinafyAPIError do Check(E.StatusCode = 503, 'Wrongly typed error fields preserve HTTP status'); end;
  Fake.NextStatus := 200;
  Fake.NextBody := 'invalid json';
  try
    Response := Client.GetUser;
    Response.Free;
    raise Exception.Create('Expected protocol error');
  except on E: EAssinafyProtocolError do Check(True, 'Invalid successful JSON rejected'); end;
  Fake.NextContentType := 'application/pdf';
  Fake.NextBody := '%PDF-' + #0 + #255 + 'binary';
  Response := Client.DownloadDocumentArtifact('doc', 'original');
  Stream := TMemoryStream.Create;
  try
    Check(Response.JSON = nil, 'PDF is not parsed as JSON');
    Response.SaveToStream(Stream);
    Check(Stream.Size = Length(Fake.NextBody), 'Binary bytes saved without truncation');
    Check(CompareByte(Stream.Memory^, Fake.NextBody[1], Stream.Size) = 0, 'Binary bytes unchanged');
  finally Stream.Free; Response.Free; end;
  Fake.NextStatus := 204;
  Fake.NextBody := '';
  Fake.NextContentType := 'application/json';
  Response := Client.DeleteDocument('doc');
  try Check(Response.Data = nil, 'Empty success supported'); finally Response.Free; end;
  Fake.NextStatus := 200;
  Fake.NextBody := '{"status":200,"message":"ok","data":{}}';
  OldClient := TAssinafyClient.Create('api-key', 'account', AssinafySandboxURL, Fake);
  try
    Response := OldClient.GetUser;
    Response.Free;
    Check(Fake.LastAuth = 'key', 'API key header supported');
    Response := OldClient.ListMyAccounts;
    Response.Free;
    Response := OldClient.VerifyASignedDocument('hash');
    Response.Free;
    Check(Fake.LastAuth = 'public', 'Public call suppresses API key');
  finally OldClient.Free; end;
end;

procedure TestOAuth;
var
  PKCE, Second: TAssinafyPKCE;
  Config: TAssinafyOAuthConfig;
  Callback: TStringList;
  URL: string;
begin
  Fake.NextBody := '{"access_token":"access","refresh_token":"replacement","token_type":"Bearer","expires_in":3600}';
  Check(PKCEChallenge('dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk') =
    'E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM', 'RFC 7636 PKCE vector');
  PKCE := GeneratePKCE;
  Second := GeneratePKCE;
  Check(Length(PKCE.Verifier) = 43, 'PKCE verifier length');
  Check(PKCE.Verifier <> Second.Verifier, 'PKCE fresh randomness');
  Check(Length(GenerateState) = 43, 'State has 256 bits of entropy');
  Config.ClientID := 'client-id';
  Config.RedirectURI := 'https://app.example.com/oauth/callback';
  Config.Scopes := 'documents:read offline_access';
  URL := AuthorizationURL(Config, 'state', PKCE.Verifier);
  Check(Pos('code_challenge_method=S256', URL) > 0, 'PKCE is always S256');
  Check(Pos('scope=documents%3Aread%20offline_access', URL) > 0, 'Scope encoded');
  Callback := TStringList.Create;
  try
    Callback.Add('state=state');
    Callback.Add('iss=' + AssinafyOAuthIssuer);
    Callback.Add('code=code-value');
    Check(ValidateOAuthCallback(Callback, 'state') = 'code-value', 'Valid callback accepted');
    Callback.Add('state=attacker');
    try ValidateOAuthCallback(Callback, 'state'); raise Exception.Create('Duplicate callback accepted');
    except on E: EAssinafyInputError do Check(True, 'Duplicate callback rejected'); end;
    Callback.Delete(3);
    Callback.Values['iss'] := 'https://attacker.example.com';
    try ValidateOAuthCallback(Callback, 'state'); raise Exception.Create('Wrong issuer accepted');
    except on E: EAssinafyInputError do Check(True, 'Wrong issuer rejected'); end;
    Callback.Values['iss'] := AssinafyOAuthIssuer;
    try ValidateOAuthCallback(Callback, 'other-state'); raise Exception.Create('Wrong state accepted');
    except on E: EAssinafyInputError do Check(True, 'Wrong state rejected'); end;
    Callback.Add('error=access_denied');
    try ValidateOAuthCallback(Callback, 'state'); raise Exception.Create('Code and error accepted');
    except on E: EAssinafyInputError do Check(True, 'Ambiguous callback rejected'); end;
  finally Callback.Free; end;
  Response := ExchangeCode(Client, Config, 'code', PKCE.Verifier);
  Response.Free;
  Check(Pos('authorization_code', Fake.LastBody) > 0, 'Authorization grant');
  Check(Pos('client_secret', Fake.LastBody) = 0, 'Public clients omit secret');
  Config.ClientSecret := 'confidential-secret';
  Response := RefreshToken(Client, Config, 'refresh');
  Response.Free;
  Check(Pos('refresh_token', Fake.LastBody) > 0, 'Refresh grant');
  Check(Pos('confidential-secret', Fake.LastBody) > 0, 'Confidential client authentication');
  Check(Fake.LastAuth = 'public', 'OAuth token exchange omits workspace credentials');
  Response := RevokeToken(Client, Config, 'token', 'refresh_token');
  Response.Free;
  Check(Pos('token_type_hint', Fake.LastBody) > 0, 'Revocation token hint');
  Fake.NextBody := '{"access_token":"access","token_type":"Bearer"}';
  try
    Response := RefreshToken(Client, Config, 'old-refresh');
    Response.Free;
    raise Exception.Create('Missing replacement refresh token accepted');
  except on E: EAssinafyProtocolError do Check(True, 'Missing replacement refresh token rejected'); end;
  Fake.NextBody := '{"access_token":"access","token_type":"wrong-type"}';
  try
    Response := ExchangeCode(Client, Config, 'code', PKCE.Verifier);
    Response.Free;
    raise Exception.Create('Invalid token type accepted');
  except on E: EAssinafyProtocolError do Check(True, 'Invalid token type rejected'); end;
  try PKCEChallenge('short'); raise Exception.Create('Short verifier accepted');
  except on E: EAssinafyInputError do Check(True, 'Short verifier rejected'); end;
end;

procedure TestWebhooks;
const
  Secret = 'whsec_c2VjcmV0';
  Body = '{"event":"document_ready"}';
  Timestamp = '1700000000';
var
  Signature: string;
  Headers: TStringList;
  CurrentTimestamp: string;
begin
  Check(EncodeStringBase64(SHA256('abc')) = 'ungWv48Bz+pBQUDeXa4iI7ADYaOWF3qctBD/YfIAFa0=', 'SHA256 known vector');
  Check(EncodeStringBase64(HMACSHA256('key', 'The quick brown fox jumps over the lazy dog')) =
    '97yD9DBThCSxMpjmqm+xQ+9NWaFJRhdZl0edvC0aPNg=', 'HMAC-SHA256 known vector');
  Signature := 'v1,' + EncodeStringBase64(HMACSHA256('secret', 'msg_1.' + Timestamp + '.' + Body));
  Check(VerifyWebhook(Secret, 'msg_1', Timestamp, Signature, Body, 1700000000), 'Valid webhook');
  Check(VerifyWebhook(Secret, 'msg_1', Timestamp, 'v2,ignored v1,wrong ' + Signature, Body, 1700000000), 'Multiple signatures');
  Check(not VerifyWebhook(Secret, 'msg_1', Timestamp, Signature, Body + ' ', 1700000000), 'Tampered body rejected');
  Check(not VerifyWebhook(Secret, 'msg_2', Timestamp, Signature, Body, 1700000000), 'Tampered ID rejected');
  Check(not VerifyWebhook(Secret, 'msg_1', Timestamp, Signature, Body, 1700000301), 'Stale webhook rejected');
  Check(not VerifyWebhook(Secret, 'msg_1', Timestamp, Signature, Body, 1699999699), 'Future webhook rejected');
  Check(VerifyWebhook(Secret, 'msg_1', Timestamp, Signature, Body, 1700000300), 'Tolerance boundary');
  Check(not VerifyWebhook('bad-secret', 'msg_1', Timestamp, Signature, Body, 1700000000), 'Invalid secret rejected');
  Check(not VerifyWebhook('whsec_invalid!', 'msg_1', Timestamp, Signature, Body, 1700000000), 'Invalid base64 rejected');
  Check(not VerifyWebhook(Secret, '', Timestamp, Signature, Body, 1700000000), 'Missing ID rejected');
  Check(not VerifyWebhook(Secret, 'msg_1', '-1', Signature, Body, 1700000000), 'Negative time rejected');
  Check(not VerifyWebhook(Secret, 'msg_1', '9999999999999999999999', Signature, Body, 1700000000), 'Overflow time rejected');
  Headers := TStringList.Create;
  try
    CurrentTimestamp := IntToStr(DateTimeToUnix(Now, False));
    Signature := 'v1,' + EncodeStringBase64(HMACSHA256('secret', 'msg_1.' + CurrentTimestamp + '.' + Body));
    Headers.Add('Webhook-ID: msg_1');
    Headers.Add('WEBHOOK-TIMESTAMP: ' + CurrentTimestamp);
    Headers.Add('webhook-signature: v2,ignored');
    Headers.Add('webhook-signature: ' + Signature);
    Check(VerifyWebhookHeaders(Secret, Headers, Body), 'Header names and multiple signature headers');
    Headers.Add('webhook-id: msg_1');
    Check(not VerifyWebhookHeaders(Secret, Headers, Body), 'Duplicate webhook ID rejected');
    Headers.Delete(4);
    Headers.Clear;
    Headers.Add('webhook-id=msg_1');
    Headers.Add('webhook-timestamp=' + CurrentTimestamp);
    Headers.Add('webhook-signature=' + Signature);
    Check(VerifyWebhookHeaders(Secret, Headers, Body), 'Name=value webhook headers');
    Headers.Insert(0, 'webhook-id:');
    Check(not VerifyWebhookHeaders(Secret, Headers, Body), 'Empty duplicate webhook ID rejected');
    Headers.Delete(0);
    Headers.Insert(0, 'webhook-timestamp:');
    Check(not VerifyWebhookHeaders(Secret, Headers, Body), 'Empty duplicate webhook timestamp rejected');
    Check(not VerifyWebhookHeaders(Secret, nil, Body), 'Missing header list rejected');
  finally Headers.Free; end;
end;

procedure TestSigningMethods;
const
  Methods: array[0..2] of string = ('Email', 'Whatsapp', 'DigitalCertificate');
var
  Method, Channel: string;
  Body: TJSONObject;
  Signers: TJSONArray;
begin
  Fake.NextBody := '{"status":200,"message":"ok","data":{}}';
  for Method in Methods do
  begin
    Channel := 'Email';
    if Method = 'Whatsapp' then Channel := 'Whatsapp';
    Body := TJSONObject.Create(['method', 'virtual']);
    try
      Signers := TJSONArray.Create;
      Body.Add('signers', Signers);
      Signers.Add(TJSONObject.Create(['id', 'signer', 'verification_method', Method,
        'notification_methods', TJSONArray.Create([Channel]), 'step', 1]));
      Response := Client.EstimateAssignmentCost('document', Body);
      Response.Free;
      Check(Fake.LastBody = Body.AsJSON, Method + ' estimation payload retained');
      Response := Client.CreateAssignment('document', Body);
      Response.Free;
      Check(Fake.LastBody = Body.AsJSON, Method + ' assignment payload retained');
    finally Body.Free; end;
  end;
  Body := TJSONObject.Create(['verification-code', '123456']);
  try
    Response := Client.VerifySignerCode('signer-code', Body);
    Response.Free;
    Check(Fake.LastBody = Body.AsJSON, 'OTP field spelling preserved');
    Check(Fake.LastAuth = 'signer', 'OTP uses signer authentication');
  finally Body.Free; end;
end;

var
  Fixture: TFileStream;
  I: Integer;
begin
  FixtureFile := GetTempFileName;
  Fixture := TFileStream.Create(FixtureFile, fmCreate);
  try Fixture.WriteBuffer('test', 4); finally Fixture.Free; end;
  Fake := TFakeTransport.Create;
  Fake.NextStatus := 200;
  Fake.NextBody := '{"status":200,"message":"ok","data":{}}';
  Fake.NextContentType := 'application/json';
  Client := TAssinafyClient.Create('test-key', 'default-account', AssinafySandboxURL, Fake);
  Client.AccessToken := 'test-bearer';
  TestBody := TJSONObject.Create(['enabled', False, 'email', 'developer@example.com']);
  TestQuery := TStringList.Create;
  TestQuery.Add('search=Ana & Joao');
  try
    {$I operations.inc}
    Response := Client.GetDocument('doc/with space');
    Response.Free;
    Check(Pos('doc%2Fwith%20space', Fake.LastURL) > 0, 'Path segments encoded');
    for I := 1 to 11 do ExpectInputError('Input ' + IntToStr(I), I);
    TestResponses;
    TestOAuth;
    TestWebhooks;
    TestSigningMethods;
    WriteLn('PASS: ', Checks, ' checks across all 106 API methods, responses, OAuth and webhooks');
  finally
    TestQuery.Free;
    TestBody.Free;
    Client.Free;
    Fake.Free;
    DeleteFile(FixtureFile);
  end;
end.
