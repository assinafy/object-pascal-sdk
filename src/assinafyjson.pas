unit AssinafyJson;

{$IFDEF FPC}{$mode objfpc}{$H+}{$ENDIF}
{$B-}

interface

uses
  Classes, SysUtils, {$IFDEF FPC}fpjson{$ELSE}System.JSON{$ENDIF};

type
  EAssinafyJSONEncodingError = class(EConvertError);
  EAssinafyJSONNulError = class(EConvertError);

  {$IFDEF FPC}
  TJSONData = fpjson.TJSONData;
  TJSONObject = fpjson.TJSONObject;
  TJSONArray = fpjson.TJSONArray;
  TJSONType = fpjson.TJSONType;
  {$ELSE}
  TJSONData = System.JSON.TJSONValue;
  TJSONObject = System.JSON.TJSONObject;
  TJSONArray = System.JSON.TJSONArray;
  TJSONType = (jtUnknown, jtNumber, jtString, jtBoolean, jtNull, jtArray, jtObject);
  {$ENDIF}

{$IFDEF FPC}
const
  jtUnknown = fpjson.jtUnknown;
  jtNumber = fpjson.jtNumber;
  jtString = fpjson.jtString;
  jtBoolean = fpjson.jtBoolean;
  jtNull = fpjson.jtNull;
  jtArray = fpjson.jtArray;
  jtObject = fpjson.jtObject;
{$ENDIF}

function JSONObj(const Values: array of const): TJSONObject;
function JSONArr(const Values: array of const): TJSONArray;
procedure JSONAdd(Obj: TJSONObject; const Name: string; Value: TJSONData); overload;
procedure JSONAdd(Obj: TJSONObject; const Name, Value: string); overload;
procedure JSONAdd(Obj: TJSONObject; const Name: string; Value: Boolean); overload;
procedure JSONAdd(Arr: TJSONArray; Value: TJSONData); overload;
function JSONFind(Value: TJSONData; const Path: string): TJSONData;
function JSONText(Value: TJSONData): UTF8String;
function JSONString(Value: TJSONData): UTF8String;
function JSONInteger(Value: TJSONData): Int64;
function JSONBoolean(Value: TJSONData): Boolean;
function JSONKind(Value: TJSONData): TJSONType;
function JSONGet(Obj: TJSONObject; const Name, DefaultValue: string): UTF8String;
function ParseJSONStrict(const Bytes: RawByteString): TJSONData;

implementation

uses
  {$IFDEF FPC}
  {$IFDEF DARWIN}fpwidestring, cpall,{$ELSE}
  {$IFDEF UNIX}cwstring,{$ENDIF}{$ENDIF}
  jsonparser, jsonscanner{$ELSE}System.Generics.Collections{$ENDIF};

{$IFDEF FPC}
type
  TJSONArguments = record
    Values: array of TVarRec;
    Strings: array of UTF8String;
  end;

function PrepareArguments(const Values: array of const): TJSONArguments;
var I: Integer;
begin
  Result := Default(TJSONArguments);
  SetLength(Result.Values, Length(Values));
  SetLength(Result.Strings, Length(Values));
  for I := 0 to High(Values) do
  begin
    Result.Values[I] := Values[I];
    if Values[I].VType = vtAnsiString then
    begin
      // fpjson's constructor assumes UTF-8 bytes and ignores ANSI code-page metadata.
      Result.Strings[I] := UTF8Encode(UnicodeString(RawByteString(Values[I].VAnsiString)));
      Result.Values[I].VAnsiString := Pointer(Result.Strings[I]);
    end;
  end;
end;
{$ENDIF}

function ConstValue(const Value: TVarRec): TJSONData;
{$IFDEF FPC}
var
  Input: array[0..0] of TVarRec;
  Arguments: TJSONArguments;
  Values: TJSONArray;
begin
  Input[0] := Value;
  Arguments := PrepareArguments(Input);
  Values := TJSONArray.Create(Arguments.Values);
  try Result := Values.Extract(0); finally Values.Free; end;
