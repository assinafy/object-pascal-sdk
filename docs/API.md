# API reference

Contract: [Assinafy API v1](https://api.assinafy.com.br/v1/docs) and [OpenAPI](https://api.assinafy.com.br/v1/docs/openapi.json).

The client exposes all 106 published operations. Each method below links its request, response, authentication, and status codes to the bundled [contract](openapi.json). Shared response models are fully defined in [Schemas](SCHEMAS.md).

## Ownership and payloads

Every call returns a caller-owned `TAssinafyResponse`; free it in `finally`. `Response.JSON` contains the entire wire response; `Response.Data` refers to the envelope’s `data`, or the entire flat OAuth response. Both are borrowed until `Response.Free`. Requests borrow `Body` and `Query`; the caller frees them. Empty account IDs use the client’s configured account. Other path parameters are required and percent-encoded.

`Query` is a `TStrings` of decoded `name=value` pairs; use the exact API field names. The SDK percent-encodes names and values, preserving duplicates and empty values. Send JSON booleans, arrays, numbers and explicit nulls using `AssinafyJson` helpers or the compiler’s native JSON classes. Binary response bytes remain in `Response.Body`; use `Response.SaveToStream` to write them after a successful request.

Payload examples show the documented fields, including optional fields. They illustrate shapes; follow each schema’s `required`, `enum`, constraints and descriptions when constructing an actual request. Placeholder values and mutually exclusive variants must be replaced with valid values. `{}` denotes an open object whose fields the API does not specify.

## Operations

| Method | HTTP operation |
| --- | --- |
| [GetAccount](#getaccount) | `GET /v1/accounts/{accountId}` |
| [UpdateAccount](#updateaccount) | `PUT /v1/accounts/{accountId}` |
| [DeleteAccount](#deleteaccount) | `DELETE /v1/accounts/{accountId}` |
| [GetAccountTheme](#getaccounttheme) | `GET /v1/accounts/{accountId}/theme` |
| [DownloadAccountLogo](#downloadaccountlogo) | `GET /v1/accounts/{accountId}/logo` |
| [UploadAccountLogo](#uploadaccountlogo) | `POST /v1/accounts/{accountId}/logo` |
| [DeleteAccountLogo](#deleteaccountlogo) | `DELETE /v1/accounts/{accountId}/logo` |
| [ListMyAccounts](#listmyaccounts) | `GET /v1/accounts` |
| [CreateAccount](#createaccount) | `POST /v1/accounts` |
| [ListDocumentActivities](#listdocumentactivities) | `GET /v1/documents/{documentId}/activities` |
| [ListAssignments](#listassignments) | `GET /v1/assignments` |
| [CreateAssignment](#createassignment) | `POST /v1/documents/{documentId}/assignments` |
| [EstimateAssignmentCost](#estimateassignmentcost) | `POST /v1/documents/{documentId}/assignments/estimate-cost` |
| [ResendSignatureRequest](#resendsignaturerequest) | `PUT /v1/documents/{documentId}/assignments/{assignmentId}/signers/{signerId}/resend` |
| [EstimateResendCost](#estimateresendcost) | `POST /v1/documents/{documentId}/assignments/{assignmentId}/signers/{signerId}/estimate-resend-cost` |
| [ResetAssignmentExpiration](#resetassignmentexpiration) | `PUT /v1/documents/{documentId}/assignments/{assignmentId}/reset-expiration` |
| [Login](#login) | `POST /v1/login` |
| [RequestPasswordReset](#requestpasswordreset) | `PUT /v1/authentication/request-password-reset` |
| [ResetPassword](#resetpassword) | `PUT /v1/authentication/reset-password` |
| [ChangePassword](#changepassword) | `PUT /v1/authentication/change-password` |
| [CompleteATwoFactorLogin](#completeatwofactorlogin) | `POST /v1/authentication/mfa/verify` |
| [ListDocuments](#listdocuments) | `GET /v1/accounts/{accountId}/documents` |
| [UploadDocument](#uploaddocument) | `POST /v1/accounts/{accountId}/documents` |
| [SearchDocuments](#searchdocuments) | `GET /v1/accounts/{accountId}/documents/search` |
| [ListDocumentStatuses](#listdocumentstatuses) | `GET /v1/documents/statuses` |
| [GetDocument](#getdocument) | `GET /v1/documents/{documentId}` |
| [DeleteDocument](#deletedocument) | `DELETE /v1/documents/{documentId}` |
| [RenameDocument](#renamedocument) | `PATCH /v1/documents/{documentId}` |
| [DownloadDocumentArtifact](#downloaddocumentartifact) | `GET /v1/documents/{documentId}/download/{artifactName}` |
| [VerifyASignedDocument](#verifyasigneddocument) | `GET /v1/documents/{documentSignatureHash}/verify` |
| [ListDocumentTags](#listdocumenttags) | `GET /v1/accounts/{accountId}/documents/{documentId}/tags` |
| [ReplaceDocumentTags](#replacedocumenttags) | `PUT /v1/accounts/{accountId}/documents/{documentId}/tags` |
| [AttachDocumentTags](#attachdocumenttags) | `POST /v1/accounts/{accountId}/documents/{documentId}/tags` |
| [DetachDocumentTag](#detachdocumenttag) | `DELETE /v1/accounts/{accountId}/documents/{documentId}/tags/{tagId}` |
| [ListFields](#listfields) | `GET /v1/accounts/{accountId}/fields` |
| [CreateField](#createfield) | `POST /v1/accounts/{accountId}/fields` |
| [GetField](#getfield) | `GET /v1/accounts/{accountId}/fields/{fieldId}` |
| [UpdateField](#updatefield) | `PUT /v1/accounts/{accountId}/fields/{fieldId}` |
| [DeleteField](#deletefield) | `DELETE /v1/accounts/{accountId}/fields/{fieldId}` |
| [ValidateFieldValue](#validatefieldvalue) | `POST /v1/accounts/{accountId}/fields/{fieldId}/validate` |
| [ValidateMultipleFieldValues](#validatemultiplefieldvalues) | `POST /v1/accounts/{accountId}/fields/validate-multiple` |
| [ListFieldTypes](#listfieldtypes) | `GET /v1/field-types` |
| [ListTwoFactorMethods](#listtwofactormethods) | `GET /v1/users/self/mfa` |
| [StartAuthenticatorEnrollment](#startauthenticatorenrollment) | `POST /v1/users/self/mfa/totp` |
| [ConfirmAuthenticatorEnrollment](#confirmauthenticatorenrollment) | `PUT /v1/users/self/mfa/totp/confirm` |
| [RegenerateRecoveryCodes](#regeneraterecoverycodes) | `POST /v1/users/self/mfa/recovery-codes` |
| [RemoveATwoFactorMethod](#removeatwofactormethod) | `DELETE /v1/users/self/mfa/{customId}` |
| [GetMyNotificationPreferences](#getmynotificationpreferences) | `GET /v1/users/self/notification-preferences` |
| [UpdateMyNotificationPreferences](#updatemynotificationpreferences) | `PUT /v1/users/self/notification-preferences` |
| [ExchangeOAuthToken](#exchangeoauthtoken) | `POST /v1/oauth/token` |
| [RevokeOAuthToken](#revokeoauthtoken) | `POST /v1/oauth/revoke` |
| [GetOAuthUserInfo](#getoauthuserinfo) | `GET /v1/oauth/userinfo` |
| [DownloadDocumentThumbnail](#downloaddocumentthumbnail) | `GET /v1/documents/{documentId}/thumbnail` |
| [DownloadDocumentPage](#downloaddocumentpage) | `GET /v1/documents/{documentId}/pages/{pageId}/download` |
| [ViewPublicDocument](#viewpublicdocument) | `GET /v1/public/documents/{documentId}` |
| [SendAccessTokenForPublicDocument](#sendaccesstokenforpublicdocument) | `PUT /v1/public/documents/{documentId}/send-token` |
| [ListSigners](#listsigners) | `GET /v1/accounts/{accountId}/signers` |
| [CreateSigner](#createsigner) | `POST /v1/accounts/{accountId}/signers` |
| [GetSigner](#getsigner) | `GET /v1/accounts/{accountId}/signers/{signerId}` |
| [UpdateSigner](#updatesigner) | `PUT /v1/accounts/{accountId}/signers/{signerId}` |
| [DeleteSigner](#deletesigner) | `DELETE /v1/accounts/{accountId}/signers/{signerId}` |
| [GetCurrentSigner](#getcurrentsigner) | `GET /v1/signers/self` |
| [GetSignerDocument](#getsignerdocument) | `GET /v1/signers/{signerId}/document` |
| [ViewDocumentToSign](#viewdocumenttosign) | `GET /v1/sign` |
| [SignAssignmentItems](#signassignmentitems) | `POST /v1/documents/{documentId}/assignments/{assignmentId}` |
| [RejectAssignment](#rejectassignment) | `PUT /v1/documents/{documentId}/assignments/{assignmentId}/reject` |
| [SignMultipleDocuments](#signmultipledocuments) | `PUT /v1/signers/documents/sign-multiple` |
| [DeclineMultipleDocuments](#declinemultipledocuments) | `PUT /v1/signers/documents/decline-multiple` |
| [VerifySignerCode](#verifysignercode) | `POST /v1/verify` |
| [ConfirmSignerData](#confirmsignerdata) | `PUT /v1/documents/{documentId}/signers/confirm-data` |
| [AcceptTerms](#acceptterms) | `PUT /v1/signers/accept-terms` |
| [UploadSignatureImage](#uploadsignatureimage) | `POST /v1/signature` |
| [DownloadSignatureImage](#downloadsignatureimage) | `GET /v1/signature/{signatureType}` |
| [ListSignerDocuments](#listsignerdocuments) | `GET /v1/signers/{signerId}/documents` |
| [ListSignerDocumentsAsWorkspace](#listsignerdocumentsasworkspace) | `GET /v1/signers/{signerId}/documents` |
| [SearchSignerDocuments](#searchsignerdocuments) | `GET /v1/signers/{signerId}/documents/search` |
| [SearchSignerDocumentsAsWorkspace](#searchsignerdocumentsasworkspace) | `GET /v1/signers/{signerId}/documents/search` |
| [DownloadSignerDocumentArtifact](#downloadsignerdocumentartifact) | `GET /v1/signers/{signerId}/documents/{documentId}/download/{artifactName}` |
| [SocialLogin](#sociallogin) | `POST /v1/authentication/social-login` |
| [LinkSocialLogin](#linksociallogin) | `POST /v1/auth/link-social-login` |
| [GetAccountStats](#getaccountstats) | `GET /v1/accounts/{accountId}/stats` |
| [GetUserStats](#getuserstats) | `GET /v1/users/self/stats` |
| [ListTags](#listtags) | `GET /v1/accounts/{accountId}/tags` |
| [CreateTag](#createtag) | `POST /v1/accounts/{accountId}/tags` |
| [UpdateTag](#updatetag) | `PUT /v1/accounts/{accountId}/tags/{tagId}` |
| [DeleteTag](#deletetag) | `DELETE /v1/accounts/{accountId}/tags/{tagId}` |
| [ListTemplates](#listtemplates) | `GET /v1/accounts/{accountId}/templates` |
| [CreateDocumentFromTemplate](#createdocumentfromtemplate) | `POST /v1/accounts/{accountId}/templates/{templateId}/documents` |
| [EstimateDocumentFromTemplateCost](#estimatedocumentfromtemplatecost) | `POST /v1/accounts/{accountId}/templates/{templateId}/documents/estimate-cost` |
| [GetUser](#getuser) | `GET /v1/users/self` |
| [GetAPIKey](#getapikey) | `GET /v1/users/api-keys` |
| [CreateAPIKey](#createapikey) | `POST /v1/users/api-keys` |
| [DeleteAPIKey](#deleteapikey) | `DELETE /v1/users/api-keys` |
| [GetWebhookSubscription](#getwebhooksubscription) | `GET /v1/accounts/{accountId}/webhooks/subscriptions` |
| [UpdateWebhookSubscription](#updatewebhooksubscription) | `PUT /v1/accounts/{accountId}/webhooks/subscriptions` |
| [InactivateWebhookSubscription](#inactivatewebhooksubscription) | `PUT /v1/accounts/{accountId}/webhooks/inactivate` |
| [ListWebhookEventTypes](#listwebhookeventtypes) | `GET /v1/webhooks/event-types` |
| [ListWebhookDeliveries](#listwebhookdeliveries) | `GET /v1/accounts/{accountId}/webhooks` |
| [RetryWebhookDelivery](#retrywebhookdelivery) | `POST /v1/accounts/{accountId}/webhooks/{historyId}/retry` |
| [ListWebhookEndpoints](#listwebhookendpoints) | `GET /v1/accounts/{accountId}/webhooks/endpoints` |
| [CreateWebhookEndpoint](#createwebhookendpoint) | `POST /v1/accounts/{accountId}/webhooks/endpoints` |
| [GetWebhookEndpoint](#getwebhookendpoint) | `GET /v1/accounts/{accountId}/webhooks/endpoints/{endpointId}` |
| [UpdateWebhookEndpoint](#updatewebhookendpoint) | `PUT /v1/accounts/{accountId}/webhooks/endpoints/{endpointId}` |
| [DeleteWebhookEndpoint](#deletewebhookendpoint) | `DELETE /v1/accounts/{accountId}/webhooks/endpoints/{endpointId}` |
| [GetWebhookEndpointSigningSecret](#getwebhookendpointsigningsecret) | `GET /v1/accounts/{accountId}/webhooks/endpoints/{endpointId}/secret` |
| [RotateWebhookEndpointSigningSecret](#rotatewebhookendpointsigningsecret) | `POST /v1/accounts/{accountId}/webhooks/endpoints/{endpointId}/secret/rotate` |
| [GetOAuthResourceMetadata](#getoauthresourcemetadata) | `GET /.well-known/oauth-protected-resource` |
| [ListWhatsAppNotifications](#listwhatsappnotifications) | `GET /v1/documents/{documentId}/assignments/{assignmentId}/whatsapp-notifications` |

## GetAccount

```pascal
function GetAccount(const AAccountId: string): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}`

Retrieve a workspace account the user belongs to.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The account

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Account"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "account",
    "id": "6401df46d6a6b0c692d9ec49",
    "name": "Acme Inc.",
    "primary_color": "aabbcc",
    "secondary_color": "112233",
    "notification_sender_type": "User",
    "roles": [
      "owner"
    ],
    "is_delete_allowed": true,
    "created_at": "2026-06-03T03:54:16Z"
  }
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## UpdateAccount

```pascal
function UpdateAccount(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/accounts/{accountId}`

Update a workspace account's profile.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "properties": {
    "name": {
      "type": "string",
      "example": "Acme Inc."
    },
    "notification_sender_type": {
      "description": "Who signers see as the notification sender for documents in this account. `User` (default) shows the document owner's name; `Account` shows this account's name.",
      "type": "string",
      "enum": [
        "User",
        "Account"
      ],
      "example": "Account"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "name": "Acme Inc.",
  "notification_sender_type": "Account"
}
```


**Response `200`:** The updated account

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Account"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "account",
    "id": "6401df46d6a6b0c692d9ec49",
    "name": "Acme Inc.",
    "primary_color": "aabbcc",
    "secondary_color": "112233",
    "notification_sender_type": "User",
    "roles": [
      "owner"
    ],
    "is_delete_allowed": true,
    "created_at": "2026-06-03T03:54:16Z"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## DeleteAccount

```pascal
function DeleteAccount(const AAccountId: string; Body: TJSONData = nil): TAssinafyResponse;
```

`DELETE /v1/accounts/{accountId}`

Delete a workspace account.

By default the request fails with `400` when the workspace has an active paid subscription — the `restrictions` array in the response lists each blocker by code so you can address them individually before retrying. Pass `force: true` to cancel any active paid subscription automatically and proceed with immediate deletion.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (optional)**

```json
{
  "properties": {
    "force": {
      "description": "When `true`, cancels any active paid subscription on this workspace and proceeds with deletion immediately. Defaults to `false`.",
      "type": "boolean",
      "example": false
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "force": false
}
```


**Response `200`:** Account deleted

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": [],
          "example": []
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": []
}
```


**Response `400`:** Deletion blocked by active restrictions. Each `restrictions` entry describes one blocker; resolve them individually, or retry with `force: true` to cancel blocking subscriptions/documents automatically.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 400
        },
        "message": {
          "type": "string",
          "example": "Cannot delete while restrictions are active."
        },
        "restrictions": {
          "type": "array",
          "items": {
            "properties": {
              "code": {
                "description": "Machine-readable restriction code. `PendingDocuments` only appears together with `ActivePaidSubscription`, never alone.",
                "type": "string",
                "enum": [
                  "ActivePaidSubscription",
                  "PendingDocuments"
                ],
                "example": "ActivePaidSubscription"
              },
              "message": {
                "type": "string",
                "example": "Account has an active paid subscription."
              },
              "account_ids": {
                "description": "IDs of the accounts affected by this restriction.",
                "type": "array",
                "items": {
                  "type": "string"
                },
                "example": [
                  "vmvk6Urzus3byLD2qO"
                ]
              }
            },
            "type": "object"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 400,
  "message": "Cannot delete while restrictions are active.",
  "data": null,
  "restrictions": [
    {
      "code": "ActivePaidSubscription",
      "message": "Account has an active paid subscription.",
      "account_ids": [
        "vmvk6Urzus3byLD2qO"
      ]
    }
  ]
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## GetAccountTheme

```pascal
function GetAccountTheme(const AAccountId: string): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/theme`

Retrieve account theme information (branding name, colors, and logo URL).

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The theme

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/AccountTheme"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "account_name": "Account Name",
    "primary_color": "aabbcc",
    "secondary_color": "aabbcc",
    "logo": "https://api.assinafy.com.br/v1/accounts/1a/logo"
  }
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## DownloadAccountLogo

```pascal
function DownloadAccountLogo(const AAccountId: string): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/logo`

Download the account logo image binary.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The logo image

Content type: `image/*`

```json
{
  "type": "string",
  "format": "binary"
}
```

Raw binary bytes; preserved without JSON decoding.

**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## UploadAccountLogo

```pascal
function UploadAccountLogo(const AAccountId: string; const FileName: string; const ContentType: string = 'application/octet-stream'): TAssinafyResponse;
```

`POST /v1/accounts/{accountId}/logo`

Upload or replace the account logo image.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

`ContentType` is an optional SDK parameter for the file part media type (for example `image/png` or `image/jpeg`); the default is `application/octet-stream`. It does not add a JSON field.

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request: `multipart/form-data` (required)**

```json
{
  "required": [
    "file"
  ],
  "properties": {
    "file": {
      "type": "string",
      "format": "binary"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "file": "<binary bytes>"
}
```


**Response `200`:** Logo updated

Content type: `application/json`

```json
{
  "$ref": "#/components/schemas/Envelope"
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": ""
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## DeleteAccountLogo

```pascal
function DeleteAccountLogo(const AAccountId: string): TAssinafyResponse;
```

`DELETE /v1/accounts/{accountId}/logo`

Remove the account logo image.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** Logo deleted

Content type: `application/json`

```json
{
  "$ref": "#/components/schemas/Envelope"
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": ""
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListMyAccounts

```pascal
function ListMyAccounts: TAssinafyResponse;
```

`GET /v1/accounts`

List the workspace accounts the authenticated user belongs to.

Called with an OAuth application token, this returns exactly one workspace: the one the user chose when they authorized the application. Use its `id` as the `{accountId}` segment of every other endpoint — a token is bound to a single workspace, and any request naming a different one is refused. This endpoint needs no particular scope.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request body:** none.

**Response `200`:** The user's accounts

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/Account"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "resource": "account",
      "id": "6401df46d6a6b0c692d9ec49",
      "name": "Acme Inc.",
      "primary_color": "aabbcc",
      "secondary_color": "112233",
      "notification_sender_type": "User",
      "roles": [
        "owner"
      ],
      "is_delete_allowed": true,
      "created_at": "2026-06-03T03:54:16Z"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## CreateAccount

```pascal
function CreateAccount(Body: TJSONData): TAssinafyResponse;
```

`POST /v1/accounts`

Create a new workspace account owned by the authenticated user.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request: `application/json` (required)**

```json
{
  "required": [
    "name"
  ],
  "properties": {
    "name": {
      "type": "string",
      "example": "Acme Inc."
    },
    "notification_sender_type": {
      "description": "Who signers see as the notification sender for documents in this account. `User` (default) shows the document owner's name; `Account` shows this account's name.",
      "type": "string",
      "enum": [
        "User",
        "Account"
      ],
      "example": "Account"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "name": "Acme Inc.",
  "notification_sender_type": "Account"
}
```


**Response `200`:** The created account

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Account"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "account",
    "id": "6401df46d6a6b0c692d9ec49",
    "name": "Acme Inc.",
    "primary_color": "aabbcc",
    "secondary_color": "112233",
    "notification_sender_type": "User",
    "roles": [
      "owner"
    ],
    "is_delete_allowed": true,
    "created_at": "2026-06-03T03:54:16Z"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListDocumentActivities

```pascal
function ListDocumentActivities(const DocumentId: string): TAssinafyResponse;
```

`GET /v1/documents/{documentId}/activities`

List the activities recorded for a document. Each entry carries an event-specific `payload` snapshot (keys vary per event) and the request `origin` (`ip`, `user-agent`).

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** Document activities

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/DocumentActivity"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "id": 4,
      "event": "assignment_created",
      "message": "Assignment created by John Smith.",
      "payload": {},
      "origin": {
        "ip": "172.19.0.1",
        "user-agent": "<string>"
      },
      "created_at": "2022-07-19T19:28:13Z"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListAssignments

```pascal
function ListAssignments(Query: TStrings = nil): TAssinafyResponse;
```

`GET /v1/assignments`

List the assignments belonging to the authenticated user's current account.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `page` (query, optional): Page number.
```json
{
  "type": "integer",
  "minimum": 1,
  "example": 1
}
```


- `per-page` (query, optional): Records per page (max 100).
```json
{
  "type": "integer",
  "maximum": 100,
  "example": 25
}
```


**Request body:** none.

**Response `200`:** A page of assignments

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/Assignment"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "resource": "assignment",
      "id": "615606ef81d199996981dbce",
      "sender_email": "developer@example.com",
      "method": "virtual",
      "expires_at": null,
      "message": "<string>",
      "signers": [
        {
          "resource": "signer",
          "id": "62d6ee35c7741ca4006b9e11",
          "full_name": "John Signer",
          "email": "developer@example.com",
          "whatsapp_phone_number": "+5548999990000",
          "government_id": "39053344705",
          "has_accepted_terms": false,
          "verification_method": "Email",
          "notification_methods": [
            "Email"
          ],
          "step": 1,
          "notified": false,
          "completed": false,
          "notification_history": [
            {
              "event": "signature_request",
              "status": "sent",
              "error_code": "<string>",
              "error_message": "<string>",
              "sent_at": "2026-07-07T12:00:00Z",
              "failed_at": null
            }
          ]
        }
      ],
      "copy_receivers": [
        {}
      ],
      "items": [
        {
          "id": "<string>",
          "page": {
            "id": "615601faf166d6d1d8e7dc30",
            "number": 1,
            "height": 2100,
            "width": 1275,
            "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
          },
          "signer": {},
          "field": {},
          "display_settings": "<string>",
          "value": "<string>",
          "completed": false
        }
      ],
      "summary": {
        "signer_count": 1,
        "completed_count": 1,
        "signers": [
          {}
        ]
      },
      "signing_urls": [
        {
          "signer_id": "<string>",
          "url": "https://api.assinafy.com.br/v1/sign/doc1?email=developer@example.com"
        }
      ]
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## CreateAssignment

```pascal
function CreateAssignment(const DocumentId: string; Body: TJSONData): TAssinafyResponse;
```

`POST /v1/documents/{documentId}/assignments`

Request signatures on a document. Use `method: virtual` to sign without input fields, or `method: collect` to place input fields on specific pages.

For **virtual**, the document may be in `uploaded`, `metadata_processing` or `metadata_ready`; it is promoted to `pending_signature` automatically once metadata processing completes. For **collect**, the document must be in `metadata_ready` (fields reference specific pages).

`step` controls signing order: signers sharing a step sign in parallel, and the next step is notified only after the previous step completes. If supplied, every signer must supply it and values must be contiguous starting at 1.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "required": [
    "method",
    "signers"
  ],
  "properties": {
    "method": {
      "type": "string",
      "enum": [
        "virtual",
        "collect"
      ],
      "example": "virtual"
    },
    "signers": {
      "type": "array",
      "items": {
        "required": [
          "id"
        ],
        "properties": {
          "id": {
            "type": "string",
            "example": "615605f50e968054a5b7c9b8"
          },
          "verification_method": {
            "description": "How the signer's identity is verified before signing. `Email` (default) sends a one-time code to the signer's email; `Whatsapp` sends the code over WhatsApp — the verification itself is not billed, but it requires the WhatsApp notification channel, so the signer costs 0.45 credits (available only on paid subscriptions); `DigitalCertificate` has the signer sign with their own ICP-Brasil certificate (A1/A3) — it requires the Digital Certificate feature, the signer must have a CPF or CNPJ in `government_id`, must be alone in its signing step, and is charged 0.5 credits per signer. A CPF requires that person's certificate (an e-CPF, or an e-CNPJ naming them as legal representative); a CNPJ requires an e-CNPJ for that company, from any of its representatives. Omit to default to `Email`.",
            "type": "string",
            "enum": [
              "Email",
              "Whatsapp",
              "DigitalCertificate"
            ],
            "example": "Email"
          },
          "notification_methods": {
            "description": "How the signer is told a signature is being requested. **Exactly one method per signer** — the array shape is historical, and sending two returns `400`. The method must also be compatible with `verification_method`: `Email` verification takes `Email`, `Whatsapp` verification takes `Whatsapp`, and `DigitalCertificate` takes either. WhatsApp incurs an additional cost and is available only on paid subscriptions. Omit it to have it inferred from `verification_method`, or `{\"Email\"}` when neither is sent. See **Verification & Notification Methods** for the full pairing table.",
            "type": "array",
            "items": {
              "type": "string",
              "enum": [
                "Email",
                "Whatsapp"
              ]
            },
            "example": [
              "Email"
            ]
          },
          "step": {
            "type": "integer",
            "example": 1
          }
        },
        "type": "object"
      }
    },
    "entries": {
      "description": "Required for `collect`: field placements per page.",
      "type": "array",
      "items": {
        "properties": {
          "page_id": {
            "type": "string"
          },
          "fields": {
            "type": "array",
            "items": {
              "properties": {
                "signer_id": {
                  "type": "string"
                },
                "field_id": {
                  "type": "string"
                },
                "display_settings": {
                  "$ref": "#/components/schemas/DisplaySettings"
                }
              },
              "type": "object"
            }
          }
        },
        "type": "object"
      }
    },
    "message": {
      "description": "Text included in the invitation email.",
      "type": "string"
    },
    "expires_at": {
      "description": "ISO 8601; default is no expiration. Must be at least one hour in the future.",
      "type": "string",
      "format": "date-time"
    },
    "copy_receivers": {
      "description": "Signer IDs that only receive a copy.",
      "type": "array",
      "items": {
        "type": "string"
      }
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "method": "virtual",
  "signers": [
    {
      "id": "615605f50e968054a5b7c9b8",
      "verification_method": "Email",
      "notification_methods": [
        "Email"
      ],
      "step": 1
    }
  ],
  "entries": [
    {
      "page_id": "<string>",
      "fields": [
        {
          "signer_id": "<string>",
          "field_id": "<string>",
          "display_settings": {
            "left": 69,
            "top": 282,
            "width": 421,
            "height": 45.86,
            "fontFamily": "Arial",
            "fontSize": 22,
            "backgroundColor": "#D5EBFF"
          }
        }
      ]
    }
  ],
  "message": "<string>",
  "expires_at": "2030-01-01T12:00:00Z",
  "copy_receivers": [
    "<string>"
  ]
}
```


**Response `200`:** The created assignment

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Assignment"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "assignment",
    "id": "615606ef81d199996981dbce",
    "sender_email": "developer@example.com",
    "method": "virtual",
    "expires_at": null,
    "message": "<string>",
    "signers": [
      {
        "resource": "signer",
        "id": "62d6ee35c7741ca4006b9e11",
        "full_name": "John Signer",
        "email": "developer@example.com",
        "whatsapp_phone_number": "+5548999990000",
        "government_id": "39053344705",
        "has_accepted_terms": false,
        "verification_method": "Email",
        "notification_methods": [
          "Email"
        ],
        "step": 1,
        "notified": false,
        "completed": false,
        "notification_history": [
          {
            "event": "signature_request",
            "status": "sent",
            "error_code": "<string>",
            "error_message": "<string>",
            "sent_at": "2026-07-07T12:00:00Z",
            "failed_at": null
          }
        ]
      }
    ],
    "copy_receivers": [
      {}
    ],
    "items": [
      {
        "id": "<string>",
        "page": {
          "id": "615601faf166d6d1d8e7dc30",
          "number": 1,
          "height": 2100,
          "width": 1275,
          "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
        },
        "signer": {},
        "field": {},
        "display_settings": "<string>",
        "value": "<string>",
        "completed": false
      }
    ],
    "summary": {
      "signer_count": 1,
      "completed_count": 1,
      "signers": [
        {}
      ]
    },
    "signing_urls": [
      {
        "signer_id": "<string>",
        "url": "https://api.assinafy.com.br/v1/sign/doc1?email=developer@example.com"
      }
    ]
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## EstimateAssignmentCost

```pascal
function EstimateAssignmentCost(const DocumentId: string; Body: TJSONData): TAssinafyResponse;
```

`POST /v1/documents/{documentId}/assignments/estimate-cost`

Estimate the cost of creating an assignment without creating it, returning a cost breakdown and the current account balances. Signer IDs are not required — only the verification/notification method affects cost. Each assignment consumes 1 document from the plan allowance; if exhausted, an extra document is charged from credits (`needs_extra_document` = true). `blocking_reason` may be `PendingPayment`, `InsufficientDocuments` or `InsufficientCredits`.

### Pricing

Per-unit costs (in credits) used to build the estimate:

| Item | Cost |
|------|------|
| Extra document | 1 credit |
| Email notification | 0 credits |
| WhatsApp notification | 0.45 credits |
| Digital certificate signature (per signer) | 0.5 credits |

Verification methods are not priced separately — every line in the `breakdown` is a notification or a signature. A `Whatsapp`-verified signer therefore shows up as a WhatsApp notification, because that channel is mandatory for that verification method. A `DigitalCertificate` signer adds the digital-certificate signature cost **on top of** its notification cost; it appears in the `breakdown` under the `SignatureDigitalCertificate` code.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "properties": {
    "method": {
      "type": "string",
      "enum": [
        "virtual",
        "collect"
      ],
      "example": "virtual"
    },
    "signers": {
      "description": "Required for `virtual`; each entry may be `{}` to default to Email.",
      "type": "array",
      "items": {
        "properties": {
          "verification_method": {
            "description": "Verification method to price. `Whatsapp` forces the WhatsApp notification, so it prices at 0.45 credits per signer; `DigitalCertificate` adds the per-signer signature cost on top of its notification.",
            "type": "string",
            "enum": [
              "Email",
              "Whatsapp",
              "DigitalCertificate"
            ],
            "example": "Whatsapp"
          },
          "notification_methods": {
            "description": "The notification channel to price — exactly one per signer, subject to the same pairing rules as **Create assignment**. `Whatsapp` costs 0.45 credits per signer. Omit it to have it inferred from `verification_method`.",
            "type": "array",
            "items": {
              "type": "string",
              "enum": [
                "Email",
                "Whatsapp"
              ]
            }
          }
        },
        "type": "object"
      }
    },
    "entries": {
      "description": "Required for `collect`.",
      "type": "array",
      "items": {
        "type": "object"
      }
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "method": "virtual",
  "signers": [
    {
      "verification_method": "Whatsapp",
      "notification_methods": [
        "Email"
      ]
    }
  ],
  "entries": [
    {}
  ]
}
```


**Response `200`:** Cost estimate and balances

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/CostEstimate"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "documents": 1,
    "credits": 1,
    "needs_extra_document": false,
    "extra_document_cost": 1,
    "total_credits": 1,
    "breakdown": [
      {
        "code": "NotificationWhatsapp",
        "name": "Whatsapp Notification",
        "cost": 0.9,
        "quantity": 2,
        "unit_cost": 0.45
      }
    ],
    "document_balance": 1,
    "credit_balance": 1,
    "has_sufficient_resources": false,
    "blocking_reason": null,
    "message": "<string>"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ResendSignatureRequest

```pascal
function ResendSignatureRequest(const DocumentId: string; const AssignmentId: string; const SignerId: string): TAssinafyResponse;
```

`PUT /v1/documents/{documentId}/assignments/{assignmentId}/signers/{signerId}/resend`

Resend the signature-request notification to a specific signer of an assignment.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


- `assignmentId` (path, required): The assignment ID.
```json
{
  "type": "string"
}
```


- `signerId` (path, required): The signer ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** Resend result

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "properties": {
            "is_sent": {
              "type": "boolean"
            },
            "document_id": {
              "type": "string"
            },
            "signer_id": {
              "type": "string"
            }
          },
          "type": "object"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "is_sent": false,
    "document_id": "<string>",
    "signer_id": "<string>"
  }
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## EstimateResendCost

```pascal
function EstimateResendCost(const DocumentId: string; const AssignmentId: string; const SignerId: string): TAssinafyResponse;
```

`POST /v1/documents/{documentId}/assignments/{assignmentId}/signers/{signerId}/estimate-resend-cost`

Estimate the cost of resending the signature request to a signer.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


- `assignmentId` (path, required): The assignment ID.
```json
{
  "type": "string"
}
```


- `signerId` (path, required): The signer ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** Cost estimate

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/CostEstimate"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "documents": 1,
    "credits": 1,
    "needs_extra_document": false,
    "extra_document_cost": 1,
    "total_credits": 1,
    "breakdown": [
      {
        "code": "NotificationWhatsapp",
        "name": "Whatsapp Notification",
        "cost": 0.9,
        "quantity": 2,
        "unit_cost": 0.45
      }
    ],
    "document_balance": 1,
    "credit_balance": 1,
    "has_sufficient_resources": false,
    "blocking_reason": null,
    "message": "<string>"
  }
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ResetAssignmentExpiration

```pascal
function ResetAssignmentExpiration(const DocumentId: string; const AssignmentId: string; Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/documents/{documentId}/assignments/{assignmentId}/reset-expiration`

Set a new expiration date for an assignment, or remove its expiration by sending `expires_at: null`. Not allowed once the document is closed.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


- `assignmentId` (path, required): The assignment ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "required": [
    "expires_at"
  ],
  "properties": {
    "expires_at": {
      "description": "New expiration date (ISO 8601). Must be at least one hour in the future. Send `null` to remove the expiration — the key itself is required.",
      "type": [
        "string",
        "null"
      ],
      "format": "date-time",
      "example": "2026-12-31T23:59:59Z"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "expires_at": "2026-12-31T23:59:59Z"
}
```


**Response `200`:** The updated assignment

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Assignment"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "assignment",
    "id": "615606ef81d199996981dbce",
    "sender_email": "developer@example.com",
    "method": "virtual",
    "expires_at": null,
    "message": "<string>",
    "signers": [
      {
        "resource": "signer",
        "id": "62d6ee35c7741ca4006b9e11",
        "full_name": "John Signer",
        "email": "developer@example.com",
        "whatsapp_phone_number": "+5548999990000",
        "government_id": "39053344705",
        "has_accepted_terms": false,
        "verification_method": "Email",
        "notification_methods": [
          "Email"
        ],
        "step": 1,
        "notified": false,
        "completed": false,
        "notification_history": [
          {
            "event": "signature_request",
            "status": "sent",
            "error_code": "<string>",
            "error_message": "<string>",
            "sent_at": "2026-07-07T12:00:00Z",
            "failed_at": null
          }
        ]
      }
    ],
    "copy_receivers": [
      {}
    ],
    "items": [
      {
        "id": "<string>",
        "page": {
          "id": "615601faf166d6d1d8e7dc30",
          "number": 1,
          "height": 2100,
          "width": 1275,
          "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
        },
        "signer": {},
        "field": {},
        "display_settings": "<string>",
        "value": "<string>",
        "completed": false
      }
    ],
    "summary": {
      "signer_count": 1,
      "completed_count": 1,
      "signers": [
        {}
      ]
    },
    "signing_urls": [
      {
        "signer_id": "<string>",
        "url": "https://api.assinafy.com.br/v1/sign/doc1?email=developer@example.com"
      }
    ]
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## Login

```pascal
function Login(Body: TJSONData): TAssinafyResponse;
```

`POST /v1/login`

Authenticate with email and password and receive a JWT access token.

**Authentication:** Public: workspace credentials are omitted.

**Parameters:**

No path or query parameters.

**Request: `application/json` (required)**

```json
{
  "required": [
    "email",
    "password"
  ],
  "properties": {
    "email": {
      "type": "string",
      "format": "email",
      "example": "developer@example.com"
    },
    "password": {
      "type": "string",
      "format": "password",
      "example": "password"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "email": "developer@example.com",
  "password": "password"
}
```


**Response `200`:** Access token, user and accounts

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/AuthSession"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "user": {
      "id": "bgjazeo5r9v2lq7l36dx48np",
      "name": "John Smith",
      "email": "developer@example.com",
      "telephone": "17989206641",
      "government_id": "15774136604",
      "is_email_verified": false,
      "has_accepted_terms": true,
      "created_at": "2023-03-03T11:51:34Z",
      "to_be_deleted_at": null
    },
    "accounts": [
      {
        "id": "6401df46d6a6b0c692d9ec49",
        "name": "JS",
        "roles": [
          "owner"
        ],
        "is_delete_allowed": true,
        "created_at": "2023-03-03T11:51:34Z"
      }
    ]
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## RequestPasswordReset

```pascal
function RequestPasswordReset(Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/authentication/request-password-reset`

Send the user an email with instructions to reset their password. Used when the password was forgotten or never set.

**Authentication:** Public: workspace credentials are omitted.

**Parameters:**

No path or query parameters.

**Request: `application/json` (required)**

```json
{
  "required": [
    "email"
  ],
  "properties": {
    "email": {
      "type": "string",
      "format": "email",
      "example": "developer@example.com"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "email": "developer@example.com"
}
```


**Response `200`:** Reset email sent

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "properties": {
            "email": {
              "type": "string",
              "format": "email",
              "example": "developer@example.com"
            }
          },
          "type": "object"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "email": "developer@example.com"
  }
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ResetPassword

```pascal
function ResetPassword(Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/authentication/reset-password`

Reset the user's password using the token received by email.

**Authentication:** Public: workspace credentials are omitted.

**Parameters:**

No path or query parameters.

**Request: `application/json` (required)**

```json
{
  "required": [
    "email",
    "new_password"
  ],
  "properties": {
    "email": {
      "type": "string",
      "format": "email",
      "example": "developer@example.com"
    },
    "token": {
      "description": "Token received by email.",
      "type": "string",
      "example": "b3ac64d6c55b3ac64d6c55"
    },
    "new_password": {
      "type": "string",
      "format": "password",
      "example": "N3w_p4ssw0rd"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "email": "developer@example.com",
  "token": "b3ac64d6c55b3ac64d6c55",
  "new_password": "N3w_p4ssw0rd"
}
```


**Response `200`:** Password reset

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "properties": {
            "email": {
              "type": "string",
              "format": "email",
              "example": "developer@example.com"
            }
          },
          "type": "object"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "email": "developer@example.com"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ChangePassword

```pascal
function ChangePassword(Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/authentication/change-password`

Change the authenticated user's password.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request: `application/json` (required)**

```json
{
  "required": [
    "email",
    "password",
    "new_password"
  ],
  "properties": {
    "email": {
      "type": "string",
      "format": "email",
      "example": "developer@example.com"
    },
    "password": {
      "description": "The current password.",
      "type": "string",
      "format": "password",
      "example": "X3$_!456aTa"
    },
    "new_password": {
      "description": "The new password.",
      "type": "string",
      "format": "password",
      "example": "X3$_!456aT"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "email": "developer@example.com",
  "password": "X3$_!456aTa",
  "new_password": "X3$_!456aT"
}
```


**Response `200`:** Password changed

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "properties": {
            "email": {
              "type": "string",
              "format": "email",
              "example": "developer@example.com"
            }
          },
          "type": "object"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "email": "developer@example.com"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## CompleteATwoFactorLogin

```pascal
function CompleteATwoFactorLogin(Body: TJSONData): TAssinafyResponse;
```

`POST /v1/authentication/mfa/verify`

Exchanges the `mfa_token` returned by login for an access token. `code` is either the 6-digit code from the authenticator app or one of the recovery codes issued at enrollment. The challenge is single-use and expires 5 minutes after login.

**Authentication:** Public: workspace credentials are omitted.

**Parameters:**

No path or query parameters.

**Request: `application/json` (required)**

```json
{
  "required": [
    "mfa_token",
    "code"
  ],
  "properties": {
    "mfa_token": {
      "description": "The token returned by the login response.",
      "type": "string"
    },
    "code": {
      "description": "A 6-digit authenticator code, or a recovery code such as ABCD-EFGH-JKMN.",
      "type": "string",
      "example": "123456"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "mfa_token": "<string>",
  "code": "123456"
}
```


**Response `200`:** Access token, user and accounts

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/AuthSession"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "user": {
      "id": "bgjazeo5r9v2lq7l36dx48np",
      "name": "John Smith",
      "email": "developer@example.com",
      "telephone": "17989206641",
      "government_id": "15774136604",
      "is_email_verified": false,
      "has_accepted_terms": true,
      "created_at": "2023-03-03T11:51:34Z",
      "to_be_deleted_at": null
    },
    "accounts": [
      {
        "id": "6401df46d6a6b0c692d9ec49",
        "name": "JS",
        "roles": [
          "owner"
        ],
        "is_delete_allowed": true,
        "created_at": "2023-03-03T11:51:34Z"
      }
    ]
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** The challenge expired, was already used, or too many codes were tried

**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListDocuments

```pascal
function ListDocuments(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/documents`

List documents of the workspace.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `status` (query, optional): Status filter, e.g. `pending_signature`.
```json
{
  "type": "string"
}
```


- `method` (query, optional): Signature method filter.
```json
{
  "type": "string",
  "enum": [
    "virtual",
    "collect"
  ]
}
```


- `search` (query, optional): Partial match on document.name, signer.full_name, signer.email.
```json
{
  "type": "string"
}
```


- `tags` (query, optional): Comma-separated tag IDs; returns documents having ALL listed tags.
```json
{
  "type": "string"
}
```


- `sort` (query, optional): Sort by `name` or `updated_at`.
```json
{
  "type": "string"
}
```


- `page` (query, optional): Page number.
```json
{
  "type": "integer",
  "minimum": 1,
  "example": 1
}
```


- `per-page` (query, optional): Records per page (max 100).
```json
{
  "type": "integer",
  "maximum": 100,
  "example": 25
}
```


**Request body:** none.

**Response `200`:** A page of documents

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/Document"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "resource": "document",
      "id": "615601fab04c0a3147bb1246",
      "account_id": "d199996981dbd199996981db",
      "template_id": null,
      "name": "document.pdf",
      "status": "metadata_ready",
      "artifacts": {
        "original": "https://api.assinafy.com.br/v1/documents/doc1/download/original"
      },
      "is_closed": false,
      "signing_url": "https://api.assinafy.com.br/v1/sign/doc1",
      "decline_reason": null,
      "declined_by": {
        "resource": "signer",
        "id": "62d6ee35c7741ca4006b9e11",
        "full_name": "John Signer",
        "email": "developer@example.com",
        "whatsapp_phone_number": "+5548999990000",
        "government_id": "39053344705",
        "has_accepted_terms": false
      },
      "tags": [
        {
          "id": "<string>",
          "name": "<string>"
        }
      ],
      "assignment": {
        "resource": "assignment",
        "id": "615606ef81d199996981dbce",
        "sender_email": "developer@example.com",
        "method": "virtual",
        "expires_at": null,
        "message": "<string>",
        "signers": [
          {
            "resource": "signer",
            "id": "62d6ee35c7741ca4006b9e11",
            "full_name": "John Signer",
            "email": "developer@example.com",
            "whatsapp_phone_number": "+5548999990000",
            "government_id": "39053344705",
            "has_accepted_terms": false,
            "verification_method": "Email",
            "notification_methods": [
              "Email"
            ],
            "step": 1,
            "notified": false,
            "completed": false,
            "notification_history": [
              {
                "event": "signature_request",
                "status": "sent",
                "error_code": "<string>",
                "error_message": "<string>",
                "sent_at": "2026-07-07T12:00:00Z",
                "failed_at": null
              }
            ]
          }
        ],
        "copy_receivers": [
          {}
        ],
        "items": [
          {
            "id": "<string>",
            "page": {
              "id": "615601faf166d6d1d8e7dc30",
              "number": 1,
              "height": 2100,
              "width": 1275,
              "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
            },
            "signer": {},
            "field": {},
            "display_settings": "<string>",
            "value": "<string>",
            "completed": false
          }
        ],
        "summary": {
          "signer_count": 1,
          "completed_count": 1,
          "signers": [
            {}
          ]
        },
        "signing_urls": [
          {
            "signer_id": "<string>",
            "url": "https://api.assinafy.com.br/v1/sign/doc1?email=developer@example.com"
          }
        ]
      },
      "pages": [
        {
          "id": "615601faf166d6d1d8e7dc30",
          "number": 1,
          "height": 2100,
          "width": 1275,
          "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
        }
      ],
      "created_at": "2026-06-03T03:54:16Z",
      "updated_at": "2026-06-03T03:54:16Z"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## UploadDocument

```pascal
function UploadDocument(const AAccountId: string; const FileName: string): TAssinafyResponse;
```

`POST /v1/accounts/{accountId}/documents`

Create a document from an uploaded file. Maximum file size 25MB; maximum 2000 pages.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request: `multipart/form-data` (required)**

```json
{
  "required": [
    "file"
  ],
  "properties": {
    "file": {
      "description": "The PDF file to upload.",
      "type": "string",
      "format": "binary"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "file": "<binary bytes>"
}
```


**Response `200`:** The created document

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Document"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "document",
    "id": "615601fab04c0a3147bb1246",
    "account_id": "d199996981dbd199996981db",
    "template_id": null,
    "name": "document.pdf",
    "status": "metadata_ready",
    "artifacts": {
      "original": "https://api.assinafy.com.br/v1/documents/doc1/download/original"
    },
    "is_closed": false,
    "signing_url": "https://api.assinafy.com.br/v1/sign/doc1",
    "decline_reason": null,
    "declined_by": {
      "resource": "signer",
      "id": "62d6ee35c7741ca4006b9e11",
      "full_name": "John Signer",
      "email": "developer@example.com",
      "whatsapp_phone_number": "+5548999990000",
      "government_id": "39053344705",
      "has_accepted_terms": false
    },
    "tags": [
      {
        "id": "<string>",
        "name": "<string>"
      }
    ],
    "assignment": {
      "resource": "assignment",
      "id": "615606ef81d199996981dbce",
      "sender_email": "developer@example.com",
      "method": "virtual",
      "expires_at": null,
      "message": "<string>",
      "signers": [
        {
          "resource": "signer",
          "id": "62d6ee35c7741ca4006b9e11",
          "full_name": "John Signer",
          "email": "developer@example.com",
          "whatsapp_phone_number": "+5548999990000",
          "government_id": "39053344705",
          "has_accepted_terms": false,
          "verification_method": "Email",
          "notification_methods": [
            "Email"
          ],
          "step": 1,
          "notified": false,
          "completed": false,
          "notification_history": [
            {
              "event": "signature_request",
              "status": "sent",
              "error_code": "<string>",
              "error_message": "<string>",
              "sent_at": "2026-07-07T12:00:00Z",
              "failed_at": null
            }
          ]
        }
      ],
      "copy_receivers": [
        {}
      ],
      "items": [
        {
          "id": "<string>",
          "page": {
            "id": "615601faf166d6d1d8e7dc30",
            "number": 1,
            "height": 2100,
            "width": 1275,
            "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
          },
          "signer": {},
          "field": {},
          "display_settings": "<string>",
          "value": "<string>",
          "completed": false
        }
      ],
      "summary": {
        "signer_count": 1,
        "completed_count": 1,
        "signers": [
          {}
        ]
      },
      "signing_urls": [
        {
          "signer_id": "<string>",
          "url": "https://api.assinafy.com.br/v1/sign/doc1?email=developer@example.com"
        }
      ]
    },
    "pages": [
      {
        "id": "615601faf166d6d1d8e7dc30",
        "number": 1,
        "height": 2100,
        "width": 1275,
        "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
      }
    ],
    "created_at": "2026-06-03T03:54:16Z",
    "updated_at": "2026-06-03T03:54:16Z"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## SearchDocuments

```pascal
function SearchDocuments(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/documents/search`

Search documents of the workspace, returning a compact representation (no expanded assignment/pages).

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `search` (query, optional): Search term.
```json
{
  "type": "string"
}
```


- `status` (query, optional):
```json
{
  "type": "string"
}
```


- `page` (query, optional): Page number.
```json
{
  "type": "integer",
  "minimum": 1,
  "example": 1
}
```


- `per-page` (query, optional): Records per page (max 100).
```json
{
  "type": "integer",
  "maximum": 100,
  "example": 25
}
```


**Request body:** none.

**Response `200`:** Matching documents

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/Document"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "resource": "document",
      "id": "615601fab04c0a3147bb1246",
      "account_id": "d199996981dbd199996981db",
      "template_id": null,
      "name": "document.pdf",
      "status": "metadata_ready",
      "artifacts": {
        "original": "https://api.assinafy.com.br/v1/documents/doc1/download/original"
      },
      "is_closed": false,
      "signing_url": "https://api.assinafy.com.br/v1/sign/doc1",
      "decline_reason": null,
      "declined_by": {
        "resource": "signer",
        "id": "62d6ee35c7741ca4006b9e11",
        "full_name": "John Signer",
        "email": "developer@example.com",
        "whatsapp_phone_number": "+5548999990000",
        "government_id": "39053344705",
        "has_accepted_terms": false
      },
      "tags": [
        {
          "id": "<string>",
          "name": "<string>"
        }
      ],
      "assignment": {
        "resource": "assignment",
        "id": "615606ef81d199996981dbce",
        "sender_email": "developer@example.com",
        "method": "virtual",
        "expires_at": null,
        "message": "<string>",
        "signers": [
          {
            "resource": "signer",
            "id": "62d6ee35c7741ca4006b9e11",
            "full_name": "John Signer",
            "email": "developer@example.com",
            "whatsapp_phone_number": "+5548999990000",
            "government_id": "39053344705",
            "has_accepted_terms": false,
            "verification_method": "Email",
            "notification_methods": [
              "Email"
            ],
            "step": 1,
            "notified": false,
            "completed": false,
            "notification_history": [
              {
                "event": "signature_request",
                "status": "sent",
                "error_code": "<string>",
                "error_message": "<string>",
                "sent_at": "2026-07-07T12:00:00Z",
                "failed_at": null
              }
            ]
          }
        ],
        "copy_receivers": [
          {}
        ],
        "items": [
          {
            "id": "<string>",
            "page": {
              "id": "615601faf166d6d1d8e7dc30",
              "number": 1,
              "height": 2100,
              "width": 1275,
              "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
            },
            "signer": {},
            "field": {},
            "display_settings": "<string>",
            "value": "<string>",
            "completed": false
          }
        ],
        "summary": {
          "signer_count": 1,
          "completed_count": 1,
          "signers": [
            {}
          ]
        },
        "signing_urls": [
          {
            "signer_id": "<string>",
            "url": "https://api.assinafy.com.br/v1/sign/doc1?email=developer@example.com"
          }
        ]
      },
      "pages": [
        {
          "id": "615601faf166d6d1d8e7dc30",
          "number": 1,
          "height": 2100,
          "width": 1275,
          "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
        }
      ],
      "created_at": "2026-06-03T03:54:16Z",
      "updated_at": "2026-06-03T03:54:16Z"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListDocumentStatuses

```pascal
function ListDocumentStatuses: TAssinafyResponse;
```

`GET /v1/documents/statuses`

The supported document statuses and whether a document in each status can be deleted.

| Status | Deletable | Description |
|--------|-----------|-------------|
| `uploading` | no | The document upload is in process. |
| `uploaded` | no | The document has been uploaded. |
| `metadata_processing` | no | The initial processing is under way. |
| `metadata_ready` | yes | The initial processing has been completed. |
| `expired` | yes | The signature deadline has been reached. |
| `certificating` | no | The document has been signed and is being certificated. |
| `certificated` | no | The document is certificated. |
| `rejected_by_signer` | yes | A signer declined signing the document. |
| `pending_signature` | yes | The document is waiting for signatures. |
| `rejected_by_user` | yes | The signature process was cancelled by a user. |
| `failed` | yes | The document processing has failed. |

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request body:** none.

**Response `200`:** Supported statuses

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/DocumentStatus"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "code": "metadata_ready",
      "deletable": true
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## GetDocument

```pascal
function GetDocument(const DocumentId: string): TAssinafyResponse;
```

`GET /v1/documents/{documentId}`

Get a document by its ID. `decline_reason` is only present when the access token belongs to the document's creator.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The document

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Document"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "document",
    "id": "615601fab04c0a3147bb1246",
    "account_id": "d199996981dbd199996981db",
    "template_id": null,
    "name": "document.pdf",
    "status": "metadata_ready",
    "artifacts": {
      "original": "https://api.assinafy.com.br/v1/documents/doc1/download/original"
    },
    "is_closed": false,
    "signing_url": "https://api.assinafy.com.br/v1/sign/doc1",
    "decline_reason": null,
    "declined_by": {
      "resource": "signer",
      "id": "62d6ee35c7741ca4006b9e11",
      "full_name": "John Signer",
      "email": "developer@example.com",
      "whatsapp_phone_number": "+5548999990000",
      "government_id": "39053344705",
      "has_accepted_terms": false
    },
    "tags": [
      {
        "id": "<string>",
        "name": "<string>"
      }
    ],
    "assignment": {
      "resource": "assignment",
      "id": "615606ef81d199996981dbce",
      "sender_email": "developer@example.com",
      "method": "virtual",
      "expires_at": null,
      "message": "<string>",
      "signers": [
        {
          "resource": "signer",
          "id": "62d6ee35c7741ca4006b9e11",
          "full_name": "John Signer",
          "email": "developer@example.com",
          "whatsapp_phone_number": "+5548999990000",
          "government_id": "39053344705",
          "has_accepted_terms": false,
          "verification_method": "Email",
          "notification_methods": [
            "Email"
          ],
          "step": 1,
          "notified": false,
          "completed": false,
          "notification_history": [
            {
              "event": "signature_request",
              "status": "sent",
              "error_code": "<string>",
              "error_message": "<string>",
              "sent_at": "2026-07-07T12:00:00Z",
              "failed_at": null
            }
          ]
        }
      ],
      "copy_receivers": [
        {}
      ],
      "items": [
        {
          "id": "<string>",
          "page": {
            "id": "615601faf166d6d1d8e7dc30",
            "number": 1,
            "height": 2100,
            "width": 1275,
            "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
          },
          "signer": {},
          "field": {},
          "display_settings": "<string>",
          "value": "<string>",
          "completed": false
        }
      ],
      "summary": {
        "signer_count": 1,
        "completed_count": 1,
        "signers": [
          {}
        ]
      },
      "signing_urls": [
        {
          "signer_id": "<string>",
          "url": "https://api.assinafy.com.br/v1/sign/doc1?email=developer@example.com"
        }
      ]
    },
    "pages": [
      {
        "id": "615601faf166d6d1d8e7dc30",
        "number": 1,
        "height": 2100,
        "width": 1275,
        "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
      }
    ],
    "created_at": "2026-06-03T03:54:16Z",
    "updated_at": "2026-06-03T03:54:16Z"
  }
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## DeleteDocument

```pascal
function DeleteDocument(const DocumentId: string): TAssinafyResponse;
```

`DELETE /v1/documents/{documentId}`

Delete a document by its ID. Only documents in a deletable status can be removed (see GET /v1/documents/statuses).

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** Document deleted

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": [],
          "example": []
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": []
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## RenameDocument

```pascal
function RenameDocument(const DocumentId: string; Body: TJSONData): TAssinafyResponse;
```

`PATCH /v1/documents/{documentId}`

Update a document's name. Only allowed before any assignment is created (i.e. while the document is in `uploaded` or `metadata_ready` status and has no signers yet); once the signature process has started or the document is certificated, the name is locked. The name is normalized: diacritics are removed and unsupported characters are replaced with dashes.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "required": [
    "name"
  ],
  "properties": {
    "name": {
      "type": "string",
      "maxLength": 255,
      "example": "Service agreement.pdf"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "name": "Service agreement.pdf"
}
```


**Response `200`:** The updated document

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Document"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "document",
    "id": "615601fab04c0a3147bb1246",
    "account_id": "d199996981dbd199996981db",
    "template_id": null,
    "name": "document.pdf",
    "status": "metadata_ready",
    "artifacts": {
      "original": "https://api.assinafy.com.br/v1/documents/doc1/download/original"
    },
    "is_closed": false,
    "signing_url": "https://api.assinafy.com.br/v1/sign/doc1",
    "decline_reason": null,
    "declined_by": {
      "resource": "signer",
      "id": "62d6ee35c7741ca4006b9e11",
      "full_name": "John Signer",
      "email": "developer@example.com",
      "whatsapp_phone_number": "+5548999990000",
      "government_id": "39053344705",
      "has_accepted_terms": false
    },
    "tags": [
      {
        "id": "<string>",
        "name": "<string>"
      }
    ],
    "assignment": {
      "resource": "assignment",
      "id": "615606ef81d199996981dbce",
      "sender_email": "developer@example.com",
      "method": "virtual",
      "expires_at": null,
      "message": "<string>",
      "signers": [
        {
          "resource": "signer",
          "id": "62d6ee35c7741ca4006b9e11",
          "full_name": "John Signer",
          "email": "developer@example.com",
          "whatsapp_phone_number": "+5548999990000",
          "government_id": "39053344705",
          "has_accepted_terms": false,
          "verification_method": "Email",
          "notification_methods": [
            "Email"
          ],
          "step": 1,
          "notified": false,
          "completed": false,
          "notification_history": [
            {
              "event": "signature_request",
              "status": "sent",
              "error_code": "<string>",
              "error_message": "<string>",
              "sent_at": "2026-07-07T12:00:00Z",
              "failed_at": null
            }
          ]
        }
      ],
      "copy_receivers": [
        {}
      ],
      "items": [
        {
          "id": "<string>",
          "page": {
            "id": "615601faf166d6d1d8e7dc30",
            "number": 1,
            "height": 2100,
            "width": 1275,
            "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
          },
          "signer": {},
          "field": {},
          "display_settings": "<string>",
          "value": "<string>",
          "completed": false
        }
      ],
      "summary": {
        "signer_count": 1,
        "completed_count": 1,
        "signers": [
          {}
        ]
      },
      "signing_urls": [
        {
          "signer_id": "<string>",
          "url": "https://api.assinafy.com.br/v1/sign/doc1?email=developer@example.com"
        }
      ]
    },
    "pages": [
      {
        "id": "615601faf166d6d1d8e7dc30",
        "number": 1,
        "height": 2100,
        "width": 1275,
        "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
      }
    ],
    "created_at": "2026-06-03T03:54:16Z",
    "updated_at": "2026-06-03T03:54:16Z"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## DownloadDocumentArtifact

```pascal
function DownloadDocumentArtifact(const DocumentId: string; const ArtifactName: string): TAssinafyResponse;
```

`GET /v1/documents/{documentId}/download/{artifactName}`

Download a document artifact. Artifact types: original, certificated, certificate-page, pades, bundle. The pades artifact (signers' ICP-Brasil signatures + platform certification box) is only present on documents that had digital-certificate signers; `bundle` is a zip of the original, certificated and certificate-page artifacts, plus the pades artifact on documents that have one.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


- `artifactName` (path, required): Artifact type.
```json
{
  "type": "string",
  "enum": [
    "original",
    "certificated",
    "certificate-page",
    "pades",
    "bundle"
  ]
}
```


**Request body:** none.

**Response `200`:** The artifact binary

Content type: `application/pdf`

```json
{
  "type": "string",
  "format": "binary"
}
```

Raw binary bytes; preserved without JSON decoding.

**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## VerifyASignedDocument

```pascal
function VerifyASignedDocument(const DocumentSignatureHash: string): TAssinafyResponse;
```

`GET /v1/documents/{documentSignatureHash}/verify`

Verify a document by its signature hash (found on a signed document) and return its certification details. Always returns `200`: when the hash is not found or the document is not signed, `is_valid` is `false`, the other fields are `null`, and `message` explains why. Public endpoint.

**Authentication:** Public: workspace credentials are omitted.

**Parameters:**

- `documentSignatureHash` (path, required): The document signature hash.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** Verification result

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/DocumentVerification"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "hash": "FE32EDDADE7CBDDCBB934E7402047450B0E59C02",
    "id": "63ddb172402799bfc991d10d",
    "agreement_code": "550E8400-E29B-41D4-A716-446655440000",
    "status": "certificated",
    "page_count": "1",
    "signer_count": "1",
    "completed_count": 1,
    "completed_at": "2023-01-27T19:27:44Z",
    "verified_at": "2023-01-27T19:27:46Z",
    "is_valid": true,
    "message": ""
  }
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListDocumentTags

```pascal
function ListDocumentTags(const AAccountId: string; const DocumentId: string): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/documents/{documentId}/tags`

List the tags attached to a document.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `documentId` (path, required): The document ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** Attached tags

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/Tag"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "resource": "tag",
      "id": "fa8c09f3e709a8a1c82d69b1454",
      "name": "Contracts",
      "color": "ff8800",
      "created_at": "2026-05-14T12:00:00Z",
      "updated_at": "2026-05-14T12:00:00Z"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ReplaceDocumentTags

```pascal
function ReplaceDocumentTags(const AAccountId: string; const DocumentId: string; Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/accounts/{accountId}/documents/{documentId}/tags`

Replace the full set of tags attached to a document.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `documentId` (path, required): The document ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "properties": {
    "tags": {
      "description": "Tag IDs.",
      "type": "array",
      "items": {
        "type": "string"
      }
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "tags": [
    "<string>"
  ]
}
```


**Response `200`:** Updated tags

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/Tag"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "resource": "tag",
      "id": "fa8c09f3e709a8a1c82d69b1454",
      "name": "Contracts",
      "color": "ff8800",
      "created_at": "2026-05-14T12:00:00Z",
      "updated_at": "2026-05-14T12:00:00Z"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## AttachDocumentTags

```pascal
function AttachDocumentTags(const AAccountId: string; const DocumentId: string; Body: TJSONData): TAssinafyResponse;
```

`POST /v1/accounts/{accountId}/documents/{documentId}/tags`

Attach one or more tags to a document.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `documentId` (path, required): The document ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "properties": {
    "tags": {
      "description": "Tag IDs.",
      "type": "array",
      "items": {
        "type": "string"
      }
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "tags": [
    "<string>"
  ]
}
```


**Response `200`:** Attached tags

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/Tag"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "resource": "tag",
      "id": "fa8c09f3e709a8a1c82d69b1454",
      "name": "Contracts",
      "color": "ff8800",
      "created_at": "2026-05-14T12:00:00Z",
      "updated_at": "2026-05-14T12:00:00Z"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## DetachDocumentTag

```pascal
function DetachDocumentTag(const AAccountId: string; const DocumentId: string; const TagId: string): TAssinafyResponse;
```

`DELETE /v1/accounts/{accountId}/documents/{documentId}/tags/{tagId}`

Detach a single tag from a document.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `documentId` (path, required): The document ID.
```json
{
  "type": "string"
}
```


- `tagId` (path, required): The tag ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** Tag detached

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "properties": {
            "detached": {
              "type": "boolean",
              "example": true
            }
          },
          "type": "object"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "detached": true
  }
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListFields

```pascal
function ListFields(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/fields`

List the field definitions of a workspace.

When `include_standard` is enabled, records of type `signature`, `initial` and `signatureDate` are also returned.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `include_inactive` (query, optional): Include inactive field definitions.
```json
{
  "type": "boolean"
}
```


- `include_standard` (query, optional): Include standard field types (signature, initial, signatureDate).
```json
{
  "type": "boolean"
}
```


**Request body:** none.

**Response `200`:** Field definitions

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/Field"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "resource": "field",
      "id": "6152120297080d55bdd13197",
      "name": "Signature",
      "type": "signature",
      "regex": "<string>",
      "is_pre_defined": false,
      "is_active": false,
      "is_required": false,
      "is_standard": false,
      "is_read_only": false,
      "is_visible": false
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## CreateField

```pascal
function CreateField(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
```

`POST /v1/accounts/{accountId}/fields`

Create a field definition in the workspace.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "required": [
    "name",
    "type"
  ],
  "properties": {
    "name": {
      "type": "string",
      "example": "Full name"
    },
    "type": {
      "type": "string",
      "example": "text"
    },
    "regex": {
      "type": [
        "string",
        "null"
      ]
    },
    "is_required": {
      "type": "boolean"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "name": "Full name",
  "type": "text",
  "regex": "<string>",
  "is_required": false
}
```


**Response `200`:** The created field

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Field"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "field",
    "id": "6152120297080d55bdd13197",
    "name": "Signature",
    "type": "signature",
    "regex": "<string>",
    "is_pre_defined": false,
    "is_active": false,
    "is_required": false,
    "is_standard": false,
    "is_read_only": false,
    "is_visible": false
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## GetField

```pascal
function GetField(const AAccountId: string; const FieldId: string): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/fields/{fieldId}`

Retrieve a single field definition.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `fieldId` (path, required): The field ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The field

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Field"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "field",
    "id": "6152120297080d55bdd13197",
    "name": "Signature",
    "type": "signature",
    "regex": "<string>",
    "is_pre_defined": false,
    "is_active": false,
    "is_required": false,
    "is_standard": false,
    "is_read_only": false,
    "is_visible": false
  }
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## UpdateField

```pascal
function UpdateField(const AAccountId: string; const FieldId: string; Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/accounts/{accountId}/fields/{fieldId}`

Update a field definition.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `fieldId` (path, required): The field ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "properties": {
    "name": {
      "type": "string"
    },
    "regex": {
      "type": [
        "string",
        "null"
      ]
    },
    "is_active": {
      "type": "boolean"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "name": "<string>",
  "regex": "<string>",
  "is_active": false
}
```


**Response `200`:** The updated field

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Field"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "field",
    "id": "6152120297080d55bdd13197",
    "name": "Signature",
    "type": "signature",
    "regex": "<string>",
    "is_pre_defined": false,
    "is_active": false,
    "is_required": false,
    "is_standard": false,
    "is_read_only": false,
    "is_visible": false
  }
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## DeleteField

```pascal
function DeleteField(const AAccountId: string; const FieldId: string): TAssinafyResponse;
```

`DELETE /v1/accounts/{accountId}/fields/{fieldId}`

Delete a field definition.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `fieldId` (path, required): The field ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** Field deleted

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": [],
          "example": []
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": []
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ValidateFieldValue

```pascal
function ValidateFieldValue(const AAccountId: string; const FieldId: string; Body: TJSONData): TAssinafyResponse;
```

`POST /v1/accounts/{accountId}/fields/{fieldId}/validate`

Validate an input value against a field definition. Typically called with a signer access code during the signing flow.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `fieldId` (path, required): The field ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "required": [
    "value"
  ],
  "properties": {
    "value": {
      "description": "The input value to validate.",
      "example": "400.676.228-36"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "value": "400.676.228-36"
}
```


**Response `200`:** Validation result

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/FieldValidation"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "type": "cpf",
    "success": true,
    "error_message": ""
  }
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ValidateMultipleFieldValues

```pascal
function ValidateMultipleFieldValues(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
```

`POST /v1/accounts/{accountId}/fields/validate-multiple`

Validate multiple input values at once. The request body is a JSON array of `{field_id, value}` objects.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "type": "array",
  "items": {
    "required": [
      "field_id",
      "value"
    ],
    "properties": {
      "field_id": {
        "description": "The field definition ID.",
        "type": "string",
        "example": "63488ffb7adf435aba319787"
      },
      "value": {
        "description": "The input value to validate.",
        "example": "1111111111111"
      }
    },
    "type": "object"
  }
}
```

**Payload shape:**

```json
[
  {
    "field_id": "63488ffb7adf435aba319787",
    "value": "1111111111111"
  }
]
```


**Response `200`:** Validation results

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/FieldValidationResult"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "field_id": "63488ffb7adf435aba319787",
      "type": "cpf",
      "success": false,
      "error_message": "Invalid CPF."
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListFieldTypes

```pascal
function ListFieldTypes: TAssinafyResponse;
```

`GET /v1/field-types`

List the possible field types. `cpf` expects 11 digits; `cnpj` accepts 14-char values (letters A-Z allowed in positions 1–12 per the CNPJ Alfanumérico rule; check digits 13–14 stay numeric). Punctuation is ignored during validation.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request body:** none.

**Response `200`:** Field types

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/FieldType"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "type": "cpf",
      "name": "CPF"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListTwoFactorMethods

```pascal
function ListTwoFactorMethods: TAssinafyResponse;
```

`GET /v1/users/self/mfa`

The authenticated user's enrolled two-factor methods and how many recovery codes remain unused.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request body:** none.

**Response `200`:** Enrolled methods

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "properties": {
            "methods": {
              "type": "array",
              "items": {
                "properties": {
                  "id": {
                    "type": "string",
                    "example": "a1b2c3d4e5f60718293a4b5c6d7e8f90"
                  },
                  "type": {
                    "type": "string",
                    "example": "Totp"
                  },
                  "label": {
                    "type": "string",
                    "example": "My phone"
                  },
                  "confirmed_at": {
                    "type": "string",
                    "format": "date-time",
                    "example": "2026-09-09T14:21:03Z"
                  },
                  "last_used_at": {
                    "type": "string",
                    "format": "date-time",
                    "example": "2026-09-09T18:02:44Z"
                  }
                },
                "type": "object"
              }
            },
            "recovery_codes_remaining": {
              "type": "integer",
              "example": 8
            }
          },
          "type": "object"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "methods": [
      {
        "id": "a1b2c3d4e5f60718293a4b5c6d7e8f90",
        "type": "Totp",
        "label": "My phone",
        "confirmed_at": "2026-09-09T14:21:03Z",
        "last_used_at": "2026-09-09T18:02:44Z"
      }
    ],
    "recovery_codes_remaining": 8
  }
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## StartAuthenticatorEnrollment

```pascal
function StartAuthenticatorEnrollment(Body: TJSONData = nil): TAssinafyResponse;
```

`POST /v1/users/self/mfa/totp`

Creates an unconfirmed authenticator method and returns the shared secret. The secret is returned only by this call and cannot be retrieved again. Two-factor authentication is not active until the enrollment is confirmed.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request: `application/json` (optional)**

```json
{
  "properties": {
    "label": {
      "type": "string",
      "example": "My phone"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "label": "My phone"
}
```


**Response `200`:** Enrollment started

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "properties": {
            "id": {
              "type": "string",
              "example": "a1b2c3d4e5f60718293a4b5c6d7e8f90"
            },
            "secret": {
              "type": "string",
              "example": "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ"
            },
            "provisioning_uri": {
              "type": "string",
              "example": "otpauth://totp/user%40example.com?issuer=Assinafy&secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ"
            }
          },
          "type": "object"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "id": "a1b2c3d4e5f60718293a4b5c6d7e8f90",
    "secret": "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ",
    "provisioning_uri": "otpauth://totp/user%40example.com?issuer=Assinafy&secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ"
  }
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ConfirmAuthenticatorEnrollment

```pascal
function ConfirmAuthenticatorEnrollment(Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/users/self/mfa/totp/confirm`

Activates the method by proving one live code from the NEW device (`code`). Returns the recovery codes, which are shown only once and cannot be retrieved again. From this point every login requires a second factor. If the user already has a confirmed method of the same type, confirming REPLACES it — the old one is soft-deleted and recovery codes are reissued — so this call additionally requires re-authentication via `password` or `reauth_code` (a live code from the CURRENT device, or one of the existing recovery codes), exactly like disabling a method. First-time enrollment needs neither.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request: `application/json` (required)**

```json
{
  "required": [
    "id",
    "code"
  ],
  "properties": {
    "id": {
      "type": "string",
      "example": "a1b2c3d4e5f60718293a4b5c6d7e8f90"
    },
    "code": {
      "description": "Live code from the NEW device being confirmed.",
      "type": "string",
      "example": "123456"
    },
    "password": {
      "description": "Re-authentication proof, required only when replacing an existing confirmed method.",
      "type": "string",
      "format": "password"
    },
    "reauth_code": {
      "description": "Re-authentication proof alternative to password: a live code from the CURRENT device, or a recovery code. Required only when replacing an existing confirmed method.",
      "type": "string"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "id": "a1b2c3d4e5f60718293a4b5c6d7e8f90",
  "code": "123456",
  "password": "<string>",
  "reauth_code": "<string>"
}
```


**Response `200`:** Two-factor enabled

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "properties": {
            "recovery_codes": {
              "type": "array",
              "items": {
                "type": "string",
                "example": "ABCD-EFGH-JKMN"
              }
            }
          },
          "type": "object"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "recovery_codes": [
      "ABCD-EFGH-JKMN"
    ]
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## RegenerateRecoveryCodes

```pascal
function RegenerateRecoveryCodes(Body: TJSONData): TAssinafyResponse;
```

`POST /v1/users/self/mfa/recovery-codes`

Issues a fresh set of ten recovery codes and invalidates the previous set. Requires the current password, a live authenticator code, or one of the existing recovery codes (which is then consumed).

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request: `application/json` (required)**

```json
{
  "properties": {
    "password": {
      "type": "string",
      "format": "password"
    },
    "code": {
      "description": "A live 6-digit authenticator code, or one of the existing recovery codes.",
      "type": "string",
      "example": "123456"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "password": "<string>",
  "code": "123456"
}
```


**Response `200`:** New recovery codes

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "properties": {
            "recovery_codes": {
              "type": "array",
              "items": {
                "type": "string",
                "example": "ABCD-EFGH-JKMN"
              }
            }
          },
          "type": "object"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "recovery_codes": [
      "ABCD-EFGH-JKMN"
    ]
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## RemoveATwoFactorMethod

```pascal
function RemoveATwoFactorMethod(const CustomId: string; Body: TJSONData): TAssinafyResponse;
```

`DELETE /v1/users/self/mfa/{customId}`

Removes an enrolled method. Requires the current password, a live authenticator code, or one of the existing recovery codes (which is then consumed), so that a stolen session cannot silently disable two-factor authentication. Removing the last method also discards the recovery codes.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `customId` (path, required):
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "properties": {
    "password": {
      "type": "string",
      "format": "password"
    },
    "code": {
      "description": "A live 6-digit authenticator code, or one of the existing recovery codes.",
      "type": "string",
      "example": "123456"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "password": "<string>",
  "code": "123456"
}
```


**Response `200`:** Method removed

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "properties": {
            "is_mfa_enabled": {
              "type": "boolean",
              "example": false
            }
          },
          "type": "object"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "is_mfa_enabled": false
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## GetMyNotificationPreferences

```pascal
function GetMyNotificationPreferences: TAssinafyResponse;
```

`GET /v1/users/self/notification-preferences`

Which owner-facing document notifications the authenticated user receives by e-mail. All nine keys are always returned; everything defaults to `true`. Account and security e-mail (welcome, password reset, invitations, account deletion) is not configurable and never appears here.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request body:** none.

**Response `200`:** The current preferences

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/NotificationPreferences"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "DocumentCompleted": true,
    "SignerDeclined": true,
    "DocumentCancelled": true,
    "DocumentAboutToExpire": true,
    "DocumentExpired": true,
    "DocumentExpirationReset": true,
    "DocumentProcessingFailed": true,
    "TemplateProcessingFailed": true,
    "SignerWhatsappFailed": true
  }
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## UpdateMyNotificationPreferences

```pascal
function UpdateMyNotificationPreferences(Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/users/self/notification-preferences`

Merges the supplied map into the authenticated user's preferences. Send only the keys you want to change — omitted keys keep their current value. Setting a key to `false` stops that e-mail for this user in every account they belong to. Returns the full map. An unknown code, a non-boolean value, or an empty body is rejected with 400 and nothing is written.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request: `application/json` (required)**

```json
{
  "description": "Owner-facing document notifications, keyed by notification type. `true` means the e-mail is sent.",
  "properties": {
    "DocumentCompleted": {
      "description": "Every signer has signed and the document is certified.",
      "type": "boolean",
      "example": true
    },
    "SignerDeclined": {
      "description": "A signer declined to sign.",
      "type": "boolean",
      "example": true
    },
    "DocumentCancelled": {
      "description": "The document was cancelled.",
      "type": "boolean",
      "example": true
    },
    "DocumentAboutToExpire": {
      "description": "The signature deadline is approaching.",
      "type": "boolean",
      "example": true
    },
    "DocumentExpired": {
      "description": "The signature deadline passed.",
      "type": "boolean",
      "example": true
    },
    "DocumentExpirationReset": {
      "description": "The signature deadline was extended.",
      "type": "boolean",
      "example": true
    },
    "DocumentProcessingFailed": {
      "description": "An uploaded document could not be processed.",
      "type": "boolean",
      "example": true
    },
    "TemplateProcessingFailed": {
      "description": "A template could not be processed.",
      "type": "boolean",
      "example": true
    },
    "SignerWhatsappFailed": {
      "description": "A WhatsApp notification to a signer could not be delivered.",
      "type": "boolean",
      "example": true
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "DocumentCompleted": true,
  "SignerDeclined": true,
  "DocumentCancelled": true,
  "DocumentAboutToExpire": true,
  "DocumentExpired": true,
  "DocumentExpirationReset": true,
  "DocumentProcessingFailed": true,
  "TemplateProcessingFailed": true,
  "SignerWhatsappFailed": true
}
```


**Response `200`:** The updated preferences

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/NotificationPreferences"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "DocumentCompleted": true,
    "SignerDeclined": true,
    "DocumentCancelled": true,
    "DocumentAboutToExpire": true,
    "DocumentExpired": true,
    "DocumentExpirationReset": true,
    "DocumentProcessingFailed": true,
    "TemplateProcessingFailed": true,
    "SignerWhatsappFailed": true
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ExchangeOAuthToken

```pascal
function ExchangeOAuthToken(Body: TJSONData): TAssinafyResponse;
```

`POST /v1/oauth/token`

Implements the RFC 6749 §5.1/§5.2 token-endpoint body contract in
     *         both directions: a successful exchange returns a flat JSON object with
     *         `access_token` at the top level, and a failure returns a flat
     *         `{error, error_description}` object — neither is wrapped in this API's
     *         usual response envelope, since no standard OAuth client library (or MCP
     *         connector) would find `access_token` or `error` inside a `data` key.
     *
     *         The third grant, `urn:ietf:params:oauth:grant-type:token-exchange` (RFC 8693),
     *         is restricted to a confidential internal-service client (see `/oauth/introspect`)
     *         and trades a front-end resource's access token (the `subject_token`) for one
     *         minted for THIS API — the crossing an MCP server makes after a user consents,
     *         since its own token can never be forwarded here directly. The issued token is
     *         never wider than the subject: `scope`, when sent, must be a subset of the
     *         subject's own scopes, and `resource` must equal this API's own resource
     *         identifier exactly. No refresh token is issued; the caller re-exchanges from
     *         the user's own token instead of holding unattended API access.

**Authentication:** Public: workspace credentials are omitted.

**Parameters:**

No path or query parameters.

**Request: `application/x-www-form-urlencoded` (required)**

```json
{
  "description": "Body of `POST /v1/oauth/token`. Sent form-encoded per RFC 6749, or as JSON.",
  "required": [
    "grant_type",
    "client_id"
  ],
  "properties": {
    "grant_type": {
      "description": "`urn:ietf:params:oauth:grant-type:token-exchange` is for internal service clients only (Assinafy's own MCP server) — an ordinary confidential or public client authenticates with it and always gets `invalid_client`, exactly as an unrecognized client would. Everyday integrators use `authorization_code` and `refresh_token`.",
      "type": "string",
      "enum": [
        "authorization_code",
        "refresh_token",
        "urn:ietf:params:oauth:grant-type:token-exchange"
      ]
    },
    "code": {
      "type": "string"
    },
    "redirect_uri": {
      "type": "string",
      "format": "uri"
    },
    "code_verifier": {
      "description": "RFC 7636: 43-128 characters from [A-Za-z0-9-._~]. Shorter values are rejected with `invalid_grant`.",
      "type": "string"
    },
    "refresh_token": {
      "type": "string"
    },
    "client_id": {
      "type": "string"
    },
    "client_secret": {
      "description": "Confidential clients only. Public clients authenticate with PKCE and are never issued a secret; the token-exchange grant requires a confidential, internal-service client and therefore always requires this.",
      "type": "string"
    },
    "resource": {
      "description": "RFC 8707 resource indicator. For `authorization_code`/`refresh_token`, optional; when present it must be the `resource` value published by /.well-known/oauth-protected-resource and must match the one sent to /authorize, otherwise `invalid_target`. For the token-exchange grant it is REQUIRED and must equal this API's own resource identifier exactly (never a front-end resource such as the MCP server), otherwise `invalid_target`.",
      "type": "string",
      "format": "uri"
    },
    "subject_token": {
      "description": "Token-exchange grant only. The front-end resource's access token being traded in. Must be a live, original (never itself exchanged) token minted for a resource this server issues tokens for, other than this API's own audience.",
      "type": "string"
    },
    "subject_token_type": {
      "description": "Token-exchange grant only. Required; only `urn:ietf:params:oauth:token-type:access_token` is supported.",
      "type": "string",
      "enum": [
        "urn:ietf:params:oauth:token-type:access_token"
      ]
    },
    "requested_token_type": {
      "description": "Token-exchange grant only. Optional; when present it must agree with the only type this server issues.",
      "type": "string",
      "enum": [
        "urn:ietf:params:oauth:token-type:access_token"
      ]
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "grant_type": "authorization_code",
  "code": "<string>",
  "redirect_uri": "https://app.example.com/resource",
  "code_verifier": "<string>",
  "refresh_token": "<string>",
  "client_id": "<string>",
  "client_secret": "<string>",
  "resource": "https://app.example.com/resource",
  "subject_token": "<string>",
  "subject_token_type": "urn:ietf:params:oauth:token-type:access_token",
  "requested_token_type": "urn:ietf:params:oauth:token-type:access_token"
}
```


**Request: `application/json` (required)**

```json
{
  "description": "Body of `POST /v1/oauth/token`. Sent form-encoded per RFC 6749, or as JSON.",
  "required": [
    "grant_type",
    "client_id"
  ],
  "properties": {
    "grant_type": {
      "description": "`urn:ietf:params:oauth:grant-type:token-exchange` is for internal service clients only (Assinafy's own MCP server) — an ordinary confidential or public client authenticates with it and always gets `invalid_client`, exactly as an unrecognized client would. Everyday integrators use `authorization_code` and `refresh_token`.",
      "type": "string",
      "enum": [
        "authorization_code",
        "refresh_token",
        "urn:ietf:params:oauth:grant-type:token-exchange"
      ]
    },
    "code": {
      "type": "string"
    },
    "redirect_uri": {
      "type": "string",
      "format": "uri"
    },
    "code_verifier": {
      "description": "RFC 7636: 43-128 characters from [A-Za-z0-9-._~]. Shorter values are rejected with `invalid_grant`.",
      "type": "string"
    },
    "refresh_token": {
      "type": "string"
    },
    "client_id": {
      "type": "string"
    },
    "client_secret": {
      "description": "Confidential clients only. Public clients authenticate with PKCE and are never issued a secret; the token-exchange grant requires a confidential, internal-service client and therefore always requires this.",
      "type": "string"
    },
    "resource": {
      "description": "RFC 8707 resource indicator. For `authorization_code`/`refresh_token`, optional; when present it must be the `resource` value published by /.well-known/oauth-protected-resource and must match the one sent to /authorize, otherwise `invalid_target`. For the token-exchange grant it is REQUIRED and must equal this API's own resource identifier exactly (never a front-end resource such as the MCP server), otherwise `invalid_target`.",
      "type": "string",
      "format": "uri"
    },
    "subject_token": {
      "description": "Token-exchange grant only. The front-end resource's access token being traded in. Must be a live, original (never itself exchanged) token minted for a resource this server issues tokens for, other than this API's own audience.",
      "type": "string"
    },
    "subject_token_type": {
      "description": "Token-exchange grant only. Required; only `urn:ietf:params:oauth:token-type:access_token` is supported.",
      "type": "string",
      "enum": [
        "urn:ietf:params:oauth:token-type:access_token"
      ]
    },
    "requested_token_type": {
      "description": "Token-exchange grant only. Optional; when present it must agree with the only type this server issues.",
      "type": "string",
      "enum": [
        "urn:ietf:params:oauth:token-type:access_token"
      ]
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "grant_type": "authorization_code",
  "code": "<string>",
  "redirect_uri": "https://app.example.com/resource",
  "code_verifier": "<string>",
  "refresh_token": "<string>",
  "client_id": "<string>",
  "client_secret": "<string>",
  "resource": "https://app.example.com/resource",
  "subject_token": "<string>",
  "subject_token_type": "urn:ietf:params:oauth:token-type:access_token",
  "requested_token_type": "urn:ietf:params:oauth:token-type:access_token"
}
```


**Response `200`:** The token response

Content type: `application/json`

```json
{
  "properties": {
    "access_token": {
      "type": "string"
    },
    "issued_token_type": {
      "description": "Present only for the token-exchange grant, per RFC 8693 §2.2.1.",
      "type": "string",
      "example": "urn:ietf:params:oauth:token-type:access_token"
    },
    "token_type": {
      "type": "string",
      "example": "Bearer"
    },
    "expires_in": {
      "description": "For the token-exchange grant, clamped to the subject token's own remaining lifetime as well as the exchanged-token TTL — never longer than either.",
      "type": "integer",
      "example": 3600
    },
    "refresh_token": {
      "description": "Present only when the `offline_access` scope was requested AND consented on the authorization_code/refresh_token grants. Never present for the token-exchange grant. Without it a client must send the user through the authorization flow again once the access token expires.",
      "type": [
        "string",
        "null"
      ]
    },
    "scope": {
      "description": "The scope of the ACCESS token. `offline_access` is a request-time signal rather than a permission, so it never appears here even when it was requested.",
      "type": "string",
      "example": "documents:read"
    },
    "id_token": {
      "description": "A signed OIDC id_token (RS256). Present only when the openid scope was granted.",
      "type": [
        "string",
        "null"
      ]
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "access_token": "<string>",
  "issued_token_type": "urn:ietf:params:oauth:token-type:access_token",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "<string>",
  "scope": "documents:read",
  "id_token": "<string>"
}
```


**Response `400`:** `invalid_grant` (bad, expired, replayed, or wrong-client authorization code; a `code_verifier` outside the RFC 7636 grammar of 43-128 unreserved characters; redirect_uri mismatch; a refresh token whose authorization no longer includes `offline_access`; for token-exchange, a `subject_token` that is unusable, itself an exchanged token, not visible to service clients, or expired), `invalid_target` (a `resource` this server does not issue tokens for, one disagreeing with the authorized value, or — for token-exchange — one other than this API's own resource identifier), `invalid_scope` (token-exchange only: the requested `scope` is not a subset of the subject token's own scopes), `invalid_request` (token-exchange only: an unsupported `subject_token_type`/`requested_token_type`), or `unsupported_grant_type`

Content type: `application/json`

```json
{
  "properties": {
    "error": {
      "type": "string",
      "enum": [
        "invalid_grant",
        "invalid_target",
        "invalid_scope",
        "invalid_request",
        "unsupported_grant_type"
      ]
    },
    "error_description": {
      "type": "string"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "error": "invalid_grant",
  "error_description": "<string>"
}
```


**Response `401`:** `invalid_client` — unknown/disabled client or failed client authentication. The description never reveals whether client_id exists.

Content type: `application/json`

```json
{
  "properties": {
    "error": {
      "type": "string",
      "example": "invalid_client"
    },
    "error_description": {
      "type": "string",
      "example": "Client authentication failed."
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "error": "invalid_client",
  "error_description": "Client authentication failed."
}
```


**Response `429`:** Rate limit exceeded; wait the `Retry-After` seconds. Limited per caller IP.

**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## RevokeOAuthToken

```pascal
function RevokeOAuthToken(Body: TJSONData): TAssinafyResponse;
```

`POST /v1/oauth/revoke`

Revokes an access or refresh token. Every token outcome always returns 200 — including a token that does not exist, is already revoked, or is malformed — so the endpoint can never be used to probe whether a token exists. The one exception is failed client authentication, which returns 401.

**Authentication:** Public: workspace credentials are omitted.

**Parameters:**

No path or query parameters.

**Request: `application/x-www-form-urlencoded` (required)**

```json
{
  "description": "Body of `POST /v1/oauth/revoke`. Sent form-encoded per RFC 7009, or as JSON.",
  "required": [
    "token",
    "client_id"
  ],
  "properties": {
    "token": {
      "type": "string"
    },
    "token_type_hint": {
      "type": "string",
      "enum": [
        "access_token",
        "refresh_token"
      ]
    },
    "client_id": {
      "type": "string"
    },
    "client_secret": {
      "type": "string"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "token": "<string>",
  "token_type_hint": "access_token",
  "client_id": "<string>",
  "client_secret": "<string>"
}
```


**Request: `application/json` (required)**

```json
{
  "description": "Body of `POST /v1/oauth/revoke`. Sent form-encoded per RFC 7009, or as JSON.",
  "required": [
    "token",
    "client_id"
  ],
  "properties": {
    "token": {
      "type": "string"
    },
    "token_type_hint": {
      "type": "string",
      "enum": [
        "access_token",
        "refresh_token"
      ]
    },
    "client_id": {
      "type": "string"
    },
    "client_secret": {
      "type": "string"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "token": "<string>",
  "token_type_hint": "access_token",
  "client_id": "<string>",
  "client_secret": "<string>"
}
```


**Response `200`:** Revoked

**Response `401`:** `invalid_client` — the only case that is not reported as success. Every token outcome (revoked, already revoked, unknown, malformed) always returns 200; only failed client authentication returns 401.

Content type: `application/json`

```json
{
  "properties": {
    "error": {
      "type": "string",
      "example": "invalid_client"
    },
    "error_description": {
      "type": "string",
      "example": "Client authentication failed."
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "error": "invalid_client",
  "error_description": "Client authentication failed."
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## GetOAuthUserInfo

```pascal
function GetOAuthUserInfo: TAssinafyResponse;
```

`GET /v1/oauth/userinfo`

Claims about the user who authorized this token. Requires the openid scope; name requires profile and email requires email. Per OIDC Core §5.3.2, the response is a flat JSON object of claims — never this API's usual `{status, data, message}` envelope.

**Authentication:** Required bearer access token (`Client.AccessToken`).

**Parameters:**

No path or query parameters.

**Request body:** none.

**Response `200`:** The user's claims

Content type: `application/json`

```json
{
  "properties": {
    "sub": {
      "type": "string",
      "example": "d6zqpbyog2v3xvxerwn8la94"
    },
    "name": {
      "type": [
        "string",
        "null"
      ],
      "example": "Maria Silva"
    },
    "email": {
      "type": [
        "string",
        "null"
      ],
      "format": "email"
    },
    "email_verified": {
      "type": [
        "boolean",
        "null"
      ]
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "sub": "d6zqpbyog2v3xvxerwn8la94",
  "name": "Maria Silva",
  "email": "developer@example.com",
  "email_verified": false
}
```


**Response `403`:** Authenticated but not allowed to perform this action.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 403
        },
        "message": {
          "type": "string",
          "example": "You are not allowed to perform this action."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 403,
  "message": "You are not allowed to perform this action.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## DownloadDocumentThumbnail

```pascal
function DownloadDocumentThumbnail(const DocumentId: string): TAssinafyResponse;
```

`GET /v1/documents/{documentId}/thumbnail`

Download the thumbnail image of a document's first page.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The thumbnail image

Content type: `image/*`

```json
{
  "type": "string",
  "format": "binary"
}
```

Raw binary bytes; preserved without JSON decoding.

**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## DownloadDocumentPage

```pascal
function DownloadDocumentPage(const DocumentId: string; const PageId: string): TAssinafyResponse;
```

`GET /v1/documents/{documentId}/pages/{pageId}/download`

Download the rendered image of a specific document page.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


- `pageId` (path, required): The page ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The page image

Content type: `image/*`

```json
{
  "type": "string",
  "format": "binary"
}
```

Raw binary bytes; preserved without JSON decoding.

**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ViewPublicDocument

```pascal
function ViewPublicDocument(const DocumentId: string): TAssinafyResponse;
```

`GET /v1/public/documents/{documentId}`

Retrieve a publicly shared document by ID. Public endpoint.

**Authentication:** Public: workspace credentials are omitted.

**Parameters:**

- `documentId` (path, required): The document ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The public document

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Document"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "document",
    "id": "615601fab04c0a3147bb1246",
    "account_id": "d199996981dbd199996981db",
    "template_id": null,
    "name": "document.pdf",
    "status": "metadata_ready",
    "artifacts": {
      "original": "https://api.assinafy.com.br/v1/documents/doc1/download/original"
    },
    "is_closed": false,
    "signing_url": "https://api.assinafy.com.br/v1/sign/doc1",
    "decline_reason": null,
    "declined_by": {
      "resource": "signer",
      "id": "62d6ee35c7741ca4006b9e11",
      "full_name": "John Signer",
      "email": "developer@example.com",
      "whatsapp_phone_number": "+5548999990000",
      "government_id": "39053344705",
      "has_accepted_terms": false
    },
    "tags": [
      {
        "id": "<string>",
        "name": "<string>"
      }
    ],
    "assignment": {
      "resource": "assignment",
      "id": "615606ef81d199996981dbce",
      "sender_email": "developer@example.com",
      "method": "virtual",
      "expires_at": null,
      "message": "<string>",
      "signers": [
        {
          "resource": "signer",
          "id": "62d6ee35c7741ca4006b9e11",
          "full_name": "John Signer",
          "email": "developer@example.com",
          "whatsapp_phone_number": "+5548999990000",
          "government_id": "39053344705",
          "has_accepted_terms": false,
          "verification_method": "Email",
          "notification_methods": [
            "Email"
          ],
          "step": 1,
          "notified": false,
          "completed": false,
          "notification_history": [
            {
              "event": "signature_request",
              "status": "sent",
              "error_code": "<string>",
              "error_message": "<string>",
              "sent_at": "2026-07-07T12:00:00Z",
              "failed_at": null
            }
          ]
        }
      ],
      "copy_receivers": [
        {}
      ],
      "items": [
        {
          "id": "<string>",
          "page": {
            "id": "615601faf166d6d1d8e7dc30",
            "number": 1,
            "height": 2100,
            "width": 1275,
            "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
          },
          "signer": {},
          "field": {},
          "display_settings": "<string>",
          "value": "<string>",
          "completed": false
        }
      ],
      "summary": {
        "signer_count": 1,
        "completed_count": 1,
        "signers": [
          {}
        ]
      },
      "signing_urls": [
        {
          "signer_id": "<string>",
          "url": "https://api.assinafy.com.br/v1/sign/doc1?email=developer@example.com"
        }
      ]
    },
    "pages": [
      {
        "id": "615601faf166d6d1d8e7dc30",
        "number": 1,
        "height": 2100,
        "width": 1275,
        "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
      }
    ],
    "created_at": "2026-06-03T03:54:16Z",
    "updated_at": "2026-06-03T03:54:16Z"
  }
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## SendAccessTokenForPublicDocument

```pascal
function SendAccessTokenForPublicDocument(const DocumentId: string; Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/public/documents/{documentId}/send-token`

Send a one-time access token to a signer of a public document, so they can view it. The document must be pending signature, and `recipient` must belong to a signer of the document who has not signed yet. Only the `email` channel is supported. Public endpoint.

**Authentication:** Public: workspace credentials are omitted.

**Parameters:**

- `documentId` (path, required): The document ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "required": [
    "channel",
    "recipient"
  ],
  "properties": {
    "channel": {
      "description": "Where to send the token. Only `email` is supported.",
      "type": "string",
      "enum": [
        "email"
      ],
      "example": "email"
    },
    "recipient": {
      "description": "The signer's address on that channel — for `email`, the signer's email address.",
      "type": "string",
      "example": "signer@example.com"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "channel": "email",
  "recipient": "signer@example.com"
}
```


**Response `200`:** Token sent

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "properties": {
            "document": {
              "properties": {
                "resource": {
                  "type": "string",
                  "example": "document"
                },
                "id": {
                  "type": "string",
                  "example": "a1b2c3d4e5f6a7b8c9d0"
                },
                "name": {
                  "type": "string",
                  "example": "Contract.pdf"
                },
                "page_count": {
                  "type": "integer",
                  "example": 3
                },
                "created_by": {
                  "type": "string",
                  "example": "Jane Doe"
                }
              },
              "type": "object"
            },
            "channel": {
              "type": "string",
              "example": "email"
            },
            "recipient": {
              "type": "string",
              "example": "signer@example.com"
            }
          },
          "type": "object"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "document": {
      "resource": "document",
      "id": "a1b2c3d4e5f6a7b8c9d0",
      "name": "Contract.pdf",
      "page_count": 3,
      "created_by": "Jane Doe"
    },
    "channel": "email",
    "recipient": "signer@example.com"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListSigners

```pascal
function ListSigners(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/signers`

List the signers of a workspace.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `search` (query, optional): Filter by full_name or email.
```json
{
  "type": "string"
}
```


- `page` (query, optional): Page number.
```json
{
  "type": "integer",
  "minimum": 1,
  "example": 1
}
```


- `per-page` (query, optional): Records per page (max 100).
```json
{
  "type": "integer",
  "maximum": 100,
  "example": 25
}
```


**Request body:** none.

**Response `200`:** A page of signers

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/Signer"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "resource": "signer",
      "id": "62d6ee35c7741ca4006b9e11",
      "full_name": "John Signer",
      "email": "developer@example.com",
      "whatsapp_phone_number": "+5548999990000",
      "government_id": "39053344705",
      "has_accepted_terms": false
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## CreateSigner

```pascal
function CreateSigner(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
```

`POST /v1/accounts/{accountId}/signers`

Create a signer in the workspace.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "required": [
    "full_name"
  ],
  "properties": {
    "full_name": {
      "type": "string",
      "example": "John Dove"
    },
    "email": {
      "type": "string",
      "format": "email",
      "example": "developer@example.com"
    },
    "whatsapp_phone_number": {
      "description": "E.164; normalized on save.",
      "type": "string",
      "example": "+5548999990000"
    },
    "government_id": {
      "description": "Signer's CPF (11 digits) or CNPJ (14 characters; may be alphanumeric). Formatting is accepted and the value is normalized on save.",
      "type": "string",
      "example": "390.533.447-05"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "full_name": "John Dove",
  "email": "developer@example.com",
  "whatsapp_phone_number": "+5548999990000",
  "government_id": "390.533.447-05"
}
```


**Response `200`:** The created signer

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Signer"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "signer",
    "id": "62d6ee35c7741ca4006b9e11",
    "full_name": "John Signer",
    "email": "developer@example.com",
    "whatsapp_phone_number": "+5548999990000",
    "government_id": "39053344705",
    "has_accepted_terms": false
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## GetSigner

```pascal
function GetSigner(const AAccountId: string; const SignerId: string): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/signers/{signerId}`

Retrieve a signer's information.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `signerId` (path, required): The signer ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The signer

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Signer"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "signer",
    "id": "62d6ee35c7741ca4006b9e11",
    "full_name": "John Signer",
    "email": "developer@example.com",
    "whatsapp_phone_number": "+5548999990000",
    "government_id": "39053344705",
    "has_accepted_terms": false
  }
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## UpdateSigner

```pascal
function UpdateSigner(const AAccountId: string; const SignerId: string; Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/accounts/{accountId}/signers/{signerId}`

Update a signer's information.

**Verification integrity:** `email` / `whatsapp_phone_number` cannot be changed while the signer has verified that channel on an in-flight (not yet certificated) document — the response is `400` naming the offending document(s). Already-certificated documents do not block updates. Changing a channel that has *unverified* in-flight requests rotates their access/verification codes (invalidating previously sent links/OTPs); use the resend endpoint to redeliver. `full_name` can always be updated.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `signerId` (path, required): The signer ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "properties": {
    "full_name": {
      "type": "string",
      "example": "John Dove"
    },
    "email": {
      "type": "string",
      "format": "email",
      "example": "developer@example.com"
    },
    "whatsapp_phone_number": {
      "description": "E.164; normalized on save.",
      "type": "string",
      "example": "+5548999990000"
    },
    "government_id": {
      "description": "Signer's CPF (11 digits) or CNPJ (14 characters; may be alphanumeric). Formatting is accepted and the value is normalized on save.",
      "type": "string",
      "example": "390.533.447-05"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "full_name": "John Dove",
  "email": "developer@example.com",
  "whatsapp_phone_number": "+5548999990000",
  "government_id": "390.533.447-05"
}
```


**Response `200`:** The updated signer

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Signer"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "signer",
    "id": "62d6ee35c7741ca4006b9e11",
    "full_name": "John Signer",
    "email": "developer@example.com",
    "whatsapp_phone_number": "+5548999990000",
    "government_id": "39053344705",
    "has_accepted_terms": false
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## DeleteSigner

```pascal
function DeleteSigner(const AAccountId: string; const SignerId: string): TAssinafyResponse;
```

`DELETE /v1/accounts/{accountId}/signers/{signerId}`

Delete a signer.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `signerId` (path, required): The signer ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** Signer deleted

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": [],
          "example": []
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": []
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## GetCurrentSigner

```pascal
function GetCurrentSigner(const SignerAccessCode: string): TAssinafyResponse;
```

`GET /v1/signers/self`

Return the signer identified by the signer access code, including the `has_signature`/`has_initial`/`is_signature_reusable` flags.

**Authentication:** Required `SignerAccessCode` as the `signer-access-code` query parameter. Workspace credentials are omitted.

**Parameters:**

No path or query parameters.

**Request body:** none.

**Response `200`:** The signer

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/SignerSelf"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "signer",
    "id": "62d6ee35c7741ca4006b9e11",
    "full_name": "John Signer",
    "email": "developer@example.com",
    "whatsapp_phone_number": "+5548999990000",
    "government_id": "39053344705",
    "has_accepted_terms": false,
    "has_signature": true,
    "has_initial": false,
    "is_signature_reusable": false
  }
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## GetSignerDocument

```pascal
function GetSignerDocument(const SignerId: string; const SignerAccessCode: string): TAssinafyResponse;
```

`GET /v1/signers/{signerId}/document`

Return the document and the signer's assignment items, scoped to the signer access code.

**Authentication:** Required `SignerAccessCode` as the `signer-access-code` query parameter. Workspace credentials are omitted.

**Parameters:**

- `signerId` (path, required): The signer ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The document with the signer's items

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Document"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "document",
    "id": "615601fab04c0a3147bb1246",
    "account_id": "d199996981dbd199996981db",
    "template_id": null,
    "name": "document.pdf",
    "status": "metadata_ready",
    "artifacts": {
      "original": "https://api.assinafy.com.br/v1/documents/doc1/download/original"
    },
    "is_closed": false,
    "signing_url": "https://api.assinafy.com.br/v1/sign/doc1",
    "decline_reason": null,
    "declined_by": {
      "resource": "signer",
      "id": "62d6ee35c7741ca4006b9e11",
      "full_name": "John Signer",
      "email": "developer@example.com",
      "whatsapp_phone_number": "+5548999990000",
      "government_id": "39053344705",
      "has_accepted_terms": false
    },
    "tags": [
      {
        "id": "<string>",
        "name": "<string>"
      }
    ],
    "assignment": {
      "resource": "assignment",
      "id": "615606ef81d199996981dbce",
      "sender_email": "developer@example.com",
      "method": "virtual",
      "expires_at": null,
      "message": "<string>",
      "signers": [
        {
          "resource": "signer",
          "id": "62d6ee35c7741ca4006b9e11",
          "full_name": "John Signer",
          "email": "developer@example.com",
          "whatsapp_phone_number": "+5548999990000",
          "government_id": "39053344705",
          "has_accepted_terms": false,
          "verification_method": "Email",
          "notification_methods": [
            "Email"
          ],
          "step": 1,
          "notified": false,
          "completed": false,
          "notification_history": [
            {
              "event": "signature_request",
              "status": "sent",
              "error_code": "<string>",
              "error_message": "<string>",
              "sent_at": "2026-07-07T12:00:00Z",
              "failed_at": null
            }
          ]
        }
      ],
      "copy_receivers": [
        {}
      ],
      "items": [
        {
          "id": "<string>",
          "page": {
            "id": "615601faf166d6d1d8e7dc30",
            "number": 1,
            "height": 2100,
            "width": 1275,
            "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
          },
          "signer": {},
          "field": {},
          "display_settings": "<string>",
          "value": "<string>",
          "completed": false
        }
      ],
      "summary": {
        "signer_count": 1,
        "completed_count": 1,
        "signers": [
          {}
        ]
      },
      "signing_urls": [
        {
          "signer_id": "<string>",
          "url": "https://api.assinafy.com.br/v1/sign/doc1?email=developer@example.com"
        }
      ]
    },
    "pages": [
      {
        "id": "615601faf166d6d1d8e7dc30",
        "number": 1,
        "height": 2100,
        "width": 1275,
        "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
      }
    ],
    "created_at": "2026-06-03T03:54:16Z",
    "updated_at": "2026-06-03T03:54:16Z"
  }
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ViewDocumentToSign

```pascal
function ViewDocumentToSign(const SignerAccessCode: string; Query: TStrings = nil): TAssinafyResponse;
```

`GET /v1/sign`

Retrieve the document a signer has been invited to sign, using the signer access code. Marks the document as viewed. Returns 409 while the document is still being prepared (retry with backoff).

**Signers whose verification method is `DigitalCertificate`** must have confirmed their data *and* accepted the terms before this returns the document; otherwise it is `400`. Both are satisfied in one call to `PUT /v1/documents/{documentId}/signers/confirm-data` with `has_accepted_terms: true`, so send that before this endpoint — the `has_accepted_terms` query parameter here is too late to open the gate. `PUT /v1/signers/accept-terms` also works and is never gated.

**Authentication:** Required `SignerAccessCode` as the `signer-access-code` query parameter. Workspace credentials are omitted.

**Parameters:**

- `has_accepted_terms` (query, optional): Set true to record terms acceptance.
```json
{
  "type": "boolean"
}
```


**Request body:** none.

**Response `200`:** The document with the signer's assignment

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Document"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "document",
    "id": "615601fab04c0a3147bb1246",
    "account_id": "d199996981dbd199996981db",
    "template_id": null,
    "name": "document.pdf",
    "status": "metadata_ready",
    "artifacts": {
      "original": "https://api.assinafy.com.br/v1/documents/doc1/download/original"
    },
    "is_closed": false,
    "signing_url": "https://api.assinafy.com.br/v1/sign/doc1",
    "decline_reason": null,
    "declined_by": {
      "resource": "signer",
      "id": "62d6ee35c7741ca4006b9e11",
      "full_name": "John Signer",
      "email": "developer@example.com",
      "whatsapp_phone_number": "+5548999990000",
      "government_id": "39053344705",
      "has_accepted_terms": false
    },
    "tags": [
      {
        "id": "<string>",
        "name": "<string>"
      }
    ],
    "assignment": {
      "resource": "assignment",
      "id": "615606ef81d199996981dbce",
      "sender_email": "developer@example.com",
      "method": "virtual",
      "expires_at": null,
      "message": "<string>",
      "signers": [
        {
          "resource": "signer",
          "id": "62d6ee35c7741ca4006b9e11",
          "full_name": "John Signer",
          "email": "developer@example.com",
          "whatsapp_phone_number": "+5548999990000",
          "government_id": "39053344705",
          "has_accepted_terms": false,
          "verification_method": "Email",
          "notification_methods": [
            "Email"
          ],
          "step": 1,
          "notified": false,
          "completed": false,
          "notification_history": [
            {
              "event": "signature_request",
              "status": "sent",
              "error_code": "<string>",
              "error_message": "<string>",
              "sent_at": "2026-07-07T12:00:00Z",
              "failed_at": null
            }
          ]
        }
      ],
      "copy_receivers": [
        {}
      ],
      "items": [
        {
          "id": "<string>",
          "page": {
            "id": "615601faf166d6d1d8e7dc30",
            "number": 1,
            "height": 2100,
            "width": 1275,
            "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
          },
          "signer": {},
          "field": {},
          "display_settings": "<string>",
          "value": "<string>",
          "completed": false
        }
      ],
      "summary": {
        "signer_count": 1,
        "completed_count": 1,
        "signers": [
          {}
        ]
      },
      "signing_urls": [
        {
          "signer_id": "<string>",
          "url": "https://api.assinafy.com.br/v1/sign/doc1?email=developer@example.com"
        }
      ]
    },
    "pages": [
      {
        "id": "615601faf166d6d1d8e7dc30",
        "number": 1,
        "height": 2100,
        "width": 1275,
        "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
      }
    ],
    "created_at": "2026-06-03T03:54:16Z",
    "updated_at": "2026-06-03T03:54:16Z"
  }
}
```


**Response `400`:** A digital-certificate signer has not yet confirmed their data or accepted the terms.

**Response `409`:** The document is not ready to be viewed yet.

**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## SignAssignmentItems

```pascal
function SignAssignmentItems(const DocumentId: string; const AssignmentId: string; const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
```

`POST /v1/documents/{documentId}/assignments/{assignmentId}`

Sign a document with input fields (collect method): submit the signer's item values, completing their items. For **virtual** assignments the signer must first confirm their data via `PUT /v1/documents/{documentId}/signers/confirm-data`, otherwise this returns `400` (Signer data must be confirmed before signing). Signers whose verification method is `DigitalCertificate` cannot use this endpoint — their signature must be produced through `POST /v1/signers/certificate/start` + `/complete`, and this returns `400`. The request body is a JSON array of item entries. Uses the signer access code.

**Authentication:** Required `SignerAccessCode` as the `signer-access-code` query parameter. Workspace credentials are omitted.

**Parameters:**

- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


- `assignmentId` (path, required): The assignment ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "type": "array",
  "items": {
    "required": [
      "itemId",
      "fieldId",
      "pageId",
      "value"
    ],
    "properties": {
      "itemId": {
        "description": "The assignment item ID.",
        "type": "string",
        "example": "615606efcde1a39c9d21e30e"
      },
      "fieldId": {
        "description": "Field associated with the item.",
        "type": "string",
        "example": "6152120297080d55bdd13197"
      },
      "pageId": {
        "description": "The page ID.",
        "type": "string",
        "example": "615213ed81b071f4293b2fc2"
      },
      "value": {
        "description": "String representation of the value.",
        "type": "string",
        "example": "Signed by Sonny Bayer"
      }
    },
    "type": "object"
  }
}
```

**Payload shape:**

```json
[
  {
    "itemId": "615606efcde1a39c9d21e30e",
    "fieldId": "6152120297080d55bdd13197",
    "pageId": "615213ed81b071f4293b2fc2",
    "value": "Signed by Sonny Bayer"
  }
]
```


**Response `200`:** Signing result

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "object"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {}
}
```


**Response `400`:** Signer data must be confirmed before signing (virtual assignments), or the signer must sign with a digital certificate through the digital certificate endpoints.

**Response `409`:** The document is not ready to be signed yet.

**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## RejectAssignment

```pascal
function RejectAssignment(const DocumentId: string; const AssignmentId: string; const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/documents/{documentId}/assignments/{assignmentId}/reject`

The signer declines to sign the document, giving a reason. Uses the signer access code.

**Authentication:** Required `SignerAccessCode` as the `signer-access-code` query parameter. Workspace credentials are omitted.

**Parameters:**

- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


- `assignmentId` (path, required): The assignment ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "required": [
    "decline_reason"
  ],
  "properties": {
    "decline_reason": {
      "description": "Descriptive reason for declining. Up to 2000 characters; longer values return 400.",
      "type": "string",
      "maxLength": 2000,
      "example": "I do not agree with clause 2."
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "decline_reason": "I do not agree with clause 2."
}
```


**Response `200`:** Assignment declined

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "description": "Empty array.",
          "type": "array",
          "items": []
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {}
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## SignMultipleDocuments

```pascal
function SignMultipleDocuments(const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/signers/documents/sign-multiple`

Sign several documents in one request, for a signer with multiple pending documents. Each document must be prepared for the **virtual** signature method. Uses the signer access code.

**Authentication:** Required `SignerAccessCode` as the `signer-access-code` query parameter. Workspace credentials are omitted.

**Parameters:**

No path or query parameters.

**Request: `application/json` (required)**

```json
{
  "required": [
    "document_ids"
  ],
  "properties": {
    "document_ids": {
      "description": "IDs of the documents to sign.",
      "type": "array",
      "items": {
        "type": "string"
      },
      "example": [
        "documentid1",
        "documentid2"
      ]
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "document_ids": [
    "documentid1",
    "documentid2"
  ]
}
```


**Response `200`:** Signing result

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "description": "Empty array.",
          "type": "array",
          "items": []
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {}
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## DeclineMultipleDocuments

```pascal
function DeclineMultipleDocuments(const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/signers/documents/decline-multiple`

Decline several documents in one request. Uses the signer access code.

**Authentication:** Required `SignerAccessCode` as the `signer-access-code` query parameter. Workspace credentials are omitted.

**Parameters:**

No path or query parameters.

**Request: `application/json` (required)**

```json
{
  "required": [
    "document_ids",
    "decline_reason"
  ],
  "properties": {
    "document_ids": {
      "description": "IDs of the documents to decline.",
      "type": "array",
      "items": {
        "type": "string"
      },
      "example": [
        "documentid1",
        "documentid2"
      ]
    },
    "decline_reason": {
      "description": "Reason for declining. Up to 2000 characters; longer values return 400.",
      "type": "string",
      "maxLength": 2000,
      "example": "Unfavorable terms."
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "document_ids": [
    "documentid1",
    "documentid2"
  ],
  "decline_reason": "Unfavorable terms."
}
```


**Response `200`:** Decline result

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "description": "Empty array.",
          "type": "array",
          "items": []
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {}
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## VerifySignerCode

```pascal
function VerifySignerCode(const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
```

`POST /v1/verify`

Submit the verification code (OTP) sent to the signer to unlock the signing flow. Uses the signer access code.

**Authentication:** Required `SignerAccessCode` as the `signer-access-code` query parameter. Workspace credentials are omitted.

**Parameters:**

No path or query parameters.

**Request: `application/json` (required)**

```json
{
  "required": [
    "verification-code"
  ],
  "properties": {
    "verification-code": {
      "type": "string",
      "example": "123456"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "verification-code": "123456"
}
```


**Response `200`:** Code verified

Content type: `application/json`

```json
{
  "$ref": "#/components/schemas/Envelope"
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": ""
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ConfirmSignerData

```pascal
function ConfirmSignerData(const DocumentId: string; const SignerAccessCode: string; Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/documents/{documentId}/signers/confirm-data`

The signer confirms or updates their data before signing. Uses the signer access code.

**Authentication:** Required `SignerAccessCode` as the `signer-access-code` query parameter. Workspace credentials are omitted.

**Parameters:**

- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "properties": {
    "full_name": {
      "type": "string"
    },
    "email": {
      "type": "string",
      "format": "email"
    },
    "government_id": {
      "type": "string"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "full_name": "<string>",
  "email": "developer@example.com",
  "government_id": "<string>"
}
```


**Response `200`:** Data confirmed

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Signer"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "signer",
    "id": "62d6ee35c7741ca4006b9e11",
    "full_name": "John Signer",
    "email": "developer@example.com",
    "whatsapp_phone_number": "+5548999990000",
    "government_id": "39053344705",
    "has_accepted_terms": false
  }
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## AcceptTerms

```pascal
function AcceptTerms(const SignerAccessCode: string): TAssinafyResponse;
```

`PUT /v1/signers/accept-terms`

Record that the signer accepted the terms of use. Uses the signer access code.

**Authentication:** Required `SignerAccessCode` as the `signer-access-code` query parameter. Workspace credentials are omitted.

**Parameters:**

No path or query parameters.

**Request body:** none.

**Response `200`:** Terms accepted

Content type: `application/json`

```json
{
  "$ref": "#/components/schemas/Envelope"
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": ""
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## UploadSignatureImage

```pascal
function UploadSignatureImage(const SignerAccessCode: string; const FileName: string; Query: TStrings = nil): TAssinafyResponse;
```

`POST /v1/signature`

Upload the signer's signature (or initials) image as the raw request body. Uses the signer access code.

**Authentication:** Required `SignerAccessCode` as the `signer-access-code` query parameter. Workspace credentials are omitted.

**Parameters:**

- `type` (query, optional): Image type, e.g. `signature` or `initial`.
```json
{
  "type": "string"
}
```


- `reuse` (query, optional): Whether the signer opted to reuse this signature in future processes. When set, updates the signer's `is_signature_reusable` flag; when omitted, the flag is left unchanged.
```json
{
  "type": "boolean"
}
```


**Request: `image/png` (required)**

```json
{
  "type": "string",
  "format": "binary"
}
```

**Payload shape:**

```json
"<binary bytes>"
```


**Response `200`:** Signature stored

Content type: `application/json`

```json
{
  "$ref": "#/components/schemas/Envelope"
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": ""
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## DownloadSignatureImage

```pascal
function DownloadSignatureImage(const SignatureType: string; const SignerAccessCode: string): TAssinafyResponse;
```

`GET /v1/signature/{signatureType}`

Download the signer's stored signature/initials image. Uses the signer access code.

**Authentication:** Required `SignerAccessCode` as the `signer-access-code` query parameter. Workspace credentials are omitted.

**Parameters:**

- `signatureType` (path, required): Image type (e.g. `signature`, `initial`).
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The signature image

Content type: `image/*`

```json
{
  "type": "string",
  "format": "binary"
}
```

Raw binary bytes; preserved without JSON decoding.

**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListSignerDocuments

```pascal
function ListSignerDocuments(const SignerId: string; const SignerAccessCode: string = ''; Query: TStrings = nil): TAssinafyResponse;
```

`GET /v1/signers/{signerId}/documents`

List the documents a signer is party to. Accepts either the signer access code or the account's own credentials (API key or bearer token) — with account credentials, the signer must belong to that account's workspace.

**Authentication:** Required `SignerAccessCode` as the `signer-access-code` query parameter; an empty code is rejected before transport and workspace credentials are never sent. For API key or bearer token access to the same route, use [ListSignerDocumentsAsWorkspace](#listsignerdocumentsasworkspace).

**Parameters:**

- `signerId` (path, required): The signer ID.
```json
{
  "type": "string"
}
```


- `page` (query, optional): Page number.
```json
{
  "type": "integer",
  "minimum": 1,
  "example": 1
}
```


- `per-page` (query, optional): Records per page (max 100).
```json
{
  "type": "integer",
  "maximum": 100,
  "example": 25
}
```


**Request body:** none.

**Response `200`:** The signer's documents

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/Document"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "resource": "document",
      "id": "615601fab04c0a3147bb1246",
      "account_id": "d199996981dbd199996981db",
      "template_id": null,
      "name": "document.pdf",
      "status": "metadata_ready",
      "artifacts": {
        "original": "https://api.assinafy.com.br/v1/documents/doc1/download/original"
      },
      "is_closed": false,
      "signing_url": "https://api.assinafy.com.br/v1/sign/doc1",
      "decline_reason": null,
      "declined_by": {
        "resource": "signer",
        "id": "62d6ee35c7741ca4006b9e11",
        "full_name": "John Signer",
        "email": "developer@example.com",
        "whatsapp_phone_number": "+5548999990000",
        "government_id": "39053344705",
        "has_accepted_terms": false
      },
      "tags": [
        {
          "id": "<string>",
          "name": "<string>"
        }
      ],
      "assignment": {
        "resource": "assignment",
        "id": "615606ef81d199996981dbce",
        "sender_email": "developer@example.com",
        "method": "virtual",
        "expires_at": null,
        "message": "<string>",
        "signers": [
          {
            "resource": "signer",
            "id": "62d6ee35c7741ca4006b9e11",
            "full_name": "John Signer",
            "email": "developer@example.com",
            "whatsapp_phone_number": "+5548999990000",
            "government_id": "39053344705",
            "has_accepted_terms": false,
            "verification_method": "Email",
            "notification_methods": [
              "Email"
            ],
            "step": 1,
            "notified": false,
            "completed": false,
            "notification_history": [
              {
                "event": "signature_request",
                "status": "sent",
                "error_code": "<string>",
                "error_message": "<string>",
                "sent_at": "2026-07-07T12:00:00Z",
                "failed_at": null
              }
            ]
          }
        ],
        "copy_receivers": [
          {}
        ],
        "items": [
          {
            "id": "<string>",
            "page": {
              "id": "615601faf166d6d1d8e7dc30",
              "number": 1,
              "height": 2100,
              "width": 1275,
              "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
            },
            "signer": {},
            "field": {},
            "display_settings": "<string>",
            "value": "<string>",
            "completed": false
          }
        ],
        "summary": {
          "signer_count": 1,
          "completed_count": 1,
          "signers": [
            {}
          ]
        },
        "signing_urls": [
          {
            "signer_id": "<string>",
            "url": "https://api.assinafy.com.br/v1/sign/doc1?email=developer@example.com"
          }
        ]
      },
      "pages": [
        {
          "id": "615601faf166d6d1d8e7dc30",
          "number": 1,
          "height": 2100,
          "width": 1275,
          "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
        }
      ],
      "created_at": "2026-06-03T03:54:16Z",
      "updated_at": "2026-06-03T03:54:16Z"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListSignerDocumentsAsWorkspace

```pascal
function ListSignerDocumentsAsWorkspace(const SignerId: string; Query: TStrings = nil): TAssinafyResponse;
```

`GET /v1/signers/{signerId}/documents`

List the documents a signer is party to. Accepts either the signer access code or the account's own credentials (API key or bearer token) — with account credentials, the signer must belong to that account's workspace.

Workspace-credential form of [ListSignerDocuments](#listsignerdocuments): it sends the API key or bearer token and never a signer access code.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `signerId` (path, required): The signer ID.
```json
{
  "type": "string"
}
```


- `page` (query, optional): Page number.
```json
{
  "type": "integer",
  "minimum": 1,
  "example": 1
}
```


- `per-page` (query, optional): Records per page (max 100).
```json
{
  "type": "integer",
  "maximum": 100,
  "example": 25
}
```


**Request body:** none.

**Response `200`:** The signer's documents

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/Document"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "resource": "document",
      "id": "615601fab04c0a3147bb1246",
      "account_id": "d199996981dbd199996981db",
      "template_id": null,
      "name": "document.pdf",
      "status": "metadata_ready",
      "artifacts": {
        "original": "https://api.assinafy.com.br/v1/documents/doc1/download/original"
      },
      "is_closed": false,
      "signing_url": "https://api.assinafy.com.br/v1/sign/doc1",
      "decline_reason": null,
      "declined_by": {
        "resource": "signer",
        "id": "62d6ee35c7741ca4006b9e11",
        "full_name": "John Signer",
        "email": "developer@example.com",
        "whatsapp_phone_number": "+5548999990000",
        "government_id": "39053344705",
        "has_accepted_terms": false
      },
      "tags": [
        {
          "id": "<string>",
          "name": "<string>"
        }
      ],
      "assignment": {
        "resource": "assignment",
        "id": "615606ef81d199996981dbce",
        "sender_email": "developer@example.com",
        "method": "virtual",
        "expires_at": null,
        "message": "<string>",
        "signers": [
          {
            "resource": "signer",
            "id": "62d6ee35c7741ca4006b9e11",
            "full_name": "John Signer",
            "email": "developer@example.com",
            "whatsapp_phone_number": "+5548999990000",
            "government_id": "39053344705",
            "has_accepted_terms": false,
            "verification_method": "Email",
            "notification_methods": [
              "Email"
            ],
            "step": 1,
            "notified": false,
            "completed": false,
            "notification_history": [
              {
                "event": "signature_request",
                "status": "sent",
                "error_code": "<string>",
                "error_message": "<string>",
                "sent_at": "2026-07-07T12:00:00Z",
                "failed_at": null
              }
            ]
          }
        ],
        "copy_receivers": [
          {}
        ],
        "items": [
          {
            "id": "<string>",
            "page": {
              "id": "615601faf166d6d1d8e7dc30",
              "number": 1,
              "height": 2100,
              "width": 1275,
              "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
            },
            "signer": {},
            "field": {},
            "display_settings": "<string>",
            "value": "<string>",
            "completed": false
          }
        ],
        "summary": {
          "signer_count": 1,
          "completed_count": 1,
          "signers": [
            {}
          ]
        },
        "signing_urls": [
          {
            "signer_id": "<string>",
            "url": "https://api.assinafy.com.br/v1/sign/doc1?email=developer@example.com"
          }
        ]
      },
      "pages": [
        {
          "id": "615601faf166d6d1d8e7dc30",
          "number": 1,
          "height": 2100,
          "width": 1275,
          "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
        }
      ],
      "created_at": "2026-06-03T03:54:16Z",
      "updated_at": "2026-06-03T03:54:16Z"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## SearchSignerDocuments

```pascal
function SearchSignerDocuments(const SignerId: string; const SignerAccessCode: string = ''; Query: TStrings = nil): TAssinafyResponse;
```

`GET /v1/signers/{signerId}/documents/search`

Search the documents a signer is party to (compact representation). Accepts either the signer access code or the account's own credentials (API key or bearer token) — with account credentials, the signer must belong to that account's workspace.

**Authentication:** Required `SignerAccessCode` as the `signer-access-code` query parameter; an empty code is rejected before transport and workspace credentials are never sent. For API key or bearer token access to the same route, use [SearchSignerDocumentsAsWorkspace](#searchsignerdocumentsasworkspace).

**Parameters:**

- `signerId` (path, required): The signer ID.
```json
{
  "type": "string"
}
```


- `search` (query, optional): Search term.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** Matching documents

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/Document"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "resource": "document",
      "id": "615601fab04c0a3147bb1246",
      "account_id": "d199996981dbd199996981db",
      "template_id": null,
      "name": "document.pdf",
      "status": "metadata_ready",
      "artifacts": {
        "original": "https://api.assinafy.com.br/v1/documents/doc1/download/original"
      },
      "is_closed": false,
      "signing_url": "https://api.assinafy.com.br/v1/sign/doc1",
      "decline_reason": null,
      "declined_by": {
        "resource": "signer",
        "id": "62d6ee35c7741ca4006b9e11",
        "full_name": "John Signer",
        "email": "developer@example.com",
        "whatsapp_phone_number": "+5548999990000",
        "government_id": "39053344705",
        "has_accepted_terms": false
      },
      "tags": [
        {
          "id": "<string>",
          "name": "<string>"
        }
      ],
      "assignment": {
        "resource": "assignment",
        "id": "615606ef81d199996981dbce",
        "sender_email": "developer@example.com",
        "method": "virtual",
        "expires_at": null,
        "message": "<string>",
        "signers": [
          {
            "resource": "signer",
            "id": "62d6ee35c7741ca4006b9e11",
            "full_name": "John Signer",
            "email": "developer@example.com",
            "whatsapp_phone_number": "+5548999990000",
            "government_id": "39053344705",
            "has_accepted_terms": false,
            "verification_method": "Email",
            "notification_methods": [
              "Email"
            ],
            "step": 1,
            "notified": false,
            "completed": false,
            "notification_history": [
              {
                "event": "signature_request",
                "status": "sent",
                "error_code": "<string>",
                "error_message": "<string>",
                "sent_at": "2026-07-07T12:00:00Z",
                "failed_at": null
              }
            ]
          }
        ],
        "copy_receivers": [
          {}
        ],
        "items": [
          {
            "id": "<string>",
            "page": {
              "id": "615601faf166d6d1d8e7dc30",
              "number": 1,
              "height": 2100,
              "width": 1275,
              "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
            },
            "signer": {},
            "field": {},
            "display_settings": "<string>",
            "value": "<string>",
            "completed": false
          }
        ],
        "summary": {
          "signer_count": 1,
          "completed_count": 1,
          "signers": [
            {}
          ]
        },
        "signing_urls": [
          {
            "signer_id": "<string>",
            "url": "https://api.assinafy.com.br/v1/sign/doc1?email=developer@example.com"
          }
        ]
      },
      "pages": [
        {
          "id": "615601faf166d6d1d8e7dc30",
          "number": 1,
          "height": 2100,
          "width": 1275,
          "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
        }
      ],
      "created_at": "2026-06-03T03:54:16Z",
      "updated_at": "2026-06-03T03:54:16Z"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## SearchSignerDocumentsAsWorkspace

```pascal
function SearchSignerDocumentsAsWorkspace(const SignerId: string; Query: TStrings = nil): TAssinafyResponse;
```

`GET /v1/signers/{signerId}/documents/search`

Search the documents a signer is party to (compact representation). Accepts either the signer access code or the account's own credentials (API key or bearer token) — with account credentials, the signer must belong to that account's workspace.

Workspace-credential form of [SearchSignerDocuments](#searchsignerdocuments): it sends the API key or bearer token and never a signer access code.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `signerId` (path, required): The signer ID.
```json
{
  "type": "string"
}
```


- `search` (query, optional): Search term.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** Matching documents

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/Document"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "resource": "document",
      "id": "615601fab04c0a3147bb1246",
      "account_id": "d199996981dbd199996981db",
      "template_id": null,
      "name": "document.pdf",
      "status": "metadata_ready",
      "artifacts": {
        "original": "https://api.assinafy.com.br/v1/documents/doc1/download/original"
      },
      "is_closed": false,
      "signing_url": "https://api.assinafy.com.br/v1/sign/doc1",
      "decline_reason": null,
      "declined_by": {
        "resource": "signer",
        "id": "62d6ee35c7741ca4006b9e11",
        "full_name": "John Signer",
        "email": "developer@example.com",
        "whatsapp_phone_number": "+5548999990000",
        "government_id": "39053344705",
        "has_accepted_terms": false
      },
      "tags": [
        {
          "id": "<string>",
          "name": "<string>"
        }
      ],
      "assignment": {
        "resource": "assignment",
        "id": "615606ef81d199996981dbce",
        "sender_email": "developer@example.com",
        "method": "virtual",
        "expires_at": null,
        "message": "<string>",
        "signers": [
          {
            "resource": "signer",
            "id": "62d6ee35c7741ca4006b9e11",
            "full_name": "John Signer",
            "email": "developer@example.com",
            "whatsapp_phone_number": "+5548999990000",
            "government_id": "39053344705",
            "has_accepted_terms": false,
            "verification_method": "Email",
            "notification_methods": [
              "Email"
            ],
            "step": 1,
            "notified": false,
            "completed": false,
            "notification_history": [
              {
                "event": "signature_request",
                "status": "sent",
                "error_code": "<string>",
                "error_message": "<string>",
                "sent_at": "2026-07-07T12:00:00Z",
                "failed_at": null
              }
            ]
          }
        ],
        "copy_receivers": [
          {}
        ],
        "items": [
          {
            "id": "<string>",
            "page": {
              "id": "615601faf166d6d1d8e7dc30",
              "number": 1,
              "height": 2100,
              "width": 1275,
              "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
            },
            "signer": {},
            "field": {},
            "display_settings": "<string>",
            "value": "<string>",
            "completed": false
          }
        ],
        "summary": {
          "signer_count": 1,
          "completed_count": 1,
          "signers": [
            {}
          ]
        },
        "signing_urls": [
          {
            "signer_id": "<string>",
            "url": "https://api.assinafy.com.br/v1/sign/doc1?email=developer@example.com"
          }
        ]
      },
      "pages": [
        {
          "id": "615601faf166d6d1d8e7dc30",
          "number": 1,
          "height": 2100,
          "width": 1275,
          "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
        }
      ],
      "created_at": "2026-06-03T03:54:16Z",
      "updated_at": "2026-06-03T03:54:16Z"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## DownloadSignerDocumentArtifact

```pascal
function DownloadSignerDocumentArtifact(const SignerId: string; const DocumentId: string; const ArtifactName: string): TAssinafyResponse;
```

`GET /v1/signers/{signerId}/documents/{documentId}/download/{artifactName}`

Download an artifact of a document the signer is party to. Public (signer-link) endpoint. Artifact types: original, certificated, certificate-page, pades, bundle. The pades artifact (signers' ICP-Brasil signatures + platform certification box) is only present on documents that had digital-certificate signers; `bundle` is a zip of the original, certificated and certificate-page artifacts, plus the pades artifact on documents that have one.

**Authentication:** Public: workspace credentials are omitted.

**Parameters:**

- `signerId` (path, required): The signer ID.
```json
{
  "type": "string"
}
```


- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


- `artifactName` (path, required): Artifact type.
```json
{
  "type": "string",
  "enum": [
    "original",
    "certificated",
    "certificate-page",
    "pades",
    "bundle"
  ]
}
```


**Request body:** none.

**Response `200`:** The artifact binary

Content type: `application/pdf`

```json
{
  "type": "string",
  "format": "binary"
}
```

Raw binary bytes; preserved without JSON decoding.

**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## SocialLogin

```pascal
function SocialLogin(Body: TJSONData): TAssinafyResponse;
```

`POST /v1/authentication/social-login`

Exchange a token from a social login provider (currently only `google`) for an Assinafy access token.

**Authentication:** Public: workspace credentials are omitted.

**Parameters:**

No path or query parameters.

**Request: `application/json` (required)**

```json
{
  "required": [
    "provider",
    "token",
    "has_accepted_terms"
  ],
  "properties": {
    "provider": {
      "type": "string",
      "enum": [
        "google"
      ],
      "example": "google"
    },
    "token": {
      "description": "Access/ID token from the provider.",
      "type": "string",
      "example": "yOTUvImV4cCI6MTY3OTY1ODY5NS..."
    },
    "has_accepted_terms": {
      "type": "boolean",
      "example": true
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "provider": "google",
  "token": "yOTUvImV4cCI6MTY3OTY1ODY5NS...",
  "has_accepted_terms": true
}
```


**Response `200`:** Access token, user and accounts

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/AuthSession"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "user": {
      "id": "bgjazeo5r9v2lq7l36dx48np",
      "name": "John Smith",
      "email": "developer@example.com",
      "telephone": "17989206641",
      "government_id": "15774136604",
      "is_email_verified": false,
      "has_accepted_terms": true,
      "created_at": "2023-03-03T11:51:34Z",
      "to_be_deleted_at": null
    },
    "accounts": [
      {
        "id": "6401df46d6a6b0c692d9ec49",
        "name": "JS",
        "roles": [
          "owner"
        ],
        "is_delete_allowed": true,
        "created_at": "2023-03-03T11:51:34Z"
      }
    ]
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## LinkSocialLogin

```pascal
function LinkSocialLogin(Body: TJSONData): TAssinafyResponse;
```

`POST /v1/auth/link-social-login`

Link a social-login provider account to the authenticated user.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request: `application/json` (required)**

```json
{
  "required": [
    "provider",
    "token"
  ],
  "properties": {
    "provider": {
      "type": "string",
      "enum": [
        "google"
      ],
      "example": "google"
    },
    "token": {
      "description": "Token from the provider.",
      "type": "string"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "provider": "google",
  "token": "<string>"
}
```


**Response `200`:** Provider linked

Content type: `application/json`

```json
{
  "$ref": "#/components/schemas/Envelope"
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": ""
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## GetAccountStats

```pascal
function GetAccountStats(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/stats`

Precomputed per-account document-funnel KPIs. `granularity=monthly` (default) returns the last 12 months, most recent first; `granularity=daily` with `month=YYYY-MM` returns that month's days. Series are zero-filled.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `granularity` (query, optional): `monthly` (default) or `daily`.
```json
{
  "type": "string",
  "enum": [
    "monthly",
    "daily"
  ]
}
```


- `month` (query, optional): Target month `YYYY-MM` (required when `granularity=daily`).
```json
{
  "type": "string",
  "example": "2026-06"
}
```


**Request body:** none.

**Response `200`:** KPI series

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/DocumentStatsRow"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "period": "2026-06",
      "documents_uploaded": 42,
      "documents_sent": 37,
      "signature_requests": 61,
      "signature_requests_notification_email": 55,
      "signature_requests_notification_whatsapp": 18,
      "signature_requests_notification_bypass": 3,
      "signature_requests_verification_email": 48,
      "signature_requests_verification_whatsapp": 6,
      "signature_requests_verification_bypass": 3,
      "signature_requests_verification_digital_certificate": 4,
      "signature_requests_viewed": 44,
      "signature_requests_completed": 52,
      "documents_certified": 30
    }
  ]
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## GetUserStats

```pascal
function GetUserStats(Query: TStrings = nil): TAssinafyResponse;
```

`GET /v1/users/self/stats`

The authenticated user's document-funnel KPIs summed across all accounts they currently belong to. `granularity=monthly` (default) returns the last 12 months, most recent first; `granularity=daily` with `month=YYYY-MM` returns that month's days. Series are zero-filled.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `granularity` (query, optional): `monthly` (default) or `daily`.
```json
{
  "type": "string",
  "enum": [
    "monthly",
    "daily"
  ]
}
```


- `month` (query, optional): Target month `YYYY-MM` (required when `granularity=daily`).
```json
{
  "type": "string",
  "example": "2026-06"
}
```


**Request body:** none.

**Response `200`:** KPI series

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/DocumentStatsRow"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "period": "2026-06",
      "documents_uploaded": 42,
      "documents_sent": 37,
      "signature_requests": 61,
      "signature_requests_notification_email": 55,
      "signature_requests_notification_whatsapp": 18,
      "signature_requests_notification_bypass": 3,
      "signature_requests_verification_email": 48,
      "signature_requests_verification_whatsapp": 6,
      "signature_requests_verification_bypass": 3,
      "signature_requests_verification_digital_certificate": 4,
      "signature_requests_viewed": 44,
      "signature_requests_completed": 52,
      "documents_certified": 30
    }
  ]
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListTags

```pascal
function ListTags(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/tags`

List the tags of a workspace.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `search` (query, optional): Search term.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The workspace tags

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/Tag"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "resource": "tag",
      "id": "fa8c09f3e709a8a1c82d69b1454",
      "name": "Contracts",
      "color": "ff8800",
      "created_at": "2026-05-14T12:00:00Z",
      "updated_at": "2026-05-14T12:00:00Z"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## CreateTag

```pascal
function CreateTag(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
```

`POST /v1/accounts/{accountId}/tags`

Create a tag in the workspace. Names are unique per workspace (case-insensitive); a collision returns 409.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "required": [
    "name"
  ],
  "properties": {
    "name": {
      "description": "Trimmed; whitespace collapsed; max 64 chars.",
      "type": "string",
      "example": "Contracts"
    },
    "color": {
      "description": "6-char hex (with or without leading #).",
      "type": [
        "string",
        "null"
      ],
      "example": "ff8800"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "name": "Contracts",
  "color": "ff8800"
}
```


**Response `200`:** The created tag

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Tag"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "tag",
    "id": "fa8c09f3e709a8a1c82d69b1454",
    "name": "Contracts",
    "color": "ff8800",
    "created_at": "2026-05-14T12:00:00Z",
    "updated_at": "2026-05-14T12:00:00Z"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `409`:** A tag with the same name already exists.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 409
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 409,
  "message": "Bad request.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## UpdateTag

```pascal
function UpdateTag(const AAccountId: string; const TagId: string; Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/accounts/{accountId}/tags/{tagId}`

Update a tag's name or color.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `tagId` (path, required): The tag ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "properties": {
    "name": {
      "type": "string",
      "example": "Signed Contracts"
    },
    "color": {
      "type": [
        "string",
        "null"
      ],
      "example": "00aa55"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "name": "Signed Contracts",
  "color": "00aa55"
}
```


**Response `200`:** The updated tag

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Tag"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "tag",
    "id": "fa8c09f3e709a8a1c82d69b1454",
    "name": "Contracts",
    "color": "ff8800",
    "created_at": "2026-05-14T12:00:00Z",
    "updated_at": "2026-05-14T12:00:00Z"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## DeleteTag

```pascal
function DeleteTag(const AAccountId: string; const TagId: string; Query: TStrings = nil): TAssinafyResponse;
```

`DELETE /v1/accounts/{accountId}/tags/{tagId}`

Delete a tag. Pass `?force=true` to detach it from any documents/templates it is attached to.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `tagId` (path, required): The tag ID.
```json
{
  "type": "string"
}
```


- `force` (query, optional): Detach from resources before deleting.
```json
{
  "type": "boolean"
}
```


**Request body:** none.

**Response `200`:** Tag deleted

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "properties": {
            "deleted": {
              "type": "boolean",
              "example": true
            }
          },
          "type": "object"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "deleted": true
  }
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListTemplates

```pascal
function ListTemplates(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/templates`

List the templates of a workspace.

The `status` field of a template is one of:

| Status | Description |
|--------|-------------|
| `uploading` | The template is being uploaded. |
| `uploaded` | The template has been uploaded. |
| `processing` | The template is being processed. |
| `ready` | The template is ready to use. |
| `failed` | The template processing has failed. |

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `search` (query, optional): Search term.
```json
{
  "type": "string"
}
```


- `page` (query, optional): Page number.
```json
{
  "type": "integer",
  "minimum": 1,
  "example": 1
}
```


- `per-page` (query, optional): Records per page (max 100).
```json
{
  "type": "integer",
  "maximum": 100,
  "example": 25
}
```


**Request body:** none.

**Response `200`:** A page of templates (default_document_tags omitted in the list)

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/Template"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "resource": "template",
      "id": "fa88b732db84d01427d4cdd1092",
      "name": "template.pdf",
      "document_name": "<string>",
      "message": "<string>",
      "status": "ready",
      "pages": [
        {
          "id": "<string>",
          "number": 1,
          "height": 2100,
          "width": 1275,
          "download_url": "<string>",
          "fields": [
            {
              "id": "<string>",
              "field_id": "<string>",
              "role_id": "<string>",
              "label": "<string>",
              "display_settings": "<string>",
              "created_at": "2030-01-01T12:00:00Z",
              "updated_at": "2030-01-01T12:00:00Z"
            }
          ]
        }
      ],
      "roles": [
        {
          "id": "<string>",
          "name": "Editor",
          "assignment_type": "Editor",
          "created_at": "2030-01-01T12:00:00Z",
          "updated_at": "2030-01-01T12:00:00Z"
        }
      ],
      "tags": [
        {
          "id": "<string>",
          "name": "<string>"
        }
      ],
      "default_document_tags": [
        {
          "id": "<string>",
          "name": "<string>"
        }
      ],
      "created_at": "2030-01-01T12:00:00Z",
      "updated_at": "2030-01-01T12:00:00Z"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## CreateDocumentFromTemplate

```pascal
function CreateDocumentFromTemplate(const AAccountId: string; const TemplateId: string; Body: TJSONData): TAssinafyResponse;
```

`POST /v1/accounts/{accountId}/templates/{templateId}/documents`

Generate a new document from a template, creating its assignment in the same call. Provide one signer entry per template role; the signers must already exist in the account.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `templateId` (path, required): The template ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "required": [
    "signers"
  ],
  "properties": {
    "signers": {
      "description": "One entry per template role.",
      "type": "array",
      "items": {
        "required": [
          "role_id",
          "id"
        ],
        "properties": {
          "role_id": {
            "description": "The template role ID associated with the signer.",
            "type": "string",
            "example": "fa8c14f32d732271e071998246e"
          },
          "id": {
            "description": "The signer ID. The signer must already exist in the account.",
            "type": "string",
            "example": "fa8c140cb49b79f940aab95fddd"
          },
          "verification_method": {
            "description": "Verification method for this signer. If provided without notification_methods, the notification method is inferred. Defaults to Email. `DigitalCertificate` has the signer sign with their own ICP-Brasil certificate — it requires the Digital Certificate feature, the signer must have a CPF or CNPJ in `government_id` (a CPF requires that person's certificate; a CNPJ requires an e-CNPJ for that company), must be alone in its signing step, and is charged 0.5 credits per signer. Only applies to signers (not copy receivers).",
            "type": "string",
            "enum": [
              "Email",
              "Whatsapp",
              "DigitalCertificate"
            ],
            "example": "Email"
          },
          "notification_methods": {
            "description": "Notification method codes for this signer. If provided without verification_method, the verification method is inferred. Defaults to Email. Only one method allowed per signer.",
            "type": "array",
            "items": {
              "type": "string"
            },
            "example": [
              "Email"
            ]
          },
          "step": {
            "description": "Positive integer that controls signing order. Signers sharing the same step sign in parallel; a step activates only after every signer in the previous step has signed. If supplied for any role it must be supplied for all, forming a contiguous sequence starting at 1. Copy receivers ignore this field.",
            "type": "integer",
            "example": 1
          }
        },
        "type": "object"
      }
    },
    "editor_fields": {
      "description": "Editor field values to bake into the generated document.",
      "type": "array",
      "items": {
        "required": [
          "field_id",
          "value"
        ],
        "properties": {
          "field_id": {
            "description": "The field identifier, matching the field_id in the template data.",
            "type": "string",
            "example": "fa8c14f3af99d2846d1789de4ba"
          },
          "value": {
            "description": "The value to assign to the field.",
            "type": "string",
            "example": "Field value"
          }
        },
        "type": "object"
      }
    },
    "name": {
      "description": "Title for the document. Defaults to the template name.",
      "type": "string",
      "example": "sample-contract-one-page.pdf"
    },
    "message": {
      "description": "Optional message sent to signers.",
      "type": "string",
      "example": "Message to the signers"
    },
    "expires_at": {
      "description": "Assignment expiration date (ISO 8601). No expiration by default. Must be at least one hour in the future.",
      "type": "string",
      "format": "date-time",
      "example": "2024-07-30T23:59:00Z"
    },
    "tags": {
      "description": "Tag names to attach to the new document. Names that don't exist are auto-created. The template's default-document-tags are always applied; values here are merged on top (duplicates removed).",
      "type": "array",
      "items": {
        "type": "string"
      }
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "signers": [
    {
      "role_id": "fa8c14f32d732271e071998246e",
      "id": "fa8c140cb49b79f940aab95fddd",
      "verification_method": "Email",
      "notification_methods": [
        "Email"
      ],
      "step": 1
    }
  ],
  "editor_fields": [
    {
      "field_id": "fa8c14f3af99d2846d1789de4ba",
      "value": "Field value"
    }
  ],
  "name": "sample-contract-one-page.pdf",
  "message": "Message to the signers",
  "expires_at": "2024-07-30T23:59:00Z",
  "tags": [
    "<string>"
  ]
}
```


**Response `200`:** The created document

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/Document"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "document",
    "id": "615601fab04c0a3147bb1246",
    "account_id": "d199996981dbd199996981db",
    "template_id": null,
    "name": "document.pdf",
    "status": "metadata_ready",
    "artifacts": {
      "original": "https://api.assinafy.com.br/v1/documents/doc1/download/original"
    },
    "is_closed": false,
    "signing_url": "https://api.assinafy.com.br/v1/sign/doc1",
    "decline_reason": null,
    "declined_by": {
      "resource": "signer",
      "id": "62d6ee35c7741ca4006b9e11",
      "full_name": "John Signer",
      "email": "developer@example.com",
      "whatsapp_phone_number": "+5548999990000",
      "government_id": "39053344705",
      "has_accepted_terms": false
    },
    "tags": [
      {
        "id": "<string>",
        "name": "<string>"
      }
    ],
    "assignment": {
      "resource": "assignment",
      "id": "615606ef81d199996981dbce",
      "sender_email": "developer@example.com",
      "method": "virtual",
      "expires_at": null,
      "message": "<string>",
      "signers": [
        {
          "resource": "signer",
          "id": "62d6ee35c7741ca4006b9e11",
          "full_name": "John Signer",
          "email": "developer@example.com",
          "whatsapp_phone_number": "+5548999990000",
          "government_id": "39053344705",
          "has_accepted_terms": false,
          "verification_method": "Email",
          "notification_methods": [
            "Email"
          ],
          "step": 1,
          "notified": false,
          "completed": false,
          "notification_history": [
            {
              "event": "signature_request",
              "status": "sent",
              "error_code": "<string>",
              "error_message": "<string>",
              "sent_at": "2026-07-07T12:00:00Z",
              "failed_at": null
            }
          ]
        }
      ],
      "copy_receivers": [
        {}
      ],
      "items": [
        {
          "id": "<string>",
          "page": {
            "id": "615601faf166d6d1d8e7dc30",
            "number": 1,
            "height": 2100,
            "width": 1275,
            "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
          },
          "signer": {},
          "field": {},
          "display_settings": "<string>",
          "value": "<string>",
          "completed": false
        }
      ],
      "summary": {
        "signer_count": 1,
        "completed_count": 1,
        "signers": [
          {}
        ]
      },
      "signing_urls": [
        {
          "signer_id": "<string>",
          "url": "https://api.assinafy.com.br/v1/sign/doc1?email=developer@example.com"
        }
      ]
    },
    "pages": [
      {
        "id": "615601faf166d6d1d8e7dc30",
        "number": 1,
        "height": 2100,
        "width": 1275,
        "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
      }
    ],
    "created_at": "2026-06-03T03:54:16Z",
    "updated_at": "2026-06-03T03:54:16Z"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## EstimateDocumentFromTemplateCost

```pascal
function EstimateDocumentFromTemplateCost(const AAccountId: string; const TemplateId: string; Body: TJSONData): TAssinafyResponse;
```

`POST /v1/accounts/{accountId}/templates/{templateId}/documents/estimate-cost`

Estimate the cost of creating a document from a template without creating it. Contact information is not required — only the role_id and optionally a verification or notification method are needed. Each document always consumes 1 document from the plan's monthly allowance; if exhausted, the ExtraDocument cost is charged from credits (needs_extra_document = true). blocking_reason may be PendingPayment, InsufficientDocuments, or InsufficientCredits.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `templateId` (path, required): The template ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "required": [
    "signers"
  ],
  "properties": {
    "signers": {
      "description": "One entry per template role (editor roles are ignored for cost calculation).",
      "type": "array",
      "items": {
        "required": [
          "role_id"
        ],
        "properties": {
          "role_id": {
            "description": "The template role ID associated with the signer.",
            "type": "string",
            "example": "fa8c14f32d732271e071998246e"
          },
          "verification_method": {
            "description": "Verification method. If provided without notification_methods, the notification method is inferred. Defaults to Email. Verification is never billed on its own — the cost comes from the notification it is paired with, so `Whatsapp` verification requires the WhatsApp notification and costs 0.45 credits per signer. `DigitalCertificate` adds the per-signer signature cost (0.5 credits) on top of the notification cost.",
            "type": "string",
            "enum": [
              "Email",
              "Whatsapp",
              "DigitalCertificate"
            ],
            "example": "Whatsapp"
          },
          "notification_methods": {
            "description": "Notification method for this signer — exactly one, and it must be compatible with `verification_method`. If provided without verification_method, the verification method is inferred. Defaults to Email.",
            "type": "array",
            "items": {
              "type": "string"
            },
            "example": [
              "Whatsapp"
            ]
          }
        },
        "type": "object"
      }
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "signers": [
    {
      "role_id": "fa8c14f32d732271e071998246e",
      "verification_method": "Whatsapp",
      "notification_methods": [
        "Whatsapp"
      ]
    }
  ]
}
```


**Response `200`:** Cost estimate

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/CostEstimate"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "documents": 1,
    "credits": 1,
    "needs_extra_document": false,
    "extra_document_cost": 1,
    "total_credits": 1,
    "breakdown": [
      {
        "code": "NotificationWhatsapp",
        "name": "Whatsapp Notification",
        "cost": 0.9,
        "quantity": 2,
        "unit_cost": 0.45
      }
    ],
    "document_balance": 1,
    "credit_balance": 1,
    "has_sufficient_resources": false,
    "blocking_reason": null,
    "message": "<string>"
  }
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## GetUser

```pascal
function GetUser: TAssinafyResponse;
```

`GET /v1/users/self`

Returns the profile of the user owning the access token.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request body:** none.

**Response `200`:** The current user

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/AuthUser"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "id": "bgjazeo5r9v2lq7l36dx48np",
    "name": "John Smith",
    "email": "developer@example.com",
    "telephone": "17989206641",
    "government_id": "15774136604",
    "is_email_verified": false,
    "has_accepted_terms": true,
    "created_at": "2023-03-03T11:51:34Z",
    "to_be_deleted_at": null
  }
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## GetAPIKey

```pascal
function GetAPIKey: TAssinafyResponse;
```

`GET /v1/users/api-keys`

Retrieve a masked version of the existing API key. The full key cannot be retrieved. Returns `null` when no key has been generated yet.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request body:** none.

**Response `200`:** The masked API key

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/ApiKey"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "api_key": "mIpe_zdJfKUpMK9Va3XuYgzPXMxz49fIaRCWXseVkpVAX608A9j3i_D67qU5qW3M"
  }
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## CreateAPIKey

```pascal
function CreateAPIKey(Body: TJSONData): TAssinafyResponse;
```

`POST /v1/users/api-keys`

Generate an API key for the user, used via the `X-Api-Key` header. Generating a new key deletes the previous one. Never use an API key from a front-end application.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request: `application/json` (required)**

```json
{
  "required": [
    "password"
  ],
  "properties": {
    "password": {
      "description": "The user's password.",
      "type": "string",
      "format": "password",
      "example": "password"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "password": "password"
}
```


**Response `200`:** The generated API key (shown in full only once)

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/ApiKey"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "api_key": "mIpe_zdJfKUpMK9Va3XuYgzPXMxz49fIaRCWXseVkpVAX608A9j3i_D67qU5qW3M"
  }
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## DeleteAPIKey

```pascal
function DeleteAPIKey: TAssinafyResponse;
```

`DELETE /v1/users/api-keys`

Delete the existing API key.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request body:** none.

**Response `200`:** API key deleted

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": [],
          "example": []
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": []
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## GetWebhookSubscription

```pascal
function GetWebhookSubscription(const AAccountId: string): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/webhooks/subscriptions`

Retrieve the account's oldest webhook endpoint — which events it is subscribed to and the delivery configuration. Accounts with several endpoints should use **List webhook endpoints**. Requires the `account:read` OAuth scope.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The subscription

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/WebhookSubscription"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "events": [
      "document_ready",
      "document_prepared"
    ],
    "is_active": true,
    "url": "http://example.com?test=1",
    "email": "developer@example.com",
    "updated_at": "2023-05-10T14:58:24Z"
  }
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## UpdateWebhookSubscription

```pascal
function UpdateWebhookSubscription(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/accounts/{accountId}/webhooks/subscriptions`

Update the account's oldest webhook endpoint (creating it if the account has none) — which events are monitored, whether delivery is enabled, and the delivery/contact details. Accounts with several endpoints should use **Update webhook endpoint**. Requires the `webhooks:write` OAuth scope.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "required": [
    "events",
    "is_active",
    "url",
    "email"
  ],
  "properties": {
    "events": {
      "description": "Event type codes to subscribe to (see `GET /v1/webhooks/event-types`).",
      "type": "array",
      "items": {
        "type": "string"
      },
      "example": [
        "document_ready",
        "document_prepared"
      ]
    },
    "is_active": {
      "description": "Whether events should be delivered to the webhook.",
      "type": "boolean",
      "example": true
    },
    "url": {
      "description": "The URL that will receive events.",
      "type": "string",
      "format": "uri",
      "example": "http://example.com?test=1"
    },
    "email": {
      "description": "Email that receives important webhook-communication notices.",
      "type": "string",
      "format": "email",
      "example": "developer@example.com"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "events": [
    "document_ready",
    "document_prepared"
  ],
  "is_active": true,
  "url": "http://example.com?test=1",
  "email": "developer@example.com"
}
```


**Response `200`:** The updated subscription

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/WebhookSubscription"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "events": [
      "document_ready",
      "document_prepared"
    ],
    "is_active": true,
    "url": "http://example.com?test=1",
    "email": "developer@example.com",
    "updated_at": "2023-05-10T14:58:24Z"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## InactivateWebhookSubscription

```pascal
function InactivateWebhookSubscription(const AAccountId: string): TAssinafyResponse;
```

`PUT /v1/accounts/{accountId}/webhooks/inactivate`

Deactivate the account's oldest webhook endpoint. While inactive, no events are sent to it; other endpoints are unaffected. Requires the `webhooks:write` OAuth scope.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The inactivated subscription

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/WebhookSubscription"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "events": [
      "document_ready",
      "document_prepared"
    ],
    "is_active": true,
    "url": "http://example.com?test=1",
    "email": "developer@example.com",
    "updated_at": "2023-05-10T14:58:24Z"
  }
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListWebhookEventTypes

```pascal
function ListWebhookEventTypes: TAssinafyResponse;
```

`GET /v1/webhooks/event-types`

List all available event types that can be subscribed to via webhooks. Requires the `documents:read` OAuth scope.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

No path or query parameters.

**Request body:** none.

**Response `200`:** Event types

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/WebhookEventType"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "id": "document_ready",
      "description": "Triggered when the last Signer of the assignment signs the Document."
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListWebhookDeliveries

```pascal
function ListWebhookDeliveries(const AAccountId: string; Query: TStrings = nil): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/webhooks`

Retrieve the delivery history for webhooks sent to the account's endpoints — use it to monitor status, debug failures, and verify payloads. Pagination is returned in the `X-Pagination-*` response headers. Requires the `documents:read` OAuth scope.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `endpoint_id` (query, optional): Only deliveries to this webhook endpoint.
```json
{
  "type": "string"
}
```


- `event` (query, optional): Filter by event type (e.g. `document_ready`).
```json
{
  "type": "string"
}
```


- `delivered` (query, optional): Filter by delivery status: `true` or `false`.
```json
{
  "type": "string",
  "enum": [
    "true",
    "false"
  ]
}
```


- `from` (query, optional): Unix timestamp — only entries after this time.
```json
{
  "type": "integer"
}
```


- `to` (query, optional): Unix timestamp — only entries before this time.
```json
{
  "type": "integer"
}
```


- `page` (query, optional): Page number.
```json
{
  "type": "integer",
  "default": 1
}
```


- `per-page` (query, optional): Items per page (default: 20).
```json
{
  "type": "integer",
  "default": 20
}
```


**Request body:** none.

**Response `200`:** Delivery history

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/WebhookDispatch"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "resource": "activity_dispatching_history",
      "id": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6",
      "event": "document_ready",
      "activity_id": 456,
      "endpoint_id": "65f1c2a9b3e4d5f60718293a4b5c6d7e",
      "endpoint": "https://example.com/webhook",
      "payload": {},
      "delivered": true,
      "http_status": 200,
      "response_body": "OK",
      "error": null,
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## RetryWebhookDelivery

```pascal
function RetryWebhookDelivery(const AAccountId: string; const HistoryId: string): TAssinafyResponse;
```

`POST /v1/accounts/{accountId}/webhooks/{historyId}/retry`

Manually retry a webhook delivery for a specific entry, without waiting for automatic retries. The event is sent again only to the endpoint of that entry. Returns the newly created dispatch entry.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `historyId` (path, required): The webhook dispatch entry ID to retry.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The new dispatch entry

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/WebhookDispatch"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "resource": "activity_dispatching_history",
    "id": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6",
    "event": "document_ready",
    "activity_id": 456,
    "endpoint_id": "65f1c2a9b3e4d5f60718293a4b5c6d7e",
    "endpoint": "https://example.com/webhook",
    "payload": {},
    "delivered": true,
    "http_status": 200,
    "response_body": "OK",
    "error": null,
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListWebhookEndpoints

```pascal
function ListWebhookEndpoints(const AAccountId: string): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/webhooks/endpoints`

List the account's webhook endpoints, oldest first. Requires the `account:read` OAuth scope.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The endpoints

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/WebhookEndpoint"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "id": "65f1c2a9b3e4d5f60718293a4b5c6d7e",
      "name": "ERP",
      "url": "https://example.com/webhooks/assinafy",
      "email": "developer@example.com",
      "events": [
        "document_ready",
        "signer_signed_document"
      ],
      "is_active": true,
      "signing_enabled": true,
      "created_at": "2026-10-01T12:00:00Z",
      "updated_at": "2026-10-01T12:00:00Z"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## CreateWebhookEndpoint

```pascal
function CreateWebhookEndpoint(const AAccountId: string; Body: TJSONData): TAssinafyResponse;
```

`POST /v1/accounts/{accountId}/webhooks/endpoints`

Register a URL to receive the account's webhook events. An account can have 1 endpoint, or up to 3 on paid plans; creating one past the limit returns `403`. Each endpoint of a workspace must have a different `url` (`400` otherwise). When `signing_enabled` is `true`, a signing secret is generated: read it with **Get webhook endpoint signing secret**. Requires the `webhooks:write` OAuth scope.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "required": [
    "url",
    "email",
    "events"
  ],
  "properties": {
    "url": {
      "description": "URL that receives the events (http or https).",
      "type": "string",
      "format": "uri",
      "example": "https://example.com/webhooks/assinafy"
    },
    "email": {
      "description": "Contact email for delivery-failure notices.",
      "type": "string",
      "format": "email",
      "example": "developer@example.com"
    },
    "events": {
      "description": "Event types to deliver (see `GET /v1/webhooks/event-types`).",
      "type": "array",
      "items": {
        "type": "string"
      },
      "example": [
        "document_ready",
        "signer_signed_document"
      ]
    },
    "name": {
      "description": "Label to tell endpoints apart.",
      "type": "string",
      "example": "ERP"
    },
    "is_active": {
      "description": "Whether events are delivered. Defaults to `true`.",
      "type": "boolean",
      "example": true
    },
    "signing_enabled": {
      "description": "Sign deliveries with a Standard Webhooks signature. Defaults to `false`.",
      "type": "boolean",
      "example": true
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "url": "https://example.com/webhooks/assinafy",
  "email": "developer@example.com",
  "events": [
    "document_ready",
    "signer_signed_document"
  ],
  "name": "ERP",
  "is_active": true,
  "signing_enabled": true
}
```


**Response `200`:** The created endpoint

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/WebhookEndpoint"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "id": "65f1c2a9b3e4d5f60718293a4b5c6d7e",
    "name": "ERP",
    "url": "https://example.com/webhooks/assinafy",
    "email": "developer@example.com",
    "events": [
      "document_ready",
      "signer_signed_document"
    ],
    "is_active": true,
    "signing_enabled": true,
    "created_at": "2026-10-01T12:00:00Z",
    "updated_at": "2026-10-01T12:00:00Z"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `403`:** Authenticated but not allowed to perform this action.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 403
        },
        "message": {
          "type": "string",
          "example": "You are not allowed to perform this action."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 403,
  "message": "You are not allowed to perform this action.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## GetWebhookEndpoint

```pascal
function GetWebhookEndpoint(const AAccountId: string; const EndpointId: string): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/webhooks/endpoints/{endpointId}`

Retrieve one webhook endpoint. Requires the `account:read` OAuth scope.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `endpointId` (path, required): The webhook endpoint ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The endpoint

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/WebhookEndpoint"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "id": "65f1c2a9b3e4d5f60718293a4b5c6d7e",
    "name": "ERP",
    "url": "https://example.com/webhooks/assinafy",
    "email": "developer@example.com",
    "events": [
      "document_ready",
      "signer_signed_document"
    ],
    "is_active": true,
    "signing_enabled": true,
    "created_at": "2026-10-01T12:00:00Z",
    "updated_at": "2026-10-01T12:00:00Z"
  }
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## UpdateWebhookEndpoint

```pascal
function UpdateWebhookEndpoint(const AAccountId: string; const EndpointId: string; Body: TJSONData): TAssinafyResponse;
```

`PUT /v1/accounts/{accountId}/webhooks/endpoints/{endpointId}`

Change a webhook endpoint. Only the fields sent are updated; `url` cannot be one another endpoint of the workspace already uses (`400`). Setting `signing_enabled` to `true` generates a secret if the endpoint has none and keeps the current one otherwise; setting it to `false` discards the secret. Requires the `webhooks:write` OAuth scope.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `endpointId` (path, required): The webhook endpoint ID.
```json
{
  "type": "string"
}
```


**Request: `application/json` (required)**

```json
{
  "properties": {
    "url": {
      "type": "string",
      "format": "uri",
      "example": "https://example.com/webhooks/assinafy"
    },
    "email": {
      "type": "string",
      "format": "email",
      "example": "developer@example.com"
    },
    "events": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "example": [
        "document_ready"
      ]
    },
    "name": {
      "type": "string",
      "example": "ERP"
    },
    "is_active": {
      "type": "boolean",
      "example": false
    },
    "signing_enabled": {
      "type": "boolean",
      "example": true
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "url": "https://example.com/webhooks/assinafy",
  "email": "developer@example.com",
  "events": [
    "document_ready"
  ],
  "name": "ERP",
  "is_active": false,
  "signing_enabled": true
}
```


**Response `200`:** The updated endpoint

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/WebhookEndpoint"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "id": "65f1c2a9b3e4d5f60718293a4b5c6d7e",
    "name": "ERP",
    "url": "https://example.com/webhooks/assinafy",
    "email": "developer@example.com",
    "events": [
      "document_ready",
      "signer_signed_document"
    ],
    "is_active": true,
    "signing_enabled": true,
    "created_at": "2026-10-01T12:00:00Z",
    "updated_at": "2026-10-01T12:00:00Z"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## DeleteWebhookEndpoint

```pascal
function DeleteWebhookEndpoint(const AAccountId: string; const EndpointId: string): TAssinafyResponse;
```

`DELETE /v1/accounts/{accountId}/webhooks/endpoints/{endpointId}`

Stop delivering events to an endpoint and free its slot. Requires the `webhooks:write` OAuth scope.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `endpointId` (path, required): The webhook endpoint ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** Endpoint deleted

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": [],
          "example": []
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": []
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## GetWebhookEndpointSigningSecret

```pascal
function GetWebhookEndpointSigningSecret(const AAccountId: string; const EndpointId: string): TAssinafyResponse;
```

`GET /v1/accounts/{accountId}/webhooks/endpoints/{endpointId}/secret`

Return the secret used to sign deliveries to this endpoint (see **Webhook Payloads → Verifying signatures**). Returns `400` when signing is disabled. Not available to OAuth applications.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `endpointId` (path, required): The webhook endpoint ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The secret

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/WebhookEndpointSecret"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "secret": "whsec_MfKQ9r8GKYqrTwjUPD8ILPZIo2LaLaSw"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## RotateWebhookEndpointSigningSecret

```pascal
function RotateWebhookEndpointSigningSecret(const AAccountId: string; const EndpointId: string): TAssinafyResponse;
```

`POST /v1/accounts/{accountId}/webhooks/endpoints/{endpointId}/secret/rotate`

Replace the endpoint's signing secret and return the new one. The old secret stops working immediately, so update your receiver right away. Returns `400` when signing is disabled. Not available to OAuth applications.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `accountId` (path, required): Workspace account ID.
```json
{
  "type": "string"
}
```


- `endpointId` (path, required): The webhook endpoint ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** The new secret

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "$ref": "#/components/schemas/WebhookEndpointSecret"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": {
    "secret": "whsec_MfKQ9r8GKYqrTwjUPD8ILPZIo2LaLaSw"
  }
}
```


**Response `400`:** One or more fields failed validation.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 422
        },
        "message": {
          "type": "string",
          "example": "One or more fields failed validation."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 422,
  "message": "One or more fields failed validation.",
  "data": null
}
```


**Response `404`:** The requested resource does not exist.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 404
        },
        "message": {
          "type": "string",
          "example": "The requested resource was not found."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 404,
  "message": "The requested resource was not found.",
  "data": null
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## GetOAuthResourceMetadata

```pascal
function GetOAuthResourceMetadata: TAssinafyResponse;
```

`GET /.well-known/oauth-protected-resource`

RFC 9728. Identifies this API as a protected resource, the
     *         authorization server(s) that can issue tokens for it, and the scopes it
     *         accepts. `scopes_supported` deliberately excludes `offline_access` — per the
     *         MCP specification, requesting a refresh token is a client concern, not
     *         something a resource is protected by. Also referenced from the
     *         `WWW-Authenticate: Bearer resource_metadata="..."` challenge on a 401/403.
     *         Per RFC 8615, the response is the bare metadata object itself — never this
     *         API's usual `{status, data, message}` envelope. The `authorization_servers` entry names the host that owns the browser-facing flow — start every integration by fetching `{authorization_servers[0]}/.well-known/oauth-authorization-server` (RFC 8414) from there, not from this API.

**Authentication:** Public: workspace credentials are omitted.

**Parameters:**

No path or query parameters.

**Request body:** none.

**Response `200`:** The protected resource metadata

Content type: `application/json`

```json
{
  "properties": {
    "resource": {
      "type": "string",
      "format": "uri"
    },
    "authorization_servers": {
      "type": "array",
      "items": {
        "type": "string",
        "format": "uri"
      }
    },
    "scopes_supported": {
      "type": "array",
      "items": {
        "type": "string"
      }
    },
    "bearer_methods_supported": {
      "type": "array",
      "items": {
        "type": "string",
        "example": "header"
      }
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "resource": "https://app.example.com/resource",
  "authorization_servers": [
    "https://app.example.com/resource"
  ],
  "scopes_supported": [
    "<string>"
  ],
  "bearer_methods_supported": [
    "header"
  ]
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```


## ListWhatsAppNotifications

```pascal
function ListWhatsAppNotifications(const DocumentId: string; const AssignmentId: string): TAssinafyResponse;
```

`GET /v1/documents/{documentId}/assignments/{assignmentId}/whatsapp-notifications`

List all WhatsApp notification messages sent for an assignment. The response includes the rendered template text split into `header`, `body` and `buttons` — exactly what the signer would see. In sandbox/stage, WhatsApp messages are simulated (no real delivery) and button URLs include access/verification codes you can use to simulate the signing flow; in production the button URLs are stripped. Requires the `documents:read` OAuth scope.

**Authentication:** API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.

**Parameters:**

- `documentId` (path, required): Document ID.
```json
{
  "type": "string"
}
```


- `assignmentId` (path, required): The assignment ID.
```json
{
  "type": "string"
}
```


**Request body:** none.

**Response `200`:** WhatsApp notifications

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Envelope"
    },
    {
      "properties": {
        "data": {
          "type": "array",
          "items": {
            "$ref": "#/components/schemas/WhatsappNotification"
          }
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": "",
  "data": [
    {
      "sent_at": 1710000000,
      "header": "Documento para assinatura: Contrato de Servico",
      "body": "<string>",
      "buttons": [
        {
          "text": "Abrir documento"
        }
      ],
      "phone_number": "+5511999990001",
      "signer_id": "a51edaee68a7"
    }
  ]
}
```


**Response `401`:** Missing or invalid credentials.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 401
        },
        "message": {
          "type": "string",
          "example": "Your request was made with invalid credentials."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 401,
  "message": "Your request was made with invalid credentials.",
  "data": null
}
```


**Response `500`:** Unexpected server error.

Content type: `application/json`

```json
{
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/ErrorEnvelope"
    },
    {
      "properties": {
        "status": {
          "type": "integer",
          "example": 500
        },
        "message": {
          "type": "string",
          "example": "An unexpected error occurred."
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "status": 500,
  "message": "An unexpected error occurred.",
  "data": null
}
```
