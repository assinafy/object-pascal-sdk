program SDKTests;

{$IFDEF FPC}{$mode objfpc}{$H+}{$ENDIF}{$ASSERTIONS ON}
{$IFDEF FPC}{$codepage utf8}{$ENDIF}
{$IFNDEF FPC}{$APPTYPE CONSOLE}{$ENDIF}

uses
  {$ifdef unix}cthreads,{$endif}
  Classes, SysUtils, {$IFNDEF FPC}System.IOUtils,{$ENDIF} DateUtils, {$IFDEF FPC}fpjson,{$ENDIF} AssinafyJson, Assinafy, AssinafyHttp,
  AssinafyCrypto, AssinafyOAuth, AssinafyWebhooks, AssinafyURI;

type
  TFakeTransport = class(TAssinafyTransport)
  public
    LastMethod, LastURL, LastAuth, LastFile, LastFileField, LastContentType: string;
    LastBody: RawByteString;
    NextStatus, Calls: Integer;
    NextBody: RawByteString;
    NextContentType: string;
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
  LastFileField := Request.FileField;
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
      12: begin Temp := TAssinafyClient.Create('test-key', '', AssinafySandboxURL, Fake); Temp.Free; end;
      13: begin Response := Client.UploadDocument('', ''); Response.Free; end;
      14: begin Response := Client.UploadAccountLogo('', ''); Response.Free; end;
      15: begin Response := Client.UploadSignatureImage('signer-code', ''); Response.Free; end;
      16: begin Response := Client.UploadAccountLogo('', FixtureFile, ''); Response.Free; end;
      17: begin Response := Client.UploadAccountLogo('', FixtureFile, 'image/png' + #13#10 + 'Injected: value'); Response.Free; end;
    end;
    raise Exception.Create(Name + ': expected input error');
  except
    on E: EAssinafyInputError do Check(Fake.Calls = PriorCalls, Name + ': rejected before transport');
  end;
  Client.AccessToken := 'test-bearer';
  Client.TimeoutMS := 30000;
end;

function RawBytes(const Values: array of Byte): RawByteString;
var I: Integer;
begin
  Result := '';
  SetLength(Result, Length(Values));
  for I := 0 to High(Values) do Result[I + 1] := AnsiChar(Values[I]);
end;

procedure TestResponses;
const
  StatusCodes: array[0..6] of Integer = (400, 401, 403, 404, 415, 429, 500);
  InvalidBodies: array[0..5] of RawByteString = ('invalid json', '{"data":1}garbage',
    '{"data":1}{"data":2}', '   ', '{"data":1,"data":2}', '{"data":1}' + #0 + 'garbage');
var
  Stream: TMemoryStream;
  OldClient: TAssinafyClient;
  Code: Integer;
  InvalidBody: RawByteString;
  ExpectedText: RawByteString;
  procedure RejectBody(const Bytes: RawByteString; const ExpectedMessage: string = 'The API returned invalid JSON');
  begin
    Fake.NextBody := Bytes;
    try
      Response := Client.GetUser;
      Response.Free;
      raise Exception.Create('Expected protocol error');
    except
      on E: EAssinafyProtocolError do
      begin
        Check(E.Message = ExpectedMessage, 'Protocol error message remains compatible');
        Check(E.StatusCode = 200, 'Protocol error retains successful HTTP status');
        Check(E.ResponseBody = Bytes, 'Protocol error retains original response bytes');
      end;
    end;
  end;
  procedure RejectUTF8(const Bytes: array of Byte);
  begin
    RejectBody('{"data":"' + RawBytes(Bytes) + '"}', 'The API returned invalid UTF-8');
  end;
begin
  Fake.NextBody := '{"status":200,"message":"ok","data":{"nullable":null,"enabled":false,"value":9007199254740993,"extra":"kept"}}';
  Response := Client.GetAccount('');
  try
    Check(JSONBoolean(JSONFind(Response.Data, 'enabled')) = False, 'JSON boolean preserved');
    Check(JSONKind(JSONFind(Response.Data, 'nullable')) = jtNull, 'JSON null preserved');
    Check(JSONInteger(JSONFind(Response.Data, 'value')) = 9007199254740993, '64-bit integer preserved');
    Check(JSONString(JSONFind(Response.Data, 'extra')) = 'kept', 'Unknown response fields preserved');
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
  for InvalidBody in InvalidBodies do RejectBody(InvalidBody);
  RejectUTF8([$FF]);
  RejectUTF8([$80]);
  RejectUTF8([$C0, $AF]);
  RejectUTF8([$E0, $80, $AF]);
  RejectUTF8([$F0, $80, $80, $AF]);
  RejectUTF8([$ED, $A0, $80]);
  RejectUTF8([$F4, $90, $80, $80]);
  RejectUTF8([$F5, $80, $80, $80]);
  RejectUTF8([$E2, $82]);
  RejectUTF8([$C2]);
  for Code := 0 to 31 do
  begin
    Fake.NextBody := '{"data":"raw' + Chr(Code) + 'control"}';
    try
      Response := Client.GetUser;
      Response.Free;
      raise Exception.Create('Expected raw JSON control character rejection');
    except on E: EAssinafyProtocolError do Check(True, 'Raw JSON control character rejected'); end;
  end;
  Fake.NextBody := '{"data":"escaped\u0000null"}';
  try
    Response := Client.CreateAssignment('document', TestBody);
    Response.Free;
    raise Exception.Create('Expected escaped JSON NUL rejection');
  except
    on E: EAssinafyProtocolError do
    begin
      Check(E.Message = 'Escaped NUL is unsupported by the JSON parser', 'Escaped NUL protocol message remains compatible');
      Check(E.StatusCode = 200, 'Successful mutation status survives escaped NUL error');
      Check(E.ResponseBody = Fake.NextBody, 'Successful mutation payload survives escaped NUL error');
    end;
  end;
  Fake.NextBody := '{"data":"literal\\u0000"}';
  Response := Client.GetUser;
  try Check(JSONString(Response.Data) = 'literal\u0000', 'Literal Unicode escape text preserved'); finally Response.Free; end;
  ExpectedText := 'Jo' + RawBytes([$C3, $A3]) + 'o ' + RawBytes([$F0, $9F, $98, $80]);
  Fake.NextBody := '{"data":"' + ExpectedText + '"}';
  Response := Client.GetUser;
  try Check(UTF8Encode(UnicodeString(JSONString(Response.Data))) = ExpectedText, 'Accented and supplementary UTF-8 preserved'); finally Response.Free; end;
  Fake.NextContentType := 'application/pdf';
  Fake.NextBody := '%PDF-' + RawBytes([0, 255]) + 'binary';
  Response := Client.DownloadDocumentArtifact('doc', 'original');
  Stream := TMemoryStream.Create;
  try
    Check(Response.JSON = nil, 'PDF is not parsed as JSON');
    Response.SaveToStream(Stream);
    Check(Stream.Size = Length(Fake.NextBody), 'Binary bytes saved without truncation');
    Check(CompareMem(Stream.Memory, Pointer(Fake.NextBody), Stream.Size), 'Binary bytes unchanged');
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
    try
      OldClient.AccessToken := 'test-bearer';
      raise Exception.Create('API key and OAuth token accepted together');
    except on E: EAssinafyInputError do Check(OldClient.AccessToken = '', 'Mixed authentication rejected without changing client'); end;
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

procedure TestAuthenticationAndURLs;
var
  KeyClient, PrefixedClient: TAssinafyClient;
  I, PriorCalls: Integer;
begin
  KeyClient := TAssinafyClient.Create('api-key', 'account', AssinafySandboxURL, Fake);
  PrefixedClient := TAssinafyClient.Create('', '', 'https://proxy.example.com:8443/api/v1///', Fake);
  try
    for I := 0 to 1 do
    begin
      if I = 0 then Response := Client.ListSignerDocuments('signer')
      else Response := Client.SearchSignerDocuments('signer');
      Response.Free;
      Check(Fake.LastAuth = 'bearer', 'Signer-or-API uses bearer without signer code');
      Check(Pos('signer-access-code', Fake.LastURL) = 0, 'Bearer fallback omits signer code');
      if I = 0 then Response := KeyClient.ListSignerDocuments('signer')
      else Response := KeyClient.SearchSignerDocuments('signer');
      Response.Free;
      Check(Fake.LastAuth = 'key', 'Signer-or-API uses API key without signer code');
    end;
    PriorCalls := Fake.Calls;
    try
      Response := KeyClient.GetOAuthUserInfo;
      Response.Free;
      raise Exception.Create('Userinfo accepted an API key');
    except on E: EAssinafyInputError do Check(Fake.Calls = PriorCalls, 'Userinfo requires bearer before transport'); end;
    Response := Client.GetAccount('explicit/account');
    Response.Free;
    Check(Fake.LastURL = AssinafySandboxURL + '/accounts/explicit%2Faccount', 'Explicit account overrides default');
    Response := PrefixedClient.GetOAuthResourceMetadata;
    Response.Free;
    Check(Fake.LastURL = 'https://proxy.example.com:8443/.well-known/oauth-protected-resource', 'Metadata uses origin, preserving port');
    Check(PrefixedClient.BaseURL = 'https://proxy.example.com:8443/api/v1', 'URL slashes normalize portably');
    Check(TrimURLTrailingSlash('https://api.example.com/v1/') = 'https://api.example.com/v1', 'URL trailing slash helper');
    Check(TrimURLTrailingSlash('') = '', 'Empty URL trimming is safe');
  finally PrefixedClient.Free; KeyClient.Free; end;
end;

procedure TestUploadLimits;
const
  Fields: array[0..2] of string = ('file', 'attachment', '');
var
  Transport: TAssinafyDefaultTransport;
  Request: TAssinafyRequest;
  Headers: TStringList;
  FileName, Field: string;
  FileStream: TFileStream;
begin
  {$IFDEF FPC}FileName := GetTempFileName;{$ELSE}
  FileName := System.IOUtils.TPath.GetTempFileName;{$ENDIF}
  FileStream := TFileStream.Create(FileName, fmCreate);
  try FileStream.Size := 25 * 1024 * 1024 + 1; finally FileStream.Free; end;
  Headers := TStringList.Create;
  Transport := TAssinafyDefaultTransport.Create;
  try
    Request := Default(TAssinafyRequest);
    Request.Method := 'POST';
    Request.URL := 'http://127.0.0.1:9/v1/upload';
    Request.Headers := Headers;
    Request.ContentType := 'application/octet-stream';
    Request.TimeoutMS := -1;
    try
      Response := Transport.Execute(Request);
      Response.Free;
      raise Exception.Create('Negative transport timeout accepted');
    except on E: EAssinafyInputError do Check(True, 'Direct transport rejects negative timeout'); end;
    Request.FileName := FileName;
    Request.TimeoutMS := 1000;
    for Field in Fields do
    begin
      Request.FileField := Field;
      try
        Response := Transport.Execute(Request);
        Response.Free;
        raise Exception.Create('Oversized upload accepted');
      except on E: EAssinafyInputError do Check(True, 'All upload fields enforce size before transfer'); end;
    end;
  finally Transport.Free; Headers.Free; DeleteFile(FileName); end;
end;

procedure TestTransportHeaders;
const
  Invalid: array[0..7] of string = ('X-Test: ok' + #13#10 + 'Injected: value',
    'X-Test: before' + #0 + 'after', 'X-Test: ' + #1, 'X-Test: ' + #127,
    'Bad Name: value', ': value', 'NoSeparator', 'X-Á: value');
var
  Transport: TAssinafyDefaultTransport;
  Request: TAssinafyRequest;
  Headers: TStringList;
  Line: string;
begin
  Transport := TAssinafyDefaultTransport.Create;
  Headers := TStringList.Create;
  try
    Request := Default(TAssinafyRequest);
    Request.Method := 'GET';
    Request.URL := 'http://127.0.0.1:9/v1/unused';
    Request.TimeoutMS := 1000;
    Request.Headers := Headers;
    for Line in Invalid do
    begin
      Headers.Clear;
      Headers.Add(Line);
      try
        Response := Transport.Execute(Request);
        Response.Free;
        raise Exception.Create('Invalid direct HTTP header accepted');
      except on E: EAssinafyInputError do Check(True, 'Direct transport validates HTTP headers before transfer'); end;
    end;
    Headers.Clear;
    Request.ContentType := 'application/json' + #13#10 + 'Injected: value';
    try
      Response := Transport.Execute(Request);
      Response.Free;
      raise Exception.Create('Invalid direct content type accepted');
    except on E: EAssinafyInputError do Check(True, 'Direct transport rejects content-type injection'); end;
    Request.ContentType := '';
    Request.Headers := nil;
    try
      Response := Transport.Execute(Request);
      Response.Free;
      raise Exception.Create('Missing direct headers accepted');
    except on E: EAssinafyInputError do Check(True, 'Direct transport rejects missing header collection'); end;
  finally Headers.Free; Transport.Free; end;
end;

procedure TestOAuth;
const
  InvalidRefreshBodies: array[0..2] of string = (
    '{"access_token":"new-access","token_type":"Bearer"}',
    '{"access_token":"new-access","refresh_token":null,"token_type":"Bearer"}',
    '{"access_token":"new-access","refresh_token":"rotated","token_type":"wrong-type"}');
var
  PKCE, Second: TAssinafyPKCE;
  Config: TAssinafyOAuthConfig;
  Callback: TStringList;
  URL: string;
  UnicodeVerifier: UnicodeString;
  InvalidBody: string;
  PriorCalls: Integer;
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
  Config.Issuer := AssinafyOAuthIssuer + '/';
  Check(Pos(AssinafyOAuthIssuer + '/oauth/authorize?', AuthorizationURL(Config, 'state', PKCE.Verifier)) = 1,
    'Issuer trailing slash does not duplicate URL separator');
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
    Callback.Values['state'] := 'João 😀';
    Check(ValidateOAuthCallback(Callback, 'João 😀') = 'code-value', 'Unicode OAuth state matches exactly');
    try ValidateOAuthCallback(Callback, 'Joao 😀'); raise Exception.Create('Different Unicode state accepted');
    except on E: EAssinafyInputError do Check(True, 'Different Unicode OAuth state rejected'); end;
    {$IFNDEF FPC}
    Callback.Values['state'] := 'state' + Char($D800);
    try ValidateOAuthCallback(Callback, 'state' + Char($D801)); raise Exception.Create('Distinct surrogate states accepted');
    except on E: EAssinafyInputError do Check(True, 'OAuth state compares exact Unicode code units'); end;
    {$ENDIF}
    Callback.Values['state'] := 'state';
    Callback.Add('error=access_denied');
    try ValidateOAuthCallback(Callback, 'state'); raise Exception.Create('Code and error accepted');
    except on E: EAssinafyInputError do Check(True, 'Ambiguous callback rejected'); end;
  finally Callback.Free; end;
  Config.Issuer := 'https://auth-sandbox.assinafy.com.br';
  Config.Resource := 'https://sandbox.assinafy.com.br:443/';
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
  for InvalidBody in InvalidRefreshBodies do
  begin
    Fake.NextBody := InvalidBody;
    PriorCalls := Fake.Calls;
    try
      Response := RefreshToken(Client, Config, 'old-refresh');
      Response.Free;
      raise Exception.Create('Invalid refresh response accepted');
    except
      on E: EAssinafyProtocolError do
      begin
        Check(E.StatusCode = 200, 'Refresh protocol error preserves HTTP status');
        Check(E.ResponseBody = InvalidBody, 'Returned tokens remain recoverable after refresh rejection');
        Check(Fake.Calls = PriorCalls + 1, 'Refresh is never retried');
      end;
    end;
  end;
  Fake.NextBody := '{"access_token":"access","token_type":"wrong-type"}';
  try
    Response := ExchangeCode(Client, Config, 'code', PKCE.Verifier);
    Response.Free;
    raise Exception.Create('Invalid token type accepted');
  except on E: EAssinafyProtocolError do Check(True, 'Invalid token type rejected'); end;
  UnicodeVerifier := UnicodeString(StringOfChar('A', 42)) + WideChar($0141);
  try PKCEChallenge(string(UnicodeVerifier)); raise Exception.Create('Non-ASCII PKCE verifier accepted');
  except on E: EAssinafyInputError do Check(True, 'PKCE rejects Unicode characters sharing ASCII low bytes'); end;
  try PKCEChallenge('short'); raise Exception.Create('Short verifier accepted');
  except on E: EAssinafyInputError do Check(True, 'Short verifier rejected'); end;
end;

procedure TestTextEncoding;
type
  TLatinText = type AnsiString(1252);
var
  {$IFDEF FPC}OldCodePage: TSystemCodePage;{$ENDIF}
  Name: TLatinText;
  UTF8Name: UTF8String;
  Obj: TJSONObject;
  Arr: TJSONArray;
  Body: RawByteString;
  Query: TStringList;
begin
  {$IFDEF FPC}OldCodePage := DefaultSystemCodePage;{$ENDIF}
  Query := TStringList.Create;
  try
    {$IFDEF FPC}DefaultSystemCodePage := 1252;{$ENDIF}
    Name := 'João';
    Check((StringCodePage(Name) = 1252) and (Length(Name) = 4) and (Ord(Name[3]) = $E3),
      'Legacy text fixture preserves its declared code page and bytes');
    UTF8Name := 'João 😀';
    Obj := JSONObj(['utf8', UTF8Name, 'legacy', Name]);
    try
      Check(JSONString(JSONFind(Obj, 'utf8')) = UTF8Name, 'JSON constructor retains UTF-8 string code page');
      Check(JSONString(JSONFind(Obj, 'legacy')) = UTF8String('João'), 'JSON constructor converts declared legacy code page');
    finally Obj.Free; end;
    Arr := JSONArr([UTF8Name, Name]);
    try
      Check(JSONString(Arr.Items[0]) = UTF8Name, 'JSON array retains UTF-8 string code page');
      Check(JSONString(Arr.Items[1]) = UTF8String('João'), 'JSON array converts declared legacy code page');
    finally Arr.Free; end;
    Check(PercentEncode(Name) = 'Jo%C3%A3o', 'Legacy code page converts query text to UTF-8');
    Query.Add('search=' + Name);
    Check(EncodeQuery(Query) = 'search=Jo%C3%A3o', 'Legacy query values use UTF-8 on the wire');
    Response := TAssinafyResponse.Create;
    try
      Response.Body := RawBytes([$7B, $22, $74, $65, $78, $74, $22, $3A, $22,
        $F0, $9F, $98, $80, $22, $7D]);
      Response.ParseJSON;
      Check(JSONString(JSONFind(Response.JSON, 'text')) = UTF8String('😀'),
        'JSON string helper retains UTF-8 outside the legacy code page');
    finally Response.Free; end;
    Body := '%PDF-' + RawBytes([0, 255]) + 'fixture';
    {$IFDEF FPC}SetCodePage(Body, CP_UTF8, False);{$ENDIF}
    Check(VerifyWebhook('whsec_c2VjcmV0', Name, '1700000000',
      'v1,V95AJ5O7LD3URtN97mJ8JxW7e3LweqtrXHysLXqkKWM=', Body, 1700000000),
      'Webhook text uses UTF-8 while raw body bytes are unchanged');
  finally
    {$IFDEF FPC}DefaultSystemCodePage := OldCodePage;{$ENDIF}
    Query.Free;
  end;
end;

procedure TestOAuthEnvironments;
const
  Resources: array[0..1] of string = ('https://sandbox.assinafy.com.br', 'https://api.assinafy.com.br');
  Issuers: array[0..1] of string = ('https://auth-sandbox.assinafy.com.br', AssinafyOAuthIssuer);
var
  Clients: array[0..1] of TAssinafyClient;
  Config: TAssinafyOAuthConfig;
  I, J, Grant, PriorCalls: Integer;
begin
  Clients[0] := Client;
  Clients[1] := TAssinafyClient.Create('', '', AssinafyProductionURL, Fake);
  Config := Default(TAssinafyOAuthConfig);
  Config.ClientID := 'client-id';
  Config.RedirectURI := 'https://app.example.com/oauth/callback';
  Fake.NextBody := '{"access_token":"access","refresh_token":"replacement","token_type":"Bearer"}';
  try
    for I := 0 to 1 do
      for J := 0 to 2 do
      begin
        Config.Issuer := Issuers[I];
        Config.Resource := Resources[I];
        case J of
          0: Config.Resource := Resources[1 - I];
          1: begin Config.Resource := ''; Config.Issuer := Issuers[1 - I]; end;
          2: Config.Resource := Resources[I] + ':444';
        end;
        for Grant := 0 to 1 do
        begin
          PriorCalls := Fake.Calls;
          try
            if Grant = 0 then Response := ExchangeCode(Clients[I], Config, 'code', StringOfChar('a', 43))
            else Response := RefreshToken(Clients[I], Config, 'refresh');
            Response.Free;
            raise Exception.Create('OAuth environment mismatch accepted');
          except on E: EAssinafyInputError do Check(Fake.Calls = PriorCalls, 'OAuth environment mismatch rejected before transport'); end;
        end;
      end;
  finally Clients[1].Free; end;
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
  Check(Base64Encode(SHA256('abc')) = 'ungWv48Bz+pBQUDeXa4iI7ADYaOWF3qctBD/YfIAFa0=', 'SHA256 known vector');
  Check(Base64Encode(HMACSHA256('key', 'The quick brown fox jumps over the lazy dog')) =
    '97yD9DBThCSxMpjmqm+xQ+9NWaFJRhdZl0edvC0aPNg=', 'HMAC-SHA256 known vector');
  Signature := 'v1,' + Base64Encode(HMACSHA256('secret', 'msg_1.' + Timestamp + '.' + Body));
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
    Signature := 'v1,' + Base64Encode(HMACSHA256('secret', 'msg_1.' + CurrentTimestamp + '.' + Body));
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
    Signature := 'v1,' + Base64Encode(HMACSHA256('secret', 'msg:1=2.' + CurrentTimestamp + '.' + Body));
    Headers[0] := 'webhook-id=msg:1=2';
    Headers[2] := 'webhook-signature=' + Signature;
    Check(VerifyWebhookHeaders(Secret, Headers, Body), 'Name=value header retains colon in value');
    Headers[0] := 'webhook-id: msg:1=2';
    Headers[2] := 'webhook-signature: ' + Signature;
    Check(VerifyWebhookHeaders(Secret, Headers, Body), 'Name:value header retains equals in value');
    Headers.Insert(0, 'webhook-id:');
    Check(not VerifyWebhookHeaders(Secret, Headers, Body), 'Empty duplicate webhook ID rejected');
    Headers.Delete(0);
    Headers.Insert(0, 'webhook-timestamp:');
    Check(not VerifyWebhookHeaders(Secret, Headers, Body), 'Empty duplicate webhook timestamp rejected');
    Check(not VerifyWebhookHeaders(Secret, nil, Body), 'Missing header list rejected');
  finally Headers.Free; end;
end;

procedure TestURIOrigins;
const
  Invalid: array[0..9] of string = ('https://api.example.com:99999/v1',
    'https://api.example.com:65536/v1', 'https://api.example.com:18446744073709551616/v1',
    'https://api.example.com:-1/v1', 'https://api.example.com:+443/v1',
    'https://api.example.com:abc/v1', 'https://api.example.com:1e3/v1',
    'https://[::1]:70000/v1', 'https://[::1]:abc/v1', 'https://[::1/v1');
var URI: TAssinafyURI; Value: string;
begin
  URI := ParseAssinafyURI('https://user:password@api.example.com:8443/v1?type=original#fragment');
  Check(TrimURLTrailingSlash(URI.Origin) = 'https://api.example.com:8443', 'URI origin contains only scheme, host and port');
  Check((URI.UserName = 'user') and (URI.Password = 'password'), 'URI validation retains original credentials');
  Check((URI.Params = 'type=original') and (URI.Bookmark = 'fragment'), 'URI validation retains original query and fragment');
  URI := ParseAssinafyURI('https://api.example.com:65535/v1');
  Check(URI.Port = 65535, 'Maximum URI port preserved');
  URI := ParseAssinafyURI('https://api.example.com:0/v1');
  Check(URI.Port = 0, 'Zero URI port remains representable');
  URI := ParseAssinafyURI('https://api.example.com:/v1');
  Check(URI.Host = 'api.example.com', 'Empty URI port normalizes to the default');
  URI := ParseAssinafyURI('https://[::1]:/v1');
  Check((URI.Host = '[::1]') or (URI.Host = '::1'), 'Empty IPv6 URI port normalizes to the default');
  URI := ParseAssinafyURI('https://[::1]:443/v1');
  Check(URI.Port = 443, 'Bracketed IPv6 port preserved');
  URI := ParseAssinafyURI('https://user:99999@api.example.com/path?next=:99999#fragment');
  Check(URI.Host = 'api.example.com', 'Credentials and query text are not parsed as ports');
  for Value in Invalid do
    try
      URI := ParseAssinafyURI(Value);
      raise Exception.Create('Invalid URI port accepted');
    except on E: EAssinafyInputError do Check(True, 'Invalid URI ports have a consistent input error'); end;
end;

procedure TestJSONCompatibility;
const
  Invalid: array[0..15] of string = ('[1,]', '{"a":1,}', '[,1]',
    '01', '-01', '1.', '1e', '1e+', '+1', 'NaN', '/*comment*/1',
    '{"a":"\x00"}', '{"a":"\u00xz"}', '{"a":1,"\u0061":2}',
    '{"nested":{"a":1,"a":2}}', '[{"a":1,"a":2}]');
var Obj, CopyObj, Child: TJSONObject; Arr: TJSONArray; Value: TJSONData; Text: string; Rejected: Boolean;
begin
  Obj := JSONObj(['empty', '', 'null', nil, 'enabled', False,
    'large', Int64(9007199254740993), 'text', 'João 😀']);
  try
    Arr := JSONArr(['Email', 3, True]);
    JSONAdd(Obj, 'list', Arr);
    JSONAdd(Arr, JSONObj(['id', 'child']));
    JSONAdd(Obj, '', 'empty name');
    Child := JSONObj(['value', 'retained']);
    try
      Rejected := False;
      try JSONAdd(Obj, 'empty', Child); except on E: Exception do Rejected := True; end;
      Check(Rejected, 'Duplicate JSON property rejected');
      Check(JSONGet(Child, 'value', '') = 'retained', 'Rejected JSON child remains caller-owned');
    finally Child.Free; end;
    Check(Obj.Count = 7, 'Empty JSON property name retained');
    Value := ParseJSONStrict(JSONText(Obj));
    try
      CopyObj := TJSONObject(Value);
      Check(JSONGet(CopyObj, 'empty', 'fallback') = '', 'Empty JSON strings retained');
      Check(JSONKind(JSONFind(Value, 'null')) = jtNull, 'Explicit JSON null retained');
      Check(not JSONBoolean(JSONFind(Value, 'enabled')), 'JSON false retained');
      Check(JSONInteger(JSONFind(Value, 'large')) = 9007199254740993, 'JSON integer keeps precision');
      Check(UTF8Encode(UnicodeString(JSONString(JSONFind(Value, 'text')))) = UTF8String('João 😀'), 'JSON Unicode constructor round trip');
      Check(JSONString(TJSONArray(JSONFind(Value, 'list')).Items[0]) = 'Email', 'JSON array values retained');
      Check(JSONGet(CopyObj, 'missing', 'fallback') = 'fallback', 'Missing JSON string default');
    finally Value.Free; end;
  finally Obj.Free; end;
  Rejected := False;
  try
    Obj := JSONObj(['duplicate', 1, 'duplicate', 2]);
    Obj.Free;
  except on E: Exception do Rejected := True; end;
  Check(Rejected, 'JSON constructor rejects duplicate scalar properties');
  Child := JSONObj(['value', 'retained']);
  try
    Rejected := False;
    try
      Obj := JSONObj(['duplicate', 1, 'duplicate', Child]);
      Obj.Free;
    except on E: Exception do Rejected := True; end;
    Check(Rejected, 'JSON constructor rejects duplicate child properties');
    Check(JSONGet(Child, 'value', '') = 'retained', 'Rejected constructor child remains caller-owned');
  finally Child.Free; end;
  Value := ParseJSONStrict('1.5');
  try
    try
      JSONInteger(Value);
      raise Exception.Create('Fractional integer accepted');
    except on E: EConvertError do Check(True, 'Integer helper rejects fractional numbers'); end;
  finally Value.Free; end;
  Value := ParseJSONStrict(StringOfChar('[', 512) + StringOfChar(']', 512));
  try Check(Value is TJSONArray, 'Maximum JSON nesting accepted'); finally Value.Free; end;
  try
    Value := ParseJSONStrict(StringOfChar('[', 513) + StringOfChar(']', 513));
    Value.Free;
    raise Exception.Create('Excessive JSON nesting accepted');
  except on E: EConvertError do Check(True, 'Excessive JSON nesting rejected'); end;
  for Text in Invalid do
    try
      Value := ParseJSONStrict(UTF8Encode(UnicodeString(Text)));
      Value.Free;
      raise Exception.Create('Invalid JSON syntax accepted: ' + Text);
    except
      on E: Exception do
      begin
        if Pos('Invalid JSON syntax accepted:', E.Message) = 1 then raise;
        Check(True, 'Invalid JSON rejected');
      end;
    end;
end;

{$IFDEF FPC}
procedure TestNativeFPCCompatibility;
var Body: fpjson.TJSONObject; Root: fpjson.TJSONData;
begin
  Body := fpjson.TJSONObject.Create(['name', 'legacy']);
  try
    Fake.NextBody := '{"data":{"name":"legacy"}}';
    Response := Client.RenameDocument('document', Body);
    try
      Root := Response.JSON;
      Check(Root.FindPath('data.name').AsString = 'legacy', 'Native fpjson response access remains compatible');
      Check(Fake.LastBody = Body.AsJSON, 'Native fpjson request bodies remain compatible');
    finally Response.Free; end;
  finally Body.Free; end;
end;
{$ENDIF}

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
    Body := JSONObj(['method', 'virtual']);
    try
      Signers := TJSONArray.Create;
      JSONAdd(Body, 'signers', Signers);
      JSONAdd(Signers, JSONObj(['id', 'signer', 'verification_method', Method,
        'notification_methods', JSONArr([Channel]), 'step', 1]));
      Response := Client.EstimateAssignmentCost('document', Body);
      Response.Free;
      Check(Fake.LastBody = JSONText(Body), Method + ' estimation payload retained');
      Response := Client.CreateAssignment('document', Body);
      Response.Free;
      Check(Fake.LastBody = JSONText(Body), Method + ' assignment payload retained');
    finally Body.Free; end;
  end;
  Body := JSONObj(['verification-code', '123456']);
  try
    Response := Client.VerifySignerCode('signer-code', Body);
    Response.Free;
    Check(Fake.LastBody = JSONText(Body), 'OTP field spelling preserved');
    Check(Fake.LastAuth = 'signer', 'OTP uses signer authentication');
  finally Body.Free; end;
end;

var
  Fixture: TFileStream;
  I: Integer;
begin
  {$IFDEF FPC}HaltOnNotReleased := True;{$ENDIF}
  FixtureFile := GetTempFileName;
  Fixture := TFileStream.Create(FixtureFile, fmCreate);
  try Fixture.WriteBuffer('test', 4); finally Fixture.Free; end;
  Fake := TFakeTransport.Create;
  Fake.NextStatus := 200;
  Fake.NextBody := '{"status":200,"message":"ok","data":{}}';
  Fake.NextContentType := 'application/json';
  Client := TAssinafyClient.Create('', 'default-account', AssinafySandboxURL, Fake);
  Client.AccessToken := 'test-bearer';
  TestBody := JSONObj(['enabled', False, 'email', 'developer@example.com']);
  TestQuery := TStringList.Create;
  TestQuery.Add('search=Ana & Joao');
  try
    {$I operations.inc}
    Response := Client.GetDocument('doc/with space');
    Response.Free;
    Check(Pos('doc%2Fwith%20space', Fake.LastURL) > 0, 'Path segments encoded');
    for I := 1 to 17 do ExpectInputError('Input ' + IntToStr(I), I);
    TestResponses;
    TestAuthenticationAndURLs;
    TestUploadLimits;
    TestTransportHeaders;
    TestOAuth;
    TestOAuthEnvironments;
    TestTextEncoding;
    TestWebhooks;
    TestURIOrigins;
    TestJSONCompatibility;
    {$IFDEF FPC}TestNativeFPCCompatibility;{$ENDIF}
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
