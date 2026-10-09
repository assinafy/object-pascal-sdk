param(
    [ValidateSet('Win32', 'Win64')][string]$Platform = 'Win32',
    [Parameter(Mandatory = $true)][string]$CryptoDirectory,
    [switch]$TrustTestCertificate
)
$ErrorActionPreference = 'Stop'
$TaskRoot = Split-Path -Parent $PSScriptRoot
$TaskOutput = Join-Path $TaskRoot "build\delphi\$Platform"
$CompilerName = if ($Platform -eq 'Win64') { 'dcc64.exe' } else { 'dcc32.exe' }
$TaskCompiler = (Get-Command $CompilerName -ErrorAction Stop).Source
$TaskCrypto = (Resolve-Path $CryptoDirectory).Path
$TaskDll = if ($Platform -eq 'Win64') { 'libcrypto-3-x64.dll' } else { 'libcrypto-3.dll' }
if (-not (Test-Path (Join-Path $TaskCrypto $TaskDll))) {
    throw "Missing matching OpenSSL 3 runtime: $TaskDll"
}
if (-not $TrustTestCertificate) {
    throw 'HTTP/TLS integration requires -TrustTestCertificate on an isolated Windows test machine. It temporarily trusts only the generated fixture certificate and removes it afterward.'
}
function Invoke-Checked([string]$Executable, [string[]]$Arguments) {
    & $Executable @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Command failed: $Executable ($LASTEXITCODE)" }
}
$TaskOldPath = $env:PATH
Push-Location $TaskRoot
try {
    New-Item -ItemType Directory -Force $TaskOutput | Out-Null
    $env:PATH = "$TaskCrypto;$TaskOldPath"
    # Dependencies stay next to the test executables for secure DLL loading.
    Copy-Item (Join-Path $TaskCrypto '*.dll') $TaskOutput -Force
    $TaskFlags = @('-B', '--codepage:65001', '-NSSystem;Winapi', "-U$TaskRoot\src",
        "-I$TaskRoot\src;$TaskRoot\tests", "-N0$TaskOutput", "-E$TaskOutput")
    Invoke-Checked 'python' @('scripts/generate.py', '--check')
    Invoke-Checked 'python' @('scripts/check_contract.py')
    Invoke-Checked 'python' @('-m', 'unittest', 'discover', '-s', 'tests', '-p', 'test_*.py')
    Invoke-Checked $TaskCompiler ($TaskFlags + @('delphi/AssinafySDK.dpk'))
    foreach ($TaskSource in @('delphi/sdk_tests.dpr', 'delphi/http_tests.dpr',
        'delphi/workflow.dpr', 'delphi/oauth_connect.dpr')) {
        Invoke-Checked $TaskCompiler ($TaskFlags + @('-$R+', '-$Q+', '-$I+', '-$C+', $TaskSource))
    }
    Invoke-Checked (Join-Path $TaskOutput 'sdk_tests.exe') @()
    Invoke-Checked 'python' @('tests/http_server.py', (Join-Path $TaskOutput 'http_tests.exe'), '--windows-store-trust')
    Invoke-Checked 'python' (@('scripts/check_examples.py', '--delphi', $TaskCompiler) + $TaskFlags)
} finally {
    $env:PATH = $TaskOldPath
    Pop-Location
}
