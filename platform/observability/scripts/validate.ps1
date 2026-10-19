$ErrorActionPreference = "Stop"

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$rulesFile = Join-Path $repositoryRoot "platform/observability/prometheus/platform.rules.yaml"

if (-not (Test-Path -LiteralPath $rulesFile -PathType Leaf)) {
    throw "Prometheus rule file not found: $rulesFile"
}

$content = Get-Content -Raw -LiteralPath $rulesFile
foreach ($requiredKey in @("groups:", "rules:", "alert:", "expr:")) {
    if (-not $content.Contains($requiredKey)) {
        throw "Prometheus rule file is missing required key: $requiredKey"
    }
}

$promtool = Get-Command promtool -ErrorAction SilentlyContinue
if ($promtool) {
    Write-Host "Checking Prometheus rules with promtool"
    & $promtool.Source check rules $rulesFile
    if ($LASTEXITCODE -ne 0) {
        throw "promtool rule validation failed."
    }
} else {
    Write-Warning "promtool is unavailable; Prometheus rule syntax and evaluation were not verified."
}

& git -C $repositoryRoot diff --check
if ($LASTEXITCODE -ne 0) {
    throw "git diff --check failed."
}
