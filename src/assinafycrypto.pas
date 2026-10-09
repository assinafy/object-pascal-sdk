unit AssinafyCrypto;

{$IFDEF FPC}{$mode objfpc}{$H+}{$ENDIF}
{$B-}

{$IFNDEF FPC}
{$IFNDEF MSWINDOWS}{$MESSAGE FATAL 'Delphi targets are Windows Win32 and Win64'}{$ENDIF}
{$ENDIF}

interface

uses
  SysUtils;

function SHA256(const Value: RawByteString): RawByteString;
function HMACSHA256(const Key, Value: RawByteString): RawByteString;
function SecureRandom(Count: Integer): RawByteString;
function ConstantTimeEqual(const Left, Right: RawByteString): Boolean;
function Base64Encode(const Value: RawByteString): string;
function Base64URL(const Value: RawByteString): string;
function StrictBase64Decode(const Value: string): RawByteString;

implementation

uses
  {$IFDEF FPC}ctypes, DynLibs, base64, SyncObjs,{$ELSE}
  Winapi.Windows, System.SyncObjs, System.NetEncoding,{$ENDIF} AssinafyHttp;

type
  {$IFNDEF FPC}
  cint = Integer;
  csize_t = NativeUInt;
  Pcsize_t = ^csize_t;
  TLibHandle = HMODULE;
  {$ENDIF}
  TQDigest = function(Context: Pointer; Name, Properties: PAnsiChar; Data: Pointer;
    Size: csize_t; Digest: Pointer; DigestSize: Pcsize_t): cint; cdecl;
  TQMac = function(Context: Pointer; Name, Properties, SubAlgorithm: PAnsiChar;
    Params, Key: Pointer; KeySize: csize_t; Data: Pointer; DataSize: csize_t;
    Digest: Pointer; DigestSize: csize_t; Written: Pcsize_t): Pointer; cdecl;
  TRandBytes = function(Buffer: Pointer; Count: cint): cint; cdecl;
  TMemCmp = function(Left, Right: Pointer; Count: csize_t): cint; cdecl;

var
  CryptoLibrary: TLibHandle = 0;
  CryptoLock: TCriticalSection;
  QDigest: TQDigest;
  QMac: TQMac;
  RandBytes: TRandBytes;
  MemCmp: TMemCmp;

procedure EnsureCrypto;
const
  {$IF DEFINED(WINDOWS) OR DEFINED(MSWINDOWS)}
  {$IF DEFINED(CPU64) OR DEFINED(WIN64)}
  LibraryName = 'libcrypto-3-x64.dll';
  {$else}
  LibraryName = 'libcrypto-3.dll';
  {$endif}
  {$else}
  {$ifdef darwin}
  LibraryName = 'libcrypto.3.dylib';
  {$else}
  LibraryName = 'libcrypto.so.3';
  {$endif}
  {$endif}
