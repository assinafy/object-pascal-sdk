unit AssinafyCrypto;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

function SHA256(const Value: RawByteString): RawByteString;
function HMACSHA256(const Key, Value: RawByteString): RawByteString;
function SecureRandom(Count: Integer): RawByteString;
function ConstantTimeEqual(const Left, Right: RawByteString): Boolean;
function Base64URL(const Value: RawByteString): string;
function StrictBase64Decode(const Value: string): RawByteString;

implementation

uses
  ctypes, DynLibs, base64, AssinafyHttp;

type
  TQDigest = function(Context: Pointer; Name, Properties: PChar; Data: Pointer;
    Size: csize_t; Digest: Pointer; DigestSize: Pcsize_t): cint; cdecl;
  TQMac = function(Context: Pointer; Name, Properties, SubAlgorithm: PChar;
    Params, Key: Pointer; KeySize: csize_t; Data: Pointer; DataSize: csize_t;
    Digest: Pointer; DigestSize: csize_t; Written: Pcsize_t): Pointer; cdecl;
  TRandBytes = function(Buffer: Pointer; Count: cint): cint; cdecl;
  TMemCmp = function(Left, Right: Pointer; Count: csize_t): cint; cdecl;

var
  CryptoLibrary: TLibHandle = NilHandle;
  CryptoLock: TRTLCriticalSection;
  QDigest: TQDigest;
  QMac: TQMac;
  RandBytes: TRandBytes;
  MemCmp: TMemCmp;

procedure EnsureCrypto;
const
  {$ifdef windows}
  {$ifdef cpu64}
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
  EnterCriticalSection(CryptoLock);
  try
    if CryptoLibrary <> NilHandle then Exit;
    CryptoLibrary := LoadLibrary(LibraryName);
    if CryptoLibrary = NilHandle then
      raise EAssinafyTransportError.Create('OpenSSL 3 libcrypto is required for OAuth and webhook signatures');
    Pointer(QDigest) := GetProcedureAddress(CryptoLibrary, 'EVP_Q_digest');
    Pointer(QMac) := GetProcedureAddress(CryptoLibrary, 'EVP_Q_mac');
    Pointer(RandBytes) := GetProcedureAddress(CryptoLibrary, 'RAND_bytes');
    Pointer(MemCmp) := GetProcedureAddress(CryptoLibrary, 'CRYPTO_memcmp');
    if not (Assigned(QDigest) and Assigned(QMac) and Assigned(RandBytes) and Assigned(MemCmp)) then
    begin
      UnloadLibrary(CryptoLibrary);
      CryptoLibrary := NilHandle;
      raise EAssinafyTransportError.Create('OpenSSL 3 crypto functions are unavailable');
    end;
  finally
    LeaveCriticalSection(CryptoLock);
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

function Base64URL(const Value: RawByteString): string;
begin
  Result := EncodeStringBase64(Value);
  Result := StringReplace(Result, '+', '-', [rfReplaceAll]);
  Result := StringReplace(Result, '/', '_', [rfReplaceAll]);
  Result := StringReplace(Result, '=', '', [rfReplaceAll]);
end;

function StrictBase64Decode(const Value: string): RawByteString;
begin
  Result := '';
  if (Value = '') or (Length(Value) mod 4 <> 0) then
    raise EAssinafyInputError.Create('Invalid base64 value');
  try
    Result := DecodeStringBase64(Value, True);
  except
    on E: Exception do raise EAssinafyInputError.Create('Invalid base64 value');
  end;
  if EncodeStringBase64(Result) <> Value then
    raise EAssinafyInputError.Create('Invalid base64 value');
end;

initialization
  InitCriticalSection(CryptoLock);

finalization
  if CryptoLibrary <> NilHandle then UnloadLibrary(CryptoLibrary);
  DoneCriticalSection(CryptoLock);

end.
