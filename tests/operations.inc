  Response := Client.GetAccount('');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetAccount verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account', 'GetAccount URL');
  Check(Fake.LastAuth = 'bearer', 'GetAccount authentication');

  Response := Client.UpdateAccount('', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'UpdateAccount verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account', 'UpdateAccount URL');
  Check(Fake.LastAuth = 'bearer', 'UpdateAccount authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'UpdateAccount body');
  Check(Fake.LastContentType = 'application/json', 'UpdateAccount content type');

  Response := Client.DeleteAccount('', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'DELETE', 'DeleteAccount verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account', 'DeleteAccount URL');
  Check(Fake.LastAuth = 'bearer', 'DeleteAccount authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'DeleteAccount body');
  Check(Fake.LastContentType = 'application/json', 'DeleteAccount content type');

  Response := Client.GetAccountTheme('');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetAccountTheme verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/theme', 'GetAccountTheme URL');
  Check(Fake.LastAuth = 'bearer', 'GetAccountTheme authentication');

  Response := Client.DownloadAccountLogo('');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'DownloadAccountLogo verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/logo', 'DownloadAccountLogo URL');
  Check(Fake.LastAuth = 'bearer', 'DownloadAccountLogo authentication');

  Response := Client.UploadAccountLogo('', FixtureFile, 'application/octet-stream');
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'UploadAccountLogo verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/logo', 'UploadAccountLogo URL');
  Check(Fake.LastAuth = 'bearer', 'UploadAccountLogo authentication');
  Check(Fake.LastFile = FixtureFile, 'UploadAccountLogo file');
  Check(Fake.LastFileField = 'file', 'UploadAccountLogo file field');
  Check(Fake.LastContentType = 'application/octet-stream', 'UploadAccountLogo content type');

  Response := Client.DeleteAccountLogo('');
  Response.Free;
  Check(Fake.LastMethod = 'DELETE', 'DeleteAccountLogo verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/logo', 'DeleteAccountLogo URL');
  Check(Fake.LastAuth = 'bearer', 'DeleteAccountLogo authentication');

  Response := Client.ListMyAccounts;
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListMyAccounts verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts', 'ListMyAccounts URL');
  Check(Fake.LastAuth = 'bearer', 'ListMyAccounts authentication');

  Response := Client.CreateAccount(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'CreateAccount verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts', 'CreateAccount URL');
  Check(Fake.LastAuth = 'bearer', 'CreateAccount authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'CreateAccount body');
  Check(Fake.LastContentType = 'application/json', 'CreateAccount content type');

  Response := Client.ListDocumentActivities('DocumentId');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListDocumentActivities verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/activities', 'ListDocumentActivities URL');
  Check(Fake.LastAuth = 'bearer', 'ListDocumentActivities authentication');

  TestQuery.Clear;
  TestQuery.Add('page=1');
  TestQuery.Add('per-page=25');
  Response := Client.ListAssignments(TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListAssignments verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/assignments?page=1&per-page=25', 'ListAssignments URL');
  Check(Fake.LastAuth = 'bearer', 'ListAssignments authentication');

  Response := Client.CreateAssignment('DocumentId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'CreateAssignment verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/assignments', 'CreateAssignment URL');
  Check(Fake.LastAuth = 'bearer', 'CreateAssignment authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'CreateAssignment body');
  Check(Fake.LastContentType = 'application/json', 'CreateAssignment content type');

  Response := Client.EstimateAssignmentCost('DocumentId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'EstimateAssignmentCost verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/assignments/estimate-cost', 'EstimateAssignmentCost URL');
  Check(Fake.LastAuth = 'bearer', 'EstimateAssignmentCost authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'EstimateAssignmentCost body');
  Check(Fake.LastContentType = 'application/json', 'EstimateAssignmentCost content type');

  Response := Client.ResendSignatureRequest('DocumentId', 'AssignmentId', 'SignerId');
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'ResendSignatureRequest verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/assignments/AssignmentId/signers/SignerId/resend', 'ResendSignatureRequest URL');
  Check(Fake.LastAuth = 'bearer', 'ResendSignatureRequest authentication');

  Response := Client.EstimateResendCost('DocumentId', 'AssignmentId', 'SignerId');
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'EstimateResendCost verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/assignments/AssignmentId/signers/SignerId/estimate-resend-cost', 'EstimateResendCost URL');
  Check(Fake.LastAuth = 'bearer', 'EstimateResendCost authentication');

  Response := Client.ResetAssignmentExpiration('DocumentId', 'AssignmentId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'ResetAssignmentExpiration verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/assignments/AssignmentId/reset-expiration', 'ResetAssignmentExpiration URL');
  Check(Fake.LastAuth = 'bearer', 'ResetAssignmentExpiration authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'ResetAssignmentExpiration body');
  Check(Fake.LastContentType = 'application/json', 'ResetAssignmentExpiration content type');

  Response := Client.Login(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'Login verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/login', 'Login URL');
  Check(Fake.LastAuth = 'public', 'Login authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'Login body');
  Check(Fake.LastContentType = 'application/json', 'Login content type');

  Response := Client.RequestPasswordReset(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'RequestPasswordReset verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/authentication/request-password-reset', 'RequestPasswordReset URL');
  Check(Fake.LastAuth = 'public', 'RequestPasswordReset authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'RequestPasswordReset body');
  Check(Fake.LastContentType = 'application/json', 'RequestPasswordReset content type');

  Response := Client.ResetPassword(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'ResetPassword verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/authentication/reset-password', 'ResetPassword URL');
  Check(Fake.LastAuth = 'public', 'ResetPassword authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'ResetPassword body');
  Check(Fake.LastContentType = 'application/json', 'ResetPassword content type');

  Response := Client.ChangePassword(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'ChangePassword verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/authentication/change-password', 'ChangePassword URL');
  Check(Fake.LastAuth = 'bearer', 'ChangePassword authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'ChangePassword body');
  Check(Fake.LastContentType = 'application/json', 'ChangePassword content type');

  Response := Client.CompleteATwoFactorLogin(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'CompleteATwoFactorLogin verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/authentication/mfa/verify', 'CompleteATwoFactorLogin URL');
  Check(Fake.LastAuth = 'public', 'CompleteATwoFactorLogin authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'CompleteATwoFactorLogin body');
  Check(Fake.LastContentType = 'application/json', 'CompleteATwoFactorLogin content type');

  TestQuery.Clear;
  TestQuery.Add('status=<string>');
  TestQuery.Add('method=virtual');
  TestQuery.Add('search=<string>');
  TestQuery.Add('tags=<string>');
  TestQuery.Add('sort=<string>');
  TestQuery.Add('page=1');
  TestQuery.Add('per-page=25');
  Response := Client.ListDocuments('', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListDocuments verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/documents?status=%3Cstring%3E&method=virtual&search=%3Cstring%3E&tags=%3Cstring%3E&sort=%3Cstring%3E&page=1&per-page=25', 'ListDocuments URL');
  Check(Fake.LastAuth = 'bearer', 'ListDocuments authentication');

  Response := Client.UploadDocument('', FixtureFile);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'UploadDocument verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/documents', 'UploadDocument URL');
  Check(Fake.LastAuth = 'bearer', 'UploadDocument authentication');
  Check(Fake.LastFile = FixtureFile, 'UploadDocument file');
  Check(Fake.LastFileField = 'file', 'UploadDocument file field');
  Check(Fake.LastContentType = 'application/pdf', 'UploadDocument content type');

  TestQuery.Clear;
  TestQuery.Add('search=<string>');
  TestQuery.Add('status=<string>');
  TestQuery.Add('page=1');
  TestQuery.Add('per-page=25');
  Response := Client.SearchDocuments('', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'SearchDocuments verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/documents/search?search=%3Cstring%3E&status=%3Cstring%3E&page=1&per-page=25', 'SearchDocuments URL');
  Check(Fake.LastAuth = 'bearer', 'SearchDocuments authentication');

  Response := Client.ListDocumentStatuses;
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListDocumentStatuses verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/statuses', 'ListDocumentStatuses URL');
  Check(Fake.LastAuth = 'bearer', 'ListDocumentStatuses authentication');

  Response := Client.GetDocument('DocumentId');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetDocument verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId', 'GetDocument URL');
  Check(Fake.LastAuth = 'bearer', 'GetDocument authentication');

  Response := Client.DeleteDocument('DocumentId');
  Response.Free;
  Check(Fake.LastMethod = 'DELETE', 'DeleteDocument verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId', 'DeleteDocument URL');
  Check(Fake.LastAuth = 'bearer', 'DeleteDocument authentication');

  Response := Client.RenameDocument('DocumentId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PATCH', 'RenameDocument verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId', 'RenameDocument URL');
  Check(Fake.LastAuth = 'bearer', 'RenameDocument authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'RenameDocument body');
  Check(Fake.LastContentType = 'application/json', 'RenameDocument content type');

  Response := Client.DownloadDocumentArtifact('DocumentId', 'ArtifactName');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'DownloadDocumentArtifact verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/download/ArtifactName', 'DownloadDocumentArtifact URL');
  Check(Fake.LastAuth = 'bearer', 'DownloadDocumentArtifact authentication');

  Response := Client.VerifyASignedDocument('DocumentSignatureHash');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'VerifyASignedDocument verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentSignatureHash/verify', 'VerifyASignedDocument URL');
  Check(Fake.LastAuth = 'public', 'VerifyASignedDocument authentication');

  Response := Client.ListDocumentTags('', 'DocumentId');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListDocumentTags verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/documents/DocumentId/tags', 'ListDocumentTags URL');
  Check(Fake.LastAuth = 'bearer', 'ListDocumentTags authentication');

  Response := Client.ReplaceDocumentTags('', 'DocumentId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'ReplaceDocumentTags verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/documents/DocumentId/tags', 'ReplaceDocumentTags URL');
  Check(Fake.LastAuth = 'bearer', 'ReplaceDocumentTags authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'ReplaceDocumentTags body');
  Check(Fake.LastContentType = 'application/json', 'ReplaceDocumentTags content type');

  Response := Client.AttachDocumentTags('', 'DocumentId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'AttachDocumentTags verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/documents/DocumentId/tags', 'AttachDocumentTags URL');
  Check(Fake.LastAuth = 'bearer', 'AttachDocumentTags authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'AttachDocumentTags body');
  Check(Fake.LastContentType = 'application/json', 'AttachDocumentTags content type');

  Response := Client.DetachDocumentTag('', 'DocumentId', 'TagId');
  Response.Free;
  Check(Fake.LastMethod = 'DELETE', 'DetachDocumentTag verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/documents/DocumentId/tags/TagId', 'DetachDocumentTag URL');
  Check(Fake.LastAuth = 'bearer', 'DetachDocumentTag authentication');

  TestQuery.Clear;
  TestQuery.Add('include_inactive=false');
  TestQuery.Add('include_standard=false');
  Response := Client.ListFields('', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListFields verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/fields?include_inactive=false&include_standard=false', 'ListFields URL');
  Check(Fake.LastAuth = 'bearer', 'ListFields authentication');

  Response := Client.CreateField('', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'CreateField verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/fields', 'CreateField URL');
  Check(Fake.LastAuth = 'bearer', 'CreateField authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'CreateField body');
  Check(Fake.LastContentType = 'application/json', 'CreateField content type');

  Response := Client.GetField('', 'FieldId');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetField verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/fields/FieldId', 'GetField URL');
  Check(Fake.LastAuth = 'bearer', 'GetField authentication');

  Response := Client.UpdateField('', 'FieldId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'UpdateField verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/fields/FieldId', 'UpdateField URL');
  Check(Fake.LastAuth = 'bearer', 'UpdateField authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'UpdateField body');
  Check(Fake.LastContentType = 'application/json', 'UpdateField content type');

  Response := Client.DeleteField('', 'FieldId');
  Response.Free;
  Check(Fake.LastMethod = 'DELETE', 'DeleteField verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/fields/FieldId', 'DeleteField URL');
  Check(Fake.LastAuth = 'bearer', 'DeleteField authentication');

  Response := Client.ValidateFieldValue('', 'FieldId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'ValidateFieldValue verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/fields/FieldId/validate', 'ValidateFieldValue URL');
  Check(Fake.LastAuth = 'bearer', 'ValidateFieldValue authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'ValidateFieldValue body');
  Check(Fake.LastContentType = 'application/json', 'ValidateFieldValue content type');

  Response := Client.ValidateMultipleFieldValues('', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'ValidateMultipleFieldValues verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/fields/validate-multiple', 'ValidateMultipleFieldValues URL');
  Check(Fake.LastAuth = 'bearer', 'ValidateMultipleFieldValues authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'ValidateMultipleFieldValues body');
  Check(Fake.LastContentType = 'application/json', 'ValidateMultipleFieldValues content type');

  Response := Client.ListFieldTypes;
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListFieldTypes verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/field-types', 'ListFieldTypes URL');
  Check(Fake.LastAuth = 'bearer', 'ListFieldTypes authentication');

  Response := Client.ListTwoFactorMethods;
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListTwoFactorMethods verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/users/self/mfa', 'ListTwoFactorMethods URL');
  Check(Fake.LastAuth = 'bearer', 'ListTwoFactorMethods authentication');

  Response := Client.StartAuthenticatorEnrollment(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'StartAuthenticatorEnrollment verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/users/self/mfa/totp', 'StartAuthenticatorEnrollment URL');
  Check(Fake.LastAuth = 'bearer', 'StartAuthenticatorEnrollment authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'StartAuthenticatorEnrollment body');
  Check(Fake.LastContentType = 'application/json', 'StartAuthenticatorEnrollment content type');

  Response := Client.ConfirmAuthenticatorEnrollment(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'ConfirmAuthenticatorEnrollment verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/users/self/mfa/totp/confirm', 'ConfirmAuthenticatorEnrollment URL');
  Check(Fake.LastAuth = 'bearer', 'ConfirmAuthenticatorEnrollment authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'ConfirmAuthenticatorEnrollment body');
  Check(Fake.LastContentType = 'application/json', 'ConfirmAuthenticatorEnrollment content type');

  Response := Client.RegenerateRecoveryCodes(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'RegenerateRecoveryCodes verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/users/self/mfa/recovery-codes', 'RegenerateRecoveryCodes URL');
  Check(Fake.LastAuth = 'bearer', 'RegenerateRecoveryCodes authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'RegenerateRecoveryCodes body');
  Check(Fake.LastContentType = 'application/json', 'RegenerateRecoveryCodes content type');

  Response := Client.RemoveATwoFactorMethod('CustomId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'DELETE', 'RemoveATwoFactorMethod verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/users/self/mfa/CustomId', 'RemoveATwoFactorMethod URL');
  Check(Fake.LastAuth = 'bearer', 'RemoveATwoFactorMethod authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'RemoveATwoFactorMethod body');
  Check(Fake.LastContentType = 'application/json', 'RemoveATwoFactorMethod content type');

  Response := Client.GetMyNotificationPreferences;
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetMyNotificationPreferences verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/users/self/notification-preferences', 'GetMyNotificationPreferences URL');
  Check(Fake.LastAuth = 'bearer', 'GetMyNotificationPreferences authentication');

  Response := Client.UpdateMyNotificationPreferences(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'UpdateMyNotificationPreferences verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/users/self/notification-preferences', 'UpdateMyNotificationPreferences URL');
  Check(Fake.LastAuth = 'bearer', 'UpdateMyNotificationPreferences authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'UpdateMyNotificationPreferences body');
  Check(Fake.LastContentType = 'application/json', 'UpdateMyNotificationPreferences content type');

  Response := Client.ExchangeOAuthToken(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'ExchangeOAuthToken verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/oauth/token', 'ExchangeOAuthToken URL');
  Check(Fake.LastAuth = 'public', 'ExchangeOAuthToken authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'ExchangeOAuthToken body');
  Check(Fake.LastContentType = 'application/json', 'ExchangeOAuthToken content type');

  Response := Client.RevokeOAuthToken(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'RevokeOAuthToken verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/oauth/revoke', 'RevokeOAuthToken URL');
  Check(Fake.LastAuth = 'public', 'RevokeOAuthToken authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'RevokeOAuthToken body');
  Check(Fake.LastContentType = 'application/json', 'RevokeOAuthToken content type');

  Response := Client.GetOAuthUserInfo;
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetOAuthUserInfo verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/oauth/userinfo', 'GetOAuthUserInfo URL');
  Check(Fake.LastAuth = 'bearer', 'GetOAuthUserInfo authentication');

  Response := Client.DownloadDocumentThumbnail('DocumentId');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'DownloadDocumentThumbnail verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/thumbnail', 'DownloadDocumentThumbnail URL');
  Check(Fake.LastAuth = 'bearer', 'DownloadDocumentThumbnail authentication');

  Response := Client.DownloadDocumentPage('DocumentId', 'PageId');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'DownloadDocumentPage verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/pages/PageId/download', 'DownloadDocumentPage URL');
  Check(Fake.LastAuth = 'bearer', 'DownloadDocumentPage authentication');

  Response := Client.ViewPublicDocument('DocumentId');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ViewPublicDocument verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/public/documents/DocumentId', 'ViewPublicDocument URL');
  Check(Fake.LastAuth = 'public', 'ViewPublicDocument authentication');

  Response := Client.SendAccessTokenForPublicDocument('DocumentId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'SendAccessTokenForPublicDocument verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/public/documents/DocumentId/send-token', 'SendAccessTokenForPublicDocument URL');
  Check(Fake.LastAuth = 'public', 'SendAccessTokenForPublicDocument authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'SendAccessTokenForPublicDocument body');
  Check(Fake.LastContentType = 'application/json', 'SendAccessTokenForPublicDocument content type');

  TestQuery.Clear;
  TestQuery.Add('search=<string>');
  TestQuery.Add('page=1');
  TestQuery.Add('per-page=25');
  Response := Client.ListSigners('', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListSigners verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/signers?search=%3Cstring%3E&page=1&per-page=25', 'ListSigners URL');
  Check(Fake.LastAuth = 'bearer', 'ListSigners authentication');

  Response := Client.CreateSigner('', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'CreateSigner verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/signers', 'CreateSigner URL');
  Check(Fake.LastAuth = 'bearer', 'CreateSigner authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'CreateSigner body');
  Check(Fake.LastContentType = 'application/json', 'CreateSigner content type');

  Response := Client.GetSigner('', 'SignerId');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetSigner verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/signers/SignerId', 'GetSigner URL');
  Check(Fake.LastAuth = 'bearer', 'GetSigner authentication');

  Response := Client.UpdateSigner('', 'SignerId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'UpdateSigner verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/signers/SignerId', 'UpdateSigner URL');
  Check(Fake.LastAuth = 'bearer', 'UpdateSigner authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'UpdateSigner body');
  Check(Fake.LastContentType = 'application/json', 'UpdateSigner content type');

  Response := Client.DeleteSigner('', 'SignerId');
  Response.Free;
  Check(Fake.LastMethod = 'DELETE', 'DeleteSigner verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/signers/SignerId', 'DeleteSigner URL');
  Check(Fake.LastAuth = 'bearer', 'DeleteSigner authentication');

  Response := Client.GetCurrentSigner('SignerAccessCode');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetCurrentSigner verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signers/self?signer-access-code=SignerAccessCode', 'GetCurrentSigner URL');
  Check(Fake.LastAuth = 'signer', 'GetCurrentSigner authentication');

  Response := Client.GetSignerDocument('SignerId', 'SignerAccessCode');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetSignerDocument verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signers/SignerId/document?signer-access-code=SignerAccessCode', 'GetSignerDocument URL');
  Check(Fake.LastAuth = 'signer', 'GetSignerDocument authentication');

  TestQuery.Clear;
  TestQuery.Add('has_accepted_terms=false');
  Response := Client.ViewDocumentToSign('SignerAccessCode', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ViewDocumentToSign verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/sign?has_accepted_terms=false&signer-access-code=SignerAccessCode', 'ViewDocumentToSign URL');
  Check(Fake.LastAuth = 'signer', 'ViewDocumentToSign authentication');

  Response := Client.SignAssignmentItems('DocumentId', 'AssignmentId', 'SignerAccessCode', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'SignAssignmentItems verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/assignments/AssignmentId?signer-access-code=SignerAccessCode', 'SignAssignmentItems URL');
  Check(Fake.LastAuth = 'signer', 'SignAssignmentItems authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'SignAssignmentItems body');
  Check(Fake.LastContentType = 'application/json', 'SignAssignmentItems content type');

  Response := Client.RejectAssignment('DocumentId', 'AssignmentId', 'SignerAccessCode', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'RejectAssignment verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/assignments/AssignmentId/reject?signer-access-code=SignerAccessCode', 'RejectAssignment URL');
  Check(Fake.LastAuth = 'signer', 'RejectAssignment authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'RejectAssignment body');
  Check(Fake.LastContentType = 'application/json', 'RejectAssignment content type');

  Response := Client.SignMultipleDocuments('SignerAccessCode', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'SignMultipleDocuments verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signers/documents/sign-multiple?signer-access-code=SignerAccessCode', 'SignMultipleDocuments URL');
  Check(Fake.LastAuth = 'signer', 'SignMultipleDocuments authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'SignMultipleDocuments body');
  Check(Fake.LastContentType = 'application/json', 'SignMultipleDocuments content type');

  Response := Client.DeclineMultipleDocuments('SignerAccessCode', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'DeclineMultipleDocuments verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signers/documents/decline-multiple?signer-access-code=SignerAccessCode', 'DeclineMultipleDocuments URL');
  Check(Fake.LastAuth = 'signer', 'DeclineMultipleDocuments authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'DeclineMultipleDocuments body');
  Check(Fake.LastContentType = 'application/json', 'DeclineMultipleDocuments content type');

  Response := Client.VerifySignerCode('SignerAccessCode', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'VerifySignerCode verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/verify?signer-access-code=SignerAccessCode', 'VerifySignerCode URL');
  Check(Fake.LastAuth = 'signer', 'VerifySignerCode authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'VerifySignerCode body');
  Check(Fake.LastContentType = 'application/json', 'VerifySignerCode content type');

  Response := Client.ConfirmSignerData('DocumentId', 'SignerAccessCode', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'ConfirmSignerData verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/signers/confirm-data?signer-access-code=SignerAccessCode', 'ConfirmSignerData URL');
  Check(Fake.LastAuth = 'signer', 'ConfirmSignerData authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'ConfirmSignerData body');
  Check(Fake.LastContentType = 'application/json', 'ConfirmSignerData content type');

  Response := Client.AcceptTerms('SignerAccessCode');
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'AcceptTerms verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signers/accept-terms?signer-access-code=SignerAccessCode', 'AcceptTerms URL');
  Check(Fake.LastAuth = 'signer', 'AcceptTerms authentication');

  TestQuery.Clear;
  TestQuery.Add('type=<string>');
  TestQuery.Add('reuse=false');
  Response := Client.UploadSignatureImage('SignerAccessCode', FixtureFile, TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'UploadSignatureImage verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signature?type=%3Cstring%3E&reuse=false&signer-access-code=SignerAccessCode', 'UploadSignatureImage URL');
  Check(Fake.LastAuth = 'signer', 'UploadSignatureImage authentication');
  Check(Fake.LastFile = FixtureFile, 'UploadSignatureImage file');
  Check(Fake.LastFileField = '', 'UploadSignatureImage file field');
  Check(Fake.LastContentType = 'image/png', 'UploadSignatureImage content type');

  Response := Client.DownloadSignatureImage('SignatureType', 'SignerAccessCode');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'DownloadSignatureImage verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signature/SignatureType?signer-access-code=SignerAccessCode', 'DownloadSignatureImage URL');
  Check(Fake.LastAuth = 'signer', 'DownloadSignatureImage authentication');

  TestQuery.Clear;
  TestQuery.Add('page=1');
  TestQuery.Add('per-page=25');
  Response := Client.ListSignerDocuments('SignerId', 'SignerAccessCode', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListSignerDocuments verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signers/SignerId/documents?page=1&per-page=25&signer-access-code=SignerAccessCode', 'ListSignerDocuments URL');
  Check(Fake.LastAuth = 'signer', 'ListSignerDocuments authentication');

  TestQuery.Clear;
  TestQuery.Add('page=1');
  TestQuery.Add('per-page=25');
  Response := Client.ListSignerDocumentsAsWorkspace('SignerId', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListSignerDocumentsAsWorkspace verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signers/SignerId/documents?page=1&per-page=25', 'ListSignerDocumentsAsWorkspace URL');
  Check(Fake.LastAuth = 'bearer', 'ListSignerDocumentsAsWorkspace authentication');

  TestQuery.Clear;
  TestQuery.Add('search=<string>');
  Response := Client.SearchSignerDocuments('SignerId', 'SignerAccessCode', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'SearchSignerDocuments verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signers/SignerId/documents/search?search=%3Cstring%3E&signer-access-code=SignerAccessCode', 'SearchSignerDocuments URL');
  Check(Fake.LastAuth = 'signer', 'SearchSignerDocuments authentication');

  TestQuery.Clear;
  TestQuery.Add('search=<string>');
  Response := Client.SearchSignerDocumentsAsWorkspace('SignerId', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'SearchSignerDocumentsAsWorkspace verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signers/SignerId/documents/search?search=%3Cstring%3E', 'SearchSignerDocumentsAsWorkspace URL');
  Check(Fake.LastAuth = 'bearer', 'SearchSignerDocumentsAsWorkspace authentication');

  Response := Client.DownloadSignerDocumentArtifact('SignerId', 'DocumentId', 'ArtifactName');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'DownloadSignerDocumentArtifact verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signers/SignerId/documents/DocumentId/download/ArtifactName', 'DownloadSignerDocumentArtifact URL');
  Check(Fake.LastAuth = 'public', 'DownloadSignerDocumentArtifact authentication');

  Response := Client.SocialLogin(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'SocialLogin verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/authentication/social-login', 'SocialLogin URL');
  Check(Fake.LastAuth = 'public', 'SocialLogin authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'SocialLogin body');
  Check(Fake.LastContentType = 'application/json', 'SocialLogin content type');

  Response := Client.LinkSocialLogin(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'LinkSocialLogin verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/auth/link-social-login', 'LinkSocialLogin URL');
  Check(Fake.LastAuth = 'bearer', 'LinkSocialLogin authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'LinkSocialLogin body');
  Check(Fake.LastContentType = 'application/json', 'LinkSocialLogin content type');

  TestQuery.Clear;
  TestQuery.Add('granularity=monthly');
  TestQuery.Add('month=2026-06');
  Response := Client.GetAccountStats('', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetAccountStats verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/stats?granularity=monthly&month=2026-06', 'GetAccountStats URL');
  Check(Fake.LastAuth = 'bearer', 'GetAccountStats authentication');

  TestQuery.Clear;
  TestQuery.Add('granularity=monthly');
  TestQuery.Add('month=2026-06');
  Response := Client.GetUserStats(TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetUserStats verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/users/self/stats?granularity=monthly&month=2026-06', 'GetUserStats URL');
  Check(Fake.LastAuth = 'bearer', 'GetUserStats authentication');

  TestQuery.Clear;
  TestQuery.Add('search=<string>');
  Response := Client.ListTags('', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListTags verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/tags?search=%3Cstring%3E', 'ListTags URL');
  Check(Fake.LastAuth = 'bearer', 'ListTags authentication');

  Response := Client.CreateTag('', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'CreateTag verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/tags', 'CreateTag URL');
  Check(Fake.LastAuth = 'bearer', 'CreateTag authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'CreateTag body');
  Check(Fake.LastContentType = 'application/json', 'CreateTag content type');

  Response := Client.UpdateTag('', 'TagId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'UpdateTag verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/tags/TagId', 'UpdateTag URL');
  Check(Fake.LastAuth = 'bearer', 'UpdateTag authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'UpdateTag body');
  Check(Fake.LastContentType = 'application/json', 'UpdateTag content type');

  TestQuery.Clear;
  TestQuery.Add('force=false');
  Response := Client.DeleteTag('', 'TagId', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'DELETE', 'DeleteTag verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/tags/TagId?force=false', 'DeleteTag URL');
  Check(Fake.LastAuth = 'bearer', 'DeleteTag authentication');

  TestQuery.Clear;
  TestQuery.Add('search=<string>');
  TestQuery.Add('page=1');
  TestQuery.Add('per-page=25');
  Response := Client.ListTemplates('', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListTemplates verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/templates?search=%3Cstring%3E&page=1&per-page=25', 'ListTemplates URL');
  Check(Fake.LastAuth = 'bearer', 'ListTemplates authentication');

  Response := Client.CreateDocumentFromTemplate('', 'TemplateId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'CreateDocumentFromTemplate verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/templates/TemplateId/documents', 'CreateDocumentFromTemplate URL');
  Check(Fake.LastAuth = 'bearer', 'CreateDocumentFromTemplate authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'CreateDocumentFromTemplate body');
  Check(Fake.LastContentType = 'application/json', 'CreateDocumentFromTemplate content type');

  Response := Client.EstimateDocumentFromTemplateCost('', 'TemplateId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'EstimateDocumentFromTemplateCost verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/templates/TemplateId/documents/estimate-cost', 'EstimateDocumentFromTemplateCost URL');
  Check(Fake.LastAuth = 'bearer', 'EstimateDocumentFromTemplateCost authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'EstimateDocumentFromTemplateCost body');
  Check(Fake.LastContentType = 'application/json', 'EstimateDocumentFromTemplateCost content type');

  Response := Client.GetUser;
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetUser verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/users/self', 'GetUser URL');
  Check(Fake.LastAuth = 'bearer', 'GetUser authentication');

  Response := Client.GetAPIKey;
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetAPIKey verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/users/api-keys', 'GetAPIKey URL');
  Check(Fake.LastAuth = 'bearer', 'GetAPIKey authentication');

  Response := Client.CreateAPIKey(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'CreateAPIKey verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/users/api-keys', 'CreateAPIKey URL');
  Check(Fake.LastAuth = 'bearer', 'CreateAPIKey authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'CreateAPIKey body');
  Check(Fake.LastContentType = 'application/json', 'CreateAPIKey content type');

  Response := Client.DeleteAPIKey;
  Response.Free;
  Check(Fake.LastMethod = 'DELETE', 'DeleteAPIKey verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/users/api-keys', 'DeleteAPIKey URL');
  Check(Fake.LastAuth = 'bearer', 'DeleteAPIKey authentication');

  Response := Client.GetWebhookSubscription('');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetWebhookSubscription verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/webhooks/subscriptions', 'GetWebhookSubscription URL');
  Check(Fake.LastAuth = 'bearer', 'GetWebhookSubscription authentication');

  Response := Client.UpdateWebhookSubscription('', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'UpdateWebhookSubscription verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/webhooks/subscriptions', 'UpdateWebhookSubscription URL');
  Check(Fake.LastAuth = 'bearer', 'UpdateWebhookSubscription authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'UpdateWebhookSubscription body');
  Check(Fake.LastContentType = 'application/json', 'UpdateWebhookSubscription content type');

  Response := Client.InactivateWebhookSubscription('');
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'InactivateWebhookSubscription verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/webhooks/inactivate', 'InactivateWebhookSubscription URL');
  Check(Fake.LastAuth = 'bearer', 'InactivateWebhookSubscription authentication');

  Response := Client.ListWebhookEventTypes;
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListWebhookEventTypes verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/webhooks/event-types', 'ListWebhookEventTypes URL');
  Check(Fake.LastAuth = 'bearer', 'ListWebhookEventTypes authentication');

  TestQuery.Clear;
  TestQuery.Add('endpoint_id=<string>');
  TestQuery.Add('event=<string>');
  TestQuery.Add('delivered=true');
  TestQuery.Add('from=1');
  TestQuery.Add('to=1');
  TestQuery.Add('page=1');
  TestQuery.Add('per-page=1');
  Response := Client.ListWebhookDeliveries('', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListWebhookDeliveries verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/webhooks?endpoint_id=%3Cstring%3E&event=%3Cstring%3E&delivered=true&from=1&to=1&page=1&per-page=1', 'ListWebhookDeliveries URL');
  Check(Fake.LastAuth = 'bearer', 'ListWebhookDeliveries authentication');

  Response := Client.RetryWebhookDelivery('', 'HistoryId');
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'RetryWebhookDelivery verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/webhooks/HistoryId/retry', 'RetryWebhookDelivery URL');
  Check(Fake.LastAuth = 'bearer', 'RetryWebhookDelivery authentication');

  Response := Client.ListWebhookEndpoints('');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListWebhookEndpoints verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/webhooks/endpoints', 'ListWebhookEndpoints URL');
  Check(Fake.LastAuth = 'bearer', 'ListWebhookEndpoints authentication');

  Response := Client.CreateWebhookEndpoint('', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'CreateWebhookEndpoint verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/webhooks/endpoints', 'CreateWebhookEndpoint URL');
  Check(Fake.LastAuth = 'bearer', 'CreateWebhookEndpoint authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'CreateWebhookEndpoint body');
  Check(Fake.LastContentType = 'application/json', 'CreateWebhookEndpoint content type');

  Response := Client.GetWebhookEndpoint('', 'EndpointId');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetWebhookEndpoint verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/webhooks/endpoints/EndpointId', 'GetWebhookEndpoint URL');
  Check(Fake.LastAuth = 'bearer', 'GetWebhookEndpoint authentication');

  Response := Client.UpdateWebhookEndpoint('', 'EndpointId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'UpdateWebhookEndpoint verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/webhooks/endpoints/EndpointId', 'UpdateWebhookEndpoint URL');
  Check(Fake.LastAuth = 'bearer', 'UpdateWebhookEndpoint authentication');
  Check(Fake.LastBody = JSONText(TestBody), 'UpdateWebhookEndpoint body');
  Check(Fake.LastContentType = 'application/json', 'UpdateWebhookEndpoint content type');

  Response := Client.DeleteWebhookEndpoint('', 'EndpointId');
  Response.Free;
  Check(Fake.LastMethod = 'DELETE', 'DeleteWebhookEndpoint verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/webhooks/endpoints/EndpointId', 'DeleteWebhookEndpoint URL');
  Check(Fake.LastAuth = 'bearer', 'DeleteWebhookEndpoint authentication');

  Response := Client.GetWebhookEndpointSigningSecret('', 'EndpointId');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetWebhookEndpointSigningSecret verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/webhooks/endpoints/EndpointId/secret', 'GetWebhookEndpointSigningSecret URL');
  Check(Fake.LastAuth = 'bearer', 'GetWebhookEndpointSigningSecret authentication');

  Response := Client.RotateWebhookEndpointSigningSecret('', 'EndpointId');
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'RotateWebhookEndpointSigningSecret verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/webhooks/endpoints/EndpointId/secret/rotate', 'RotateWebhookEndpointSigningSecret URL');
  Check(Fake.LastAuth = 'bearer', 'RotateWebhookEndpointSigningSecret authentication');

  Response := Client.GetOAuthResourceMetadata;
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetOAuthResourceMetadata verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/.well-known/oauth-protected-resource', 'GetOAuthResourceMetadata URL');
  Check(Fake.LastAuth = 'public', 'GetOAuthResourceMetadata authentication');

  Response := Client.ListWhatsAppNotifications('DocumentId', 'AssignmentId');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListWhatsAppNotifications verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/assignments/AssignmentId/whatsapp-notifications', 'ListWhatsAppNotifications URL');
  Check(Fake.LastAuth = 'bearer', 'ListWhatsAppNotifications authentication');
