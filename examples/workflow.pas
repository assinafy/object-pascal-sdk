program Workflow;

{$mode objfpc}{$H+}
{$codepage utf8}

uses
  {$ifdef unix}cthreads,{$endif}
  SysUtils, fpjson, Assinafy, AssinafyHttp;

var
  Client: TAssinafyClient;
  Response: TAssinafyResponse;
  SignerBody, AssignmentBody: TJSONObject;
  Signers: TJSONArray;
  DocumentID, SignerID, BaseURL, AccountID, APIKey, AccessToken: string;
begin
  if ParamCount <> 2 then
    raise EAssinafyInputError.Create('Usage: workflow <document.pdf> <signer-email>');
  APIKey := GetEnvironmentVariable('ASSINAFY_API_KEY');
  AccessToken := GetEnvironmentVariable('ASSINAFY_ACCESS_TOKEN');
  if (APIKey <> '') and (AccessToken <> '') then
    raise EAssinafyInputError.Create('Choose API key plus workspace ID or OAuth; do not configure both');
  AccountID := '';
  if APIKey <> '' then AccountID := GetEnvironmentVariable('ASSINAFY_ACCOUNT_ID')
  else RequireValue(AccessToken, 'ASSINAFY_ACCESS_TOKEN');
  BaseURL := GetEnvironmentVariable('ASSINAFY_BASE_URL');
  if BaseURL = '' then BaseURL := AssinafySandboxURL;
  Client := TAssinafyClient.Create(APIKey, AccountID, BaseURL);
  try
    Client.TimeoutMS := 180000;
    Client.AccessToken := AccessToken;
    if AccessToken <> '' then
    begin
      Response := Client.ListMyAccounts;
      try
        if not (Response.Data is TJSONArray) or (TJSONArray(Response.Data).Count <> 1) then
          raise EAssinafyProtocolError.Create('OAuth must return its authorized workspace');
        AccountID := TJSONArray(Response.Data).Items[0].FindPath('id').AsString;
        RequireValue(AccountID, 'Authorized workspace ID');
      finally Response.Free; end;
    end;
    Response := Client.UploadDocument(AccountID, ParamStr(1));
    try DocumentID := Response.Data.FindPath('id').AsString; finally Response.Free; end;
    SignerBody := TJSONObject.Create(['full_name', 'Example Signer', 'email', ParamStr(2)]);
    try
      Response := Client.CreateSigner(AccountID, SignerBody);
      try SignerID := Response.Data.FindPath('id').AsString; finally Response.Free; end;
    finally SignerBody.Free; end;
    AssignmentBody := TJSONObject.Create(['method', 'virtual']);
    try
      Signers := TJSONArray.Create;
      AssignmentBody.Add('signers', Signers);
      Signers.Add(TJSONObject.Create(['id', SignerID, 'verification_method', 'Email']));
      Response := Client.EstimateAssignmentCost(DocumentID, AssignmentBody);
      try
        WriteLn('Estimated cost: ', Response.Data.AsJSON);
        if not Response.Data.FindPath('has_sufficient_resources').AsBoolean then
          raise EAssinafyInputError.Create('Insufficient resources to request signatures');
      finally Response.Free; end;
      Response := Client.CreateAssignment(DocumentID, AssignmentBody);
      try WriteLn('Assignment: ', Response.Data.AsJSON); finally Response.Free; end;
    finally AssignmentBody.Free; end;
    WriteLn('Document ID: ', DocumentID);
  finally Client.Free; end;
end.
