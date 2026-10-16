program HTTPTests;

{$IFDEF FPC}{$mode objfpc}{$H+}{$ENDIF}{$ASSERTIONS ON}
{$IFDEF FPC}{$codepage utf8}{$ENDIF}
{$IFNDEF FPC}{$APPTYPE CONSOLE}{$ENDIF}

uses
  {$ifdef unix}cthreads,{$endif}
  Classes, SysUtils, AssinafyJson, Assinafy, AssinafyHttp, AssinafyCrypto;

procedure Check(Condition: Boolean; const MessageText: string);
begin
  if not Condition then raise Exception.Create(MessageText);
end;

var
  Client, TLSClient: TAssinafyClient;
  Response: TAssinafyResponse;
  Body, IdentityBody: TJSONObject;
  Query: TStringList;
  Transport: TAssinafyDefaultTransport;
  Request: TAssinafyRequest;
  Headers: TStringList;
  Codes: array[0..2] of string = ('redirect', 'rate-limit', 'html-error');
  Expected: array[0..2] of Integer = (302, 429, 503);
  I: Integer;
  Media, Mode: string;
  BinaryExpected: RawByteString;
  MediaTypes: array[0..1] of string = ('image/png', 'image/jpeg');
  CompleteModes: array[0..1] of string = ('complete-chunked', 'complete-close');
  SlowModes: array[0..2] of string = ('slow-chunked', 'slow-close', 'slow-encoded');
  IdentityImages: array[0..1] of string = ('face', 'document_pdf');
