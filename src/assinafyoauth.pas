unit AssinafyOAuth;

{$mode objfpc}{$H+}

interface

uses
  Classes, Assinafy, AssinafyHttp;

const
  AssinafyOAuthIssuer = 'https://auth.assinafy.com.br';
  AssinafyOAuthResource = 'https://api.assinafy.com.br';

type
  TAssinafyPKCE = record
    Verifier: string;
    Challenge: string;
  end;

  TAssinafyOAuthConfig = record
    ClientID: string;
    ClientSecret: string;
    RedirectURI: string;
    Scopes: string;
    Issuer: string;
    Resource: string;
  end;

function GeneratePKCE: TAssinafyPKCE;
function GenerateState: string;
function PKCEChallenge(const Verifier: string): string;
function AuthorizationURL(const Config: TAssinafyOAuthConfig;
  const State, Verifier: string; const Nonce: string = ''): string;
function ValidateOAuthCallback(Query: TStrings; const ExpectedState: string;
  const ExpectedIssuer: string = AssinafyOAuthIssuer): string;
function ExchangeCode(Client: TAssinafyClient; const Config: TAssinafyOAuthConfig;
  const Code, Verifier: string): TAssinafyResponse;
function RefreshToken(Client: TAssinafyClient; const Config: TAssinafyOAuthConfig;
  const Token: string): TAssinafyResponse;
function RevokeToken(Client: TAssinafyClient; const Config: TAssinafyOAuthConfig;
  const Token: string; const TokenTypeHint: string = ''): TAssinafyResponse;

implementation

uses
  SysUtils, fpjson, URIParser, AssinafyCrypto;

procedure RequireHTTPS(const Value, Name: string);
var
  URI: TURI;
begin
  RequireValue(Value, Name);
  URI := ParseURI(Value);
  if (LowerCase(URI.Protocol) <> 'https') or (URI.Host = '') or
    (URI.UserName <> '') or (URI.Password <> '') or (URI.Bookmark <> '') then
    raise EAssinafyInputError.Create(Name + ' requires HTTPS without credentials or a fragment');
end;

function PKCEChallenge(const Verifier: string): string;
var
  C: Char;
begin
  if (Length(Verifier) < 43) or (Length(Verifier) > 128) then
    raise EAssinafyInputError.Create('PKCE verifier must contain 43 to 128 characters');
  for C in Verifier do
    if not (C in ['A'..'Z', 'a'..'z', '0'..'9', '-', '.', '_', '~']) then
      raise EAssinafyInputError.Create('PKCE verifier contains an invalid character');
  Result := Base64URL(SHA256(Verifier));
end;

function GeneratePKCE: TAssinafyPKCE;
begin
  Result.Verifier := Base64URL(SecureRandom(32));
  Result.Challenge := PKCEChallenge(Result.Verifier);
end;

function GenerateState: string;
begin
  Result := Base64URL(SecureRandom(32));
end;

function AuthorizationURL(const Config: TAssinafyOAuthConfig;
  const State, Verifier, Nonce: string): string;
var
  Params: TStringList;
  Issuer: string;
begin
  RequireValue(Config.ClientID, 'Client ID');
  RequireHTTPS(Config.RedirectURI, 'Redirect URI');
  RequireValue(Config.Scopes, 'Scopes');
  RequireValue(State, 'State');
  Issuer := Config.Issuer;
  if Issuer = '' then Issuer := AssinafyOAuthIssuer;
  RequireHTTPS(Issuer, 'Issuer');
  if ParseURI(Issuer).Params <> '' then
    raise EAssinafyInputError.Create('Issuer cannot contain a query');
  Params := TStringList.Create;
  try
    Params.Values['response_type'] := 'code';
    Params.Values['client_id'] := Config.ClientID;
    Params.Values['redirect_uri'] := Config.RedirectURI;
    Params.Values['scope'] := Config.Scopes;
    Params.Values['state'] := State;
    Params.Values['code_challenge'] := PKCEChallenge(Verifier);
    Params.Values['code_challenge_method'] := 'S256';
    if Config.Resource <> '' then
    begin
      RequireHTTPS(Config.Resource, 'Resource');
      Params.Values['resource'] := Config.Resource;
    end;
    if Nonce <> '' then Params.Values['nonce'] := Nonce;
    Result := ExcludeTrailingPathDelimiter(Issuer) + '/oauth/authorize?' + EncodeQuery(Params);
  finally
    Params.Free;
  end;
end;

function ValidateOAuthCallback(Query: TStrings; const ExpectedState, ExpectedIssuer: string): string;
var
  I: Integer;
  Seen: TStringList;
  Key: string;