end;
{$ELSE}
begin
  case Value.VType of
    vtInteger: Result := TJSONNumber.Create(Value.VInteger);
    vtInt64: Result := TJSONNumber.Create(Value.VInt64^);
    vtBoolean: Result := TJSONBool.Create(Value.VBoolean);
    vtExtended: Result := TJSONNumber.Create(Value.VExtended^);
    vtCurrency: Result := TJSONNumber.Create(Value.VCurrency^);
    vtString: Result := TJSONString.Create(string(Value.VString^));
    vtChar: Result := TJSONString.Create(string(Value.VChar));
    vtWideChar: Result := TJSONString.Create(string(Value.VWideChar));
    vtPChar: Result := TJSONString.Create(string(Value.VPChar));
    vtPWideChar: Result := TJSONString.Create(string(Value.VPWideChar));
    vtAnsiString: Result := TJSONString.Create(string(RawByteString(Value.VAnsiString)));
    vtWideString: Result := TJSONString.Create(WideString(Value.VWideString));
    vtUnicodeString: Result := TJSONString.Create(UnicodeString(Value.VUnicodeString));
    vtPointer:
      if Value.VPointer = nil then Result := TJSONNull.Create
      else raise EConvertError.Create('JSON pointer values must be nil');
    vtObject:
      if Value.VObject = nil then Result := TJSONNull.Create
      else if Value.VObject is TJSONData then Result := TJSONData(Value.VObject)
      else raise EConvertError.Create('JSON object values must be JSON nodes');
  else
    raise EConvertError.Create('Unsupported JSON constructor value');
  end;
end;
{$ENDIF}

function JSONObj(const Values: array of const): TJSONObject;
var
  I: Integer;
  Key: TJSONData;
  Name: UTF8String;
begin
  if Odd(Length(Values)) then raise EConvertError.Create('JSON objects require name/value pairs');
  Result := TJSONObject.Create;
  try
    I := 0;
    while I < Length(Values) do
    begin
      Key := ConstValue(Values[I]);
      try
        if JSONKind(Key) <> jtString then raise EConvertError.Create('JSON names must be strings');
        Name := JSONString(Key);
        {$IFDEF FPC}
        if Result.IndexOfName(Name) >= 0 then
        {$ELSE}
        if Result.GetValue(string(Name)) <> nil then
        {$ENDIF}
          raise EConvertError.Create('Duplicate JSON name');
        JSONAdd(Result, string(Name), ConstValue(Values[I + 1]));
      finally
        Key.Free;
      end;
      Inc(I, 2);
    end;
  except
    Result.Free;
    raise;
  end;
end;

function JSONArr(const Values: array of const): TJSONArray;
{$IFDEF FPC}var Arguments: TJSONArguments;{$ELSE}var I: Integer;{$ENDIF}
begin
  {$IFDEF FPC}
  Arguments := PrepareArguments(Values);
  Result := TJSONArray.Create(Arguments.Values);
  {$ELSE}
  Result := TJSONArray.Create;
  try
    for I := 0 to High(Values) do Result.AddElement(ConstValue(Values[I]));
  except
    Result.Free;
    raise;
  end;
  {$ENDIF}
end;

procedure JSONAdd(Obj: TJSONObject; const Name: string; Value: TJSONData);
begin
  {$IFDEF FPC}
  Obj.Add(Name, Value);
  {$ELSE}
  if Obj.GetValue(Name) <> nil then raise EConvertError.Create('Duplicate JSON name');
  Obj.AddPair(TJSONPair.Create(TJSONString.Create(Name), Value));
  {$ENDIF}
end;

procedure JSONAdd(Obj: TJSONObject; const Name, Value: string);
begin
  {$IFDEF FPC}Obj.Add(Name, Value);{$ELSE}
  if Obj.GetValue(Name) <> nil then raise EConvertError.Create('Duplicate JSON name');
  Obj.AddPair(TJSONPair.Create(TJSONString.Create(Name), TJSONString.Create(Value)));
  {$ENDIF}
end;

