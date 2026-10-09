unit Assinafy;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, AssinafyHttp;

const
  AssinafyVersion = '0.2.1';
  AssinafyProductionURL = 'https://api.assinafy.com.br/v1';
  AssinafySandboxURL = 'https://sandbox.assinafy.com.br/v1';

type
  TAssinafyAuth = (aaPublic, aaAPI, aaSigner, aaSignerOrAPI, aaBearer);

  TAssinafyClient = class
  private
    FAPIKey, FAccountID, FBaseURL, FOrigin, FAccessToken, FCAFile: string;
    FTransport: TAssinafyTransport;
    FOwnsTransport: Boolean;
    FTimeoutMS: LongInt;
    function PathValue(const Value, Name: string): string;
    procedure SetAccessToken(const Value: string);
    function Call(const Method, Path: string; Auth: TAssinafyAuth;
      Query: TStrings; Body: TJSONData; const FileName, FileField, ContentType,
      SignerAccessCode: string): TAssinafyResponse;
  public
    constructor Create(const AAPIKey: string = ''; const AAccountID: string = '';
      const ABaseURL: string = AssinafyProductionURL; Transport: TAssinafyTransport = nil);
    destructor Destroy; override;
    property APIKey: string read FAPIKey;
    property AccountID: string read FAccountID;
    property BaseURL: string read FBaseURL;
    property AccessToken: string read FAccessToken write SetAccessToken;
    property TimeoutMS: LongInt read FTimeoutMS write FTimeoutMS;
    property CAFile: string read FCAFile write FCAFile;
    {$I resources.inc}
  end;

implementation

uses
  URIParser;

constructor TAssinafyClient.Create(const AAPIKey, AAccountID, ABaseURL: string;
  Transport: TAssinafyTransport);
var
  URI: TURI;
begin
  inherited Create;
  RequireValue(ABaseURL, 'Base URL');
  FBaseURL := TrimURLTrailingSlash(ABaseURL);
  URI := ParseURI(FBaseURL);
  if Copy(FBaseURL, Length(FBaseURL) - 2, 3) <> '/v1' then
    raise EAssinafyInputError.Create('Base URL must end with /v1');
  if (URI.UserName <> '') or (URI.Password <> '') or (URI.Params <> '') or
    (URI.Bookmark <> '') or (URI.Host = '') then
    raise EAssinafyInputError.Create('Base URL must have a host and no credentials, query or fragment');
  if (LowerCase(URI.Protocol) <> 'https') and not
    ((LowerCase(URI.Protocol) = 'http') and
     ((URI.Host = '127.0.0.1') or (URI.Host = 'localhost') or (URI.Host = '[::1]') or (URI.Host = '::1'))) then
    raise EAssinafyInputError.Create('Base URL requires HTTPS (HTTP is allowed only on loopback)');
  if AAPIKey <> '' then
  begin
    RequireValue(AAPIKey, 'API key');
    RequireValue(AAccountID, 'Workspace ID for API-key authentication');
  end;
  URI.Path := '';
  URI.Document := '';
  FOrigin := TrimURLTrailingSlash(EncodeURI(URI));
  FAPIKey := AAPIKey;
  FAccountID := AAccountID;
  FTimeoutMS := 30000;
  FTransport := Transport;
  FOwnsTransport := Transport = nil;
  if FOwnsTransport then FTransport := TAssinafyCurlTransport.Create;
end;

destructor TAssinafyClient.Destroy;
begin
  if FOwnsTransport then FTransport.Free;
  inherited Destroy;
end;

procedure TAssinafyClient.SetAccessToken(const Value: string);
begin
  if Value <> '' then
  begin
    RequireValue(Value, 'Access token');
    if FAPIKey <> '' then
      raise EAssinafyInputError.Create('Choose API key plus workspace ID or OAuth; do not configure both');
  end;
  FAccessToken := Value;
end;

function TAssinafyClient.PathValue(const Value, Name: string): string;
var
  Resolved: string;
begin
  Resolved := Value;
  if (Resolved = '') and SameText(Name, 'AccountID') then Resolved := FAccountID;
  RequireValue(Resolved, Name);
  if (Resolved = '.') or (Resolved = '..') then
    raise EAssinafyInputError.Create(Name + ' cannot be a relative path segment');
  Result := PercentEncode(Resolved);
end;

function TAssinafyClient.Call(const Method, Path: string; Auth: TAssinafyAuth;
  Query: TStrings; Body: TJSONData; const FileName, FileField, ContentType,
  SignerAccessCode: string): TAssinafyResponse;
var
  Request: TAssinafyRequest;
  Headers: TStringList;
  Params, Token: string;
  I: Integer;
begin
  if FTimeoutMS <= 0 then raise EAssinafyInputError.Create('TimeoutMS must be positive');
  Headers := TStringList.Create;
  Result := nil;
  try
    try
      Headers.Add('Accept: application/json, application/pdf, image/*, application/octet-stream');
      Headers.Add('User-Agent: assinafy-object-pascal/' + AssinafyVersion);
      Params := EncodeQuery(Query);
      if Query <> nil then
        for I := 0 to Query.Count - 1 do
          if (LowerCase(Query.Names[I]) = 'access-token') or
             (LowerCase(Query.Names[I]) = 'signer-access-code') then
            raise EAssinafyInputError.Create('Pass authentication through the SDK credential parameters');
      if (Auth = aaSigner) or ((Auth = aaSignerOrAPI) and (SignerAccessCode <> '')) then
      begin
        RequireValue(SignerAccessCode, 'Signer access code');
        if Params <> '' then Params := Params + '&';
        Params := Params + 'signer-access-code=' + PercentEncode(SignerAccessCode);
      end
      else if Auth <> aaPublic then
      begin
        Token := FAccessToken;
        if (Auth = aaBearer) or (Token <> '') then
        begin
          RequireValue(Token, 'Access token');
          Headers.Add('Authorization: Bearer ' + Token);
        end
        else
        begin
          RequireValue(FAPIKey, 'API key or access token');
          Headers.Add('X-Api-Key: ' + FAPIKey);
        end;
      end;
      Request.Method := Method;
      if Copy(Path, 1, 12) = '/.well-known' then
        Request.URL := FOrigin + Path
      else Request.URL := FBaseURL + Path;
      if Params <> '' then Request.URL := Request.URL + '?' + Params;
      Request.Headers := Headers;
      Request.Body := '';
      if Body <> nil then Request.Body := Body.AsJSON;
      Request.FileName := FileName;
      Request.FileField := FileField;
      Request.ContentType := ContentType;
      Request.TimeoutMS := FTimeoutMS;
      Request.CAFile := FCAFile;
      if (FileName <> '') then
      begin
        RequireValue(FileName, 'File name');
        if not FileExists(FileName) then raise EAssinafyInputError.Create('Upload file does not exist');
      end;
      Result := FTransport.Execute(Request);
      if Result = nil then raise EAssinafyTransportError.Create('Transport returned no response');
      if (Pos('json', LowerCase(Result.Header('Content-Type'))) > 0) then
      begin
        try
          Result.ParseJSON;
        except
          on E: EAssinafyProtocolError do
            if (Result.StatusCode >= 200) and (Result.StatusCode < 300) then raise;
        end;
      end;
      if (Result.StatusCode < 200) or (Result.StatusCode >= 300) then
        raise EAssinafyAPIError.Create(Result);
    except
      FreeAndNil(Result);
      raise;
    end;
  finally
    Headers.Free;
  end;
end;

{$I methods.inc}

end.
