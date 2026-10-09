type
  TRequestDeadline = class(TThread)
  private
    FRequest: IHTTPRequest;
    FDone: TEvent;
    FTimeout: Cardinal;
    FExpired: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(const Request: IHTTPRequest; Done: TEvent; Timeout: Cardinal);
    property Expired: Boolean read FExpired;
  end;

constructor TRequestDeadline.Create(const Request: IHTTPRequest; Done: TEvent; Timeout: Cardinal);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FRequest := Request;
  FDone := Done;
  FTimeout := Timeout;
end;

procedure TRequestDeadline.Execute;
begin
  if FDone.WaitFor(FTimeout) <> wrSignaled then
  begin
    FExpired := True;
    FRequest.Cancel;
  end;
end;

function QuotedMultipart(const Value: string): string;
begin
  RequireValue(Value, 'Multipart name');
  Result := StringReplace(Value, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
end;

function TAssinafyNetTransport.Execute(const Request: TAssinafyRequest): TAssinafyResponse;
var
  Client: THTTPClient;
  HTTPRequest: IHTTPRequest;
  HTTPResponse: IHTTPResponse;
  Source, Destination: TMemoryStream;
  Done: TEvent;
  Deadline: TRequestDeadline;
  Line, Boundary, ContentType: string;
  Payload: RawByteString;
  Header: TNameValuePair;
  I, Split: Integer;
  Guid: TGUID;
  HasBody, HasLength: Boolean;
  procedure WriteText(const Value: string);
  var Bytes: UTF8String;
  begin
    Bytes := UTF8Encode(Value);
    if Length(Bytes) > 0 then Source.WriteBuffer(Bytes[1], Length(Bytes));
  end;
begin
  if Request.CAFile <> '' then
    raise EAssinafyInputError.Create('Delphi uses the Windows certificate store; CAFile is unsupported');
  if Request.TimeoutMS < 0 then raise EAssinafyInputError.Create('TimeoutMS must not be negative');
  ValidateRequestHeaders(Request);
  Source := nil;
  Destination := nil;
  Client := nil;
  Done := nil;
  Deadline := nil;
  Result := nil;
  try
    Source := TMemoryStream.Create;
    Destination := TMemoryStream.Create;
    Payload := Request.Body;
    ContentType := Request.ContentType;
    if Request.FileName <> '' then
    begin
      Payload := ReadUploadBytes(Request.FileName);
      if Request.FileField <> '' then
      begin
        RequireValue(ContentType, 'File content type');
        CreateGUID(Guid);
        Boundary := 'assinafy-' + Copy(GUIDToString(Guid), 2, 36);
        WriteText('--' + Boundary + #13#10 +
          'Content-Disposition: form-data; name="' + QuotedMultipart(Request.FileField) +
          '"; filename="' + QuotedMultipart(ExtractFileName(Request.FileName)) + '"' + #13#10 +
          'Content-Type: ' + ContentType + #13#10#13#10);
        if Length(Payload) > 0 then Source.WriteBuffer(Payload[1], Length(Payload));
        WriteText(#13#10 + '--' + Boundary + '--' + #13#10);
        ContentType := 'multipart/form-data; boundary="' + Boundary + '"';
        Payload := '';
      end;
    end;
    if Length(Payload) > 0 then Source.WriteBuffer(Payload[1], Length(Payload));
    Source.Position := 0;
    try
      Client := THTTPClient.Create;
      Client.HandleRedirects := False;
      Client.AllowCookies := False;
      Client.AutomaticDecompression := [];
      Client.SecureProtocols := [THTTPSecureProtocol.TLS12, THTTPSecureProtocol.TLS13];
      Client.ConnectionTimeout := Request.TimeoutMS;
      Client.ResponseTimeout := Request.TimeoutMS;
      HTTPRequest := Client.GetRequest(Request.Method, Request.URL);
      for I := 0 to Request.Headers.Count - 1 do
      begin
        Line := Request.Headers[I];
        Split := Pos(':', Line);
        if Split = 0 then raise EAssinafyInputError.Create('Invalid HTTP header');
        HTTPRequest.AddHeader(Copy(Line, 1, Split - 1), Trim(Copy(Line, Split + 1, MaxInt)));
      end;
      if ContentType <> '' then HTTPRequest.AddHeader('Content-Type', ContentType);
      if (Source.Size > 0) or (ContentType <> '') then HTTPRequest.SourceStream := Source;
      Done := TEvent.Create(nil, True, False, '');
      if Request.TimeoutMS > 0 then
      begin
        Deadline := TRequestDeadline.Create(HTTPRequest, Done, Cardinal(Request.TimeoutMS));
        Deadline.Start;
      end;
      try
        HTTPResponse := Client.Execute(HTTPRequest, Destination);
      finally
        Done.SetEvent;
        if Deadline <> nil then Deadline.WaitFor;
      end;
      // A matching Content-Length establishes completion even if cancellation raced with Execute.
      if HTTPResponse = nil then
      begin
        if (Deadline <> nil) and Deadline.Expired then raise EAssinafyTransportError.Create('HTTP transfer exceeded TimeoutMS');
        raise EAssinafyTransportError.Create('Missing HTTP response');
      end;
      HasBody := (Request.Method <> 'HEAD') and
        (HTTPResponse.StatusCode <> 204) and (HTTPResponse.StatusCode <> 205) and
        (HTTPResponse.StatusCode <> 304);
      HasLength := (HTTPResponse.HeaderValue['Content-Length'] <> '') and
        (HTTPResponse.HeaderValue['Transfer-Encoding'] = '') and
        (HTTPResponse.ContentLength >= 0);
      if HasBody and HasLength and (Destination.Size <> HTTPResponse.ContentLength) then
      begin
        if (Deadline <> nil) and Deadline.Expired then raise EAssinafyTransportError.Create('HTTP transfer exceeded TimeoutMS');
        raise EAssinafyTransportError.Create('Incomplete HTTP response');
      end;
      Result := TAssinafyResponse.Create;
      try
        Result.StatusCode := HTTPResponse.StatusCode;
        for Header in HTTPResponse.Headers do Result.Headers.Add(Header.Name + ': ' + Header.Value);
        SetLength(Result.Body, Destination.Size);
        Destination.Position := 0;
        if Destination.Size > 0 then Destination.ReadBuffer(Result.Body[1], Length(Result.Body));
        if HasBody and not HasLength and (Deadline <> nil) and Deadline.Expired then
          raise EAssinafyProtocolError.Create('HTTP transfer exceeded TimeoutMS; response completion is indeterminate', Result);
      except
        FreeAndNil(Result);
        raise;
      end;
    except
      on E: EAssinafyError do raise;
      on E: Exception do
      begin
        if (Deadline <> nil) and Deadline.Expired then
          raise EAssinafyTransportError.Create('HTTP transfer exceeded TimeoutMS');
        raise EAssinafyTransportError.Create('HTTP transport: ' + E.Message);
      end;
    end;
  finally
    Deadline.Free;
    Done.Free;
    HTTPResponse := nil;
    HTTPRequest := nil;
    Client.Free;
    Destination.Free;
    Source.Free;
  end;
end;
