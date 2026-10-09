unit AssinafyURI;

{$IFDEF FPC}{$mode objfpc}{$H+}{$ENDIF}
{$B-}

interface

uses {$IFDEF FPC}URIParser{$ELSE}System.Net.URLClient{$ENDIF};

type
  TAssinafyURI = record
    Protocol, Host, UserName, Password, Params, Bookmark, Origin: string;
    Port: Integer;
  end;

function ParseAssinafyURI(const Value: string): TAssinafyURI;

implementation

uses SysUtils, AssinafyHttp;

function NormalizeURIPort(const Value: string): string;
var
  Start, Finish, Split, I, Port: Integer;
  Authority, Text: string;
begin
  Result := Value;
  Start := Pos('://', Value);
  if Start = 0 then Exit;
  Inc(Start, 3);
  Finish := Start;
  while (Finish <= Length(Value)) and not CharInSet(Value[Finish], ['/', '?', '#']) do Inc(Finish);
  Authority := Copy(Value, Start, Finish - Start);
  Split := LastDelimiter('@', Authority);
  if Split > 0 then Delete(Authority, 1, Split);
  if Authority = '' then Exit;
  if Authority[1] = '[' then
  begin
    Split := Pos(']', Authority);
    if Split = 0 then raise EAssinafyInputError.Create('Invalid URI host');
    if Split = Length(Authority) then Exit;
    Inc(Split);
    if Authority[Split] <> ':' then raise EAssinafyInputError.Create('Invalid URI port');
  end
  else
  begin
    Split := Pos(':', Authority);
    if Split = 0 then Exit;
  end;
  Text := Copy(Authority, Split + 1, MaxInt);
  if Text = '' then
  begin
    Delete(Result, Finish - 1, 1);
    Exit;
  end;
  Port := 0;
  for I := 1 to Length(Text) do
  begin
    if not CharInSet(Text[I], ['0'..'9']) then raise EAssinafyInputError.Create('Invalid URI port');
    Port := Port * 10 + Ord(Text[I]) - Ord('0');
    if Port > 65535 then raise EAssinafyInputError.Create('URI port must be between 0 and 65535');
  end;
end;

function ParseAssinafyURI(const Value: string): TAssinafyURI;
var URI: TURI; Text: string;
begin
  Text := NormalizeURIPort(Value);
  {$IFDEF FPC}
  try
    URI := ParseURI(Text);
  except
    on E: EConvertError do raise EAssinafyInputError.Create('Invalid URI');
  end;
  Result.Protocol := URI.Protocol;
  Result.Params := URI.Params;
  Result.Bookmark := URI.Bookmark;
  {$ELSE}
  try
    URI := TURI.Create(Text);
  except
    on E: ENetURIException do raise EAssinafyInputError.Create('Invalid URI');
    on E: EConvertError do raise EAssinafyInputError.Create('Invalid URI');
  end;
  Result.Protocol := URI.Scheme;
  Result.Params := URI.Query;
  Result.Bookmark := URI.Fragment;
  {$ENDIF}
  Result.Host := URI.Host;
  Result.UserName := URI.UserName;
  Result.Password := URI.Password;
  Result.Port := URI.Port;
  URI.Path := '';
  URI.UserName := '';
  URI.Password := '';
  {$IFDEF FPC}
  URI.Document := '';
  URI.Params := '';
  URI.Bookmark := '';
  Result.Origin := EncodeURI(URI);
  {$ELSE}
  URI.Query := '';
  URI.Fragment := '';
  Result.Origin := URI.ToString;
  {$ENDIF}
end;

end.