begin
  RequireValue(ExpectedState, 'Expected state');
  RequireHTTPS(ExpectedIssuer, 'Expected issuer');
  if Query = nil then raise EAssinafyInputError.Create('OAuth callback parameters are required');
  Seen := TStringList.Create;
  Seen.CaseSensitive := True;
  try
    for I := 0 to Query.Count - 1 do
    begin
      Key := Query.Names[I];
      if Seen.IndexOfName(Key) >= 0 then
        raise EAssinafyInputError.Create('OAuth callback contains duplicate parameters');
      RequireValue(Key, 'OAuth callback parameter name');
      Seen.Add(Query[I]);
    end;
    if not ConstantTimeEqual(Seen.Values['state'], ExpectedState) then
      raise EAssinafyInputError.Create('OAuth callback state does not match');
    if Seen.Values['iss'] <> ExpectedIssuer then
      raise EAssinafyInputError.Create('OAuth callback issuer does not match');
    if (Seen.Values['code'] <> '') = (Seen.Values['error'] <> '') then
      raise EAssinafyInputError.Create('OAuth callback requires exactly one code or error');
    if Seen.Values['error'] <> '' then
      raise EAssinafyInputError.Create('OAuth authorization failed: ' + Seen.Values['error']);
    Result := Seen.Values['code'];
    RequireValue(Result, 'Authorization code');
  finally
    Seen.Free;
  end;
end;

procedure ValidateTokenResponse(Response: TAssinafyResponse; RequireRefresh: Boolean);
var
  Obj: TJSONObject;
  Value: TJSONData;
begin
  if not (Response.JSON is TJSONObject) then
    raise EAssinafyProtocolError.Create('OAuth token response must be an object');
  Obj := TJSONObject(Response.JSON);
  Value := Obj.Find('access_token');
  if (Value = nil) or (Value.JSONType <> jtString) or (Value.AsString = '') then
    raise EAssinafyProtocolError.Create('OAuth response is missing an access token');
  Value := Obj.Find('token_type');
  if (Value = nil) or (Value.JSONType <> jtString) or not SameText(Value.AsString, 'Bearer') then
    raise EAssinafyProtocolError.Create('OAuth token type must be Bearer');
  if RequireRefresh then
  begin
    Value := Obj.Find('refresh_token');
    if (Value = nil) or (Value.JSONType <> jtString) or (Value.AsString = '') then
      raise EAssinafyProtocolError.Create('OAuth refresh response is missing its replacement refresh token');
  end;
end;

function TokenBody(const Config: TAssinafyOAuthConfig): TJSONObject;
begin
  RequireValue(Config.ClientID, 'Client ID');
  Result := TJSONObject.Create(['client_id', Config.ClientID]);
  if Config.ClientSecret <> '' then Result.Add('client_secret', Config.ClientSecret);
  if Config.Resource <> '' then Result.Add('resource', Config.Resource);
end;

function ExchangeCode(Client: TAssinafyClient; const Config: TAssinafyOAuthConfig;
  const Code, Verifier: string): TAssinafyResponse;
var
  Body: TJSONObject;
begin
  if Client = nil then raise EAssinafyInputError.Create('Client is required');
  RequireValue(Code, 'Authorization code');
  RequireHTTPS(Config.RedirectURI, 'Redirect URI');
  PKCEChallenge(Verifier);
  Body := TokenBody(Config);
  try
    Body.Add('grant_type', 'authorization_code');
    Body.Add('code', Code);
    Body.Add('code_verifier', Verifier);
    Body.Add('redirect_uri', Config.RedirectURI);
    Result := Client.ExchangeOAuthToken(Body);
    try
      ValidateTokenResponse(Result, False);
    except
      Result.Free;
      raise;
    end;
  finally
    Body.Free;
  end;
end;

function RefreshToken(Client: TAssinafyClient; const Config: TAssinafyOAuthConfig;
  const Token: string): TAssinafyResponse;
var
  Body: TJSONObject;
begin
  if Client = nil then raise EAssinafyInputError.Create('Client is required');
  RequireValue(Token, 'Refresh token');
  Body := TokenBody(Config);
  try
    Body.Add('grant_type', 'refresh_token');
    Body.Add('refresh_token', Token);
    Result := Client.ExchangeOAuthToken(Body);
    try
      ValidateTokenResponse(Result, True);
    except
      Result.Free;
      raise;
    end;
  finally
    Body.Free;
  end;
end;

function RevokeToken(Client: TAssinafyClient; const Config: TAssinafyOAuthConfig;
  const Token, TokenTypeHint: string): TAssinafyResponse;
var
  Body: TJSONObject;
begin
  if Client = nil then raise EAssinafyInputError.Create('Client is required');
  RequireValue(Config.ClientID, 'Client ID');
  RequireValue(Token, 'Token');
  if (TokenTypeHint <> '') and (TokenTypeHint <> 'access_token') and (TokenTypeHint <> 'refresh_token') then
    raise EAssinafyInputError.Create('Invalid token type hint');
  Body := TJSONObject.Create(['client_id', Config.ClientID, 'token', Token]);
  try
    if Config.ClientSecret <> '' then Body.Add('client_secret', Config.ClientSecret);
    if TokenTypeHint <> '' then Body.Add('token_type_hint', TokenTypeHint);
    Result := Client.RevokeOAuthToken(Body);
  finally
    Body.Free;
  end;
end;

end.
