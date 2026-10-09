program OAuthConnect;

{$mode objfpc}{$H+}

uses
  {$ifdef unix}cthreads,{$endif}
  Classes, SysUtils, fpjson, Assinafy, AssinafyHttp, AssinafyOAuth;

var
  Config: TAssinafyOAuthConfig;
  PKCE: TAssinafyPKCE;
  State, BaseURL, Line, Code: string;
  Callback: TStringList;
  Client: TAssinafyClient;
  Response: TAssinafyResponse;
begin
  Config.ClientID := GetEnvironmentVariable('ASSINAFY_CLIENT_ID');
  Config.ClientSecret := GetEnvironmentVariable('ASSINAFY_CLIENT_SECRET');
  Config.RedirectURI := GetEnvironmentVariable('ASSINAFY_REDIRECT_URI');
  Config.Issuer := GetEnvironmentVariable('ASSINAFY_OAUTH_ISSUER');
  Config.Resource := GetEnvironmentVariable('ASSINAFY_OAUTH_RESOURCE');
  Config.Scopes := 'account:read documents:read offline_access';
  BaseURL := GetEnvironmentVariable('ASSINAFY_BASE_URL');
  if BaseURL = '' then BaseURL := AssinafyProductionURL;
  if Config.Issuer = '' then
  begin
    if BaseURL = AssinafySandboxURL then Config.Issuer := 'https://auth-sandbox.assinafy.com.br'
    else Config.Issuer := AssinafyOAuthIssuer;
  end;
  PKCE := GeneratePKCE;
  State := GenerateState;
  WriteLn('Open this URL in your browser:');
  WriteLn(AuthorizationURL(Config, State, PKCE.Verifier));
  WriteLn('Return with the decoded callback values from your registered HTTPS endpoint.');
  Callback := TStringList.Create;
  Client := TAssinafyClient.Create('', '', BaseURL);
  try
    Write('state: '); ReadLn(Line); Callback.Values['state'] := Line;
    Write('iss: '); ReadLn(Line); Callback.Values['iss'] := Line;
    Write('code: '); ReadLn(Line); Callback.Values['code'] := Line;
    Code := ValidateOAuthCallback(Callback, State, Config.Issuer);
    Response := ExchangeCode(Client, Config, Code, PKCE.Verifier);
    try
      Client.AccessToken := Response.Data.FindPath('access_token').AsString;
      WriteLn('Connected. Returned scope: ', TJSONObject(Response.Data).Get('scope', ''));
    finally Response.Free; end;
    Response := Client.ListMyAccounts;
    try WriteLn('Workspaces: ', Response.Data.AsJSON); finally Response.Free; end;
  finally
    Client.Free;
    Callback.Free;
  end;
end.
