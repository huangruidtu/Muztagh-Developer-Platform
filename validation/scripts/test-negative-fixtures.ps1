$ErrorActionPreference = "Stop"

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
$fixture = Join-Path $repositoryRoot "validation/fixtures/invalid-service.yaml"

if (-not (Get-Command kubeconform -ErrorAction SilentlyContinue)) {
    throw "kubeconform is required for the negative schema test."
}

$output = & kubeconform `
    -strict `
    -kubernetes-version 1.31.0 `
    $fixture 2>&1
$result = $LASTEXITCODE
$output | Write-Host

if ($result -eq 0) {
    throw "Intentional invalid Service unexpectedly passed schema validation."
}

Write-Host "Negative test passed: kubeconform rejected the invalid Service."
exit 0
