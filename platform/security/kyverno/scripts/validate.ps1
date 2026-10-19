$ErrorActionPreference = "Stop"

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
$roots = @(
    "platform/security/kyverno",
    "platform/security/kyverno/tests",
    "platform/security/kyverno/tests/resources/valid",
    "platform/security/kyverno/tests/resources/invalid"
)

if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    throw "kubectl is required for embedded Kustomize validation."
}

foreach ($root in $roots) {
    Write-Host "Rendering $root"
    & kubectl kustomize (Join-Path $repositoryRoot $root) | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Kustomize rendering failed for $root."
    }
}

$kyverno = Get-Command kyverno -ErrorAction SilentlyContinue
if ($kyverno) {
    Write-Host "Running Kyverno policy tests"
    & $kyverno.Source test (Join-Path $repositoryRoot "platform/security/kyverno/tests") --remove-color
    if ($LASTEXITCODE -ne 0) {
        throw "Kyverno policy tests failed."
    }
} else {
    Write-Warning "Kyverno CLI is unavailable; policy behavior tests were not run."
}

& git -C $repositoryRoot diff --check
if ($LASTEXITCODE -ne 0) {
    throw "git diff --check failed."
}
