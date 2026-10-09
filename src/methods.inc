function TAssinafyClient.GetAccount(const AAccountId: string): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId'), aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.UpdateAccount(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/accounts/' + PathValue(AAccountId, 'AccountId'), aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.DeleteAccount(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
begin
  Result := Call('DELETE', '/accounts/' + PathValue(AAccountId, 'AccountId'), aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.GetAccountTheme(const AAccountId: string): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/theme', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.DownloadAccountLogo(const AAccountId: string): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/logo', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.UploadAccountLogo(const AAccountId: string; const FileName: string): TAssinafyResponse;
begin
  Result := Call('POST', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/logo', aaAPI,
    nil, nil, FileName, 'file', 'application/octet-stream', '');
end;

function TAssinafyClient.DeleteAccountLogo(const AAccountId: string): TAssinafyResponse;
begin
  Result := Call('DELETE', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/logo', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.ListMyAccounts: TAssinafyResponse;
begin
  Result := Call('GET', '/accounts', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.CreateAccount(Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/accounts', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.ListDocumentActivities(const DocumentId: string): TAssinafyResponse;
begin
  Result := Call('GET', '/documents/' + PathValue(DocumentId, 'DocumentId') + '/activities', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.ListAssignments(Query: TStrings): TAssinafyResponse;
begin
  Result := Call('GET', '/assignments', aaAPI,
    Query, nil, '', '', '', '');
end;

function TAssinafyClient.CreateAssignment(const DocumentId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/documents/' + PathValue(DocumentId, 'DocumentId') + '/assignments', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.EstimateAssignmentCost(const DocumentId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/documents/' + PathValue(DocumentId, 'DocumentId') + '/assignments/estimate-cost', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.ResendSignatureRequest(const DocumentId: string; const AssignmentId: string; const SignerId: string): TAssinafyResponse;
begin
  Result := Call('PUT', '/documents/' + PathValue(DocumentId, 'DocumentId') + '/assignments/' + PathValue(AssignmentId, 'AssignmentId') + '/signers/' + PathValue(SignerId, 'SignerId') + '/resend', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.EstimateResendCost(const DocumentId: string; const AssignmentId: string; const SignerId: string): TAssinafyResponse;
begin
  Result := Call('POST', '/documents/' + PathValue(DocumentId, 'DocumentId') + '/assignments/' + PathValue(AssignmentId, 'AssignmentId') + '/signers/' + PathValue(SignerId, 'SignerId') + '/estimate-resend-cost', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.ResetAssignmentExpiration(const DocumentId: string; const AssignmentId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/documents/' + PathValue(DocumentId, 'DocumentId') + '/assignments/' + PathValue(AssignmentId, 'AssignmentId') + '/reset-expiration', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.Login(Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/login', aaPublic,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.RequestPasswordReset(Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/authentication/request-password-reset', aaPublic,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.ResetPassword(Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/authentication/reset-password', aaPublic,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.ChangePassword(Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/authentication/change-password', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.CompleteATwoFactorLogin(Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/authentication/mfa/verify', aaPublic,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.ListDocuments(const AAccountId: string; Query: TStrings): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/documents', aaAPI,
    Query, nil, '', '', '', '');
end;

function TAssinafyClient.UploadDocument(const AAccountId: string; const FileName: string): TAssinafyResponse;
begin
  Result := Call('POST', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/documents', aaAPI,
    nil, nil, FileName, 'file', 'application/pdf', '');
end;

function TAssinafyClient.SearchDocuments(const AAccountId: string; Query: TStrings): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/documents/search', aaAPI,
    Query, nil, '', '', '', '');
end;

function TAssinafyClient.ListDocumentStatuses: TAssinafyResponse;
begin
  Result := Call('GET', '/documents/statuses', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.GetDocument(const DocumentId: string): TAssinafyResponse;
begin
  Result := Call('GET', '/documents/' + PathValue(DocumentId, 'DocumentId'), aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.DeleteDocument(const DocumentId: string): TAssinafyResponse;
begin
  Result := Call('DELETE', '/documents/' + PathValue(DocumentId, 'DocumentId'), aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.RenameDocument(const DocumentId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PATCH', '/documents/' + PathValue(DocumentId, 'DocumentId'), aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.DownloadDocumentArtifact(const DocumentId: string; const ArtifactName: string): TAssinafyResponse;
begin
  Result := Call('GET', '/documents/' + PathValue(DocumentId, 'DocumentId') + '/download/' + PathValue(ArtifactName, 'ArtifactName'), aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.VerifyASignedDocument(const DocumentSignatureHash: string): TAssinafyResponse;
begin
  Result := Call('GET', '/documents/' + PathValue(DocumentSignatureHash, 'DocumentSignatureHash') + '/verify', aaPublic,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.ListDocumentTags(const AAccountId: string; const DocumentId: string): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/documents/' + PathValue(DocumentId, 'DocumentId') + '/tags', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.ReplaceDocumentTags(const AAccountId: string; const DocumentId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/documents/' + PathValue(DocumentId, 'DocumentId') + '/tags', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.AttachDocumentTags(const AAccountId: string; const DocumentId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/documents/' + PathValue(DocumentId, 'DocumentId') + '/tags', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.DetachDocumentTag(const AAccountId: string; const DocumentId: string; const TagId: string): TAssinafyResponse;
begin
  Result := Call('DELETE', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/documents/' + PathValue(DocumentId, 'DocumentId') + '/tags/' + PathValue(TagId, 'TagId'), aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.ListFields(const AAccountId: string; Query: TStrings): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/fields', aaAPI,
    Query, nil, '', '', '', '');
end;

function TAssinafyClient.CreateField(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/fields', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.GetField(const AAccountId: string; const FieldId: string): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/fields/' + PathValue(FieldId, 'FieldId'), aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.UpdateField(const AAccountId: string; const FieldId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/fields/' + PathValue(FieldId, 'FieldId'), aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.DeleteField(const AAccountId: string; const FieldId: string): TAssinafyResponse;
begin
  Result := Call('DELETE', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/fields/' + PathValue(FieldId, 'FieldId'), aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.ValidateFieldValue(const AAccountId: string; const FieldId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/fields/' + PathValue(FieldId, 'FieldId') + '/validate', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.ValidateMultipleFieldValues(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/fields/validate-multiple', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.ListFieldTypes: TAssinafyResponse;
begin
  Result := Call('GET', '/field-types', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.ListTwoFactorMethods: TAssinafyResponse;
begin
  Result := Call('GET', '/users/self/mfa', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.StartAuthenticatorEnrollment(Body: TJSONData): TAssinafyResponse;
begin
  Result := Call('POST', '/users/self/mfa/totp', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.ConfirmAuthenticatorEnrollment(Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/users/self/mfa/totp/confirm', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.RegenerateRecoveryCodes(Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/users/self/mfa/recovery-codes', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.RemoveATwoFactorMethod(const CustomId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('DELETE', '/users/self/mfa/' + PathValue(CustomId, 'CustomId'), aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.GetMyNotificationPreferences: TAssinafyResponse;
begin
  Result := Call('GET', '/users/self/notification-preferences', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.UpdateMyNotificationPreferences(Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/users/self/notification-preferences', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.ExchangeOAuthToken(Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/oauth/token', aaPublic,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.RevokeOAuthToken(Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/oauth/revoke', aaPublic,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.GetOAuthUserInfo: TAssinafyResponse;
begin
  Result := Call('GET', '/oauth/userinfo', aaBearer,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.DownloadDocumentThumbnail(const DocumentId: string): TAssinafyResponse;
begin
  Result := Call('GET', '/documents/' + PathValue(DocumentId, 'DocumentId') + '/thumbnail', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.DownloadDocumentPage(const DocumentId: string; const PageId: string): TAssinafyResponse;
begin
  Result := Call('GET', '/documents/' + PathValue(DocumentId, 'DocumentId') + '/pages/' + PathValue(PageId, 'PageId') + '/download', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.ViewPublicDocument(const DocumentId: string): TAssinafyResponse;
begin
  Result := Call('GET', '/public/documents/' + PathValue(DocumentId, 'DocumentId'), aaPublic,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.SendAccessTokenForPublicDocument(const DocumentId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/public/documents/' + PathValue(DocumentId, 'DocumentId') + '/send-token', aaPublic,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.ListSigners(const AAccountId: string; Query: TStrings): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/signers', aaAPI,
    Query, nil, '', '', '', '');
end;

function TAssinafyClient.CreateSigner(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/signers', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.GetSigner(const AAccountId: string; const SignerId: string): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/signers/' + PathValue(SignerId, 'SignerId'), aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.UpdateSigner(const AAccountId: string; const SignerId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/signers/' + PathValue(SignerId, 'SignerId'), aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.DeleteSigner(const AAccountId: string; const SignerId: string): TAssinafyResponse;
begin
  Result := Call('DELETE', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/signers/' + PathValue(SignerId, 'SignerId'), aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.GetCurrentSigner(const SignerAccessCode: string): TAssinafyResponse;
begin
  Result := Call('GET', '/signers/self', aaSigner,
    nil, nil, '', '', '', SignerAccessCode);
end;

function TAssinafyClient.GetSignerDocument(const SignerId: string; const SignerAccessCode: string): TAssinafyResponse;
begin
  Result := Call('GET', '/signers/' + PathValue(SignerId, 'SignerId') + '/document', aaSigner,
    nil, nil, '', '', '', SignerAccessCode);
end;

function TAssinafyClient.ViewDocumentToSign(const SignerAccessCode: string; Query: TStrings): TAssinafyResponse;
begin
  Result := Call('GET', '/sign', aaSigner,
    Query, nil, '', '', '', SignerAccessCode);
end;

function TAssinafyClient.SignAssignmentItems(const DocumentId: string; const AssignmentId: string; const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/documents/' + PathValue(DocumentId, 'DocumentId') + '/assignments/' + PathValue(AssignmentId, 'AssignmentId'), aaSigner,
    nil, Body, '', '', 'application/json', SignerAccessCode);
end;

function TAssinafyClient.RejectAssignment(const DocumentId: string; const AssignmentId: string; const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/documents/' + PathValue(DocumentId, 'DocumentId') + '/assignments/' + PathValue(AssignmentId, 'AssignmentId') + '/reject', aaSigner,
    nil, Body, '', '', 'application/json', SignerAccessCode);
end;

function TAssinafyClient.SignMultipleDocuments(const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/signers/documents/sign-multiple', aaSigner,
    nil, Body, '', '', 'application/json', SignerAccessCode);
end;

function TAssinafyClient.DeclineMultipleDocuments(const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/signers/documents/decline-multiple', aaSigner,
    nil, Body, '', '', 'application/json', SignerAccessCode);
end;

function TAssinafyClient.VerifySignerCode(const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/verify', aaSigner,
    nil, Body, '', '', 'application/json', SignerAccessCode);
end;

function TAssinafyClient.ConfirmSignerData(const DocumentId: string; const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/documents/' + PathValue(DocumentId, 'DocumentId') + '/signers/confirm-data', aaSigner,
    nil, Body, '', '', 'application/json', SignerAccessCode);
end;

function TAssinafyClient.AcceptTerms(const SignerAccessCode: string): TAssinafyResponse;
begin
  Result := Call('PUT', '/signers/accept-terms', aaSigner,
    nil, nil, '', '', '', SignerAccessCode);
end;

function TAssinafyClient.UploadSignatureImage(const SignerAccessCode: string; const FileName: string; Query: TStrings): TAssinafyResponse;
begin
  Result := Call('POST', '/signature', aaSigner,
    Query, nil, FileName, '', 'image/png', SignerAccessCode);
end;

function TAssinafyClient.DownloadSignatureImage(const SignatureType: string; const SignerAccessCode: string): TAssinafyResponse;
begin
  Result := Call('GET', '/signature/' + PathValue(SignatureType, 'SignatureType'), aaSigner,
    nil, nil, '', '', '', SignerAccessCode);
end;

function TAssinafyClient.ListSignerDocuments(const SignerId: string; const SignerAccessCode: string; Query: TStrings): TAssinafyResponse;
begin
  Result := Call('GET', '/signers/' + PathValue(SignerId, 'SignerId') + '/documents', aaSignerOrAPI,
    Query, nil, '', '', '', SignerAccessCode);
end;

function TAssinafyClient.SearchSignerDocuments(const SignerId: string; const SignerAccessCode: string; Query: TStrings): TAssinafyResponse;
begin
  Result := Call('GET', '/signers/' + PathValue(SignerId, 'SignerId') + '/documents/search', aaSignerOrAPI,
    Query, nil, '', '', '', SignerAccessCode);
end;

function TAssinafyClient.DownloadSignerDocumentArtifact(const SignerId: string; const DocumentId: string; const ArtifactName: string): TAssinafyResponse;
begin
  Result := Call('GET', '/signers/' + PathValue(SignerId, 'SignerId') + '/documents/' + PathValue(DocumentId, 'DocumentId') + '/download/' + PathValue(ArtifactName, 'ArtifactName'), aaPublic,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.SocialLogin(Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/authentication/social-login', aaPublic,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.LinkSocialLogin(Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/auth/link-social-login', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.GetAccountStats(const AAccountId: string; Query: TStrings): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/stats', aaAPI,
    Query, nil, '', '', '', '');
end;

function TAssinafyClient.GetUserStats(Query: TStrings): TAssinafyResponse;
begin
  Result := Call('GET', '/users/self/stats', aaAPI,
    Query, nil, '', '', '', '');
end;

function TAssinafyClient.ListTags(const AAccountId: string; Query: TStrings): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/tags', aaAPI,
    Query, nil, '', '', '', '');
end;

function TAssinafyClient.CreateTag(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/tags', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.UpdateTag(const AAccountId: string; const TagId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/tags/' + PathValue(TagId, 'TagId'), aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.DeleteTag(const AAccountId: string; const TagId: string; Query: TStrings): TAssinafyResponse;
begin
  Result := Call('DELETE', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/tags/' + PathValue(TagId, 'TagId'), aaAPI,
    Query, nil, '', '', '', '');
end;

function TAssinafyClient.ListTemplates(const AAccountId: string; Query: TStrings): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/templates', aaAPI,
    Query, nil, '', '', '', '');
end;

function TAssinafyClient.CreateDocumentFromTemplate(const AAccountId: string; const TemplateId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/templates/' + PathValue(TemplateId, 'TemplateId') + '/documents', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.EstimateDocumentFromTemplateCost(const AAccountId: string; const TemplateId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/templates/' + PathValue(TemplateId, 'TemplateId') + '/documents/estimate-cost', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.GetUser: TAssinafyResponse;
begin
  Result := Call('GET', '/users/self', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.GetAPIKey: TAssinafyResponse;
begin
  Result := Call('GET', '/users/api-keys', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.CreateAPIKey(Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/users/api-keys', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.DeleteAPIKey: TAssinafyResponse;
begin
  Result := Call('DELETE', '/users/api-keys', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.GetWebhookSubscription(const AAccountId: string): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/webhooks/subscriptions', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.UpdateWebhookSubscription(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/webhooks/subscriptions', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.InactivateWebhookSubscription(const AAccountId: string): TAssinafyResponse;
begin
  Result := Call('PUT', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/webhooks/inactivate', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.ListWebhookEventTypes: TAssinafyResponse;
begin
  Result := Call('GET', '/webhooks/event-types', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.ListWebhookDeliveries(const AAccountId: string; Query: TStrings): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/webhooks', aaAPI,
    Query, nil, '', '', '', '');
end;

function TAssinafyClient.RetryWebhookDelivery(const AAccountId: string; const HistoryId: string): TAssinafyResponse;
begin
  Result := Call('POST', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/webhooks/' + PathValue(HistoryId, 'HistoryId') + '/retry', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.ListWebhookEndpoints(const AAccountId: string): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/webhooks/endpoints', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.CreateWebhookEndpoint(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('POST', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/webhooks/endpoints', aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.GetWebhookEndpoint(const AAccountId: string; const EndpointId: string): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/webhooks/endpoints/' + PathValue(EndpointId, 'EndpointId'), aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.UpdateWebhookEndpoint(const AAccountId: string; const EndpointId: string; Body: TJSONData): TAssinafyResponse;
begin
  if Body = nil then raise EAssinafyInputError.Create('Request body is required');
  Result := Call('PUT', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/webhooks/endpoints/' + PathValue(EndpointId, 'EndpointId'), aaAPI,
    nil, Body, '', '', 'application/json', '');
end;

function TAssinafyClient.DeleteWebhookEndpoint(const AAccountId: string; const EndpointId: string): TAssinafyResponse;
begin
  Result := Call('DELETE', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/webhooks/endpoints/' + PathValue(EndpointId, 'EndpointId'), aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.GetWebhookEndpointSigningSecret(const AAccountId: string; const EndpointId: string): TAssinafyResponse;
begin
  Result := Call('GET', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/webhooks/endpoints/' + PathValue(EndpointId, 'EndpointId') + '/secret', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.RotateWebhookEndpointSigningSecret(const AAccountId: string; const EndpointId: string): TAssinafyResponse;
begin
  Result := Call('POST', '/accounts/' + PathValue(AAccountId, 'AccountId') + '/webhooks/endpoints/' + PathValue(EndpointId, 'EndpointId') + '/secret/rotate', aaAPI,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.GetOAuthResourceMetadata: TAssinafyResponse;
begin
  Result := Call('GET', '/.well-known/oauth-protected-resource', aaPublic,
    nil, nil, '', '', '', '');
end;

function TAssinafyClient.ListWhatsAppNotifications(const DocumentId: string; const AssignmentId: string): TAssinafyResponse;
begin
  Result := Call('GET', '/documents/' + PathValue(DocumentId, 'DocumentId') + '/assignments/' + PathValue(AssignmentId, 'AssignmentId') + '/whatsapp-notifications', aaAPI,
    nil, nil, '', '', '', '');
end;
