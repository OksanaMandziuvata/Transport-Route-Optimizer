$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path $PSScriptRoot -Parent
$environmentFile = Join-Path $projectRoot '.env'
if (-not (Test-Path $environmentFile)) {
    throw 'Create the local .env file before starting the API.'
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

if ([string]::IsNullOrWhiteSpace($settings.JWT_SIGNING_KEY) -or
    [Text.Encoding]::UTF8.GetByteCount($settings.JWT_SIGNING_KEY) -lt 32) {
    throw 'JWT_SIGNING_KEY in .env must contain at least 32 UTF-8 bytes.'
}

$environment = @{
    ASPNETCORE_ENVIRONMENT = 'Development'
    ConnectionStrings__DefaultConnection = "Host=localhost;Port=5432;Database=route_optimizer;Username=route_optimizer;Password=$($settings.POSTGRES_PASSWORD)"
    Jwt__Issuer = 'RouteOptimizer'
    Jwt__Audience = 'RouteOptimizer.Client'
    Jwt__SigningKey = $settings.JWT_SIGNING_KEY
}

$previousValues = @{}
foreach ($key in $environment.Keys) {
    $previousValues[$key] = [Environment]::GetEnvironmentVariable($key, 'Process')
    [Environment]::SetEnvironmentVariable($key, $environment[$key], 'Process')
}

try {
    Push-Location $projectRoot
    dotnet run --project src\RouteOptimizer.Api --urls http://localhost:5249
    if ($LASTEXITCODE -ne 0) {
        throw "The API exited with code $LASTEXITCODE."
    }
} finally {
    Pop-Location
    foreach ($key in $environment.Keys) {
        [Environment]::SetEnvironmentVariable($key, $previousValues[$key], 'Process')
    }
}
