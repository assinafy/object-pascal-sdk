"""Compile README Pascal examples and validate JSON and shell snippet syntax."""

import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PREFIX = '''program ReadmeExample;
{$IFDEF FPC}{$mode objfpc}{$H+}{$ENDIF}
{$IFDEF FPC}{$codepage utf8}{$ENDIF}
uses
  {$ifdef unix}cthreads,{$endif}
  Classes, SysUtils, AssinafyJson, Assinafy, AssinafyHttp, AssinafyOAuth, AssinafyWebhooks;
var
  Client, OAuthClient, SignerClient: TAssinafyClient;
  Response: TAssinafyResponse;
  SignerBody, AssignmentBody, VerificationBody, ContractBody: TJSONObject;
  Signers: TJSONArray;
  Output: TFileStream;
  Query, CallbackQuery, RequestHeaders: TStringList;
  Config: TAssinafyOAuthConfig;
  PKCE: TAssinafyPKCE;
  AccountID, DocumentID, SignerID, SavedAccessToken, SignerAccessCode,
    VerificationCode, State, URL, Code, SavedState, SavedVerifier,
    CurrentRefreshToken, LatestStoredToken, EndpointSecret, ContractUpdatedAt: string;
  RawRequestBody: RawByteString;
begin
  Client := nil; OAuthClient := nil; SignerClient := nil; Response := nil;
  SignerBody := nil; AssignmentBody := nil; VerificationBody := nil; ContractBody := nil;
  Signers := nil; Output := nil; Query := nil; CallbackQuery := nil; RequestHeaders := nil;
  AccountID := ''; DocumentID := ''; SignerID := ''; SavedAccessToken := '';
  SignerAccessCode := ''; VerificationCode := ''; State := ''; URL := '';
  Code := ''; SavedState := ''; SavedVerifier := ''; CurrentRefreshToken := '';
  LatestStoredToken := ''; EndpointSecret := ''; ContractUpdatedAt := ''; RawRequestBody := '';
  Config := Default(TAssinafyOAuthConfig);
  PKCE := Default(TAssinafyPKCE);
'''


def main():
    delphi = '--delphi' in sys.argv
    arguments = [arg for arg in sys.argv[1:] if arg != '--delphi']
    build = ROOT / 'build' / 'delphi' if delphi else ROOT / 'build'
    build.mkdir(parents=True, exist_ok=True)
    snippets = re.findall(r'```(pascal|json|sh)\n(.*?)\n```',
                          (ROOT / 'README.md').read_text(encoding='utf-8'), re.DOTALL)
    if not snippets:
        raise SystemExit('README must include usage examples')
    for index, (language, body) in enumerate(snippets):
        if language == 'pascal':
            source = body if body.startswith('program ') else PREFIX + body + '\nend.\n'
            path = build / (f'readme_{index}.dpr' if delphi else f'readme_{index}.pas')
            path.write_text(source, encoding='utf-8-sig' if delphi else 'utf-8')
            result = subprocess.run([*arguments, str(path)], cwd=ROOT,
                                    stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                    text=True, check=False)
            if result.returncode != 0:
                raise SystemExit(result.stdout)
        elif language == 'json':
            json.loads(body)
        elif not delphi:
            subprocess.run(['bash', '-n'], input=body, text=True, check=True)
    if delphi:
        count = sum(language == 'pascal' for language, _ in snippets)
        print(f'PASS: {count} README Pascal examples compile; JSON syntax checked')
    else:
        print(f'PASS: {len(snippets)} README examples compile or have valid syntax')


if __name__ == '__main__':
    main()