begin
  Client := TAssinafyClient.Create('test-key', 'account', ParamStr(1));
  Body := JSONObj(['name', 'João 😀 & space', 'enabled', False]);
  Query := TStringList.Create;
  try
    Response := Client.GetAccount('');
    try
      Check(JSONString(JSONFind(Response.Data, 'key')) = 'test-key', 'API key reaches HTTP server');
      Check(JSONString(JSONFind(Response.Data, 'method')) = 'GET', 'GET verb reaches HTTP server');
    finally Response.Free; end;
    Client.Free;
    Client := nil;
    Client := TAssinafyClient.Create('', '', ParamStr(1));
    Client.AccessToken := 'test-bearer';
    Response := Client.GetUser;
    try
      Check(JSONString(JSONFind(Response.Data, 'authorization')) = 'Bearer test-bearer', 'Bearer reaches HTTP server');
      Check(JSONString(JSONFind(Response.Data, 'key')) = '', 'Bearer suppresses API key');
    finally Response.Free; end;
    Response := Client.RenameDocument('document', Body);
    try Check(JSONString(JSONFind(Response.Data, 'body.name')) = UTF8String('João 😀 & space'), 'PATCH Unicode JSON payload'); finally Response.Free; end;
    Query.Add('search=Ana & Joao');
    Query.Add('page=1');
    Response := Client.ListDocuments('account', Query);
    try
      Check(Pos('search=Ana%20%26%20Joao', JSONString(JSONFind(Response.Data, 'path'))) > 0, 'Wire query encoding');
      Check(Response.Header('X-Pagination-Current-Page') = '1', 'Wire pagination header');
    finally Response.Free; end;
    Query.Values['search'] := 'João';
    Response := Client.ListDocuments('account', Query);
    try Check(Pos('search=Jo%C3%A3o', JSONString(JSONFind(Response.Data, 'path'))) > 0, 'Unicode query bytes reach server'); finally Response.Free; end;
    Response := Client.GetIdentityVerificationStatus('code & private');
    try Check(JSONString(JSONFind(Response.Data, 'status')) = 'InReview', 'Identity status through HTTP'); finally Response.Free; end;
    IdentityBody := JSONObj(['consent', True]);
    try
      Response := Client.StartIdentityVerification('code & private', IdentityBody);
      try Check(JSONString(JSONFind(Response.Data, 'url')) = 'https://verify.example.com/c/session#t=private-token', 'Biometric capture URL through HTTP'); finally Response.Free; end;
    finally IdentityBody.Free; end;
    Response := Client.GetSignerIdentityReview('review-doc', 'assignment', 'signer');
    try Check(JSONString(JSONFind(Response.Data, 'status')) = 'InReview', 'Workspace identity review through HTTP'); finally Response.Free; end;
    for Mode in IdentityImages do
    begin
      Response := Client.DownloadSignerIdentityReviewImage('review-doc', 'assignment', 'signer', Mode);
      try
        Check((Length(Response.Body) = 15) and (Response.JSON = nil), 'Identity evidence binary response through HTTP');
        Check(Base64Encode(Response.Body) = 'JVBERi0A/2ZpeHR1cmUh', 'Identity evidence bytes unchanged');
      finally Response.Free; end;
    end;
    IdentityBody := JSONObj(['decision', 'Approved', 'note', nil]);
    try
      Response := Client.DecideSignerIdentityReview('review-doc', 'assignment', 'signer', IdentityBody);
      try Check(JSONString(JSONFind(Response.Data, 'status')) = 'Approved', 'Identity review decision through HTTP'); finally Response.Free; end;
    finally IdentityBody.Free; end;
    Query.Clear;
    Query.Add('url=https://app.example.com/hook?tenant=a&next=/x');
    Response := Client.DeleteWebhookEndpointByURL('account', Query);
    Response.Free;
    Response := Client.UploadDocument('account', ParamStr(2));
    try
      Check(JSONString(JSONFind(Response.Data, 'file_field')) = 'file', 'Multipart field name');
      Check(JSONInteger(JSONFind(Response.Data, 'file_size')) = 15, 'Multipart binary file size');
      Check(JSONBoolean(JSONFind(Response.Data, 'valid_file')), 'Multipart binary bytes');
      Check(JSONString(JSONFind(Response.Data, 'file_name')) = 'fixture.pdf', 'Multipart filename retained');
      Check(JSONString(JSONFind(Response.Data, 'file_media')) = 'application/pdf', 'Document part content type');
    finally Response.Free; end;
    Response := Client.UploadAccountLogo('account', ParamStr(2));
    try
      Check(JSONString(JSONFind(Response.Data, 'file_field')) = 'file', 'Logo multipart field');
      Check(JSONString(JSONFind(Response.Data, 'file_media')) = 'application/octet-stream', 'Logo part content type');
      Check(JSONBoolean(JSONFind(Response.Data, 'valid_file')), 'Logo upload bytes');
    finally Response.Free; end;
    for Media in MediaTypes do
    begin
      Response := Client.UploadAccountLogo('account', ParamStr(2), Media);
      try
        Check(JSONString(JSONFind(Response.Data, 'file_media')) = Media, 'Explicit logo part content type');
        Check(JSONBoolean(JSONFind(Response.Data, 'valid_file')), 'Explicit logo type preserves binary bytes');
      finally Response.Free; end;
    end;
    Transport := TAssinafyDefaultTransport.Create;
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
        Check(JSONString(JSONFind(Response.Data, 'file_field')) = 'attachment', 'Custom multipart field');
        Check(JSONBoolean(JSONFind(Response.Data, 'valid_file')), 'Upload retains checked bytes after source replacement');
      finally Response.Free; end;
      Request.Method := 'GET';
      Request.URL := ParamStr(1) + '/documents/no-timeout';
      Request.FileName := '';
      Request.FileField := '';
      Request.ContentType := '';
      Request.TimeoutMS := 0;
      Headers.Clear;
      Response := Transport.Execute(Request);
      try Check(Response.StatusCode = 200, 'Direct transport retains zero as unlimited timeout');
      finally Response.Free; end;
    finally Headers.Free; Transport.Free; end;
    Response := Client.UploadSignatureImage('signer-code', ParamStr(2));
    try
      Check(JSONBoolean(JSONFind(Response.Data, 'raw_file_valid')), 'Raw signature bytes');
      Check(JSONString(JSONFind(Response.Data, 'authorization')) = '', 'Signer request omits bearer');
    finally Response.Free; end;
    Response := Client.DownloadDocumentArtifact('binary', 'original');
    try
      BinaryExpected := '%PDF-xxfixture!';
      BinaryExpected[6] := AnsiChar(0);
      BinaryExpected[7] := AnsiChar(255);
      Check(Response.Body = BinaryExpected, 'Binary download through native HTTP');
    finally Response.Free; end;
    for Mode in CompleteModes do
    begin
      Response := Client.GetDocument(Mode);
      try Check(Response.Body = BinaryExpected, 'Completed non-Content-Length body is preserved');
      finally Response.Free; end;
    end;
    Response := Client.GetDocument('complete-encoded');
    try
      Check(Base64Encode(Response.Body) = 'H4sIAAAAAAAC/1MNcHHTZfiflllRUlqUqggAXGVJUQ8AAAA=', 'Encoded response retains exact wire bytes');
      Check(Response.Header('Content-Encoding') = 'gzip', 'Encoded response retains encoding header');
    finally Response.Free; end;
    Response := Client.ExchangeOAuthToken(Body);
    try Check(JSONString(JSONFind(Response.Data, 'access_token')) = 'test-access', 'Flat token response through HTTP'); finally Response.Free; end;
    Response := Client.GetOAuthResourceMetadata;
    try Check(JSONString(JSONFind(Response.Data, 'resource')) = 'mock-resource', 'Metadata uses host root'); finally Response.Free; end;
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
          if I = 1 then
            Check((E.RetryAfter = '3') and (E.RateLimitLimit = '60') and
              (E.RateLimitRemaining = '0') and (E.RateLimitReset = '3'), 'Wire rate-limit headers');
        end;
      end;
    end;
    {$IFDEF FPC}
    TLSClient := TAssinafyClient.Create('test-key', 'account', ParamStr(3));
    {$ELSE}
    TLSClient := TAssinafyClient.Create('test-key', 'account', ParamStr(6));
    {$ENDIF}
    try
      try
        Response := TLSClient.GetUser;
        Response.Free;
        raise Exception.Create('Untrusted certificate accepted');
      except on E: EAssinafyTransportError do Check(True, 'Untrusted TLS certificate rejected'); end;
    finally TLSClient.Free; end;
    TLSClient := TAssinafyClient.Create('test-key', 'account', ParamStr(3));
    try
      {$IFDEF FPC}
      TLSClient.CAFile := ParamStr(4);
      {$ELSE}
      TLSClient.CAFile := ParamStr(4);
      try
        Response := TLSClient.GetUser;
        Response.Free;
        raise Exception.Create('Unsupported CAFile was ignored');
      except on E: EAssinafyInputError do Check(True, 'Unsupported CAFile rejected'); end;
      TLSClient.CAFile := '';
      {$ENDIF}
      Response := TLSClient.GetUser;
      Response.Free;
    finally TLSClient.Free; end;
    TLSClient := TAssinafyClient.Create('test-key', 'account', ParamStr(5));
    try
      {$IFDEF FPC}TLSClient.CAFile := ParamStr(4);{$ENDIF}
      try
        Response := TLSClient.GetUser;
        Response.Free;
        raise Exception.Create('Mismatched TLS hostname accepted');
      except on E: EAssinafyTransportError do Check(True, 'Wrong TLS hostname rejected'); end;
    finally TLSClient.Free; end;
    try
      Response := Client.GetDocument('truncated-transfer');
      Response.Free;
      raise Exception.Create('Truncated transfer accepted');
    except on E: EAssinafyTransportError do Check(True, 'Truncated response rejected'); end;
    Client.TimeoutMS := 200;
    try
      Response := Client.GetDocument('slow-transfer');
      Response.Free;
      raise Exception.Create('Whole-transfer timeout was ignored');
    except
      on E: EAssinafyTransportError do
      begin
        Check(True, 'Trickling response cannot bypass total timeout');
        {$IFNDEF FPC}Check(E.Message = 'HTTP transfer exceeded TimeoutMS', 'Deadline cancellation has a stable timeout message');{$ENDIF}
      end;
    end;
    for Mode in SlowModes do
      try
        Response := Client.GetDocument(Mode);
        Response.Free;
        raise Exception.Create('Canceled transfer accepted as a complete response');
      except
        on E: EAssinafyTransportError do Check(True, 'Cancellation rejects incomplete response framing');
        on E: EAssinafyProtocolError do
        begin
          Check(E.StatusCode = 200, 'Indeterminate framing error retains HTTP status');
          Check(E.ResponseBody <> '', 'Indeterminate framing error retains partial bytes');
          Check(E.Message = 'HTTP transfer exceeded TimeoutMS; response completion is indeterminate', 'Indeterminate framing is explicit');
        end;
      end;
    WriteLn('PASS: native HTTP JSON, multipart, binary, identity verification, webhooks, authentication, errors and TLS verification');
  finally
    Query.Free;
    Body.Free;
    Client.Free;
  end;
end.
