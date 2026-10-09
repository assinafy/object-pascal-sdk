program HTTPTests;

{$mode objfpc}{$H+}{$ASSERTIONS ON}
{$codepage utf8}

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
  Transport: TAssinafyCurlTransport;
  Request: TAssinafyRequest;
  Headers: TStringList;
  Codes: array[0..2] of string = ('redirect', 'rate-limit', 'html-error');
  Expected: array[0..2] of Integer = (302, 429, 503);
  I: Integer;
  Media: string;
  MediaTypes: array[0..1] of string = ('image/png', 'image/jpeg');
begin
  Client := TAssinafyClient.Create('test-key', 'account', ParamStr(1));
  Body := TJSONObject.Create(['name', 'João 😀 & space', 'enabled', False]);
  Query := TStringList.Create;
  try
    Response := Client.GetAccount('');
    try
      Check(Response.Data.FindPath('key').AsString = 'test-key', 'API key reaches HTTP server');
      Check(Response.Data.FindPath('method').AsString = 'GET', 'GET verb reaches HTTP server');
    finally Response.Free; end;
    Client.Free;
    Client := nil;
    Client := TAssinafyClient.Create('', '', ParamStr(1));
    Client.AccessToken := 'test-bearer';
    Response := Client.GetUser;
    try
      Check(Response.Data.FindPath('authorization').AsString = 'Bearer test-bearer', 'Bearer reaches HTTP server');
      Check(Response.Data.FindPath('key').AsString = '', 'Bearer suppresses API key');
    finally Response.Free; end;
    Response := Client.RenameDocument('document', Body);
    try Check(Response.Data.FindPath('body.name').AsString = UTF8String('João 😀 & space'), 'PATCH Unicode JSON payload'); finally Response.Free; end;
    Query.Add('search=Ana & Joao');
    Query.Add('page=1');
    Response := Client.ListDocuments('account', Query);
    try
      Check(Pos('search=Ana%20%26%20Joao', Response.Data.FindPath('path').AsString) > 0, 'Wire query encoding');
      Check(Response.Header('X-Pagination-Current-Page') = '1', 'Wire pagination header');
    finally Response.Free; end;
    Query.Values['search'] := 'João';
    Response := Client.ListDocuments('account', Query);
    try Check(Pos('search=Jo%C3%A3o', Response.Data.FindPath('path').AsString) > 0, 'Unicode query bytes reach server'); finally Response.Free; end;
    Response := Client.UploadDocument('account', ParamStr(2));
    try
      Check(Response.Data.FindPath('file_field').AsString = 'file', 'Multipart field name');
      Check(Response.Data.FindPath('file_size').AsInteger = 15, 'Multipart binary file size');
      Check(Response.Data.FindPath('valid_file').AsBoolean, 'Multipart binary bytes');
      Check(Response.Data.FindPath('file_name').AsString = 'fixture.pdf', 'Multipart filename retained');
      Check(Response.Data.FindPath('file_media').AsString = 'application/pdf', 'Document part content type');
    finally Response.Free; end;
    Response := Client.UploadAccountLogo('account', ParamStr(2));
    try
      Check(Response.Data.FindPath('file_field').AsString = 'file', 'Logo multipart field');
      Check(Response.Data.FindPath('file_media').AsString = 'application/octet-stream', 'Logo part content type');
      Check(Response.Data.FindPath('valid_file').AsBoolean, 'Logo upload bytes');
    finally Response.Free; end;
    for Media in MediaTypes do
    begin
      Response := Client.UploadAccountLogo('account', ParamStr(2), Media);
      try
        Check(Response.Data.FindPath('file_media').AsString = Media, 'Explicit logo part content type');
        Check(Response.Data.FindPath('valid_file').AsBoolean, 'Explicit logo type preserves binary bytes');
      finally Response.Free; end;
    end;
    Transport := TAssinafyCurlTransport.Create;
    Headers := TStringList.Create;
    try
      Headers.Add('Expect: 100-continue');
      Request := Default(TAssinafyRequest);
      Request.Method := 'POST';
      Request.URL := ParamStr(1) + '/snapshot';
      Request.Headers := Headers;
      Request.FileName := ParamStr(2);
      Request.FileField := 'attachment';
      Request.ContentType := 'application/pdf';
      Request.TimeoutMS := 5000;
      Response := Transport.Execute(Request);
      try
        Response.ParseJSON;
        Check(Response.StatusCode = 200, 'Snapshot fixture HTTP success');
        Check(Response.Data.FindPath('file_field').AsString = 'attachment', 'Custom multipart field');
        Check(Response.Data.FindPath('valid_file').AsBoolean, 'Upload retains checked bytes after source replacement');
      finally Response.Free; end;
    finally Headers.Free; Transport.Free; end;
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
    try
      Response := Client.CreateAssignment('protocol-error', Body);
      Response.Free;
      raise Exception.Create('Malformed mutation response accepted');
    except
      on E: EAssinafyProtocolError do
      begin
        Check(E.StatusCode = 201, 'Successful mutation HTTP status survives decode failure');
        Check(E.ResponseBody = '{"data":{"id":"created-id","name":"\u0000"}}', 'Raw mutation response survives response cleanup');
      end;
    end;
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
