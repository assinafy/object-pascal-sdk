program LiveTests;

{$IFDEF FPC}{$mode objfpc}{$H+}{$ENDIF}{$ASSERTIONS ON}

uses
  {$ifdef unix}cthreads,{$endif}
  Classes, SysUtils, DateUtils, AssinafyJson, Assinafy, AssinafyHttp;

var
  Client: TAssinafyClient;
  Response: TAssinafyResponse;
  Query: TStringList;
  Body: TJSONObject;
  BaseURL, AccountID, DocumentID, SignerID, TagID, AssignmentID, SignerEmail, TestName, FixtureFile: string;
  Calls: Integer = 0;
  Attempt: Integer;
  VerificationMethod, Channel: string;
  PaidMethods: array[0..1] of string = ('Whatsapp', 'DigitalCertificate');
  Ready: Boolean = False;
  CleanupFailed: Boolean = False;

procedure Passed(Value: TAssinafyResponse; const Name: string);
begin
  try
    Assert((Value.StatusCode >= 200) and (Value.StatusCode < 300), Name);
    Assert((Value.StatusCode = 204) or (Value.JSON <> nil), Name + ': JSON response missing');
    Inc(Calls);
    WriteLn('PASS: ', Name);
  finally Value.Free; end;
end;

procedure Cleanup(const Kind, ID: string);
begin
  if ID = '' then Exit;
  try
    case Kind of
      'document': Passed(Client.DeleteDocument(ID), 'Delete isolated document');
      'signer': Passed(Client.DeleteSigner('', ID), 'Delete isolated signer');
      'tag': Passed(Client.DeleteTag('', ID), 'Delete isolated tag');
    end;
  except
    on E: Exception do
    begin
      CleanupFailed := True;
      WriteLn(StdErr, 'Cleanup failed for isolated ', Kind, ' ID ', ID);
    end;
  end;
end;

