Param(
    [Parameter(Mandatory=$false)][string]$KeyPath,
    [Parameter(Mandatory=$false)][string]$Email = 'admin@example.com',
    [Parameter(Mandatory=$false)][string]$Password = 'admin',
    [Parameter(Mandatory=$false)][string]$First = 'Admin',
    [Parameter(Mandatory=$false)][string]$Last = 'User',
    [Parameter(Mandatory=$false)][string]$Username = 'admin',
    [Parameter(Mandatory=$false)][string]$Role = 'administrator'
)

# Get repo root
$repoRoot = Resolve-Path "$PSScriptRoot\.."
$secretsDir = Join-Path $repoRoot '.secrets'

if (-not (Test-Path $secretsDir)) {
    Write-Output "Creating secrets folder: $secretsDir"
    New-Item -ItemType Directory -Path $secretsDir | Out-Null
}

if (-not $KeyPath) {
    Write-Output "No service account key path provided. Please enter the full path to your service account JSON file."
    $KeyPath = Read-Host 'Path to service account JSON file'
}

if (-not (Test-Path $KeyPath)) {
    Write-Error "File not found: $KeyPath"
    exit 1
}

$dest = Join-Path $secretsDir 'serviceAccountKey.json'
Copy-Item -Path $KeyPath -Destination $dest -Force
Write-Output "Service account key copied to: $dest"

# Set environment variable for the current session
$env:GOOGLE_APPLICATION_CREDENTIALS = $dest

Write-Output "GOOGLE_APPLICATION_CREDENTIALS set to: $env:GOOGLE_APPLICATION_CREDENTIALS"

# Run npm seed script with arguments passed in
$cmd = "npm run seed-admin -- --email $Email --password $Password --first $First --last $Last --username $Username --role $Role"
Write-Output "Running: $cmd"

# Execute command
Invoke-Expression $cmd

# Clean up - do not remove the key file, but remove the session env var
Remove-Variable -Name env:GOOGLE_APPLICATION_CREDENTIALS -ErrorAction SilentlyContinue
Write-Output 'Done.'
