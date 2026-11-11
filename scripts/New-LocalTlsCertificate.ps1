$ErrorActionPreference = 'Stop'

$openssl = Get-Command openssl.exe -ErrorAction SilentlyContinue
if ($openssl) {
    $opensslPath = $openssl.Source
} else {
    $gitOpenSsl = Join-Path ${env:ProgramFiles} 'Git\usr\bin\openssl.exe'
    if (-not (Test-Path $gitOpenSsl)) {
        throw 'OpenSSL is required. Install Git for Windows or add openssl.exe to PATH.'
    }

    $opensslPath = $gitOpenSsl
}

$certificateDirectory = Join-Path (Split-Path $PSScriptRoot -Parent) 'certs'
New-Item -ItemType Directory -Path $certificateDirectory -Force | Out-Null

$certificatePath = Join-Path $certificateDirectory 'localhost.crt'
$keyPath = Join-Path $certificateDirectory 'localhost.key'

& $opensslPath req `
    -x509 `
    -nodes `
    -days 365 `
    -newkey rsa:2048 `
    -keyout $keyPath `
    -out $certificatePath `
    -subj '/CN=localhost' `
    -addext 'subjectAltName=DNS:localhost,IP:127.0.0.1'

if ($LASTEXITCODE -ne 0) {
    throw "OpenSSL failed to create the local TLS certificate (exit code $LASTEXITCODE)."
}

Write-Output "Created local-only certificate: $certificatePath"
Write-Output "Created private key: $keyPath"
Write-Output 'These files are ignored by Git and must not be used in production.'