begin
  RequireValue(GetEnvironmentVariable('ASSINAFY_API_KEY'), 'ASSINAFY_API_KEY');
  AccountID := GetEnvironmentVariable('ASSINAFY_ACCOUNT_ID');
  RequireValue(AccountID, 'ASSINAFY_ACCOUNT_ID');
  BaseURL := GetEnvironmentVariable('ASSINAFY_BASE_URL');
  if BaseURL = '' then BaseURL := AssinafySandboxURL;
  if BaseURL <> AssinafySandboxURL then
    raise EAssinafyInputError.Create('Live checks run only against the Assinafy sandbox');
  Client := TAssinafyClient.Create(GetEnvironmentVariable('ASSINAFY_API_KEY'), AccountID, BaseURL);
  Query := TStringList.Create;
  Query.Add('page=1');
  Query.Add('per-page=1');
  try
    Passed(Client.GetUser, 'Authenticated user');
    Passed(Client.ListMyAccounts, 'Workspace list');
    Passed(Client.GetAccount(''), 'Workspace profile');
    Passed(Client.GetAccountTheme(''), 'Workspace theme');
    Passed(Client.GetAccountStats(''), 'Workspace stats');
    Passed(Client.GetUserStats, 'User stats');
    Passed(Client.ListDocuments('', Query), 'Document list');
    Response := Client.ListSigners('', Query);
    try
      Assert((Response.Header('X-Rate-Limit-Limit') <> '') and
        (Response.Header('X-Rate-Limit-Remaining') <> '') and
        (Response.Header('X-Rate-Limit-Reset') <> ''), 'Rate-limit headers');
    finally Passed(Response, 'Signer list with rate-limit headers'); end;
    Passed(Client.ListTemplates('', Query), 'Template list');
    Passed(Client.ListFields(''), 'Field list');
    Passed(Client.ListFieldTypes, 'Field types');
    Passed(Client.ListTags(''), 'Tag list');
    Passed(Client.ListDocumentStatuses, 'Document statuses');
    Passed(Client.ListWebhookEventTypes, 'Webhook events');
    Passed(Client.ListWebhookEndpoints(''), 'Webhook endpoints');
    Passed(Client.ListWebhookDeliveries('', Query), 'Webhook deliveries');
    Passed(Client.GetOAuthResourceMetadata, 'OAuth resource discovery');
    Body := JSONObj(['client_id', 'object-pascal-invalid-client', 'grant_type', 'authorization_code',
      'code', 'invalid-code', 'code_verifier', StringOfChar('a', 43), 'redirect_uri', 'https://app.example.com/callback']);
    try
      try
        Response := Client.ExchangeOAuthToken(Body);
        Response.Free;
        raise Exception.Create('Invalid OAuth client was accepted');
      except
        on E: EAssinafyAPIError do
        begin
          Assert(E.ErrorCode = 'invalid_client', 'OAuth error body contract');
          Inc(Calls);
          WriteLn('PASS: OAuth invalid-client error contract');
        end;
      end;
    finally Body.Free; end;
    if GetEnvironmentVariable('ASSINAFY_TEST_MUTATIONS') = '1' then
    begin
      FixtureFile := GetEnvironmentVariable('ASSINAFY_TEST_PDF');
      RequireValue(FixtureFile, 'ASSINAFY_TEST_PDF');
      TestName := 'Object Pascal SDK ' + FormatDateTime('yyyymmddhhnnsszzz', Now);
      DocumentID := ''; SignerID := ''; TagID := ''; AssignmentID := '';
      try
        Response := Client.UploadDocument('', FixtureFile);
        try DocumentID := JSONString(JSONFind(Response.Data, 'id')); finally Passed(Response, 'Upload document'); end;
        // Rename/delete are allowed once processing finishes (metadata_ready).
        for Attempt := 1 to 60 do
        begin
          Response := Client.GetDocument(DocumentID);
          try Ready := JSONString(JSONFind(Response.Data, 'status')) = 'metadata_ready';
          finally Response.Free; end;
          if Ready then Break;
          Sleep(1000);
        end;
        Assert(Ready, 'Uploaded document did not reach metadata_ready');
        Passed(Client.GetDocument(DocumentID), 'Retrieve uploaded document');
        Response := Client.DownloadDocumentArtifact(DocumentID, 'original');
        try
          Assert(Copy(Response.Body, 1, 5) = '%PDF-', 'Original PDF bytes');
          Inc(Calls); WriteLn('PASS: Download original PDF');
        finally Response.Free; end;
        Body := JSONObj(['name', TestName + '.pdf']);
        try Passed(Client.RenameDocument(DocumentID, Body), 'Rename document'); finally Body.Free; end;
        SignerEmail := 'sdk-' + FormatDateTime('yyyymmddhhnnsszzz', Now) + '@example.com';
        Body := JSONObj(['full_name', TestName, 'email', SignerEmail]);
        try
          Response := Client.CreateSigner('', Body);
          try SignerID := JSONString(JSONFind(Response.Data, 'id')); finally Passed(Response, 'Create isolated signer'); end;
        finally Body.Free; end;
        Passed(Client.GetSigner('', SignerID), 'Retrieve signer');
        Body := JSONObj(['full_name', TestName + ' updated']);
        try Passed(Client.UpdateSigner('', SignerID, Body), 'Update signer'); finally Body.Free; end;
        Passed(Client.ListSignerDocumentsAsWorkspace(SignerID, Query), 'Signer documents with workspace credentials');
        Passed(Client.SearchSignerDocumentsAsWorkspace(SignerID), 'Signer document search with workspace credentials');
        try
          Response := Client.ListSignerDocuments(SignerID);
          Response.Free;
          raise Exception.Create('Empty signer access code was sent');
        except on E: EAssinafyInputError do begin Inc(Calls); WriteLn('PASS: Empty signer access code rejected'); end; end;
        for VerificationMethod in PaidMethods do
        begin
          Channel := 'Email';
          if VerificationMethod = 'Whatsapp' then Channel := 'Whatsapp';
          Body := JSONObj(['method', 'virtual']);
          JSONAdd(Body, 'signers', JSONArr([JSONObj(['verification_method', VerificationMethod,
            'notification_methods', JSONArr([Channel])])]));
          try
            try
              Passed(Client.EstimateAssignmentCost(DocumentID, Body), VerificationMethod + ' assignment cost');
            except
              on E: EAssinafyAPIError do
              begin
                Assert(E.StatusCode = 403, VerificationMethod + ' plan gate status');
                Inc(Calls); WriteLn('PASS: ', VerificationMethod, ' assignment cost is plan-gated (403)');
              end;
            end;
          finally Body.Free; end;
        end;
        Body := JSONObj(['method', 'virtual']);
        JSONAdd(Body, 'signers', JSONArr([JSONObj(['id', SignerID, 'verification_method', 'Email'])]));
        try Passed(Client.EstimateAssignmentCost(DocumentID, Body), 'Email assignment cost'); finally Body.Free; end;
        Body := JSONObj(['method', 'virtual']);
        JSONAdd(Body, 'signers', JSONArr([JSONObj(['id', SignerID, 'verification_method', 'Email',
          'notification_methods', JSONArr(['Email'])])]));
        try
          Response := Client.CreateAssignment(DocumentID, Body);
          try AssignmentID := JSONString(JSONFind(Response.Data, 'id')); finally Passed(Response, 'Create virtual assignment'); end;
        finally Body.Free; end;
        Body := JSONObj(['expires_at', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', IncDay(LocalTimeToUniversal(Now), 2))]);
        try Passed(Client.ResetAssignmentExpiration(DocumentID, AssignmentID, Body), 'Set assignment expiration'); finally Body.Free; end;
        Body := JSONObj(['expires_at', nil]);
        try Passed(Client.ResetAssignmentExpiration(DocumentID, AssignmentID, Body), 'Clear assignment expiration with null'); finally Body.Free; end;
        Body := JSONObj(['channel', 'email', 'recipient', SignerEmail]);
        try
          Response := Client.SendAccessTokenForPublicDocument(DocumentID, Body);
          try
            Assert((JSONString(JSONFind(Response.Data, 'channel')) = 'email') and
              (JSONString(JSONFind(Response.Data, 'recipient')) = SignerEmail) and
              (JSONKind(JSONFind(Response.Data, 'document')) = jtObject), 'Send-token response shape');
          finally Passed(Response, 'Send public access token by email'); end;
        finally Body.Free; end;
        Body := JSONObj(['name', TestName, 'color', '#314159']);
        try
          Response := Client.CreateTag('', Body);
          try TagID := JSONString(JSONFind(Response.Data, 'id')); finally Passed(Response, 'Create isolated tag'); end;
        finally Body.Free; end;
        Body := TJSONObject.Create;
        JSONAdd(Body, 'tags', JSONArr([TagID]));
        try Passed(Client.AttachDocumentTags('', DocumentID, Body), 'Attach tag'); finally Body.Free; end;
        Passed(Client.ListDocumentTags('', DocumentID), 'Document tags');
        Passed(Client.DetachDocumentTag('', DocumentID, TagID), 'Detach tag');
      finally
        Cleanup('document', DocumentID);
        Cleanup('signer', SignerID);
        Cleanup('tag', TagID);
      end;
      if CleanupFailed then raise Exception.Create('Sandbox cleanup requires attention to the printed resource IDs');
    end;
    WriteLn('PASS: ', Calls, ' live sandbox operations');
  finally
    Query.Free;
    Client.Free;
  end;
end.
