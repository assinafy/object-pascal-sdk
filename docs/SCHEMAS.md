# Payload schemas

Complete shared request and response schemas from the [published API](https://api.assinafy.com.br/v1/docs). References use the identifiers in [openapi.json](openapi.json).

## Envelope

```json
{
  "description": "Standard success wrapper. Operations add their own `data`.",
  "properties": {
    "status": {
      "description": "HTTP status code, mirrored in the body.",
      "type": "integer",
      "example": 200
    },
    "message": {
      "description": "Human-readable message; empty on success.",
      "type": "string",
      "example": ""
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "status": 200,
  "message": ""
}
```

## ErrorEnvelope

```json
{
  "description": "Standard error wrapper. `status` mirrors the HTTP status code.",
  "properties": {
    "status": {
      "type": "integer",
      "example": 400
    },
    "message": {
      "description": "Human-readable error message.",
      "type": "string",
      "example": "Bad request."
    },
    "data": {
      "type": [
        "object",
        "null"
      ],
      "example": null
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "status": 400,
  "message": "Bad request.",
  "data": null
}
```

## ApiKey

```json
{
  "properties": {
    "api_key": {
      "type": [
        "string",
        "null"
      ],
      "example": "mIpe_zdJfKUpMK9Va3XuYgzPXMxz49fIaRCWXseVkpVAX608A9j3i_D67qU5qW3M"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "api_key": "mIpe_zdJfKUpMK9Va3XuYgzPXMxz49fIaRCWXseVkpVAX608A9j3i_D67qU5qW3M"
}
```

## AuthUser

```json
{
  "properties": {
    "id": {
      "type": "string",
      "example": "bgjazeo5r9v2lq7l36dx48np"
    },
    "name": {
      "type": "string",
      "example": "John Smith"
    },
    "email": {
      "type": "string",
      "format": "email",
      "example": "example@example.com"
    },
    "telephone": {
      "type": [
        "string",
        "null"
      ],
      "example": "17989206641"
    },
    "government_id": {
      "type": [
        "string",
        "null"
      ],
      "example": "15774136604"
    },
    "is_email_verified": {
      "type": "boolean",
      "example": false
    },
    "has_accepted_terms": {
      "type": "boolean",
      "example": true
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "example": "2023-03-03T11:51:34Z"
    },
    "to_be_deleted_at": {
      "type": [
        "string",
        "null"
      ],
      "format": "date-time",
      "example": null
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "id": "bgjazeo5r9v2lq7l36dx48np",
  "name": "John Smith",
  "email": "example@example.com",
  "telephone": "17989206641",
  "government_id": "15774136604",
  "is_email_verified": false,
  "has_accepted_terms": true,
  "created_at": "2023-03-03T11:51:34Z",
  "to_be_deleted_at": null
}
```

## AuthAccount

```json
{
  "properties": {
    "id": {
      "type": "string",
      "example": "6401df46d6a6b0c692d9ec49"
    },
    "name": {
      "type": "string",
      "example": "JS"
    },
    "roles": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "example": [
        "owner"
      ]
    },
    "is_delete_allowed": {
      "type": "boolean",
      "example": true
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "example": "2023-03-03T11:51:34Z"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "id": "6401df46d6a6b0c692d9ec49",
  "name": "JS",
  "roles": [
    "owner"
  ],
  "is_delete_allowed": true,
  "created_at": "2023-03-03T11:51:34Z"
}
```

## Signer

```json
{
  "description": "A signing party belonging to a workspace account.",
  "properties": {
    "resource": {
      "description": "Present in single-resource responses.",
      "type": "string",
      "example": "signer"
    },
    "id": {
      "type": "string",
      "example": "62d6ee35c7741ca4006b9e11"
    },
    "full_name": {
      "type": "string",
      "example": "John Signer"
    },
    "email": {
      "type": [
        "string",
        "null"
      ],
      "format": "email",
      "example": "john@example.com"
    },
    "whatsapp_phone_number": {
      "description": "E.164 format; normalized on save.",
      "type": [
        "string",
        "null"
      ],
      "example": "+5548999990000"
    },
    "government_id": {
      "description": "Signer's normalized CPF (11 digits) or CNPJ (14 characters; may be alphanumeric).",
      "type": [
        "string",
        "null"
      ],
      "example": "39053344705"
    },
    "has_accepted_terms": {
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
  "resource": "signer",
  "id": "62d6ee35c7741ca4006b9e11",
  "full_name": "John Signer",
  "email": "john@example.com",
  "whatsapp_phone_number": "+5548999990000",
  "government_id": "39053344705",
  "has_accepted_terms": false
}
```

## SignerSelf

```json
{
  "description": "The current signer, as returned by `GET /v1/signers/self`. Extends Signer with the signature-state flags that are only computed for the authenticated signer.",
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Signer"
    },
    {
      "properties": {
        "has_signature": {
          "description": "Whether the signer has a saved signature image stored.",
          "type": "boolean",
          "example": true
        },
        "has_initial": {
          "description": "Whether the signer has a saved initials image stored.",
          "type": "boolean",
          "example": false
        },
        "is_signature_reusable": {
          "description": "Whether the signer opted to reuse their saved signature/initials in future processes. When false, clients should not pre-render the saved image even if `has_signature`/`has_initial` is true.",
          "type": "boolean",
          "example": false
        },
        "verification_method": {
          "description": "How this signature request verifies the signer. `Email`/`Whatsapp` ask for the 6-digit code; `IdDocumentFaceMatchBasic` runs the identity document check instead (see **Identity document verification status**).",
          "type": "string",
          "enum": [
            "Email",
            "Whatsapp",
            "DigitalCertificate",
            "IdDocumentFaceMatchBasic"
          ],
          "example": "Email"
        }
      },
      "type": "object"
    }
  ]
}
```

**Payload shape:**

```json
{
  "resource": "signer",
  "id": "62d6ee35c7741ca4006b9e11",
  "full_name": "John Signer",
  "email": "john@example.com",
  "whatsapp_phone_number": "+5548999990000",
  "government_id": "39053344705",
  "has_accepted_terms": false,
  "has_signature": true,
  "has_initial": false,
  "is_signature_reusable": false,
  "verification_method": "Email"
}
```

## DocumentPage

```json
{
  "properties": {
    "id": {
      "type": "string",
      "example": "615601faf166d6d1d8e7dc30"
    },
    "number": {
      "type": "integer",
      "example": 1
    },
    "height": {
      "type": "integer",
      "example": 2100
    },
    "width": {
      "type": "integer",
      "example": 1275
    },
    "download_url": {
      "type": "string",
      "example": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "id": "615601faf166d6d1d8e7dc30",
  "number": 1,
  "height": 2100,
  "width": 1275,
  "download_url": "https://api.assinafy.com.br/v1/documents/doc1/pages/1a/download"
}
```

## DisplaySettings

```json
{
  "description": "A field placement rectangle on a document page. Geometry values are pixels in Assinafy's 150-DPI page image, measured from the upper-left corner. Clients must keep the rectangle within the selected page's width and height; the API does not clamp out-of-bounds values.",
  "required": [
    "left",
    "top",
    "width",
    "height",
    "fontSize"
  ],
  "properties": {
    "left": {
      "description": "Horizontal distance from the page's left edge, in page-image pixels.",
      "type": "number",
      "format": "float",
      "minimum": 0,
      "example": 69
    },
    "top": {
      "description": "Vertical distance from the page's top edge, in page-image pixels.",
      "type": "number",
      "format": "float",
      "minimum": 0,
      "example": 282
    },
    "width": {
      "description": "Width of the placement rectangle, in page-image pixels.",
      "type": "number",
      "format": "float",
      "exclusiveMinimum": 0,
      "example": 421
    },
    "height": {
      "description": "Height of the placement rectangle, in page-image pixels.",
      "type": "number",
      "format": "float",
      "exclusiveMinimum": 0,
      "example": 45.86
    },
    "fontFamily": {
      "description": "Font-family presentation metadata.",
      "type": "string",
      "example": "Arial"
    },
    "fontSize": {
      "description": "Font size in the 150-DPI page-image coordinate system.",
      "type": "number",
      "format": "float",
      "exclusiveMinimum": 0,
      "example": 22
    },
    "backgroundColor": {
      "description": "CSS-compatible background-color presentation metadata.",
      "type": "string",
      "example": "#D5EBFF"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "left": 69,
  "top": 282,
  "width": 421,
  "height": 45.86,
  "fontFamily": "Arial",
  "fontSize": 22,
  "backgroundColor": "#D5EBFF"
}
```

## DocumentStatus

```json
{
  "properties": {
    "code": {
      "type": "string",
      "example": "metadata_ready"
    },
    "deletable": {
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
  "code": "metadata_ready",
  "deletable": true
}
```

## Document

```json
{
  "description": "A document and its current lifecycle state.",
  "properties": {
    "resource": {
      "description": "Present in single-resource responses.",
      "type": "string",
      "example": "document"
    },
    "id": {
      "type": "string",
      "example": "615601fab04c0a3147bb1246"
    },
    "account_id": {
      "type": "string",
      "example": "d199996981dbd199996981db"
    },
    "template_id": {
      "type": [
        "string",
        "null"
      ],
      "example": null
    },
    "name": {
      "type": "string",
      "example": "document.pdf"
    },
    "status": {
      "description": "Status code — see GET /v1/documents/statuses.",
      "type": "string",
      "example": "metadata_ready"
    },
    "artifacts": {
      "description": "Artifact download URLs keyed by name. Always `original`, plus `thumbnail` once one exists. A certificated document also carries `certificated`, `certificate-page` and `bundle`, and `pades` when it was signed with a digital certificate — the PAdES version holds the signers' ICP-Brasil signatures, which certification flattens out of the certificated PDF.",
      "type": "object",
      "example": {
        "original": "https://api.assinafy.com.br/v1/documents/doc1/download/original"
      }
    },
    "is_closed": {
      "type": "boolean",
      "example": false
    },
    "signing_url": {
      "type": "string",
      "example": "https://api.assinafy.com.br/v1/sign/doc1"
    },
    "verification_code": {
      "description": "The code printed on the certificate page. Anyone can check it with `GET /v1/documents/{verification_code}/verify` or on `verification_url`. `null` until the document is `certificated`, and on documents certificated before verification codes existed.",
      "type": [
        "string",
        "null"
      ],
      "example": "a3f1c9e07b2d4e8f9a6c5b1d0e7f3a2c9b8d4e6f"
    },
    "verification_url": {
      "description": "The public verification page for this document. `null` until the document is `certificated`.",
      "type": [
        "string",
        "null"
      ],
      "format": "uri",
      "example": "https://www.assinafy.com.br/verificador/a3f1c9e07b2d4e8f9a6c5b1d0e7f3a2c9b8d4e6f"
    },
    "decline_reason": {
      "type": [
        "string",
        "null"
      ],
      "example": null
    },
    "declined_by": {
      "oneOf": [
        {
          "$ref": "#/components/schemas/Signer"
        },
        {
          "type": "null"
        }
      ]
    },
    "tags": {
      "type": "array",
      "items": {
        "properties": {
          "id": {
            "type": "string"
          },
          "name": {
            "type": "string"
          }
        },
        "type": "object"
      }
    },
    "assignment": {
      "description": "The document's assignment, or `null` before one is created. The server decides when it is included, whatever `expand` the request sends: the document list, `GET /v1/documents/{documentId}`, the signer's document list and document creation from a template always include it; `/documents/search` and the upload response never do. Only the rename response follows `?expand=assignment`.",
      "oneOf": [
        {
          "$ref": "#/components/schemas/Assignment"
        },
        {
          "type": "null"
        }
      ]
    },
    "pages": {
      "description": "The document's pages. Included on the same responses as `assignment`, and also on the upload response.",
      "type": "array",
      "items": {
        "$ref": "#/components/schemas/DocumentPage"
      }
    },
    "has_contract": {
      "description": "Only on `GET /v1/documents/{documentId}` read by the workspace, while the environment has contract tracking on: not with a signer's access code, not in document lists or webhooks, and left out when the lookup fails, so a missing key means unknown. Whether `GET /v1/accounts/{accountId}/documents/{documentId}/contract` answers with contract terms, the document's own or those of a contract it amends whose document still exists, so a page can lay out the contract section before reading it.",
      "type": "boolean",
      "example": true
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "example": "2026-06-03T03:54:16Z"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time",
      "example": "2026-06-03T03:54:16Z"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
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
  "verification_code": "a3f1c9e07b2d4e8f9a6c5b1d0e7f3a2c9b8d4e6f",
  "verification_url": "https://www.assinafy.com.br/verificador/a3f1c9e07b2d4e8f9a6c5b1d0e7f3a2c9b8d4e6f",
  "decline_reason": null,
  "declined_by": {
    "resource": "signer",
    "id": "62d6ee35c7741ca4006b9e11",
    "full_name": "John Signer",
    "email": "john@example.com",
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
    "document_id": "615601fab04c0a3147bb1246",
    "created_at": "2026-06-03T03:54:16Z",
    "sender_email": "sender@example.com",
    "method": "virtual",
    "expires_at": null,
    "message": "<string>",
    "signers": [
      {
        "resource": "signer",
        "id": "62d6ee35c7741ca4006b9e11",
        "full_name": "John Signer",
        "email": "john@example.com",
        "whatsapp_phone_number": "+5548999990000",
        "government_id": "39053344705",
        "has_accepted_terms": false,
        "verification_method": "Email",
        "notification_methods": [
          "Email"
        ],
        "step": 1,
        "notified": false,
        "identity_verification_status": "InReview",
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
        "url": "https://api.assinafy.com.br/v1/sign/doc1?email=joe@example.com"
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
  "has_contract": true,
  "created_at": "2026-06-03T03:54:16Z",
  "updated_at": "2026-06-03T03:54:16Z"
}
```

## Account

```json
{
  "description": "A workspace account (organization).",
  "properties": {
    "resource": {
      "type": "string",
      "example": "account"
    },
    "id": {
      "type": "string",
      "example": "6401df46d6a6b0c692d9ec49"
    },
    "name": {
      "type": "string",
      "example": "Acme Inc."
    },
    "primary_color": {
      "type": [
        "string",
        "null"
      ],
      "example": "aabbcc"
    },
    "secondary_color": {
      "type": [
        "string",
        "null"
      ],
      "example": "112233"
    },
    "notification_sender_type": {
      "type": "string",
      "enum": [
        "User",
        "Account"
      ],
      "example": "User"
    },
    "roles": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "example": [
        "owner"
      ]
    },
    "is_delete_allowed": {
      "type": "boolean",
      "example": true
    },
    "limits": {
      "description": "Limits of the workspace's current plan. Returned only by `GET /v1/accounts/{accountId}`, not in account lists. More keys may be added.",
      "properties": {
        "webhook_endpoints": {
          "description": "How many webhook endpoints the workspace can have: `1`, or `3` with the Multiple Webhooks feature. Creating one past the limit returns `403`.",
          "type": "integer",
          "example": 1
        }
      },
      "type": "object"
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "example": "2026-06-03T03:54:16Z"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
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
  "limits": {
    "webhook_endpoints": 1
  },
  "created_at": "2026-06-03T03:54:16Z"
}
```

## Field

```json
{
  "description": "A reusable field definition.",
  "properties": {
    "resource": {
      "type": "string",
      "example": "field"
    },
    "id": {
      "type": "string",
      "example": "6152120297080d55bdd13197"
    },
    "name": {
      "type": "string",
      "example": "Signature"
    },
    "type": {
      "type": "string",
      "example": "signature"
    },
    "regex": {
      "type": [
        "string",
        "null"
      ]
    },
    "is_pre_defined": {
      "type": "boolean"
    },
    "is_active": {
      "type": "boolean"
    },
    "is_required": {
      "type": "boolean"
    },
    "is_standard": {
      "type": "boolean"
    },
    "is_read_only": {
      "type": "boolean"
    },
    "is_visible": {
      "type": "boolean"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
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
```

## Tag

```json
{
  "description": "A workspace-scoped label. Names are unique per workspace (case-insensitive).",
  "properties": {
    "resource": {
      "type": "string",
      "example": "tag"
    },
    "id": {
      "type": "string",
      "example": "fa8c09f3e709a8a1c82d69b1454"
    },
    "name": {
      "type": "string",
      "example": "Contracts"
    },
    "color": {
      "description": "6-char hex without leading #.",
      "type": [
        "string",
        "null"
      ],
      "example": "ff8800"
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "example": "2026-05-14T12:00:00Z"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time",
      "example": "2026-05-14T12:00:00Z"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "resource": "tag",
  "id": "fa8c09f3e709a8a1c82d69b1454",
  "name": "Contracts",
  "color": "ff8800",
  "created_at": "2026-05-14T12:00:00Z",
  "updated_at": "2026-05-14T12:00:00Z"
}
```

## DocumentContract

```json
{
  "description": "The contract terms tracked on a document.",
  "properties": {
    "resource": {
      "type": "string",
      "example": "document_contract"
    },
    "document_id": {
      "type": "string",
      "example": "66b2f0e1c3a4d5e6f7a8b9c0"
    },
    "status": {
      "type": "string",
      "enum": [
        "draft",
        "active",
        "expired",
        "terminated"
      ],
      "example": "active"
    },
    "counterparty_name": {
      "type": [
        "string",
        "null"
      ],
      "example": "Acme Ltda"
    },
    "counterparty_taxpayer_id": {
      "description": "CPF or CNPJ, digits only.",
      "type": [
        "string",
        "null"
      ],
      "example": "11222333000181"
    },
    "value": {
      "description": "Two decimal places at most.",
      "type": [
        "number",
        "null"
      ],
      "example": 120000.5
    },
    "currency": {
      "description": "ISO 4217 code; `BRL` when a value is sent without one.",
      "type": [
        "string",
        "null"
      ],
      "example": "BRL"
    },
    "start_date": {
      "type": [
        "string",
        "null"
      ],
      "format": "date",
      "example": "2026-11-01"
    },
    "end_date": {
      "type": [
        "string",
        "null"
      ],
      "format": "date",
      "example": "2027-10-31"
    },
    "auto_renew": {
      "type": "boolean",
      "example": true
    },
    "renewal_term_months": {
      "type": [
        "integer",
        "null"
      ],
      "example": 12
    },
    "notice_period_days": {
      "type": [
        "integer",
        "null"
      ],
      "example": 30
    },
    "term": {
      "description": "Steps on every renewal, starting at 1.",
      "type": "integer",
      "example": 1
    },
    "owner_id": {
      "description": "ID of the workspace member who owns the contract. When the owner is no longer a member of the workspace (removed, left, or deleted with their account), the hourly run hands the contract to the first owner who is still an active member, or leaves it without one; an inactive member stays the owner. The contract's e-mails (renewal notice, expiring, expired, renewed) go to the first of the owner and the document's creator who is an active member, as that member's notification preferences allow.",
      "type": [
        "string",
        "null"
      ],
      "example": "d6zqpbyog2v3xvxerwn8la94"
    },
    "metadata": {
      "description": "Up to 50 keys of your own, each holding text of at most 500 characters; `null` when there are none. A key ending in `_at` cannot hold a number: the API returns numbers under such keys as dates.",
      "type": [
        "object",
        "null"
      ],
      "example": {
        "crm_stage": "won"
      },
      "additionalProperties": {
        "type": "string"
      }
    },
    "external_references": {
      "description": "IDs outside systems use for this contract, ordered by system and id.",
      "type": "array",
      "items": {
        "properties": {
          "system": {
            "type": "string",
            "example": "hubspot"
          },
          "id": {
            "type": "string",
            "example": "98765"
          }
        },
        "type": "object"
      }
    },
    "document": {
      "$ref": "#/components/schemas/Document",
      "description": "Only with `expand=document`: the document the terms are tracked on."
    },
    "amendments": {
      "description": "Only on the single-contract read: the documents that amend, renew or terminate this contract, the applied ones first by `number`, then the pending ones.",
      "type": "array",
      "items": {
        "$ref": "#/components/schemas/DocumentContractAmendment"
      }
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "example": "2026-10-23T12:00:00Z"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time",
      "example": "2026-10-23T12:00:00Z"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "resource": "document_contract",
  "document_id": "66b2f0e1c3a4d5e6f7a8b9c0",
  "status": "active",
  "counterparty_name": "Acme Ltda",
  "counterparty_taxpayer_id": "11222333000181",
  "value": 120000.5,
  "currency": "BRL",
  "start_date": "2026-11-01",
  "end_date": "2027-10-31",
  "auto_renew": true,
  "renewal_term_months": 12,
  "notice_period_days": 30,
  "term": 1,
  "owner_id": "d6zqpbyog2v3xvxerwn8la94",
  "metadata": {
    "crm_stage": "won"
  },
  "external_references": [
    {
      "system": "hubspot",
      "id": "98765"
    }
  ],
  "document": {
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
    "verification_code": "a3f1c9e07b2d4e8f9a6c5b1d0e7f3a2c9b8d4e6f",
    "verification_url": "https://www.assinafy.com.br/verificador/a3f1c9e07b2d4e8f9a6c5b1d0e7f3a2c9b8d4e6f",
    "decline_reason": null,
    "declined_by": {
      "resource": "signer",
      "id": "62d6ee35c7741ca4006b9e11",
      "full_name": "John Signer",
      "email": "john@example.com",
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
      "document_id": "615601fab04c0a3147bb1246",
      "created_at": "2026-06-03T03:54:16Z",
      "sender_email": "sender@example.com",
      "method": "virtual",
      "expires_at": null,
      "message": "<string>",
      "signers": [
        {
          "resource": "signer",
          "id": "62d6ee35c7741ca4006b9e11",
          "full_name": "John Signer",
          "email": "john@example.com",
          "whatsapp_phone_number": "+5548999990000",
          "government_id": "39053344705",
          "has_accepted_terms": false,
          "verification_method": "Email",
          "notification_methods": [
            "Email"
          ],
          "step": 1,
          "notified": false,
          "identity_verification_status": "InReview",
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
          "url": "https://api.assinafy.com.br/v1/sign/doc1?email=joe@example.com"
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
    "has_contract": true,
    "created_at": "2026-06-03T03:54:16Z",
    "updated_at": "2026-06-03T03:54:16Z"
  },
  "amendments": [
    {
      "resource": "document_contract_amendment",
      "document_id": "7c3d1e2f4a5b6c7d8e9f0a1b",
      "document_name": "Aditivo 1 - Contrato de prestação de serviços.pdf",
      "parent_document_id": "66b2f0e1c3a4d5e6f7a8b9c0",
      "relation_type": "amendment",
      "number": 1,
      "status": "pending",
      "document_status": "pending_signature",
      "apply_error": "<string>",
      "currency": "BRL",
      "terms": {
        "value": 130000,
        "end_date": "2028-06-30"
      },
      "changes": {
        "value": {
          "from": 120000.5,
          "to": 130000
        },
        "end_date": {
          "from": "2027-10-31",
          "to": "2028-06-30"
        },
        "term": {
          "from": 1,
          "to": 2
        }
      },
      "applied_at": "2030-01-01T12:00:00Z",
      "created_at": "2026-10-23T12:00:00Z",
      "updated_at": "2026-10-23T12:00:00Z"
    }
  ],
  "created_at": "2026-10-23T12:00:00Z",
  "updated_at": "2026-10-23T12:00:00Z"
}
```

## DocumentContractInput

```json
{
  "description": "Every attribute is optional and only the ones sent change. `null` clears an attribute, except `auto_renew` (back to `false`) and `currency` (back to `BRL` while a `value` is set); `status` does not accept `null`. A changed `end_date` starts a new `term`.",
  "properties": {
    "status": {
      "description": "On creation any status, so a contract that ended before it was tracked is registered as it ended: `expired` needs an `end_date` in the past, `terminated` its `end_date`; neither is walked by the lifecycle. Afterwards only `draft` or `active` (a contract in force never goes back to `draft`): `expired` and `terminated` are set by the lifecycle and the terminate endpoint; a closed contract is reopened by renewing it.",
      "type": "string",
      "enum": [
        "draft",
        "active",
        "expired",
        "terminated"
      ]
    },
    "counterparty_name": {
      "description": "Emoji are kept; other characters outside the 3-byte range are dropped.",
      "type": [
        "string",
        "null"
      ],
      "maxLength": 255
    },
    "counterparty_taxpayer_id": {
      "description": "A valid CPF or CNPJ, formatted or not.",
      "type": [
        "string",
        "null"
      ]
    },
    "value": {
      "description": "Two decimal places at most.",
      "type": [
        "number",
        "null"
      ],
      "maximum": 9999999999999.99,
      "minimum": 0
    },
    "currency": {
      "description": "Three letters, such as `BRL` or `USD`, stored in capitals; `BRL` when a `value` is set without one.",
      "type": [
        "string",
        "null"
      ],
      "example": "BRL"
    },
    "start_date": {
      "description": "`YYYY-MM-DD`, from the year 1000.",
      "type": [
        "string",
        "null"
      ],
      "format": "date"
    },
    "end_date": {
      "description": "`YYYY-MM-DD`, on or after `start_date`.",
      "type": [
        "string",
        "null"
      ],
      "format": "date"
    },
    "auto_renew": {
      "description": "Whether the hourly run starts the next term the day after `end_date`, by `renewal_term_months`, instead of expiring the contract.",
      "type": "boolean"
    },
    "renewal_term_months": {
      "description": "How far a renewal by the term moves `end_date`; 12 when unset.",
      "type": [
        "integer",
        "null"
      ],
      "maximum": 600,
      "minimum": 1
    },
    "notice_period_days": {
      "description": "Days before `end_date` the notice period starts (`document_contract_renewal_notice`); none when unset.",
      "type": [
        "integer",
        "null"
      ],
      "maximum": 3650,
      "minimum": 0
    },
    "owner_id": {
      "description": "An active member of this workspace.",
      "type": [
        "string",
        "null"
      ]
    },
    "metadata": {
      "description": "Your own fields: up to 50 keys of 1 to 40 letters, digits, `_`, `-` or `.`, each holding plain text of at most 500 characters; no number under a key ending in `_at`, or `stuck_since`.",
      "maxProperties": 50,
      "type": [
        "object",
        "null"
      ],
      "additionalProperties": {
        "type": "string",
        "maxLength": 500
      }
    },
    "external_references": {
      "description": "Replaces the whole list; `[]` or `null` clears it. Two items whose `system` and `id` compare equal case aside are one reference (the first sent is kept); a pair the database takes for one beyond that (accents, `ß` and `ss`) answers `400`.",
      "type": [
        "array",
        "null"
      ],
      "items": {
        "required": [
          "system",
          "id"
        ],
        "properties": {
          "system": {
            "description": "Letters, digits, `_`, `-` and `.`; stored in lower case.",
            "type": "string",
            "maxLength": 64,
            "example": "hubspot"
          },
          "id": {
            "description": "Kept as sent; must not contain emoji or other 4-byte characters.",
            "type": "string",
            "maxLength": 255,
            "example": "98765"
          }
        },
        "type": "object"
      },
      "maxItems": 20
    },
    "parent_document_id": {
      "description": "Links the document as an amendment of this contract document, or of any document in its family (resolved to the root); `null` unlinks a pending amendment. With it, the other attributes are the terms the instrument changes, not terms of its own; on a pending amendment a `null` value drops that term from the delta rather than clearing it on the parent.",
      "type": [
        "string",
        "null"
      ]
    },
    "relation_type": {
      "description": "Required on the first link. `amendment` may change `value`, `currency`, `start_date` (effective from, display only), `end_date`, `auto_renew`, `renewal_term_months`, `notice_period_days`, `counterparty_name`, `counterparty_taxpayer_id` and `metadata`; `renewal` only `end_date` and `value`; `termination` only `end_date` (the effective date).",
      "type": "string",
      "enum": [
        "amendment",
        "renewal",
        "termination"
      ]
    },
    "updated_at": {
      "description": "Optional precondition: the `updated_at` the client read the contract (or this document's amendment link) with, as the API returned it. If the contract or link changed since, nothing is written and the answer is `409` with `code: ContractChanged`. Not sent, or `null`: the write applies whatever changed meanwhile (last write wins). Compared to the second; a fraction of a second, as a JavaScript date prints it, is read and ignored. New terms and a first link have nothing to have read, so sending one answers `409`; on a pending amendment, send the link's own `updated_at` (the GET on that document).",
      "type": "string",
      "format": "date-time",
      "example": "2026-10-23T12:00:00Z"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "status": "draft",
  "counterparty_name": "<string>",
  "counterparty_taxpayer_id": "<string>",
  "value": 0,
  "currency": "BRL",
  "start_date": "<string>",
  "end_date": "<string>",
  "auto_renew": false,
  "renewal_term_months": 1,
  "notice_period_days": 0,
  "owner_id": "<string>",
  "metadata": {},
  "external_references": [
    {
      "system": "hubspot",
      "id": "98765"
    }
  ],
  "parent_document_id": "<string>",
  "relation_type": "amendment",
  "updated_at": "2026-10-23T12:00:00Z"
}
```

## DocumentContractAmendment

```json
{
  "description": "A document that amends, renews or terminates a contract: its link and the terms it changes. The parent's terms take the delta once this document is certificated; until then the parent is untouched.",
  "properties": {
    "resource": {
      "type": "string",
      "example": "document_contract_amendment"
    },
    "document_id": {
      "description": "This document, the instrument.",
      "type": "string",
      "example": "7c3d1e2f4a5b6c7d8e9f0a1b"
    },
    "document_name": {
      "description": "This document's name.",
      "type": "string",
      "example": "Aditivo 1 - Contrato de prestação de serviços.pdf"
    },
    "parent_document_id": {
      "description": "The contract document whose terms change.",
      "type": "string",
      "example": "66b2f0e1c3a4d5e6f7a8b9c0"
    },
    "relation_type": {
      "type": "string",
      "enum": [
        "amendment",
        "renewal",
        "termination"
      ],
      "example": "amendment"
    },
    "number": {
      "description": "Position among the parent's applied amendments by signing date; `null` while pending.",
      "type": [
        "integer",
        "null"
      ],
      "example": 1
    },
    "status": {
      "description": "`applied` once the delta moved the parent's terms.",
      "type": "string",
      "enum": [
        "pending",
        "applied"
      ],
      "example": "pending"
    },
    "document_status": {
      "description": "This document's own status, so a declined, cancelled or expired instrument shows as such. An instrument applies only while its document is `certificated`: one whose document reads `failed` after it was signed waits, with no `apply_error`, until it is certificated again, and then applies in its place in the signing order.",
      "type": "string",
      "example": "pending_signature"
    },
    "apply_error": {
      "description": "Why a signed instrument has not applied yet, retried every hour: the workspace's plan does not include contract tracking (it applies on the first run after the plan returns), the parent would not take the delta, an instrument signed before this one has not applied yet, one signed after it has already applied (this one then stays blocked: unlink it, and record what it still changes on a new instrument), or an unexpected failure.",
      "type": [
        "string",
        "null"
      ]
    },
    "currency": {
      "description": "The currency of the amounts in `terms` and `changes`. Once applied, the contract's currency at that moment, kept whatever the contract moves to later. While pending (and for an instrument applied before this was kept), the one this instrument moves the contract to, otherwise the contract's. `null` when neither has one.",
      "type": [
        "string",
        "null"
      ],
      "example": "BRL"
    },
    "terms": {
      "description": "The delta: only the terms this instrument changes; `null` when it changes none (a termination on the day it is signed).",
      "type": [
        "object",
        "null"
      ],
      "example": {
        "value": 130000,
        "end_date": "2028-06-30"
      }
    },
    "changes": {
      "description": "Every parent field the roll-up moves, as `{from, to}`: a preview while pending, the record once applied; `null` when it moves none.",
      "type": [
        "object",
        "null"
      ],
      "example": {
        "value": {
          "from": 120000.5,
          "to": 130000
        },
        "end_date": {
          "from": "2027-10-31",
          "to": "2028-06-30"
        },
        "term": {
          "from": 1,
          "to": 2
        }
      }
    },
    "applied_at": {
      "type": [
        "string",
        "null"
      ],
      "format": "date-time"
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "example": "2026-10-23T12:00:00Z"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time",
      "example": "2026-10-23T12:00:00Z"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "resource": "document_contract_amendment",
  "document_id": "7c3d1e2f4a5b6c7d8e9f0a1b",
  "document_name": "Aditivo 1 - Contrato de prestação de serviços.pdf",
  "parent_document_id": "66b2f0e1c3a4d5e6f7a8b9c0",
  "relation_type": "amendment",
  "number": 1,
  "status": "pending",
  "document_status": "pending_signature",
  "apply_error": "<string>",
  "currency": "BRL",
  "terms": {
    "value": 130000,
    "end_date": "2028-06-30"
  },
  "changes": {
    "value": {
      "from": 120000.5,
      "to": 130000
    },
    "end_date": {
      "from": "2027-10-31",
      "to": "2028-06-30"
    },
    "term": {
      "from": 1,
      "to": 2
    }
  },
  "applied_at": "2030-01-01T12:00:00Z",
  "created_at": "2026-10-23T12:00:00Z",
  "updated_at": "2026-10-23T12:00:00Z"
}
```

## SigningUrl

```json
{
  "properties": {
    "signer_id": {
      "type": "string"
    },
    "url": {
      "type": "string",
      "example": "https://api.assinafy.com.br/v1/sign/doc1?email=joe@example.com"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "signer_id": "<string>",
  "url": "https://api.assinafy.com.br/v1/sign/doc1?email=joe@example.com"
}
```

## AssignmentSigner

```json
{
  "description": "A signer within an assignment: the base Signer plus per-assignment verification/notification details.",
  "type": "object",
  "allOf": [
    {
      "$ref": "#/components/schemas/Signer"
    },
    {
      "properties": {
        "verification_method": {
          "type": [
            "string",
            "null"
          ],
          "example": "Email"
        },
        "notification_methods": {
          "type": [
            "array",
            "null"
          ],
          "items": {
            "type": "string"
          },
          "example": [
            "Email"
          ]
        },
        "step": {
          "description": "Sequential signing step (defaults to 1).",
          "type": [
            "integer",
            "null"
          ],
          "example": 1
        },
        "notified": {
          "type": [
            "boolean",
            "null"
          ]
        },
        "identity_verification_status": {
          "description": "Latest identity-document verification status; `InReview` means the account must decide it before the document can be certificated.",
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "Pending",
            "InReview",
            "Approved",
            "Declined",
            "Expired",
            "Abandoned"
          ],
          "example": "InReview"
        },
        "completed": {
          "description": "Only present in account-owner contexts.",
          "type": [
            "boolean",
            "null"
          ]
        },
        "notification_history": {
          "description": "Per-channel delivery history for this signer (email + WhatsApp), most-recent send order.",
          "type": [
            "array",
            "null"
          ],
          "items": {
            "$ref": "#/components/schemas/NotificationHistoryEntry"
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
  "resource": "signer",
  "id": "62d6ee35c7741ca4006b9e11",
  "full_name": "John Signer",
  "email": "john@example.com",
  "whatsapp_phone_number": "+5548999990000",
  "government_id": "39053344705",
  "has_accepted_terms": false,
  "verification_method": "Email",
  "notification_methods": [
    "Email"
  ],
  "step": 1,
  "notified": false,
  "identity_verification_status": "InReview",
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
```

## NotificationHistoryEntry

```json
{
  "description": "A single notification delivery record for a signer channel.",
  "properties": {
    "event": {
      "type": "string",
      "example": "signature_request"
    },
    "status": {
      "type": "string",
      "enum": [
        "sent",
        "failed"
      ],
      "example": "sent"
    },
    "error_code": {
      "type": [
        "string",
        "null"
      ]
    },
    "error_message": {
      "type": [
        "string",
        "null"
      ]
    },
    "sent_at": {
      "type": [
        "string",
        "null"
      ],
      "format": "date-time",
      "example": "2026-07-07T12:00:00Z"
    },
    "failed_at": {
      "type": [
        "string",
        "null"
      ],
      "format": "date-time",
      "example": null
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "event": "signature_request",
  "status": "sent",
  "error_code": "<string>",
  "error_message": "<string>",
  "sent_at": "2026-07-07T12:00:00Z",
  "failed_at": null
}
```

## AssignmentItem

```json
{
  "properties": {
    "id": {
      "type": "string"
    },
    "page": {
      "oneOf": [
        {
          "$ref": "#/components/schemas/DocumentPage"
        },
        {
          "type": "null"
        }
      ]
    },
    "signer": {
      "description": "Signer responsible for this item.",
      "type": "object"
    },
    "field": {
      "description": "Field definition associated with the item.",
      "type": [
        "object",
        "null"
      ]
    },
    "display_settings": {
      "description": "Rendering metadata for the item. Collect items use the DisplaySettings schema; virtual and legacy items may return an empty or non-object value."
    },
    "value": {
      "description": "Captured value when completed; `null` until then."
    },
    "completed": {
      "type": "boolean"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
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
```

## AssignmentSummary

```json
{
  "properties": {
    "signer_count": {
      "type": "integer"
    },
    "completed_count": {
      "type": "integer"
    },
    "signers": {
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
  "signer_count": 1,
  "completed_count": 1,
  "signers": [
    {}
  ]
}
```

## Assignment

```json
{
  "description": "A request for signers to sign a document.",
  "properties": {
    "resource": {
      "type": "string",
      "example": "assignment"
    },
    "id": {
      "type": "string",
      "example": "615606ef81d199996981dbce"
    },
    "document_id": {
      "description": "The document this assignment belongs to. `null` only if the document was deleted.",
      "type": [
        "string",
        "null"
      ],
      "example": "615601fab04c0a3147bb1246"
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "example": "2026-06-03T03:54:16Z"
    },
    "sender_email": {
      "description": "Email of the user who sent the document; null once that user has deleted their account.",
      "type": [
        "string",
        "null"
      ],
      "format": "email",
      "example": "sender@example.com"
    },
    "method": {
      "type": "string",
      "enum": [
        "virtual",
        "collect"
      ],
      "example": "virtual"
    },
    "expires_at": {
      "type": [
        "string",
        "null"
      ],
      "format": "date-time",
      "example": null
    },
    "message": {
      "type": [
        "string",
        "null"
      ]
    },
    "signers": {
      "type": "array",
      "items": {
        "$ref": "#/components/schemas/AssignmentSigner"
      }
    },
    "copy_receivers": {
      "type": "array",
      "items": {
        "type": "object"
      }
    },
    "items": {
      "type": "array",
      "items": {
        "$ref": "#/components/schemas/AssignmentItem"
      }
    },
    "summary": {
      "$ref": "#/components/schemas/AssignmentSummary"
    },
    "signing_urls": {
      "type": "array",
      "items": {
        "$ref": "#/components/schemas/SigningUrl"
      }
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "resource": "assignment",
  "id": "615606ef81d199996981dbce",
  "document_id": "615601fab04c0a3147bb1246",
  "created_at": "2026-06-03T03:54:16Z",
  "sender_email": "sender@example.com",
  "method": "virtual",
  "expires_at": null,
  "message": "<string>",
  "signers": [
    {
      "resource": "signer",
      "id": "62d6ee35c7741ca4006b9e11",
      "full_name": "John Signer",
      "email": "john@example.com",
      "whatsapp_phone_number": "+5548999990000",
      "government_id": "39053344705",
      "has_accepted_terms": false,
      "verification_method": "Email",
      "notification_methods": [
        "Email"
      ],
      "step": 1,
      "notified": false,
      "identity_verification_status": "InReview",
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
      "url": "https://api.assinafy.com.br/v1/sign/doc1?email=joe@example.com"
    }
  ]
}
```

## CostEstimateBreakdownItem

```json
{
  "properties": {
    "code": {
      "type": "string",
      "example": "NotificationWhatsapp"
    },
    "name": {
      "type": "string",
      "example": "Whatsapp Notification"
    },
    "cost": {
      "type": "number",
      "example": 0.9
    },
    "quantity": {
      "type": "integer",
      "example": 2
    },
    "unit_cost": {
      "type": "number",
      "example": 0.45
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "code": "NotificationWhatsapp",
  "name": "Whatsapp Notification",
  "cost": 0.9,
  "quantity": 2,
  "unit_cost": 0.45
}
```

## CostEstimate

```json
{
  "description": "Cost breakdown for an assignment plus current account balances. `credits` is the sum of `breakdown` (notifications, digital-certificate signatures and identity checks). `total_credits` is what the send will take from the credit balance: `credits`, plus `extra_document_cost` when `needs_extra_document` is true. The extra document is not a `breakdown` line.",
  "properties": {
    "documents": {
      "description": "Documents consumed (always 1).",
      "type": "integer",
      "example": 1
    },
    "credits": {
      "description": "Sum of the `breakdown` costs: notifications, digital-certificate signatures and identity checks. Does not include the extra document.",
      "type": "number",
      "example": 0.9
    },
    "needs_extra_document": {
      "description": "True when the plan's document allowance is exhausted and an extra document will be charged from credits.",
      "type": "boolean",
      "example": true
    },
    "extra_document_cost": {
      "description": "Credits for one extra document. Charged only when `needs_extra_document` is true.",
      "type": "number",
      "example": 1
    },
    "total_credits": {
      "description": "Credits the send will consume: `credits`, plus `extra_document_cost` when `needs_extra_document` is true.",
      "type": "number",
      "example": 1.9
    },
    "breakdown": {
      "type": "array",
      "items": {
        "$ref": "#/components/schemas/CostEstimateBreakdownItem"
      }
    },
    "document_balance": {
      "description": "Documents left in the plan.",
      "type": "number",
      "example": 0
    },
    "credit_balance": {
      "description": "Credits available.",
      "type": "number",
      "example": 10
    },
    "has_sufficient_resources": {
      "type": "boolean",
      "example": true
    },
    "blocking_reason": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "PendingPayment",
        "InsufficientDocuments",
        "InsufficientCredits"
      ],
      "example": null
    },
    "message": {
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
  "documents": 1,
  "credits": 0.9,
  "needs_extra_document": true,
  "extra_document_cost": 1,
  "total_credits": 1.9,
  "breakdown": [
    {
      "code": "NotificationWhatsapp",
      "name": "Whatsapp Notification",
      "cost": 0.9,
      "quantity": 2,
      "unit_cost": 0.45
    }
  ],
  "document_balance": 0,
  "credit_balance": 10,
  "has_sufficient_resources": true,
  "blocking_reason": null,
  "message": "<string>"
}
```

## ResendCostEstimate

```json
{
  "description": "Credits a reminder to one signer will take, and whether the account can pay for it. A reminder uses no document.",
  "properties": {
    "total": {
      "description": "Sum of the `breakdown` costs.",
      "type": "number",
      "example": 0.45
    },
    "breakdown": {
      "type": "array",
      "items": {
        "properties": {
          "code": {
            "type": "string",
            "example": "NotificationWhatsappResend"
          },
          "name": {
            "type": "string",
            "example": "Whatsapp Notification Resend"
          },
          "cost": {
            "type": "number",
            "example": 0.45
          }
        },
        "type": "object"
      }
    },
    "credit_balance": {
      "description": "Credits available. `null` when the account's credits are not limited.",
      "type": [
        "number",
        "null"
      ],
      "example": 10
    },
    "has_sufficient_credits": {
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
  "total": 0.45,
  "breakdown": [
    {
      "code": "NotificationWhatsappResend",
      "name": "Whatsapp Notification Resend",
      "cost": 0.45
    }
  ],
  "credit_balance": 10,
  "has_sufficient_credits": true
}
```

## TemplateFieldPlacement

```json
{
  "properties": {
    "id": {
      "type": "string"
    },
    "field_id": {
      "type": "string"
    },
    "role_id": {
      "type": "string"
    },
    "label": {
      "type": "string"
    },
    "display_settings": {
      "description": "Rendering metadata for the placement."
    },
    "created_at": {
      "type": "string",
      "format": "date-time"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "id": "<string>",
  "field_id": "<string>",
  "role_id": "<string>",
  "label": "<string>",
  "display_settings": "<string>",
  "created_at": "2030-01-01T12:00:00Z",
  "updated_at": "2030-01-01T12:00:00Z"
}
```

## TemplatePage

```json
{
  "properties": {
    "id": {
      "type": "string"
    },
    "number": {
      "type": "integer",
      "example": 1
    },
    "height": {
      "type": "integer",
      "example": 2100
    },
    "width": {
      "type": "integer",
      "example": 1275
    },
    "download_url": {
      "type": "string"
    },
    "fields": {
      "type": "array",
      "items": {
        "$ref": "#/components/schemas/TemplateFieldPlacement"
      }
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
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
```

## TemplateRole

```json
{
  "properties": {
    "id": {
      "type": "string"
    },
    "name": {
      "type": "string",
      "example": "Editor"
    },
    "assignment_type": {
      "type": "string",
      "example": "Editor"
    },
    "created_at": {
      "type": "string",
      "format": "date-time"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "id": "<string>",
  "name": "Editor",
  "assignment_type": "Editor",
  "created_at": "2030-01-01T12:00:00Z",
  "updated_at": "2030-01-01T12:00:00Z"
}
```

## Template

```json
{
  "description": "A reusable document template.",
  "properties": {
    "resource": {
      "type": "string",
      "example": "template"
    },
    "id": {
      "type": "string",
      "example": "fa88b732db84d01427d4cdd1092"
    },
    "name": {
      "type": "string",
      "example": "template.pdf"
    },
    "document_name": {
      "description": "Default name for documents created from this template.",
      "type": [
        "string",
        "null"
      ]
    },
    "message": {
      "description": "Default invitation message.",
      "type": [
        "string",
        "null"
      ]
    },
    "status": {
      "description": "One of uploading, uploaded, processing, ready, failed.",
      "type": "string",
      "example": "ready"
    },
    "pages": {
      "type": "array",
      "items": {
        "$ref": "#/components/schemas/TemplatePage"
      }
    },
    "roles": {
      "type": "array",
      "items": {
        "$ref": "#/components/schemas/TemplateRole"
      }
    },
    "tags": {
      "type": "array",
      "items": {
        "properties": {
          "id": {
            "type": "string"
          },
          "name": {
            "type": "string"
          }
        },
        "type": "object"
      }
    },
    "default_document_tags": {
      "description": "Applied to documents created from this template; only returned by the single-template endpoint.",
      "type": "array",
      "items": {
        "properties": {
          "id": {
            "type": "string"
          },
          "name": {
            "type": "string"
          }
        },
        "type": "object"
      }
    },
    "created_at": {
      "type": "string",
      "format": "date-time"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
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
```

## WebhookSubscription

```json
{
  "description": "An account's webhook subscription configuration.",
  "properties": {
    "events": {
      "description": "Event types subscribed for delivery.",
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
      "description": "Whether webhook delivery is active.",
      "type": "boolean",
      "example": true
    },
    "is_held": {
      "description": "Whether deliveries are paused after 10 failures in a row (see **Delivery contract**).",
      "type": "boolean",
      "example": false
    },
    "held_since": {
      "description": "When the pause began (Unix timestamp, seconds); `null` while deliveries run.",
      "type": [
        "integer",
        "null"
      ],
      "example": null
    },
    "url": {
      "description": "Webhook endpoint URL; `https` is required for a new or changed URL.",
      "type": [
        "string",
        "null"
      ],
      "example": "https://example.com?test=1"
    },
    "email": {
      "description": "Contact email for delivery notices.",
      "type": [
        "string",
        "null"
      ],
      "example": "email@example.com"
    },
    "updated_at": {
      "type": [
        "string",
        "null"
      ],
      "format": "date-time",
      "example": "2023-05-10T14:58:24Z"
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
  "is_held": false,
  "held_since": null,
  "url": "https://example.com?test=1",
  "email": "email@example.com",
  "updated_at": "2023-05-10T14:58:24Z"
}
```

## WebhookEndpoint

```json
{
  "description": "A URL that receives the account's webhook events. Every active endpoint subscribed to an event receives it.",
  "properties": {
    "resource": {
      "description": "Always `activity_event_subscription` in single-resource responses.",
      "type": "string",
      "example": "activity_event_subscription"
    },
    "id": {
      "description": "Endpoint ID.",
      "type": "string",
      "example": "65f1c2a9b3e4d5f60718293a4b5c6d7e"
    },
    "name": {
      "description": "Label to tell endpoints apart.",
      "type": [
        "string",
        "null"
      ],
      "example": "ERP"
    },
    "url": {
      "description": "URL that receives the events; `https` is required for a new or changed URL.",
      "type": "string",
      "format": "uri",
      "example": "https://example.com/webhooks/assinafy"
    },
    "email": {
      "description": "Contact email for delivery-failure notices.",
      "type": "string",
      "format": "email",
      "example": "ops@example.com"
    },
    "events": {
      "description": "Event types delivered to this endpoint (see **List webhook event types**).",
      "type": "array",
      "items": {
        "type": "string"
      },
      "example": [
        "document_ready",
        "signer_signed_document"
      ]
    },
    "is_active": {
      "description": "Whether events are delivered to this endpoint.",
      "type": "boolean",
      "example": true
    },
    "is_held": {
      "description": "Whether deliveries are paused after 10 failures in a row: we probe the endpoint on a growing schedule and deliver what it missed when it answers (see **Delivery contract**). Editing the URL, or sending `is_active: true`, lifts the pause.",
      "type": "boolean",
      "example": false
    },
    "held_since": {
      "description": "When the pause began (Unix timestamp, seconds); `null` while deliveries run.",
      "type": [
        "integer",
        "null"
      ],
      "example": null
    },
    "signing_enabled": {
      "description": "Whether deliveries carry a `webhook-signature` header (see **Webhook Payloads → Verifying signatures**).",
      "type": "boolean",
      "example": true
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "example": "2026-10-01T12:00:00Z"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time",
      "example": "2026-10-01T12:00:00Z"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "resource": "activity_event_subscription",
  "id": "65f1c2a9b3e4d5f60718293a4b5c6d7e",
  "name": "ERP",
  "url": "https://example.com/webhooks/assinafy",
  "email": "ops@example.com",
  "events": [
    "document_ready",
    "signer_signed_document"
  ],
  "is_active": true,
  "is_held": false,
  "held_since": null,
  "signing_enabled": true,
  "created_at": "2026-10-01T12:00:00Z",
  "updated_at": "2026-10-01T12:00:00Z"
}
```

## WebhookEndpointSecret

```json
{
  "description": "An endpoint's signing secret.",
  "properties": {
    "secret": {
      "description": "Standard Webhooks secret: `whsec_` followed by the base64-encoded key.",
      "type": "string",
      "example": "whsec_MfKQ9r8GKYqrTwjUPD8ILPZIo2LaLaSw"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "secret": "whsec_MfKQ9r8GKYqrTwjUPD8ILPZIo2LaLaSw"
}
```

## WebhookDispatch

```json
{
  "description": "A single webhook delivery-history entry.",
  "properties": {
    "resource": {
      "description": "Always `activity_dispatching_history` in single-resource responses.",
      "type": "string",
      "example": "activity_dispatching_history"
    },
    "id": {
      "description": "Dispatch entry ID.",
      "type": "string",
      "example": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"
    },
    "event": {
      "description": "Event type that triggered the dispatch.",
      "type": "string",
      "example": "document_ready"
    },
    "activity_id": {
      "description": "Internal activity ID associated with the dispatch.",
      "type": "integer",
      "example": 456
    },
    "endpoint_id": {
      "description": "ID of the webhook endpoint the delivery was sent to (`null` once that endpoint is deleted).",
      "type": [
        "string",
        "null"
      ],
      "example": "65f1c2a9b3e4d5f60718293a4b5c6d7e"
    },
    "endpoint": {
      "description": "URL that received the request.",
      "type": [
        "string",
        "null"
      ],
      "example": "https://example.com/webhook"
    },
    "payload": {
      "description": "JSON payload sent to the endpoint.",
      "type": [
        "object",
        "null"
      ]
    },
    "delivered": {
      "description": "Whether delivery succeeded.",
      "type": "boolean",
      "example": true
    },
    "webhook_id": {
      "description": "The `webhook-id` header of the request: the same on every attempt of this event to this endpoint.",
      "type": [
        "string",
        "null"
      ],
      "example": "9f86d081884c7d659a2feaa0c55ad015"
    },
    "attempt": {
      "description": "Which attempt of this event to this endpoint the entry records, counted from 1.",
      "type": [
        "integer",
        "null"
      ],
      "example": 2
    },
    "kind": {
      "description": "`scheduled`: the delivery of the event as it happened; `probe`: the one delivery we send to a paused endpoint to see whether it answers; `manual`: asked for through **Retry webhook delivery**.",
      "type": "string",
      "enum": [
        "scheduled",
        "probe",
        "manual"
      ],
      "example": "scheduled"
    },
    "will_retry": {
      "description": "Whether another attempt follows this one. `false` on a delivered entry and on the last attempt of a failed one.",
      "type": "boolean",
      "example": true
    },
    "http_status": {
      "description": "HTTP status returned (null if connection failed).",
      "type": [
        "integer",
        "null"
      ],
      "example": 200
    },
    "response_body": {
      "description": "Endpoint response body, truncated to 2000 chars.",
      "type": [
        "string",
        "null"
      ],
      "example": "OK"
    },
    "error": {
      "description": "Delivery error message, if any.",
      "type": [
        "string",
        "null"
      ],
      "example": null
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "example": "2024-01-15T10:30:00Z"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time",
      "example": "2024-01-15T10:30:00Z"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "resource": "activity_dispatching_history",
  "id": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6",
  "event": "document_ready",
  "activity_id": 456,
  "endpoint_id": "65f1c2a9b3e4d5f60718293a4b5c6d7e",
  "endpoint": "https://example.com/webhook",
  "payload": {},
  "delivered": true,
  "webhook_id": "9f86d081884c7d659a2feaa0c55ad015",
  "attempt": 2,
  "kind": "scheduled",
  "will_retry": true,
  "http_status": 200,
  "response_body": "OK",
  "error": null,
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

## WebhookEvent

```json
{
  "description": "Body of every webhook delivery. Timestamps in the body (`created_at`, and the `*_at` fields of `subject`/`object`) are Unix timestamps in seconds, not the ISO strings the REST responses use. `subject` and `object` are serialized from their current state when the delivery is sent.",
  "required": [
    "id",
    "event",
    "created_at",
    "subject",
    "object",
    "account_id"
  ],
  "properties": {
    "id": {
      "description": "ID of the activity that produced the event.",
      "type": "integer",
      "example": 184467
    },
    "event": {
      "description": "Event type. See **List webhook event types**.",
      "type": "string",
      "example": "signer_viewed_document"
    },
    "message": {
      "description": "Reserved; currently always `null`.",
      "type": [
        "string",
        "null"
      ],
      "example": null
    },
    "payload": {
      "description": "Event-specific parameters; keys vary per event.",
      "type": [
        "object",
        "null"
      ],
      "additionalProperties": true
    },
    "origin": {
      "description": "Where the action came from, when it was triggered by a request.",
      "properties": {
        "ip": {
          "type": "string",
          "example": "203.0.113.7"
        },
        "user-agent": {
          "type": "string",
          "example": "Mozilla/5.0"
        }
      },
      "type": [
        "object",
        "null"
      ]
    },
    "created_at": {
      "description": "When the event was recorded (Unix timestamp, seconds).",
      "type": "integer",
      "example": 1790000000
    },
    "subject": {
      "description": "Who performed the action: a `User`, `Signer` or `Account`, plus a `type` property naming it.",
      "type": "object",
      "additionalProperties": true
    },
    "object": {
      "description": "What the action was performed on: a `Document`, `Signer` or `Template` with its relations expanded, plus a `type` property naming it.",
      "type": "object",
      "additionalProperties": true
    },
    "account_id": {
      "description": "ID of the account that owns the event.",
      "type": "string",
      "example": "65f1c2a9b3e4d5f6"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "id": 184467,
  "event": "signer_viewed_document",
  "message": null,
  "payload": {},
  "origin": {
    "ip": "203.0.113.7",
    "user-agent": "Mozilla/5.0"
  },
  "created_at": 1790000000,
  "subject": {},
  "object": {},
  "account_id": "65f1c2a9b3e4d5f6"
}
```

## WebhookEventType

```json
{
  "description": "A subscribable webhook event type.",
  "properties": {
    "id": {
      "description": "Event type code.",
      "type": "string",
      "example": "document_ready"
    },
    "description": {
      "description": "When the event is triggered.",
      "type": "string",
      "example": "Triggered when the last Signer of the assignment signs the Document."
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "id": "document_ready",
  "description": "Triggered when the last Signer of the assignment signs the Document."
}
```

## AccountTheme

```json
{
  "description": "An account's branding theme.",
  "properties": {
    "account_name": {
      "type": "string",
      "example": "Account Name"
    },
    "primary_color": {
      "description": "Hex color without leading `#`.",
      "type": "string",
      "example": "aabbcc"
    },
    "secondary_color": {
      "type": [
        "string",
        "null"
      ],
      "example": "aabbcc"
    },
    "logo": {
      "description": "URL to the account logo.",
      "type": "string",
      "example": "https://api.assinafy.com.br/v1/accounts/1a/logo"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "account_name": "Account Name",
  "primary_color": "aabbcc",
  "secondary_color": "aabbcc",
  "logo": "https://api.assinafy.com.br/v1/accounts/1a/logo"
}
```

## FieldType

```json
{
  "description": "A supported field/validation type.",
  "properties": {
    "type": {
      "type": "string",
      "example": "cpf"
    },
    "name": {
      "type": "string",
      "example": "CPF"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "type": "cpf",
  "name": "CPF"
}
```

## FieldValidation

```json
{
  "description": "The result of validating a value against a field definition.",
  "properties": {
    "type": {
      "description": "The field's validation type.",
      "type": "string",
      "example": "cpf"
    },
    "success": {
      "type": "boolean",
      "example": true
    },
    "error_message": {
      "description": "Empty when valid.",
      "type": "string",
      "example": ""
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "type": "cpf",
  "success": true,
  "error_message": ""
}
```

## FieldValidationResult

```json
{
  "description": "A per-field result from a multi-field validation.",
  "properties": {
    "field_id": {
      "type": "string",
      "example": "63488ffb7adf435aba319787"
    },
    "type": {
      "type": "string",
      "example": "cpf"
    },
    "success": {
      "type": "boolean",
      "example": false
    },
    "error_message": {
      "type": "string",
      "example": "Invalid CPF."
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "field_id": "63488ffb7adf435aba319787",
  "type": "cpf",
  "success": false,
  "error_message": "Invalid CPF."
}
```

## DocumentVerification

```json
{
  "description": "The verification result for a document looked up by signature hash. When not verified, most fields are null and `is_valid` is false.",
  "properties": {
    "hash": {
      "type": "string",
      "example": "FE32EDDADE7CBDDCBB934E7402047450B0E59C02"
    },
    "id": {
      "type": [
        "string",
        "null"
      ],
      "example": "63ddb172402799bfc991d10d"
    },
    "agreement_code": {
      "description": "Agreement code printed on the document certificate.",
      "type": [
        "string",
        "null"
      ],
      "example": "550E8400-E29B-41D4-A716-446655440000"
    },
    "status": {
      "type": [
        "string",
        "null"
      ],
      "example": "certificated"
    },
    "page_count": {
      "type": [
        "string",
        "null"
      ],
      "example": "1"
    },
    "signer_count": {
      "type": [
        "string",
        "null"
      ],
      "example": "1"
    },
    "completed_count": {
      "type": [
        "integer",
        "null"
      ],
      "example": 1
    },
    "completed_at": {
      "type": [
        "string",
        "null"
      ],
      "format": "date-time",
      "example": "2023-01-27T19:27:44Z"
    },
    "verified_at": {
      "type": "string",
      "format": "date-time",
      "example": "2023-01-27T19:27:46Z"
    },
    "is_valid": {
      "type": "boolean",
      "example": true
    },
    "message": {
      "description": "Reason when not valid.",
      "type": "string",
      "example": ""
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
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
```

## DocumentActivity

```json
{
  "description": "A document activity event.",
  "properties": {
    "id": {
      "type": "integer",
      "example": 4
    },
    "event": {
      "description": "Event type code.",
      "type": "string",
      "example": "assignment_created"
    },
    "message": {
      "type": "string",
      "example": "Assignment created by John Smith."
    },
    "payload": {
      "description": "Event-specific snapshot taken when the event happened, with the same keys as the webhook of that event (see **Webhook Payloads**). The common ones: `user_name` (`assignment_created`, `user_rejected_document`); `signer_full_name` (every `signer_*` event and `signature_requested`); `signer_email`, `signer_whatsapp_phone_number` and `notification_method` (`signature_requested`); `reviewer_name` (identity review decisions); `error_message` (`document_processing_failed`). `message` already carries the actor's name, translated, so clients can show it as is. A `*_at` key inside the payload is returned as an ISO 8601 string here, as in every API response, but as a Unix integer in webhook bodies.",
      "type": [
        "object",
        "null"
      ]
    },
    "origin": {
      "description": "Request origin when available.",
      "properties": {
        "ip": {
          "type": "string",
          "example": "172.19.0.1"
        },
        "user-agent": {
          "type": "string"
        }
      },
      "type": [
        "object",
        "null"
      ]
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "example": "2022-07-19T19:28:13Z"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
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
```

## WhatsappNotification

```json
{
  "description": "A rendered WhatsApp notification sent for an assignment, split into header/body/buttons as the signer would see them.",
  "properties": {
    "sent_at": {
      "description": "When the message was sent.",
      "type": "string",
      "format": "date-time",
      "example": "2026-07-07T12:00:00Z"
    },
    "header": {
      "type": "string",
      "example": "Documento para assinatura: Contrato de Servico"
    },
    "body": {
      "type": "string"
    },
    "buttons": {
      "type": "array",
      "items": {
        "properties": {
          "text": {
            "description": "The button label shown to the signer.",
            "type": "string",
            "example": "Abrir documento"
          }
        },
        "type": "object"
      }
    },
    "phone_number": {
      "description": "Recipient phone (E.164).",
      "type": "string",
      "example": "+5511999990001"
    },
    "signer_id": {
      "type": "string",
      "example": "a51edaee68a7"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "sent_at": "2026-07-07T12:00:00Z",
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
```

## AuthSession

```json
{
  "description": "A JWT access token plus the authenticated user and the accounts they belong to.",
  "properties": {
    "access_token": {
      "type": "string",
      "example": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
    },
    "user": {
      "$ref": "#/components/schemas/AuthUser"
    },
    "accounts": {
      "type": "array",
      "items": {
        "$ref": "#/components/schemas/AuthAccount"
      }
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": "bgjazeo5r9v2lq7l36dx48np",
    "name": "John Smith",
    "email": "example@example.com",
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
```

## SignerIdentityReview

```json
{
  "properties": {
    "id": {
      "type": "string",
      "example": "104c267f8e1e8c6855d7788b76a8"
    },
    "status": {
      "type": "string",
      "enum": [
        "Pending",
        "InReview",
        "Approved",
        "Declined",
        "Expired",
        "Abandoned"
      ],
      "example": "InReview"
    },
    "provider": {
      "type": "string",
      "enum": [
        "AssinafyVerify"
      ],
      "example": "AssinafyVerify"
    },
    "verification_method": {
      "type": "string",
      "enum": [
        "IdDocumentFaceMatchBasic"
      ],
      "example": "IdDocumentFaceMatchBasic"
    },
    "reason_codes": {
      "description": "Why the provider sent it to review, in its order. Unknown codes have the code as description.",
      "type": "array",
      "items": {
        "properties": {
          "code": {
            "type": "string",
            "example": "NAME_MISMATCH"
          },
          "description": {
            "type": "string",
            "example": "Nome no documento difere do cadastrado (similaridade 52%)"
          }
        },
        "type": "object"
      }
    },
    "evidence_available": {
      "type": "boolean",
      "example": true
    },
    "expected": {
      "description": "What the signer was registered with.",
      "properties": {
        "name": {
          "type": [
            "string",
            "null"
          ],
          "example": "Maria da Silva"
        },
        "cpf": {
          "type": [
            "string",
            "null"
          ],
          "example": "52998224725"
        }
      },
      "type": [
        "object",
        "null"
      ]
    },
    "document": {
      "description": "What was read from the document.",
      "properties": {
        "type": {
          "type": [
            "string",
            "null"
          ],
          "example": "CNH"
        },
        "name": {
          "type": [
            "string",
            "null"
          ],
          "example": "MARIA SILVA"
        },
        "cpf": {
          "type": [
            "string",
            "null"
          ],
          "example": "52998224725"
        }
      },
      "type": [
        "object",
        "null"
      ]
    },
    "matches": {
      "properties": {
        "cpf": {
          "type": [
            "boolean",
            "null"
          ],
          "example": true
        },
        "name": {
          "description": "Name similarity, 0-1.",
          "type": [
            "number",
            "null"
          ],
          "example": 0.5217
        },
        "birth_date": {
          "type": [
            "boolean",
            "null"
          ],
          "example": null
        }
      },
      "type": [
        "object",
        "null"
      ]
    },
    "checks": {
      "type": "array",
      "items": {
        "properties": {
          "name": {
            "type": "string",
            "example": "name"
          },
          "result": {
            "description": "pass, review, skipped, or a failure result.",
            "type": "string",
            "example": "review"
          },
          "score": {
            "type": [
              "number",
              "null"
            ],
            "example": 0.5217
          },
          "reasons": {
            "type": "array",
            "items": {
              "type": "string"
            },
            "example": [
              "NAME_MISMATCH"
            ]
          }
        },
        "type": "object"
      }
    },
    "images": {
      "description": "The evidence images the reviewer can open with **Signer identity review image**, in display order: `document_front`, `document_back`, `document_pdf`, `face`. Only while `status` is `InReview`; empty once decided.",
      "type": "array",
      "items": {
        "type": "string",
        "enum": [
          "document_front",
          "document_back",
          "document_pdf",
          "face"
        ]
      },
      "example": [
        "document_front",
        "document_back",
        "face"
      ]
    },
    "ruleset_version": {
      "type": [
        "string",
        "null"
      ],
      "example": "2026-10-12.2"
    },
    "evidence_sha256": {
      "type": [
        "string",
        "null"
      ],
      "example": "9f2c0d6e4b1a8c3f5e7d9b0a2c4e6f8a1b3d5f7091e2c4a6b8d0f2e4a6c8e0b2"
    },
    "reviewed_by": {
      "properties": {
        "id": {
          "type": "string",
          "example": "Kx9pQ2"
        },
        "name": {
          "type": "string",
          "example": "Ana Souza"
        }
      },
      "type": [
        "object",
        "null"
      ]
    },
    "reviewed_at": {
      "type": [
        "string",
        "null"
      ],
      "format": "date-time",
      "example": "2026-10-13T21:05:00Z"
    },
    "review_note": {
      "type": [
        "string",
        "null"
      ],
      "example": "Conferido por videochamada."
    },
    "completed_at": {
      "type": [
        "string",
        "null"
      ],
      "format": "date-time",
      "example": "2026-10-13T21:05:00Z"
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
{
  "id": "104c267f8e1e8c6855d7788b76a8",
  "status": "InReview",
  "provider": "AssinafyVerify",
  "verification_method": "IdDocumentFaceMatchBasic",
  "reason_codes": [
    {
      "code": "NAME_MISMATCH",
      "description": "Nome no documento difere do cadastrado (similaridade 52%)"
    }
  ],
  "evidence_available": true,
  "expected": {
    "name": "Maria da Silva",
    "cpf": "52998224725"
  },
  "document": {
    "type": "CNH",
    "name": "MARIA SILVA",
    "cpf": "52998224725"
  },
  "matches": {
    "cpf": true,
    "name": 0.5217,
    "birth_date": null
  },
  "checks": [
    {
      "name": "name",
      "result": "review",
      "score": 0.5217,
      "reasons": [
        "NAME_MISMATCH"
      ]
    }
  ],
  "images": [
    "document_front",
    "document_back",
    "face"
  ],
  "ruleset_version": "2026-10-12.2",
  "evidence_sha256": "9f2c0d6e4b1a8c3f5e7d9b0a2c4e6f8a1b3d5f7091e2c4a6b8d0f2e4a6c8e0b2",
  "reviewed_by": {
    "id": "Kx9pQ2",
    "name": "Ana Souza"
  },
  "reviewed_at": "2026-10-13T21:05:00Z",
  "review_note": "Conferido por videochamada.",
  "completed_at": "2026-10-13T21:05:00Z"
}
```

## DocumentStatsRow

```json
{
  "description": "One period of the document-funnel KPI series. `period` is `YYYY-MM` (monthly) or `YYYY-MM-DD` (daily); series are zero-filled, no gaps. Signature requests come with two independent breakdowns: the `signature_requests_notification_*` counters split them by the channels the signer was notified on — a signer reached on more than one channel counts once per channel, so these add up to at least `signature_requests` — while the `signature_requests_verification_*` counters split them by how the signer's identity is verified, and since each request has exactly one verification method those four always add up to `signature_requests`.",
  "properties": {
    "period": {
      "description": "`YYYY-MM` (monthly) or `YYYY-MM-DD` (daily).",
      "type": "string",
      "example": "2026-06"
    },
    "documents_uploaded": {
      "type": "integer",
      "example": 42
    },
    "documents_sent": {
      "type": "integer",
      "example": 37
    },
    "signature_requests": {
      "type": "integer",
      "example": 61
    },
    "signature_requests_notification_email": {
      "description": "Requests notified by e-mail.",
      "type": "integer",
      "example": 55
    },
    "signature_requests_notification_whatsapp": {
      "description": "Requests notified by WhatsApp.",
      "type": "integer",
      "example": 18
    },
    "signature_requests_notification_bypass": {
      "description": "Requests with no notification sent (`Bypass`).",
      "type": "integer",
      "example": 3
    },
    "signature_requests_verification_email": {
      "description": "Requests verified by an e-mail token.",
      "type": "integer",
      "example": 48
    },
    "signature_requests_verification_whatsapp": {
      "description": "Requests verified by a WhatsApp token.",
      "type": "integer",
      "example": 6
    },
    "signature_requests_verification_bypass": {
      "description": "Requests signed without token verification (`Bypass`).",
      "type": "integer",
      "example": 3
    },
    "signature_requests_verification_digital_certificate": {
      "description": "Requests signed with the signer's own ICP-Brasil digital certificate.",
      "type": "integer",
      "example": 4
    },
    "signature_requests_viewed": {
      "description": "Signature requests whose document was first viewed during the period.",
      "type": "integer",
      "example": 44
    },
    "signature_requests_completed": {
      "description": "Signature requests completed by individual signers during the period.",
      "type": "integer",
      "example": 52
    },
    "documents_certified": {
      "type": "integer",
      "example": 30
    }
  },
  "type": "object"
}
```

**Payload shape:**

```json
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
```

## NotificationPreferences

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
    },
    "ContractRenewalNotice": {
      "description": "A tracked contract entered its notice period: it is about to end or to renew.",
      "type": "boolean",
      "example": true
    },
    "ContractExpiring": {
      "description": "A tracked contract ends in 45 or in 30 days.",
      "type": "boolean",
      "example": true
    },
    "ContractExpired": {
      "description": "A tracked contract ended without renewal.",
      "type": "boolean",
      "example": true
    },
    "ContractRenewed": {
      "description": "A tracked contract was auto-renewed into its next term.",
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
  "SignerWhatsappFailed": true,
  "ContractRenewalNotice": true,
  "ContractExpiring": true,
  "ContractExpired": true,
  "ContractRenewed": true
}
```

## OAuthTokenRequest

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

## OAuthRevokeRequest

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
