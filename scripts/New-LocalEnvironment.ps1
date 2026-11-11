$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path $PSScriptRoot -Parent
$environmentFile = Join-Path $projectRoot '.env'
if (Test-Path $environmentFile) {
    throw '.env already exists and was left untouched. Remove it yourself only if you intend to replace its secrets.'
}

$random = [System.Security.Cryptography.RandomNumberGenerator]::Create()
try {
    $databaseBytes = New-Object byte[] 32
    $signingKeyBytes = New-Object byte[] 48
    $random.GetBytes($databaseBytes)
    $random.GetBytes($signingKeyBytes)

    $databasePassword = [Convert]::ToBase64String($databaseBytes)
    $signingKey = [Convert]::ToBase64String($signingKeyBytes)
    $content = "POSTGRES_PASSWORD=$databasePassword`r`nJWT_SIGNING_KEY=$signingKey`r`n"
    Set-Content -Path $environmentFile -Value $content -Encoding Ascii -NoNewline
} finally {
    $random.Dispose()
}

Write-Output 'Created .env with random local-only secrets. The file is ignored by Git.'
