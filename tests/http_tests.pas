program HTTPTests;

{$mode objfpc}{$H+}{$ASSERTIONS ON}

uses
  {$ifdef unix}cthreads,{$endif}
  Classes, SysUtils, fpjson, Assinafy, AssinafyHttp;

procedure Check(Condition: Boolean; const MessageText: string);
begin
  if not Condition then raise Exception.Create(MessageText);
end;

var
  Client, TLSClient: TAssinafyClient;
  Response: TAssinafyResponse;
  Body: TJSONObject;
  Query: TStringList;
  Codes: array[0..2] of string = ('redirect', 'rate-limit', 'html-error');
  Expected: array[0..2] of Integer = (302, 429, 503);
  I: Integer;
begin
  Client := TAssinafyClient.Create('test-key', 'account', ParamStr(1));
  Body := TJSONObject.Create(['name', 'name & space', 'enabled', False]);
  Query := TStringList.Create;
  try
    Response := Client.GetAccount('');
    try
      Check(Response.Data.FindPath('key').AsString = 'test-key', 'API key reaches HTTP server');
      Check(Response.Data.FindPath('method').AsString = 'GET', 'GET verb reaches HTTP server');
    finally Response.Free; end;
    Client.AccessToken := 'test-bearer';
    Response := Client.GetUser;
    try
      Check(Response.Data.FindPath('authorization').AsString = 'Bearer test-bearer', 'Bearer reaches HTTP server');
      Check(Response.Data.FindPath('key').AsString = '', 'Bearer suppresses API key');
    finally Response.Free; end;
    Response := Client.RenameDocument('document', Body);
    try Check(Response.Data.FindPath('body.name').AsString = 'name & space', 'PATCH JSON payload'); finally Response.Free; end;
    Query.Add('search=Ana & Joao');
    Query.Add('page=1');
    Response := Client.ListDocuments('', Query);
    try
      Check(Pos('search=Ana%20%26%20Joao', Response.Data.FindPath('path').AsString) > 0, 'Wire query encoding');
      Check(Response.Header('X-Pagination-Current-Page') = '1', 'Wire pagination header');
    finally Response.Free; end;
    Response := Client.UploadDocument('', ParamStr(2));
    try
      Check(Response.Data.FindPath('file_field').AsString = 'file', 'Multipart field name');
      Check(Response.Data.FindPath('file_size').AsInteger = 15, 'Multipart binary file size');
      Check(Response.Data.FindPath('valid_file').AsBoolean, 'Multipart binary bytes');
    finally Response.Free; end;
    Response := Client.UploadSignatureImage('signer-code', ParamStr(2));
    try
      Check(Response.Data.FindPath('raw_file_valid').AsBoolean, 'Raw signature bytes');
      Check(Response.Data.FindPath('authorization').AsString = '', 'Signer request omits bearer');
    finally Response.Free; end;
    Response := Client.DownloadDocumentArtifact('binary', 'original');
    try Check(Response.Body = '%PDF-' + #0#255 + 'fixture!', 'Binary download through native HTTP'); finally Response.Free; end;
    Response := Client.ExchangeOAuthToken(Body);
    try Check(Response.Data.FindPath('access_token').AsString = 'test-access', 'Flat token response through HTTP'); finally Response.Free; end;
    Response := Client.GetOAuthResourceMetadata;
    try Check(Response.Data.FindPath('resource').AsString = 'mock-resource', 'Metadata uses host root'); finally Response.Free; end;
    for I := 0 to High(Codes) do
    begin
      try
        Response := Client.GetDocument(Codes[I]);
        Response.Free;
        raise Exception.Create('Expected HTTP error for ' + Codes[I]);
      except
        on E: EAssinafyAPIError do
        begin
          Check(E.StatusCode = Expected[I], 'Actual HTTP error status');
          if I = 1 then Check(E.RetryAfter = '3', 'Wire rate-limit retry delay');
        end;
      end;
    end;
    TLSClient := TAssinafyClient.Create('test-key', 'account', ParamStr(3));
    try
      try
        Response := TLSClient.GetUser;
        Response.Free;
        raise Exception.Create('Untrusted certificate accepted');
      except on E: EAssinafyTransportError do Check(True, 'Untrusted TLS certificate rejected'); end;
      TLSClient.CAFile := ParamStr(4);
      Response := TLSClient.GetUser;
      Response.Free;
    finally TLSClient.Free; end;
    TLSClient := TAssinafyClient.Create('test-key', 'account', ParamStr(5));
    try
      TLSClient.CAFile := ParamStr(4);
      try
        Response := TLSClient.GetUser;
        Response.Free;
        raise Exception.Create('Mismatched TLS hostname accepted');
      except on E: EAssinafyTransportError do Check(True, 'Wrong TLS hostname rejected'); end;
    finally TLSClient.Free; end;
    WriteLn('PASS: native HTTP JSON, multipart, binary, authentication, errors and TLS verification');
  finally
    Query.Free;
    Body.Free;
    Client.Free;
  end;
end.
