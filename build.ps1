param([string]$NsisCompiler = 'makensis.exe')
$ErrorActionPreference = 'Stop'

$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (!(Test-Path -LiteralPath $compiler)) {
    $compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe'
}
if (!(Get-Command $NsisCompiler -ErrorAction SilentlyContinue)) {
    foreach ($base in @(${env:ProgramFiles(x86)}, $env:ProgramFiles)) {
        if ($base) {
            $candidate = Join-Path $base 'NSIS\makensis.exe'
            if (Test-Path -LiteralPath $candidate) { $NsisCompiler = $candidate; break }
        }
    }
}
if (!(Get-Command $NsisCompiler -ErrorAction SilentlyContinue)) {
    throw 'Install NSIS, or pass -NsisCompiler with the full path to makensis.exe.'
}
$output = Join-Path $PSScriptRoot 'build'
New-Item -ItemType Directory -Path $output -Force | Out-Null
& $compiler /nologo /target:winexe /platform:anycpu /optimize+ /debug- "/out:$output\CopyPath.exe" "$PSScriptRoot\CopyPath.cs"
if ($LASTEXITCODE -ne 0) { throw 'Helper build failed.' }
Push-Location $PSScriptRoot
try {
    & $NsisCompiler /V2 /INPUTCHARSET UTF8 'CopyPath.nsi'
    if ($LASTEXITCODE -ne 0) { throw 'Installer build failed.' }
} finally { Pop-Location }
Write-Output "Built: $output\CopyPath-Setup-1.0.0.exe"
