unit AssinafyHttp;

{$mode objfpc}{$H+}
{$linklib curl}

interface

uses
  Classes, SysUtils, fpjson;

type
  EAssinafyError = class(Exception);
  EAssinafyInputError = class(EAssinafyError);
  EAssinafyTransportError = class(EAssinafyError);
  EAssinafyProtocolError = class(EAssinafyError);

  TAssinafyResponse = class
  private
    FJSON: TJSONData;
    function GetData: TJSONData;
  public
    StatusCode: Integer;
    Headers: TStringList;
    Body: RawByteString;
    constructor Create;
    destructor Destroy; override;
    procedure ParseJSON;
    function Header(const Name: string): string;
    procedure SaveToStream(Destination: TStream);
    property JSON: TJSONData read FJSON;
    property Data: TJSONData read GetData;
  end;

  EAssinafyAPIError = class(EAssinafyError)
  public
    StatusCode: Integer;
    ErrorCode: string;
    ResponseBody: RawByteString;
    RetryAfter: string;
    Authenticate: string;
    constructor Create(Response: TAssinafyResponse);
  end;

  TAssinafyRequest = record
    Method: string;
    URL: string;
    Headers: TStrings;
    Body: RawByteString;
    FileName: string;
    FileField: string;
    ContentType: string;
    TimeoutMS: LongInt;
    CAFile: string;
  end;

  TAssinafyTransport = class
  public
    function Execute(const Request: TAssinafyRequest): TAssinafyResponse;
      virtual; abstract;
  end;

  TAssinafyCurlTransport = class(TAssinafyTransport)
  public
    function Execute(const Request: TAssinafyRequest): TAssinafyResponse; override;
  end;

function PercentEncode(const Value: string): string;
function EncodeQuery(Query: TStrings): string;
procedure RequireValue(const Value, Name: string);

implementation

uses
  ctypes, libcurl, jsonparser;

function curl_mime_init(Handle: PCURL): Pointer; cdecl; external 'curl';
procedure curl_mime_free(Mime: Pointer); cdecl; external 'curl';
function curl_mime_addpart(Mime: Pointer): Pointer; cdecl; external 'curl';
function curl_mime_name(Part: Pointer; Name: PChar): CURLcode; cdecl; external 'curl';
function curl_mime_filedata(Part: Pointer; FileName: PChar): CURLcode; cdecl; external 'curl';
function curl_mime_type(Part: Pointer; MimeType: PChar): CURLcode; cdecl; external 'curl';

