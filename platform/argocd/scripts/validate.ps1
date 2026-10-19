$ErrorActionPreference = "Stop"

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$roots = @(
    "platform/argocd/bootstrap",
    "platform/argocd/applications",
    "platform/crossplane/packages",
    "platform/crossplane",
    "platform/security/kyverno",
    "user-space/gitops"
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

& git -C $repositoryRoot diff --check
if ($LASTEXITCODE -ne 0) {
    throw "git diff --check failed."
}