procedure JSONAdd(Obj: TJSONObject; const Name: string; Value: Boolean);
begin
  {$IFDEF FPC}Obj.Add(Name, Value);{$ELSE}
  if Obj.GetValue(Name) <> nil then raise EConvertError.Create('Duplicate JSON name');
  Obj.AddPair(TJSONPair.Create(TJSONString.Create(Name), TJSONBool.Create(Value)));
  {$ENDIF}
end;

procedure JSONAdd(Arr: TJSONArray; Value: TJSONData);
begin
  {$IFDEF FPC}Arr.Add(Value);{$ELSE}Arr.AddElement(Value);{$ENDIF}
end;

function JSONFind(Value: TJSONData; const Path: string): TJSONData;
begin
  if Value = nil then Exit(nil);
  {$IFDEF FPC}Result := Value.FindPath(Path);{$ELSE}Result := Value.FindValue(Path);{$ENDIF}
end;

function JSONText(Value: TJSONData): UTF8String;
begin
  {$IFDEF FPC}Result := Value.AsJSON;{$ELSE}Result := UTF8Encode(Value.ToJSON);{$ENDIF}
end;

function JSONString(Value: TJSONData): UTF8String;
begin
  if JSONKind(Value) <> jtString then raise EConvertError.Create('Expected a JSON string');
  {$IFDEF FPC}Result := Value.AsString;{$ELSE}Result := UTF8Encode(Value.Value);{$ENDIF}
end;

function JSONInteger(Value: TJSONData): Int64;
begin
  if JSONKind(Value) <> jtNumber then raise EConvertError.Create('Expected a JSON number');
  Result := StrToInt64(string(JSONText(Value)));
end;

function JSONBoolean(Value: TJSONData): Boolean;
begin
  if JSONKind(Value) <> jtBoolean then raise EConvertError.Create('Expected a JSON boolean');
  {$IFDEF FPC}Result := Value.AsBoolean;{$ELSE}Result := TJSONBool(Value).AsBoolean;{$ENDIF}
end;

function JSONKind(Value: TJSONData): TJSONType;
begin
  if Value = nil then Exit(jtUnknown);
  {$IFDEF FPC}
  Result := Value.JSONType;
  {$ELSE}
  if Value is TJSONObject then Result := jtObject
  else if Value is TJSONArray then Result := jtArray
  else if Value is TJSONString then Result := jtString
  else if Value is TJSONNumber then Result := jtNumber
  else if Value is TJSONBool then Result := jtBoolean
  else if Value is TJSONNull then Result := jtNull
  else Result := jtUnknown;
  {$ENDIF}
end;

function JSONGet(Obj: TJSONObject; const Name, DefaultValue: string): UTF8String;
var Value: TJSONData;
begin
  Value := JSONFind(Obj, Name);
  if Value = nil then Result := UTF8String(DefaultValue) else Result := JSONString(Value);
end;

