# Run from the folder this script lives in
Set-Location -Path $PSScriptRoot

# Check that a compose file exists here
$composeFiles = @("docker-compose.yml", "docker-compose.yaml", "compose.yml", "compose.yaml")
if (-not ($composeFiles | Where-Object { Test-Path $_ })) {
    Write-Host "No docker compose file found in $PSScriptRoot" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

function Test-DockerReady {
    docker info *> $null
    return ($LASTEXITCODE -eq 0)
}

if (-not (Test-DockerReady)) {
    Write-Host "Docker is not running. Starting Docker Desktop in the background..."
    $dockerExe = Join-Path $env:ProgramFiles "Docker\Docker\Docker Desktop.exe"
    if (-not (Test-Path $dockerExe)) {
        Write-Host "Could not find Docker Desktop at $dockerExe" -ForegroundColor Red
        Write-Host "Start it manually or edit this script with the correct path."
        Read-Host "Press Enter to exit"
        exit 1
    }
    Start-Process -FilePath $dockerExe -WindowStyle Minimized

    Write-Host "Waiting for Docker to become ready..."
    while (-not (Test-DockerReady)) {
        Start-Sleep -Seconds 3
    }
    Write-Host "Docker is ready."
}

Write-Host "Running docker compose in $PSScriptRoot ..."
docker compose up -d --wait

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "docker compose failed (exit code $LASTEXITCODE)." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit $LASTEXITCODE
}

Write-Host "All services are up."
exit 0
