    // GET /v1/accounts/{accountId}; payloads: docs/API.md#getaccount
    function GetAccount(const AAccountId: string): TAssinafyResponse;
    // PUT /v1/accounts/{accountId}; payloads: docs/API.md#updateaccount
    function UpdateAccount(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
    // DELETE /v1/accounts/{accountId}; payloads: docs/API.md#deleteaccount
    function DeleteAccount(const AAccountId: string; Body: TJSONData = nil): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/theme; payloads: docs/API.md#getaccounttheme
    function GetAccountTheme(const AAccountId: string): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/logo; payloads: docs/API.md#downloadaccountlogo
    function DownloadAccountLogo(const AAccountId: string): TAssinafyResponse;
    // POST /v1/accounts/{accountId}/logo; payloads: docs/API.md#uploadaccountlogo
    function UploadAccountLogo(const AAccountId: string; const FileName: string; const ContentType: string = 'application/octet-stream'): TAssinafyResponse;
    // DELETE /v1/accounts/{accountId}/logo; payloads: docs/API.md#deleteaccountlogo
    function DeleteAccountLogo(const AAccountId: string): TAssinafyResponse;
    // GET /v1/accounts; payloads: docs/API.md#listmyaccounts
    function ListMyAccounts: TAssinafyResponse;
    // POST /v1/accounts; payloads: docs/API.md#createaccount
    function CreateAccount(Body: TJSONData): TAssinafyResponse;
    // GET /v1/documents/{documentId}/activities; payloads: docs/API.md#listdocumentactivities
    function ListDocumentActivities(const DocumentId: string; Query: TStrings = nil): TAssinafyResponse;
    // GET /v1/assignments; payloads: docs/API.md#listassignments
    function ListAssignments(Query: TStrings = nil): TAssinafyResponse;
    // POST /v1/documents/{documentId}/assignments; payloads: docs/API.md#createassignment
    function CreateAssignment(const DocumentId: string; Body: TJSONData): TAssinafyResponse;
    // POST /v1/documents/{documentId}/assignments/estimate-cost; payloads: docs/API.md#estimateassignmentcost
    function EstimateAssignmentCost(const DocumentId: string; Body: TJSONData): TAssinafyResponse;
    // PUT /v1/documents/{documentId}/assignments/{assignmentId}/signers/{signerId}/resend; payloads: docs/API.md#resendsignaturerequest
    function ResendSignatureRequest(const DocumentId: string; const AssignmentId: string; const SignerId: string): TAssinafyResponse;
    // POST /v1/documents/{documentId}/assignments/{assignmentId}/signers/{signerId}/estimate-resend-cost; payloads: docs/API.md#estimateresendcost
    function EstimateResendCost(const DocumentId: string; const AssignmentId: string; const SignerId: string): TAssinafyResponse;
    // PUT /v1/documents/{documentId}/assignments/{assignmentId}/reset-expiration; payloads: docs/API.md#resetassignmentexpiration
    function ResetAssignmentExpiration(const DocumentId: string; const AssignmentId: string; Body: TJSONData): TAssinafyResponse;
    // GET /v1/documents/{documentId}/assignments/{assignmentId}/signers/{signerId}/identity-verification; payloads: docs/API.md#getsigneridentityreview
    function GetSignerIdentityReview(const DocumentId: string; const AssignmentId: string; const SignerId: string): TAssinafyResponse;
    // GET /v1/documents/{documentId}/assignments/{assignmentId}/signers/{signerId}/identity-verification/images/{name}; payloads: docs/API.md#downloadsigneridentityreviewimage
    function DownloadSignerIdentityReviewImage(const DocumentId: string; const AssignmentId: string; const SignerId: string; const Name: string): TAssinafyResponse;
    // POST /v1/documents/{documentId}/assignments/{assignmentId}/signers/{signerId}/identity-verification/review; payloads: docs/API.md#decidesigneridentityreview
    function DecideSignerIdentityReview(const DocumentId: string; const AssignmentId: string; const SignerId: string; Body: TJSONData): TAssinafyResponse;
    // POST /v1/login; payloads: docs/API.md#login
    function Login(Body: TJSONData): TAssinafyResponse;
    // PUT /v1/authentication/request-password-reset; payloads: docs/API.md#requestpasswordreset
    function RequestPasswordReset(Body: TJSONData): TAssinafyResponse;
    // PUT /v1/authentication/reset-password; payloads: docs/API.md#resetpassword
    function ResetPassword(Body: TJSONData): TAssinafyResponse;
    // PUT /v1/authentication/change-password; payloads: docs/API.md#changepassword
    function ChangePassword(Body: TJSONData): TAssinafyResponse;
    // POST /v1/authentication/mfa/verify; payloads: docs/API.md#completeatwofactorlogin
    function CompleteATwoFactorLogin(Body: TJSONData): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/contracts; payloads: docs/API.md#listcontracts
    function ListContracts(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/documents/{documentId}/contract; payloads: docs/API.md#getdocumentcontract
    function GetDocumentContract(const AAccountId: string; const DocumentId: string): TAssinafyResponse;
    // PUT /v1/accounts/{accountId}/documents/{documentId}/contract; payloads: docs/API.md#setdocumentcontract
    function SetDocumentContract(const AAccountId: string; const DocumentId: string; Body: TJSONData): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/documents/{documentId}/contract/related; payloads: docs/API.md#listrelateddocumentcontracts
    function ListRelatedDocumentContracts(const AAccountId: string; const DocumentId: string): TAssinafyResponse;
    // POST /v1/accounts/{accountId}/documents/{documentId}/contract/renew; payloads: docs/API.md#renewdocumentcontract
    function RenewDocumentContract(const AAccountId: string; const DocumentId: string; Body: TJSONData = nil): TAssinafyResponse;
    // POST /v1/accounts/{accountId}/documents/{documentId}/contract/terminate; payloads: docs/API.md#terminatedocumentcontract
    function TerminateDocumentContract(const AAccountId: string; const DocumentId: string; Body: TJSONData = nil): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/documents; payloads: docs/API.md#listdocuments
    function ListDocuments(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
    // POST /v1/accounts/{accountId}/documents; payloads: docs/API.md#uploaddocument
    function UploadDocument(const AAccountId: string; const FileName: string): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/documents/search; payloads: docs/API.md#searchdocuments
    function SearchDocuments(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
    // GET /v1/documents/statuses; payloads: docs/API.md#listdocumentstatuses
    function ListDocumentStatuses: TAssinafyResponse;
    // GET /v1/documents/{documentId}; payloads: docs/API.md#getdocument
    function GetDocument(const DocumentId: string): TAssinafyResponse;
    // DELETE /v1/documents/{documentId}; payloads: docs/API.md#deletedocument
    function DeleteDocument(const DocumentId: string): TAssinafyResponse;
    // PATCH /v1/documents/{documentId}; payloads: docs/API.md#renamedocument
    function RenameDocument(const DocumentId: string; Body: TJSONData): TAssinafyResponse;
    // GET /v1/documents/{documentId}/download/{artifactName}; payloads: docs/API.md#downloaddocumentartifact
    function DownloadDocumentArtifact(const DocumentId: string; const ArtifactName: string): TAssinafyResponse;
    // GET /v1/documents/{documentSignatureHash}/verify; payloads: docs/API.md#verifyasigneddocument
    function VerifyASignedDocument(const DocumentSignatureHash: string): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/documents/{documentId}/tags; payloads: docs/API.md#listdocumenttags
    function ListDocumentTags(const AAccountId: string; const DocumentId: string): TAssinafyResponse;
    // PUT /v1/accounts/{accountId}/documents/{documentId}/tags; payloads: docs/API.md#replacedocumenttags
    function ReplaceDocumentTags(const AAccountId: string; const DocumentId: string; Body: TJSONData): TAssinafyResponse;
    // POST /v1/accounts/{accountId}/documents/{documentId}/tags; payloads: docs/API.md#attachdocumenttags
    function AttachDocumentTags(const AAccountId: string; const DocumentId: string; Body: TJSONData): TAssinafyResponse;
    // DELETE /v1/accounts/{accountId}/documents/{documentId}/tags/{tagId}; payloads: docs/API.md#detachdocumenttag
    function DetachDocumentTag(const AAccountId: string; const DocumentId: string; const TagId: string): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/fields; payloads: docs/API.md#listfields
    function ListFields(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
    // POST /v1/accounts/{accountId}/fields; payloads: docs/API.md#createfield
    function CreateField(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/fields/{fieldId}; payloads: docs/API.md#getfield
    function GetField(const AAccountId: string; const FieldId: string): TAssinafyResponse;
    // PUT /v1/accounts/{accountId}/fields/{fieldId}; payloads: docs/API.md#updatefield
    function UpdateField(const AAccountId: string; const FieldId: string; Body: TJSONData): TAssinafyResponse;
    // DELETE /v1/accounts/{accountId}/fields/{fieldId}; payloads: docs/API.md#deletefield
    function DeleteField(const AAccountId: string; const FieldId: string): TAssinafyResponse;
    // POST /v1/accounts/{accountId}/fields/{fieldId}/validate; payloads: docs/API.md#validatefieldvalue
    function ValidateFieldValue(const AAccountId: string; const FieldId: string; Body: TJSONData): TAssinafyResponse;
    // POST /v1/accounts/{accountId}/fields/validate-multiple; payloads: docs/API.md#validatemultiplefieldvalues
    function ValidateMultipleFieldValues(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
    // GET /v1/field-types; payloads: docs/API.md#listfieldtypes
    function ListFieldTypes: TAssinafyResponse;
    // GET /v1/users/self/mfa; payloads: docs/API.md#listtwofactormethods
    function ListTwoFactorMethods: TAssinafyResponse;
    // POST /v1/users/self/mfa/totp; payloads: docs/API.md#startauthenticatorenrollment
    function StartAuthenticatorEnrollment(Body: TJSONData = nil): TAssinafyResponse;
    // PUT /v1/users/self/mfa/totp/confirm; payloads: docs/API.md#confirmauthenticatorenrollment
    function ConfirmAuthenticatorEnrollment(Body: TJSONData): TAssinafyResponse;
    // POST /v1/users/self/mfa/recovery-codes; payloads: docs/API.md#regeneraterecoverycodes
    function RegenerateRecoveryCodes(Body: TJSONData): TAssinafyResponse;
    // DELETE /v1/users/self/mfa/{customId}; payloads: docs/API.md#removeatwofactormethod
    function RemoveATwoFactorMethod(const CustomId: string; Body: TJSONData): TAssinafyResponse;
    // GET /v1/users/self/notification-preferences; payloads: docs/API.md#getmynotificationpreferences
    function GetMyNotificationPreferences: TAssinafyResponse;
    // PUT /v1/users/self/notification-preferences; payloads: docs/API.md#updatemynotificationpreferences
    function UpdateMyNotificationPreferences(Body: TJSONData): TAssinafyResponse;
    // POST /v1/oauth/token; payloads: docs/API.md#exchangeoauthtoken
    function ExchangeOAuthToken(Body: TJSONData): TAssinafyResponse;
    // POST /v1/oauth/revoke; payloads: docs/API.md#revokeoauthtoken
    function RevokeOAuthToken(Body: TJSONData): TAssinafyResponse;
    // GET /v1/oauth/userinfo; payloads: docs/API.md#getoauthuserinfo
    function GetOAuthUserInfo: TAssinafyResponse;
    // GET /v1/documents/{documentId}/thumbnail; payloads: docs/API.md#downloaddocumentthumbnail
    function DownloadDocumentThumbnail(const DocumentId: string): TAssinafyResponse;
    // GET /v1/documents/{documentId}/pages/{pageId}/download; payloads: docs/API.md#downloaddocumentpage
    function DownloadDocumentPage(const DocumentId: string; const PageId: string): TAssinafyResponse;
    // GET /v1/public/documents/{documentId}; payloads: docs/API.md#viewpublicdocument
    function ViewPublicDocument(const DocumentId: string): TAssinafyResponse;
    // PUT /v1/public/documents/{documentId}/send-token; payloads: docs/API.md#sendaccesstokenforpublicdocument
    function SendAccessTokenForPublicDocument(const DocumentId: string; Body: TJSONData): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/signers; payloads: docs/API.md#listsigners
    function ListSigners(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
    // POST /v1/accounts/{accountId}/signers; payloads: docs/API.md#createsigner
    function CreateSigner(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/signers/{signerId}; payloads: docs/API.md#getsigner
    function GetSigner(const AAccountId: string; const SignerId: string): TAssinafyResponse;
    // PUT /v1/accounts/{accountId}/signers/{signerId}; payloads: docs/API.md#updatesigner
    function UpdateSigner(const AAccountId: string; const SignerId: string; Body: TJSONData): TAssinafyResponse;
    // DELETE /v1/accounts/{accountId}/signers/{signerId}; payloads: docs/API.md#deletesigner
    function DeleteSigner(const AAccountId: string; const SignerId: string): TAssinafyResponse;
    // GET /v1/signers/self; payloads: docs/API.md#getcurrentsigner
    function GetCurrentSigner(const SignerAccessCode: string): TAssinafyResponse;
    // GET /v1/signers/identity-verification; payloads: docs/API.md#getidentityverificationstatus
    function GetIdentityVerificationStatus(const SignerAccessCode: string): TAssinafyResponse;
    // POST /v1/signers/identity-verification; payloads: docs/API.md#startidentityverification
    function StartIdentityVerification(const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
    // GET /v1/signers/{signerId}/document; payloads: docs/API.md#getsignerdocument
    function GetSignerDocument(const SignerId: string; const SignerAccessCode: string): TAssinafyResponse;
    // GET /v1/sign; payloads: docs/API.md#viewdocumenttosign
    function ViewDocumentToSign(const SignerAccessCode: string; Query: TStrings = nil): TAssinafyResponse;
    // POST /v1/documents/{documentId}/assignments/{assignmentId}; payloads: docs/API.md#signassignmentitems
    function SignAssignmentItems(const DocumentId: string; const AssignmentId: string; const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
    // PUT /v1/documents/{documentId}/assignments/{assignmentId}/reject; payloads: docs/API.md#rejectassignment
    function RejectAssignment(const DocumentId: string; const AssignmentId: string; const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
    // PUT /v1/signers/documents/sign-multiple; payloads: docs/API.md#signmultipledocuments
    function SignMultipleDocuments(const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
    // PUT /v1/signers/documents/decline-multiple; payloads: docs/API.md#declinemultipledocuments
    function DeclineMultipleDocuments(const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
    // POST /v1/verify; payloads: docs/API.md#verifysignercode
    function VerifySignerCode(const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
    // PUT /v1/documents/{documentId}/signers/confirm-data; payloads: docs/API.md#confirmsignerdata
    function ConfirmSignerData(const DocumentId: string; const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
    // PUT /v1/signers/accept-terms; payloads: docs/API.md#acceptterms
    function AcceptTerms(const SignerAccessCode: string): TAssinafyResponse;
    // POST /v1/signature; payloads: docs/API.md#uploadsignatureimage
    function UploadSignatureImage(const SignerAccessCode: string; const FileName: string; Query: TStrings = nil): TAssinafyResponse;
    // GET /v1/signature/{signatureType}; payloads: docs/API.md#downloadsignatureimage
    function DownloadSignatureImage(const SignatureType: string; const SignerAccessCode: string): TAssinafyResponse;
    // GET /v1/signers/{signerId}/documents; payloads: docs/API.md#listsignerdocuments
    function ListSignerDocuments(const SignerId: string; const SignerAccessCode: string = ''; Query: TStrings = nil): TAssinafyResponse;
    // GET /v1/signers/{signerId}/documents (workspace credentials); payloads: docs/API.md#listsignerdocumentsasworkspace
    function ListSignerDocumentsAsWorkspace(const SignerId: string; Query: TStrings = nil): TAssinafyResponse;
    // GET /v1/signers/{signerId}/documents/search; payloads: docs/API.md#searchsignerdocuments
    function SearchSignerDocuments(const SignerId: string; const SignerAccessCode: string = ''; Query: TStrings = nil): TAssinafyResponse;
    // GET /v1/signers/{signerId}/documents/search (workspace credentials); payloads: docs/API.md#searchsignerdocumentsasworkspace
    function SearchSignerDocumentsAsWorkspace(const SignerId: string; Query: TStrings = nil): TAssinafyResponse;
    // GET /v1/signers/{signerId}/documents/{documentId}/download/{artifactName}; payloads: docs/API.md#downloadsignerdocumentartifact
    function DownloadSignerDocumentArtifact(const SignerId: string; const DocumentId: string; const ArtifactName: string): TAssinafyResponse;
    // POST /v1/authentication/social-login; payloads: docs/API.md#sociallogin
    function SocialLogin(Body: TJSONData): TAssinafyResponse;
    // POST /v1/auth/link-social-login; payloads: docs/API.md#linksociallogin
    function LinkSocialLogin(Body: TJSONData): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/stats; payloads: docs/API.md#getaccountstats
    function GetAccountStats(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
    // GET /v1/users/self/stats; payloads: docs/API.md#getuserstats
    function GetUserStats(Query: TStrings = nil): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/tags; payloads: docs/API.md#listtags
    function ListTags(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
    // POST /v1/accounts/{accountId}/tags; payloads: docs/API.md#createtag
    function CreateTag(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
    // PUT /v1/accounts/{accountId}/tags/{tagId}; payloads: docs/API.md#updatetag
    function UpdateTag(const AAccountId: string; const TagId: string; Body: TJSONData): TAssinafyResponse;
    // DELETE /v1/accounts/{accountId}/tags/{tagId}; payloads: docs/API.md#deletetag
    function DeleteTag(const AAccountId: string; const TagId: string; Query: TStrings = nil): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/templates; payloads: docs/API.md#listtemplates
    function ListTemplates(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
    // POST /v1/accounts/{accountId}/templates/{templateId}/documents; payloads: docs/API.md#createdocumentfromtemplate
    function CreateDocumentFromTemplate(const AAccountId: string; const TemplateId: string; Body: TJSONData): TAssinafyResponse;
    // POST /v1/accounts/{accountId}/templates/{templateId}/documents/estimate-cost; payloads: docs/API.md#estimatedocumentfromtemplatecost
    function EstimateDocumentFromTemplateCost(const AAccountId: string; const TemplateId: string; Body: TJSONData): TAssinafyResponse;
    // GET /v1/users/self; payloads: docs/API.md#getuser
    function GetUser: TAssinafyResponse;
    // GET /v1/users/api-keys; payloads: docs/API.md#getapikey
    function GetAPIKey: TAssinafyResponse;
    // POST /v1/users/api-keys; payloads: docs/API.md#createapikey
    function CreateAPIKey(Body: TJSONData): TAssinafyResponse;
    // DELETE /v1/users/api-keys; payloads: docs/API.md#deleteapikey
    function DeleteAPIKey: TAssinafyResponse;
    // GET /v1/accounts/{accountId}/webhooks/subscriptions; payloads: docs/API.md#getwebhooksubscription
    function GetWebhookSubscription(const AAccountId: string): TAssinafyResponse;
    // PUT /v1/accounts/{accountId}/webhooks/subscriptions; payloads: docs/API.md#updatewebhooksubscription
    function UpdateWebhookSubscription(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
    // PUT /v1/accounts/{accountId}/webhooks/inactivate; payloads: docs/API.md#inactivatewebhooksubscription
    function InactivateWebhookSubscription(const AAccountId: string): TAssinafyResponse;
    // GET /v1/webhooks/event-types; payloads: docs/API.md#listwebhookeventtypes
    function ListWebhookEventTypes: TAssinafyResponse;
    // GET /v1/accounts/{accountId}/webhooks; payloads: docs/API.md#listwebhookdeliveries
    function ListWebhookDeliveries(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
    // POST /v1/accounts/{accountId}/webhooks/{historyId}/retry; payloads: docs/API.md#retrywebhookdelivery
    function RetryWebhookDelivery(const AAccountId: string; const HistoryId: string): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/webhooks/endpoints; payloads: docs/API.md#listwebhookendpoints
    function ListWebhookEndpoints(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
    // POST /v1/accounts/{accountId}/webhooks/endpoints; payloads: docs/API.md#createwebhookendpoint
    function CreateWebhookEndpoint(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
    // DELETE /v1/accounts/{accountId}/webhooks/endpoints; payloads: docs/API.md#deletewebhookendpointbyurl
    function DeleteWebhookEndpointByURL(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/webhooks/endpoints/{endpointId}; payloads: docs/API.md#getwebhookendpoint
    function GetWebhookEndpoint(const AAccountId: string; const EndpointId: string): TAssinafyResponse;
    // PUT /v1/accounts/{accountId}/webhooks/endpoints/{endpointId}; payloads: docs/API.md#updatewebhookendpoint
    function UpdateWebhookEndpoint(const AAccountId: string; const EndpointId: string; Body: TJSONData): TAssinafyResponse;
    // DELETE /v1/accounts/{accountId}/webhooks/endpoints/{endpointId}; payloads: docs/API.md#deletewebhookendpoint
    function DeleteWebhookEndpoint(const AAccountId: string; const EndpointId: string): TAssinafyResponse;
    // GET /v1/accounts/{accountId}/webhooks/endpoints/{endpointId}/secret; payloads: docs/API.md#getwebhookendpointsigningsecret
    function GetWebhookEndpointSigningSecret(const AAccountId: string; const EndpointId: string): TAssinafyResponse;
    // POST /v1/accounts/{accountId}/webhooks/endpoints/{endpointId}/secret/rotate; payloads: docs/API.md#rotatewebhookendpointsigningsecret
    function RotateWebhookEndpointSigningSecret(const AAccountId: string; const EndpointId: string): TAssinafyResponse;
    // GET /.well-known/oauth-protected-resource; payloads: docs/API.md#getoauthresourcemetadata
    function GetOAuthResourceMetadata: TAssinafyResponse;
    // GET /v1/documents/{documentId}/assignments/{assignmentId}/whatsapp-notifications; payloads: docs/API.md#listwhatsappnotifications
    function ListWhatsAppNotifications(const DocumentId: string; const AssignmentId: string): TAssinafyResponse;
