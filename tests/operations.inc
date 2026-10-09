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
  Check(Fake.LastBody = TestBody.AsJSON, 'UpdateAccount body');

  Response := Client.DeleteAccount('', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'DELETE', 'DeleteAccount verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account', 'DeleteAccount URL');
  Check(Fake.LastAuth = 'bearer', 'DeleteAccount authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'DeleteAccount body');

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

  Response := Client.UploadAccountLogo('', FixtureFile);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'UploadAccountLogo verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/logo', 'UploadAccountLogo URL');
  Check(Fake.LastAuth = 'bearer', 'UploadAccountLogo authentication');
  Check(Fake.LastFile = FixtureFile, 'UploadAccountLogo file');

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
  Check(Fake.LastBody = TestBody.AsJSON, 'CreateAccount body');

  Response := Client.ListDocumentActivities('DocumentId');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListDocumentActivities verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/activities', 'ListDocumentActivities URL');
  Check(Fake.LastAuth = 'bearer', 'ListDocumentActivities authentication');

  Response := Client.ListAssignments(TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListAssignments verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/assignments?search=Ana%20%26%20Joao', 'ListAssignments URL');
  Check(Fake.LastAuth = 'bearer', 'ListAssignments authentication');

  Response := Client.CreateAssignment('DocumentId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'CreateAssignment verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/assignments', 'CreateAssignment URL');
  Check(Fake.LastAuth = 'bearer', 'CreateAssignment authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'CreateAssignment body');

  Response := Client.EstimateAssignmentCost('DocumentId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'EstimateAssignmentCost verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/assignments/estimate-cost', 'EstimateAssignmentCost URL');
  Check(Fake.LastAuth = 'bearer', 'EstimateAssignmentCost authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'EstimateAssignmentCost body');

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
  Check(Fake.LastBody = TestBody.AsJSON, 'ResetAssignmentExpiration body');

  Response := Client.Login(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'Login verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/login', 'Login URL');
  Check(Fake.LastAuth = 'public', 'Login authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'Login body');

  Response := Client.RequestPasswordReset(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'RequestPasswordReset verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/authentication/request-password-reset', 'RequestPasswordReset URL');
  Check(Fake.LastAuth = 'public', 'RequestPasswordReset authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'RequestPasswordReset body');

  Response := Client.ResetPassword(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'ResetPassword verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/authentication/reset-password', 'ResetPassword URL');
  Check(Fake.LastAuth = 'public', 'ResetPassword authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'ResetPassword body');

  Response := Client.ChangePassword(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'ChangePassword verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/authentication/change-password', 'ChangePassword URL');
  Check(Fake.LastAuth = 'bearer', 'ChangePassword authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'ChangePassword body');

  Response := Client.CompleteATwoFactorLogin(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'CompleteATwoFactorLogin verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/authentication/mfa/verify', 'CompleteATwoFactorLogin URL');
  Check(Fake.LastAuth = 'public', 'CompleteATwoFactorLogin authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'CompleteATwoFactorLogin body');

  Response := Client.ListDocuments('', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListDocuments verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/documents?search=Ana%20%26%20Joao', 'ListDocuments URL');
  Check(Fake.LastAuth = 'bearer', 'ListDocuments authentication');

  Response := Client.UploadDocument('', FixtureFile);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'UploadDocument verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/documents', 'UploadDocument URL');
  Check(Fake.LastAuth = 'bearer', 'UploadDocument authentication');
  Check(Fake.LastFile = FixtureFile, 'UploadDocument file');

  Response := Client.SearchDocuments('', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'SearchDocuments verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/documents/search?search=Ana%20%26%20Joao', 'SearchDocuments URL');
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
  Check(Fake.LastBody = TestBody.AsJSON, 'RenameDocument body');

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
  Check(Fake.LastBody = TestBody.AsJSON, 'ReplaceDocumentTags body');

  Response := Client.AttachDocumentTags('', 'DocumentId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'AttachDocumentTags verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/documents/DocumentId/tags', 'AttachDocumentTags URL');
  Check(Fake.LastAuth = 'bearer', 'AttachDocumentTags authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'AttachDocumentTags body');

  Response := Client.DetachDocumentTag('', 'DocumentId', 'TagId');
  Response.Free;
  Check(Fake.LastMethod = 'DELETE', 'DetachDocumentTag verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/documents/DocumentId/tags/TagId', 'DetachDocumentTag URL');
  Check(Fake.LastAuth = 'bearer', 'DetachDocumentTag authentication');

  Response := Client.ListFields('', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListFields verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/fields?search=Ana%20%26%20Joao', 'ListFields URL');
  Check(Fake.LastAuth = 'bearer', 'ListFields authentication');

  Response := Client.CreateField('', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'CreateField verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/fields', 'CreateField URL');
  Check(Fake.LastAuth = 'bearer', 'CreateField authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'CreateField body');

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
  Check(Fake.LastBody = TestBody.AsJSON, 'UpdateField body');

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
  Check(Fake.LastBody = TestBody.AsJSON, 'ValidateFieldValue body');

  Response := Client.ValidateMultipleFieldValues('', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'ValidateMultipleFieldValues verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/fields/validate-multiple', 'ValidateMultipleFieldValues URL');
  Check(Fake.LastAuth = 'bearer', 'ValidateMultipleFieldValues authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'ValidateMultipleFieldValues body');

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
  Check(Fake.LastBody = TestBody.AsJSON, 'StartAuthenticatorEnrollment body');

  Response := Client.ConfirmAuthenticatorEnrollment(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'ConfirmAuthenticatorEnrollment verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/users/self/mfa/totp/confirm', 'ConfirmAuthenticatorEnrollment URL');
  Check(Fake.LastAuth = 'bearer', 'ConfirmAuthenticatorEnrollment authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'ConfirmAuthenticatorEnrollment body');

  Response := Client.RegenerateRecoveryCodes(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'RegenerateRecoveryCodes verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/users/self/mfa/recovery-codes', 'RegenerateRecoveryCodes URL');
  Check(Fake.LastAuth = 'bearer', 'RegenerateRecoveryCodes authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'RegenerateRecoveryCodes body');

  Response := Client.RemoveATwoFactorMethod('CustomId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'DELETE', 'RemoveATwoFactorMethod verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/users/self/mfa/CustomId', 'RemoveATwoFactorMethod URL');
  Check(Fake.LastAuth = 'bearer', 'RemoveATwoFactorMethod authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'RemoveATwoFactorMethod body');

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
  Check(Fake.LastBody = TestBody.AsJSON, 'UpdateMyNotificationPreferences body');

  Response := Client.ExchangeOAuthToken(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'ExchangeOAuthToken verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/oauth/token', 'ExchangeOAuthToken URL');
  Check(Fake.LastAuth = 'public', 'ExchangeOAuthToken authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'ExchangeOAuthToken body');

  Response := Client.RevokeOAuthToken(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'RevokeOAuthToken verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/oauth/revoke', 'RevokeOAuthToken URL');
  Check(Fake.LastAuth = 'public', 'RevokeOAuthToken authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'RevokeOAuthToken body');

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
  Check(Fake.LastBody = TestBody.AsJSON, 'SendAccessTokenForPublicDocument body');

  Response := Client.ListSigners('', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListSigners verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/signers?search=Ana%20%26%20Joao', 'ListSigners URL');
  Check(Fake.LastAuth = 'bearer', 'ListSigners authentication');

  Response := Client.CreateSigner('', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'CreateSigner verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/signers', 'CreateSigner URL');
  Check(Fake.LastAuth = 'bearer', 'CreateSigner authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'CreateSigner body');

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
  Check(Fake.LastBody = TestBody.AsJSON, 'UpdateSigner body');

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

  Response := Client.ViewDocumentToSign('SignerAccessCode', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ViewDocumentToSign verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/sign?search=Ana%20%26%20Joao&signer-access-code=SignerAccessCode', 'ViewDocumentToSign URL');
  Check(Fake.LastAuth = 'signer', 'ViewDocumentToSign authentication');

  Response := Client.SignAssignmentItems('DocumentId', 'AssignmentId', 'SignerAccessCode', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'SignAssignmentItems verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/assignments/AssignmentId?signer-access-code=SignerAccessCode', 'SignAssignmentItems URL');
  Check(Fake.LastAuth = 'signer', 'SignAssignmentItems authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'SignAssignmentItems body');

  Response := Client.RejectAssignment('DocumentId', 'AssignmentId', 'SignerAccessCode', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'RejectAssignment verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/assignments/AssignmentId/reject?signer-access-code=SignerAccessCode', 'RejectAssignment URL');
  Check(Fake.LastAuth = 'signer', 'RejectAssignment authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'RejectAssignment body');

  Response := Client.SignMultipleDocuments('SignerAccessCode', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'SignMultipleDocuments verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signers/documents/sign-multiple?signer-access-code=SignerAccessCode', 'SignMultipleDocuments URL');
  Check(Fake.LastAuth = 'signer', 'SignMultipleDocuments authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'SignMultipleDocuments body');

  Response := Client.DeclineMultipleDocuments('SignerAccessCode', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'DeclineMultipleDocuments verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signers/documents/decline-multiple?signer-access-code=SignerAccessCode', 'DeclineMultipleDocuments URL');
  Check(Fake.LastAuth = 'signer', 'DeclineMultipleDocuments authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'DeclineMultipleDocuments body');

  Response := Client.VerifySignerCode('SignerAccessCode', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'VerifySignerCode verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/verify?signer-access-code=SignerAccessCode', 'VerifySignerCode URL');
  Check(Fake.LastAuth = 'signer', 'VerifySignerCode authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'VerifySignerCode body');

  Response := Client.ConfirmSignerData('DocumentId', 'SignerAccessCode', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'ConfirmSignerData verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/documents/DocumentId/signers/confirm-data?signer-access-code=SignerAccessCode', 'ConfirmSignerData URL');
  Check(Fake.LastAuth = 'signer', 'ConfirmSignerData authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'ConfirmSignerData body');

  Response := Client.AcceptTerms('SignerAccessCode');
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'AcceptTerms verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signers/accept-terms?signer-access-code=SignerAccessCode', 'AcceptTerms URL');
  Check(Fake.LastAuth = 'signer', 'AcceptTerms authentication');

  Response := Client.UploadSignatureImage('SignerAccessCode', FixtureFile, TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'UploadSignatureImage verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signature?search=Ana%20%26%20Joao&signer-access-code=SignerAccessCode', 'UploadSignatureImage URL');
  Check(Fake.LastAuth = 'signer', 'UploadSignatureImage authentication');
  Check(Fake.LastFile = FixtureFile, 'UploadSignatureImage file');

  Response := Client.DownloadSignatureImage('SignatureType', 'SignerAccessCode');
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'DownloadSignatureImage verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signature/SignatureType?signer-access-code=SignerAccessCode', 'DownloadSignatureImage URL');
  Check(Fake.LastAuth = 'signer', 'DownloadSignatureImage authentication');

  Response := Client.ListSignerDocuments('SignerId', 'SignerAccessCode', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListSignerDocuments verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signers/SignerId/documents?search=Ana%20%26%20Joao&signer-access-code=SignerAccessCode', 'ListSignerDocuments URL');
  Check(Fake.LastAuth = 'signer', 'ListSignerDocuments authentication');

  Response := Client.SearchSignerDocuments('SignerId', 'SignerAccessCode', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'SearchSignerDocuments verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/signers/SignerId/documents/search?search=Ana%20%26%20Joao&signer-access-code=SignerAccessCode', 'SearchSignerDocuments URL');
  Check(Fake.LastAuth = 'signer', 'SearchSignerDocuments authentication');

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
  Check(Fake.LastBody = TestBody.AsJSON, 'SocialLogin body');

  Response := Client.LinkSocialLogin(TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'LinkSocialLogin verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/auth/link-social-login', 'LinkSocialLogin URL');
  Check(Fake.LastAuth = 'bearer', 'LinkSocialLogin authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'LinkSocialLogin body');

  Response := Client.GetAccountStats('', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetAccountStats verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/stats?search=Ana%20%26%20Joao', 'GetAccountStats URL');
  Check(Fake.LastAuth = 'bearer', 'GetAccountStats authentication');

  Response := Client.GetUserStats(TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'GetUserStats verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/users/self/stats?search=Ana%20%26%20Joao', 'GetUserStats URL');
  Check(Fake.LastAuth = 'bearer', 'GetUserStats authentication');

  Response := Client.ListTags('', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListTags verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/tags?search=Ana%20%26%20Joao', 'ListTags URL');
  Check(Fake.LastAuth = 'bearer', 'ListTags authentication');

  Response := Client.CreateTag('', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'CreateTag verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/tags', 'CreateTag URL');
  Check(Fake.LastAuth = 'bearer', 'CreateTag authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'CreateTag body');

  Response := Client.UpdateTag('', 'TagId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'PUT', 'UpdateTag verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/tags/TagId', 'UpdateTag URL');
  Check(Fake.LastAuth = 'bearer', 'UpdateTag authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'UpdateTag body');

  Response := Client.DeleteTag('', 'TagId', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'DELETE', 'DeleteTag verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/tags/TagId?search=Ana%20%26%20Joao', 'DeleteTag URL');
  Check(Fake.LastAuth = 'bearer', 'DeleteTag authentication');

  Response := Client.ListTemplates('', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListTemplates verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/templates?search=Ana%20%26%20Joao', 'ListTemplates URL');
  Check(Fake.LastAuth = 'bearer', 'ListTemplates authentication');

  Response := Client.CreateDocumentFromTemplate('', 'TemplateId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'CreateDocumentFromTemplate verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/templates/TemplateId/documents', 'CreateDocumentFromTemplate URL');
  Check(Fake.LastAuth = 'bearer', 'CreateDocumentFromTemplate authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'CreateDocumentFromTemplate body');

  Response := Client.EstimateDocumentFromTemplateCost('', 'TemplateId', TestBody);
  Response.Free;
  Check(Fake.LastMethod = 'POST', 'EstimateDocumentFromTemplateCost verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/templates/TemplateId/documents/estimate-cost', 'EstimateDocumentFromTemplateCost URL');
  Check(Fake.LastAuth = 'bearer', 'EstimateDocumentFromTemplateCost authentication');
  Check(Fake.LastBody = TestBody.AsJSON, 'EstimateDocumentFromTemplateCost body');

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
  Check(Fake.LastBody = TestBody.AsJSON, 'CreateAPIKey body');

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
  Check(Fake.LastBody = TestBody.AsJSON, 'UpdateWebhookSubscription body');

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

  Response := Client.ListWebhookDeliveries('', TestQuery);
  Response.Free;
  Check(Fake.LastMethod = 'GET', 'ListWebhookDeliveries verb');
  Check(Fake.LastURL = 'https://sandbox.assinafy.com.br/v1/accounts/default-account/webhooks?search=Ana%20%26%20Joao', 'ListWebhookDeliveries URL');
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
  Check(Fake.LastBody = TestBody.AsJSON, 'CreateWebhookEndpoint body');

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
  Check(Fake.LastBody = TestBody.AsJSON, 'UpdateWebhookEndpoint body');

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