procedure ValidateGrammar(const Bytes: RawByteString);
var
  I: NativeInt;
  procedure Fail;
  begin
    raise EConvertError.Create('Invalid JSON syntax');
  end;
  procedure Space;
  begin
    while (I <= Length(Bytes)) and (Bytes[I] in [#9, #10, #13, ' ']) do Inc(I);
  end;
  function Current: AnsiChar;
  begin
    if I > Length(Bytes) then Result := #0 else Result := Bytes[I];
  end;
  procedure Expect(C: AnsiChar);
  begin
    if Current <> C then Fail;
    Inc(I);
  end;
  procedure Quoted;
  var J: Integer;
  begin
    Expect('"');
    while Current <> '"' do
    begin
      if Ord(Current) < 32 then Fail;
      if Current = '\' then
      begin
        Inc(I);
        if Current = 'u' then
          for J := 1 to 4 do
          begin
            Inc(I);
            if not (Current in ['0'..'9', 'a'..'f', 'A'..'F']) then Fail;
          end
        else if not (Current in ['"', '\', '/', 'b', 'f', 'n', 'r', 't']) then Fail;
      end;
      Inc(I);
    end;
    Inc(I);
  end;
  procedure Digits;
  begin
    if not (Current in ['0'..'9']) then Fail;
    repeat Inc(I); until not (Current in ['0'..'9']);
  end;
  procedure Value(Depth: Integer);
  var Closing: AnsiChar; IsObject: Boolean; Literal: RawByteString;
  begin
    if Depth > 512 then Fail;
    Space;
    case Current of
      '"': Quoted;
      '{', '[':
        begin
          if Depth >= 512 then Fail;
          IsObject := Current = '{';
          if IsObject then Closing := '}' else Closing := ']';
          Inc(I);
          Space;
          if Current <> Closing then
            repeat
              if IsObject then
              begin
                Quoted;
                Space;
                Expect(':');
              end;
              Value(Depth + 1);
              Space;
              if Current <> ',' then Break;
              Inc(I);
              Space;
            until False;
          Expect(Closing);
        end;
      '-', '0'..'9':
        begin
          if Current = '-' then Inc(I);
          if Current = '0' then Inc(I) else Digits;
          if Current = '.' then begin Inc(I); Digits; end;
          if Current in ['e', 'E'] then
          begin
            Inc(I);
            if Current in ['+', '-'] then Inc(I);
            Digits;
          end;
        end;
      't', 'f', 'n':
        begin
          case Current of
            't': Literal := 'true';
            'f': Literal := 'false';
          else Literal := 'null'; end;
          if Copy(Bytes, I, Length(Literal)) <> Literal then Fail;
          Inc(I, Length(Literal));
        end;
    else Fail;
    end;
  end;
begin
  I := 1;
  Value(0);
  Space;
  if I <= Length(Bytes) then Fail;
end;

{$IFNDEF FPC}
procedure ValidateKeys(Value: TJSONData);
var
  Names: TDictionary<string, Byte>;
  Pair: TJSONPair;
  I: Integer;
begin
  if Value is TJSONObject then
  begin
    Names := TDictionary<string, Byte>.Create;
    try
      for I := 0 to TJSONObject(Value).Count - 1 do
      begin
        Pair := TJSONObject(Value).Pairs[I];
        Names.Add(Pair.JsonString.Value, 0);
        ValidateKeys(Pair.JsonValue);
      end;
    finally Names.Free; end;
  end
  else if Value is TJSONArray then
    for I := 0 to TJSONArray(Value).Count - 1 do ValidateKeys(TJSONArray(Value).Items[I]);
end;
{$ENDIF}

function ParseJSONStrict(const Bytes: RawByteString): TJSONData;
var
  I: NativeInt;
  Text: UTF8String;
  Decoded: UnicodeString;
  {$IFDEF FPC}Parser: TJSONParser; Stream: TMemoryStream;{$ENDIF}
begin
  Result := nil;
  if Bytes = '' then Exit;
  if Pos(#0, Bytes) > 0 then raise EConvertError.Create('Invalid JSON NUL byte');
  Text := '';
  SetLength(Text, Length(Bytes));
  Move(Bytes[1], Text[1], Length(Bytes));
  {$IFDEF FPC}Decoded := UnicodeString(UTF8Decode(Text));{$ELSE}Decoded := UTF8ToString(Text);{$ENDIF}
  if UTF8Encode(Decoded) <> Text then raise EAssinafyJSONEncodingError.Create('Invalid UTF-8');
  I := 1;
  while I <= Length(Bytes) do
  begin
    if Bytes[I] = '\' then
    begin
      // Reject FPC's unsupported escape consistently across compilers.
      if Copy(Bytes, I, 6) = '\u0000' then raise EAssinafyJSONNulError.Create('Escaped NUL is unsupported');
      Inc(I);
    end;
    Inc(I);
  end;
  ValidateGrammar(Bytes);
  {$IFDEF FPC}
  Stream := TMemoryStream.Create;
  try
    Stream.WriteBuffer(Bytes[1], Length(Bytes));
    Stream.Position := 0;
    Parser := TJSONParser.Create(Stream, [joUTF8, joStrict]);
    try Result := Parser.Parse; finally Parser.Free; end;
  finally Stream.Free; end;
  {$ELSE}
  Result := TJSONValue.ParseJSONValue(Decoded, True, True);
  try ValidateKeys(Result); except Result.Free; raise; end;
  {$ENDIF}
  if Result = nil then raise EConvertError.Create('Missing JSON value');
end;

end.