procedure RequireValue(const Value, Name: string);
begin
  if Trim(Value) = '' then
    raise EAssinafyInputError.Create(Name + ' is required');
  if (Pos(#0, Value) > 0) or (Pos(#13, Value) > 0) or (Pos(#10, Value) > 0) then
    raise EAssinafyInputError.Create(Name + ' contains a control character');
end;

function PercentEncode(const Value: string): string;
const
  Hex = '0123456789ABCDEF';
var
  C: AnsiChar;
begin
  Result := '';
  for C in Value do
    if C in ['A'..'Z', 'a'..'z', '0'..'9', '-', '.', '_', '~'] then
      Result := Result + C
    else
      Result := Result + '%' + Hex[(Ord(C) shr 4) + 1] + Hex[(Ord(C) and 15) + 1];
end;

function EncodeQuery(Query: TStrings): string;
var
  I: Integer;
  Name: string;
begin
  Result := '';
  if Query = nil then Exit;
  for I := 0 to Query.Count - 1 do
  begin
    Name := Query.Names[I];
    RequireValue(Name, 'Query parameter name');
    if Result <> '' then Result := Result + '&';
    Result := Result + PercentEncode(Name) + '=' + PercentEncode(Query.ValueFromIndex[I]);
  end;
end;

constructor TAssinafyResponse.Create;
begin
  inherited Create;
  Headers := TStringList.Create;
  Headers.NameValueSeparator := ':';
  Headers.CaseSensitive := False;
end;

destructor TAssinafyResponse.Destroy;
begin
  FJSON.Free;
  Headers.Free;
  inherited Destroy;
end;

procedure TAssinafyResponse.ParseJSON;
begin
  FreeAndNil(FJSON);
  if Body = '' then Exit;
  try
    FJSON := GetJSON(Body, True);
  except
    on E: Exception do
      raise EAssinafyProtocolError.Create('The API returned invalid JSON');
  end;
end;

function TAssinafyResponse.GetData: TJSONData;
begin
  Result := FJSON;
  if (FJSON is TJSONObject) and (TJSONObject(FJSON).Find('data') <> nil) then
    Result := TJSONObject(FJSON).Find('data');
end;

function TAssinafyResponse.Header(const Name: string): string;
begin
  Result := Trim(Headers.Values[Name]);
end;

procedure TAssinafyResponse.SaveToStream(Destination: TStream);
begin
  if Destination = nil then
    raise EAssinafyInputError.Create('Destination stream is required');
  if Length(Body) > 0 then
    Destination.WriteBuffer(Body[1], Length(Body));
end;

constructor EAssinafyAPIError.Create(Response: TAssinafyResponse);
var
  Detail: string;
  Obj: TJSONObject;
  function StringField(const Name: string): string;
  var
    Value: TJSONData;
  begin
    Value := Obj.Find(Name);
    if (Value <> nil) and (Value.JSONType = jtString) then Result := Value.AsString
    else Result := '';
  end;
begin
  StatusCode := Response.StatusCode;
  ResponseBody := Response.Body;
  RetryAfter := Response.Header('Retry-After');
  Authenticate := Response.Header('WWW-Authenticate');
  Detail := '';
  ErrorCode := '';
  if Response.JSON is TJSONObject then
  begin
    Obj := TJSONObject(Response.JSON);
    ErrorCode := StringField('error');
    Detail := StringField('error_description');
    if Detail = '' then Detail := StringField('message');
  end;
  inherited Create(Format('Assinafy HTTP %d: %s', [StatusCode, Detail]));
end;

procedure CheckCurl(Code: CURLcode);
begin
  if Code <> CURLE_OK then
    raise EAssinafyTransportError.Create('HTTP transport: ' + string(curl_easy_strerror(Code)));
end;

function WriteBody(Buffer: PChar; Size, Count: csize_t; UserData: Pointer): csize_t; cdecl;
var
  Stream: TStream;
begin
  Result := 0;
  try
    Stream := TStream(UserData);
    if (Size = 0) or (Count = 0) then Exit;
    if Count > csize_t(High(LongInt)) div Size then Exit;
    Result := Stream.Write(Buffer^, LongInt(Size * Count));
  except
    Result := 0;
  end;
end;

function WriteHeader(Buffer: PChar; Size, Count: csize_t; UserData: Pointer): csize_t; cdecl;
var
  Line: string;
  Headers: TStrings;
begin
  Result := 0;
  try
    if (Size = 0) or (Count = 0) then Exit;
    if Count > csize_t(High(LongInt)) div Size then Exit;
    SetString(Line, Buffer, Size * Count);
    Headers := TStrings(UserData);
    if Copy(Line, 1, 5) = 'HTTP/' then Headers.Clear
    else if Pos(':', Line) > 0 then Headers.Add(Trim(Line));
    Result := Size * Count;
  except
    Result := 0;
  end;
end;

function TAssinafyCurlTransport.Execute(const Request: TAssinafyRequest): TAssinafyResponse;
var
  Handle: PCURL;
  List, Next: Pcurl_slist;
  Mime, Part: Pointer;
  I: Integer;
  Status: clong;
  Buffer: TStringStream;
  Upload: TFileStream;
  Payload, HeaderLine: RawByteString;
begin
  Handle := curl_easy_init;
  if Handle = nil then raise EAssinafyTransportError.Create('Cannot initialize libcurl');
  List := nil;
  Mime := nil;
  Result := nil;
  Buffer := nil;
  Upload := nil;
  try
    try
      Result := TAssinafyResponse.Create;
      Buffer := TStringStream.Create('');
      CheckCurl(curl_easy_setopt(Handle, CURLOPT_URL, [PChar(Request.URL)]));
      CheckCurl(curl_easy_setopt(Handle, CURLOPT_CUSTOMREQUEST, [PChar(Request.Method)]));
      CheckCurl(curl_easy_setopt(Handle, CURLOPT_NOSIGNAL, [clong(1)]));
      CheckCurl(curl_easy_setopt(Handle, CURLOPT_TIMEOUT_MS, [clong(Request.TimeoutMS)]));
      CheckCurl(curl_easy_setopt(Handle, CURLOPT_CONNECTTIMEOUT_MS, [clong(Request.TimeoutMS)]));
      CheckCurl(curl_easy_setopt(Handle, CURLOPT_FOLLOWLOCATION, [clong(0)]));
      CheckCurl(curl_easy_setopt(Handle, CURLOPT_SSL_VERIFYPEER, [clong(1)]));
      CheckCurl(curl_easy_setopt(Handle, CURLOPT_SSL_VERIFYHOST, [clong(2)]));
      CheckCurl(curl_easy_setopt(Handle, CURLOPT_SSLVERSION, [clong(6)]));
      CheckCurl(curl_easy_setopt(Handle, CURLOPT_PROTOCOLS, [clong(CURLPROTO_HTTP or CURLPROTO_HTTPS)]));
      if Request.CAFile <> '' then
        CheckCurl(curl_easy_setopt(Handle, CURLOPT_CAINFO, [PChar(Request.CAFile)]));
      CheckCurl(curl_easy_setopt(Handle, CURLOPT_WRITEFUNCTION, [@WriteBody]));
      CheckCurl(curl_easy_setopt(Handle, CURLOPT_WRITEDATA, [Pointer(Buffer)]));
      CheckCurl(curl_easy_setopt(Handle, CURLOPT_HEADERFUNCTION, [@WriteHeader]));
      CheckCurl(curl_easy_setopt(Handle, CURLOPT_HEADERDATA, [Pointer(Result.Headers)]));
      for I := 0 to Request.Headers.Count - 1 do
      begin
        HeaderLine := Request.Headers[I];
        Next := curl_slist_append(List, PChar(HeaderLine));
        if Next = nil then raise EAssinafyTransportError.Create('Cannot allocate HTTP headers');
        List := Next;
      end;
      Payload := Request.Body;
      if Request.FileName <> '' then
      begin
        Upload := TFileStream.Create(Request.FileName, fmOpenRead or fmShareDenyWrite);
        if (Request.FileField = 'file') and (Upload.Size > 25 * 1024 * 1024) then
          raise EAssinafyInputError.Create('File exceeds 25 MiB');
        if Request.FileField <> '' then
        begin
          Mime := curl_mime_init(Handle);
          if Mime = nil then raise EAssinafyTransportError.Create('Cannot allocate multipart body');
          Part := curl_mime_addpart(Mime);
          if Part = nil then raise EAssinafyTransportError.Create('Cannot allocate multipart file');
          CheckCurl(curl_mime_name(Part, PChar(Request.FileField)));
          CheckCurl(curl_mime_filedata(Part, PChar(Request.FileName)));
          CheckCurl(curl_mime_type(Part, PChar(Request.ContentType)));
          CheckCurl(curl_easy_setopt(Handle, CURLoption(10269), [Mime]));
        end
        else
        begin
          if Upload.Size > 25 * 1024 * 1024 then
            raise EAssinafyInputError.Create('Image exceeds 25 MiB');
          SetLength(Payload, Upload.Size);
          if Upload.Size > 0 then Upload.ReadBuffer(Payload[1], Upload.Size);
        end;
      end;
      if (Mime = nil) and ((Payload <> '') or (Request.ContentType <> '')) then
      begin
        HeaderLine := 'Content-Type: ' + Request.ContentType;
        Next := curl_slist_append(List, PChar(HeaderLine));
        if Next = nil then raise EAssinafyTransportError.Create('Cannot allocate HTTP headers');
        List := Next;
        CheckCurl(curl_easy_setopt(Handle, CURLOPT_POSTFIELDS, [PChar(Payload)]));
        CheckCurl(curl_easy_setopt(Handle, CURLOPT_POSTFIELDSIZE, [clong(Length(Payload))]));
      end;
      CheckCurl(curl_easy_setopt(Handle, CURLOPT_HTTPHEADER, [List]));
      CheckCurl(curl_easy_perform(Handle));
      Status := 0;
      CheckCurl(curl_easy_getinfo(Handle, CURLINFO_RESPONSE_CODE, [@Status]));
      Result.StatusCode := Status;
      Result.Body := Buffer.DataString;
    except
      FreeAndNil(Result);
      raise;
    end;
  finally
    Upload.Free;
    Buffer.Free;
    if Mime <> nil then curl_mime_free(Mime);
    curl_slist_free_all(List);
    curl_easy_cleanup(Handle);
  end;
end;

initialization
  CheckCurl(curl_global_init(CURL_GLOBAL_DEFAULT));

finalization
  curl_global_cleanup;

end.
