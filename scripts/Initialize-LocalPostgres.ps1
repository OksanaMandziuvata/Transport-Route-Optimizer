$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path $PSScriptRoot -Parent
$environmentFile = Join-Path $projectRoot '.env'
if (-not (Test-Path $environmentFile)) {
    throw 'Create the local .env file before initializing PostgreSQL.'
}

$settings = @{}
foreach ($line in Get-Content $environmentFile) {
    if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)=(.*)$') {
        $settings[$matches[1]] = $matches[2]
    }
}

if ([string]::IsNullOrWhiteSpace($settings.POSTGRES_PASSWORD)) {
    throw 'POSTGRES_PASSWORD is missing from .env.'
}

$psql = Get-Command psql.exe -ErrorAction SilentlyContinue
if ($psql) {
    $psqlPath = $psql.Source
} else {
    $postgresBin = Get-ChildItem (Join-Path ${env:ProgramFiles} 'PostgreSQL') -Directory -ErrorAction SilentlyContinue |
        Sort-Object { [version]$_.Name } -Descending |
        ForEach-Object { Join-Path $_.FullName 'bin\psql.exe' } |
        Where-Object { Test-Path $_ } |
        Select-Object -First 1
    if (-not $postgresBin) {
        throw 'psql.exe was not found. Install PostgreSQL client tools or add psql.exe to PATH.'
    }

    $psqlPath = $postgresBin
}

$securePassword = Read-Host 'Enter the local PostgreSQL administrator password for user postgres' -AsSecureString
$passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
$previousPassword = $env:PGPASSWORD
try {
    $adminPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer)
    $env:PGPASSWORD = $adminPassword

    $sqlPassword = $settings.POSTGRES_PASSWORD.Replace("'", "''")
    $sql = @"
SELECT 'CREATE ROLE route_optimizer LOGIN PASSWORD ''$sqlPassword''' WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'route_optimizer') \gexec
ALTER ROLE route_optimizer WITH LOGIN PASSWORD '$sqlPassword';
SELECT 'CREATE DATABASE route_optimizer OWNER route_optimizer' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'route_optimizer') \gexec
ALTER DATABASE route_optimizer OWNER TO route_optimizer;
"@

    $sql | & $psqlPath --no-psqlrc --set ON_ERROR_STOP=1 --host localhost --username postgres --dbname postgres
    if ($LASTEXITCODE -ne 0) {
        throw "PostgreSQL setup failed (psql exit code $LASTEXITCODE)."
    }

    Write-Output 'Created or updated the local route_optimizer role and database.'
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
    $adminPassword = $null
    if ($null -eq $previousPassword) {
        Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
    } else {
        $env:PGPASSWORD = $previousPassword
    }
}
