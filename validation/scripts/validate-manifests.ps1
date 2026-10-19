$ErrorActionPreference = "Stop"

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
$roots = Get-ChildItem `
    -Path (Join-Path $repositoryRoot "platform"), (Join-Path $repositoryRoot "user-space") `
    -Recurse `
    -Filter "kustomization.yaml" |
    ForEach-Object {
        [System.IO.Path]::GetRelativePath($repositoryRoot, $_.DirectoryName).Replace("\", "/")
    } |
    Sort-Object

foreach ($tool in @("kubectl", "kubeconform")) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        throw "$tool is required for manifest schema validation."
    }
}

$renderDirectory = Join-Path ([System.IO.Path]::GetTempPath()) "muztagh-schema-$PID"
New-Item -ItemType Directory -Path $renderDirectory | Out-Null

try {
    foreach ($root in $roots) {
        Write-Host "Rendering and schema-checking $root"
        $rendered = & kubectl kustomize (Join-Path $repositoryRoot $root)
        if ($LASTEXITCODE -ne 0) {
            throw "Kustomize rendering failed for $root."
        }

        if ([string]::IsNullOrWhiteSpace(($rendered -join [Environment]::NewLine))) {
            Write-Host "No resources rendered for $root"
            continue
        }

        $outputName = ($root -replace "[/\\]", "-") + ".yaml"
        $outputPath = Join-Path $renderDirectory $outputName
        $rendered | Set-Content -LiteralPath $outputPath -Encoding utf8

        & kubeconform `
            -strict `
            -summary `
            -ignore-missing-schemas `
            -kubernetes-version 1.31.0 `
            $outputPath
        if ($LASTEXITCODE -ne 0) {
            throw "Kubeconform validation failed for $root."
        }
    }
} finally {
    Remove-Item -LiteralPath $renderDirectory -Recurse -Force
}