begin
  CryptoLock.Acquire;
  try
    if CryptoLibrary <> 0 then Exit;
    {$IFDEF FPC}
    CryptoLibrary := LoadLibrary(LibraryName);
    {$ELSE}
    CryptoLibrary := LoadLibraryEx(PChar(ExtractFilePath(ParamStr(0)) + LibraryName), 0,
      LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR or LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
    {$ENDIF}
    if CryptoLibrary = 0 then
      raise EAssinafyTransportError.Create('OpenSSL 3 libcrypto is required for OAuth and webhook signatures');
    {$IFDEF FPC}
    Pointer(QDigest) := GetProcedureAddress(CryptoLibrary, 'EVP_Q_digest');
    Pointer(QMac) := GetProcedureAddress(CryptoLibrary, 'EVP_Q_mac');
    Pointer(RandBytes) := GetProcedureAddress(CryptoLibrary, 'RAND_bytes');
    Pointer(MemCmp) := GetProcedureAddress(CryptoLibrary, 'CRYPTO_memcmp');
    {$ELSE}
    QDigest := TQDigest(GetProcAddress(CryptoLibrary, 'EVP_Q_digest'));
    QMac := TQMac(GetProcAddress(CryptoLibrary, 'EVP_Q_mac'));
    RandBytes := TRandBytes(GetProcAddress(CryptoLibrary, 'RAND_bytes'));
    MemCmp := TMemCmp(GetProcAddress(CryptoLibrary, 'CRYPTO_memcmp'));
    {$ENDIF}
    if not (Assigned(QDigest) and Assigned(QMac) and Assigned(RandBytes) and Assigned(MemCmp)) then
    begin
      {$IFDEF FPC}UnloadLibrary(CryptoLibrary){$ELSE}FreeLibrary(CryptoLibrary){$ENDIF};
      CryptoLibrary := 0;
      raise EAssinafyTransportError.Create('OpenSSL 3 crypto functions are unavailable');
    end;
  finally
    CryptoLock.Release;
  end;
end;

function SHA256(const Value: RawByteString): RawByteString;
var
  Written: csize_t;
begin
  Result := '';
  EnsureCrypto;
  SetLength(Result, 32);
  Written := 0;
  if (QDigest(nil, 'SHA256', nil, Pointer(Value), Length(Value), Pointer(Result), @Written) <> 1)
    or (Written <> 32) then
    raise EAssinafyTransportError.Create('SHA-256 failed');
end;

function HMACSHA256(const Key, Value: RawByteString): RawByteString;
var
  Written: csize_t;
begin
  Result := '';
  EnsureCrypto;
  SetLength(Result, 32);
  Written := 0;
  if (QMac(nil, 'HMAC', nil, 'SHA256', nil, Pointer(Key), Length(Key), Pointer(Value),
    Length(Value), Pointer(Result), 32, @Written) = nil) or (Written <> 32) then
    raise EAssinafyTransportError.Create('HMAC-SHA256 failed');
end;

function SecureRandom(Count: Integer): RawByteString;
begin
  Result := '';
  if (Count < 1) or (Count > 1024) then
    raise EAssinafyInputError.Create('Random byte count must be between 1 and 1024');
  EnsureCrypto;
  SetLength(Result, Count);
  if RandBytes(Pointer(Result), Count) <> 1 then
    raise EAssinafyTransportError.Create('Secure random generation failed');
end;

function ConstantTimeEqual(const Left, Right: RawByteString): Boolean;
begin
  if Length(Left) <> Length(Right) then Exit(False);
  if Left = '' then Exit(True);
  EnsureCrypto;
  Result := MemCmp(Pointer(Left), Pointer(Right), Length(Left)) = 0;
end;

function Base64Encode(const Value: RawByteString): string;
{$IFNDEF FPC}var Bytes: TBytes;{$ENDIF}
begin
  {$IFDEF FPC}
  Result := EncodeStringBase64(Value);
  {$ELSE}
  SetLength(Bytes, Length(Value));
  if Length(Value) > 0 then Move(Value[1], Bytes[0], Length(Value));
  Result := TNetEncoding.Base64.EncodeBytesToString(Bytes).Replace(#13, '').Replace(#10, '');
  {$ENDIF}
end;

function Base64URL(const Value: RawByteString): string;
begin
  Result := Base64Encode(Value);
  Result := StringReplace(Result, '+', '-', [rfReplaceAll]);
  Result := StringReplace(Result, '/', '_', [rfReplaceAll]);
  Result := StringReplace(Result, '=', '', [rfReplaceAll]);
end;

function StrictBase64Decode(const Value: string): RawByteString;
{$IFNDEF FPC}var Bytes: TBytes;{$ENDIF}
begin
  Result := '';
  if (Value = '') or (Length(Value) mod 4 <> 0) then
    raise EAssinafyInputError.Create('Invalid base64 value');
  try
    {$IFDEF FPC}
    Result := DecodeStringBase64(Value, True);
    {$ELSE}
    Bytes := TNetEncoding.Base64.DecodeStringToBytes(Value);
    SetLength(Result, Length(Bytes));
    if Length(Bytes) > 0 then Move(Bytes[0], Result[1], Length(Bytes));
    {$ENDIF}
  except
    on E: Exception do raise EAssinafyInputError.Create('Invalid base64 value');
  end;
  if Base64Encode(Result) <> Value then
    raise EAssinafyInputError.Create('Invalid base64 value');
end;

initialization
  CryptoLock := TCriticalSection.Create;

finalization
  if CryptoLibrary <> 0 then {$IFDEF FPC}UnloadLibrary(CryptoLibrary){$ELSE}FreeLibrary(CryptoLibrary){$ENDIF};
  CryptoLock.Free;

end.
