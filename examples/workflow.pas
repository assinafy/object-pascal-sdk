program Workflow;

{$mode objfpc}{$H+}

uses
  {$ifdef unix}cthreads,{$endif}
  SysUtils, fpjson, Assinafy, AssinafyHttp;

var
  Client: TAssinafyClient;
  Response: TAssinafyResponse;
  SignerBody, AssignmentBody: TJSONObject;
  Signers: TJSONArray;
  DocumentID, SignerID, BaseURL: string;
begin
  if ParamCount <> 2 then
    raise EAssinafyInputError.Create('Usage: workflow <document.pdf> <signer-email>');
  RequireValue(GetEnvironmentVariable('ASSINAFY_ACCOUNT_ID'), 'ASSINAFY_ACCOUNT_ID');
  BaseURL := GetEnvironmentVariable('ASSINAFY_BASE_URL');
  if BaseURL = '' then BaseURL := AssinafySandboxURL;
  Client := TAssinafyClient.Create(GetEnvironmentVariable('ASSINAFY_API_KEY'),
    GetEnvironmentVariable('ASSINAFY_ACCOUNT_ID'), BaseURL);
  Client.AccessToken := GetEnvironmentVariable('ASSINAFY_ACCESS_TOKEN');
  try
    Response := Client.UploadDocument('', ParamStr(1));
    try DocumentID := Response.Data.FindPath('id').AsString; finally Response.Free; end;
    SignerBody := TJSONObject.Create(['full_name', 'Example Signer', 'email', ParamStr(2)]);
    try
      Response := Client.CreateSigner('', SignerBody);
      try SignerID := Response.Data.FindPath('id').AsString; finally Response.Free; end;
    finally SignerBody.Free; end;
    AssignmentBody := TJSONObject.Create(['method', 'virtual']);
    try
      Signers := TJSONArray.Create;
      AssignmentBody.Add('signers', Signers);
      Signers.Add(TJSONObject.Create(['id', SignerID, 'verification_method', 'Email']));
      Response := Client.EstimateAssignmentCost(DocumentID, AssignmentBody);
      try WriteLn('Estimated cost: ', Response.Data.AsJSON); finally Response.Free; end;
      Response := Client.CreateAssignment(DocumentID, AssignmentBody);
      try WriteLn('Assignment: ', Response.Data.AsJSON); finally Response.Free; end;
    finally AssignmentBody.Free; end;
    WriteLn('Document ID: ', DocumentID);
  finally Client.Free; end;
end.
