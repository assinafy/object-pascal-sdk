unit AssinafyWebhooks;

{$IFDEF FPC}{$mode objfpc}{$H+}{$ENDIF}
{$B-}

interface

uses
  Classes;

function VerifyWebhook(const Secret, MessageID, Timestamp, Signatures: string;
  const RawBody: RawByteString; NowUnix: Int64; ToleranceSeconds: Integer = 300): Boolean;
function VerifyWebhookHeaders(const Secret: string; Headers: TStrings;
  const RawBody: RawByteString; ToleranceSeconds: Integer = 300): Boolean;

implementation

uses
  SysUtils, DateUtils, AssinafyCrypto, AssinafyHttp;

function VerifyWebhook(const Secret, MessageID, Timestamp, Signatures: string;
  const RawBody: RawByteString; NowUnix: Int64; ToleranceSeconds: Integer): Boolean;
var
  Sent: Int64;
  C: Char;
  Key, Digest, SignedBody: RawByteString;
  Prefix: UTF8String;
  Expected, Entry: string;
  Entries: TStringList;
begin
  Result := False;
  if (Copy(Secret, 1, 6) <> 'whsec_') or (MessageID = '') or
    (Timestamp = '') or (Signatures = '') or (ToleranceSeconds < 0) or (NowUnix < 0) then Exit;
  for C in Timestamp do if not CharInSet(C, ['0'..'9']) then Exit;
  if not TryStrToInt64(Timestamp, Sent) or (Sent < 0) then Exit;
  if (Sent > NowUnix) then
  begin
    if Sent - NowUnix > ToleranceSeconds then Exit;
  end
  else if NowUnix - Sent > ToleranceSeconds then Exit;
  try
    Key := StrictBase64Decode(Copy(Secret, 7, MaxInt));
  except
    on E: EAssinafyInputError do Exit;
  end;
  if Key = '' then Exit;
  Prefix := UTF8Encode(MessageID) + '.' + UTF8Encode(Timestamp) + '.';
  SignedBody := '';
  SetLength(SignedBody, Length(Prefix) + Length(RawBody));
  Move(Prefix[1], SignedBody[1], Length(Prefix));
  if RawBody <> '' then Move(RawBody[1], SignedBody[Length(Prefix) + 1], Length(RawBody));
  Digest := HMACSHA256(Key, SignedBody);
  Expected := 'v1,' + Base64Encode(Digest);
  Entries := TStringList.Create;
  try
    Entries.StrictDelimiter := True;
    Entries.Delimiter := ' ';
    Entries.DelimitedText := Signatures;
    for Entry in Entries do
      if ConstantTimeEqual(Entry, Expected) then Exit(True);
  finally
    Entries.Free;
  end;
end;

function VerifyWebhookHeaders(const Secret: string; Headers: TStrings;
  const RawBody: RawByteString; ToleranceSeconds: Integer): Boolean;
var
  ID, Timestamp, Signatures, Name, Value: string;
  I, Split, EqualsAt: Integer;
  HasID, HasTimestamp: Boolean;
begin
  if Headers = nil then Exit(False);
  ID := '';
  Timestamp := '';
  Signatures := '';
  HasID := False;
  HasTimestamp := False;
  for I := 0 to Headers.Count - 1 do
  begin
    Split := Pos(':', Headers[I]);
    EqualsAt := Pos('=', Headers[I]);
    if (EqualsAt > 0) and ((Split = 0) or (EqualsAt < Split)) then Split := EqualsAt;
    if Split = 0 then Continue;
    Name := LowerCase(Trim(Copy(Headers[I], 1, Split - 1)));
    Value := Trim(Copy(Headers[I], Split + 1, MaxInt));
    if Name = 'webhook-id' then
    begin if HasID then Exit(False); HasID := True; ID := Value; end
    else if Name = 'webhook-timestamp' then
    begin if HasTimestamp then Exit(False); HasTimestamp := True; Timestamp := Value; end
    else if Name = 'webhook-signature' then
    begin if Signatures <> '' then Signatures := Signatures + ' '; Signatures := Signatures + Value; end;
  end;
  Result := VerifyWebhook(Secret, ID, Timestamp, Signatures, RawBody,
    DateTimeToUnix(Now, False), ToleranceSeconds);
end;

end.
