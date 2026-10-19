param([Parameter(Mandatory=$true)][string]$NsisCompiler)
$ErrorActionPreference = 'Stop'
$project = $PSScriptRoot
$run = Join-Path $project ('build\verify-' + [Guid]::NewGuid().ToString('N'))
$scope = 'Software\CopyPathMiniVerification\' + [Guid]::NewGuid().ToString('N')
$registry = [Microsoft.Win32.Registry]::CurrentUser
$menus = @("$scope\Classes\AllFilesystemObjects\shell\CopyPathToClipboard", "$scope\Classes\Directory\Background\shell\CopyPathToClipboard")
New-Item -ItemType Directory -Path $run -Force | Out-Null
$installer = Join-Path $run 'CopyPath-Verification.exe'
function Assert($condition, $message) { if (!$condition) { throw $message } }
function Value($path, $name='') {
    $key=$registry.OpenSubKey($path)
    if (!$key) { return $null }
    try { return $key.GetValue($name) } finally { $key.Dispose() }
}
function Execute($file, $arguments) {
    $info=[Diagnostics.ProcessStartInfo]::new($file,$arguments)
    $info.UseShellExecute=$false
    $info.CreateNoWindow=$true
    $info.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden
    $process=[Diagnostics.Process]::Start($info)
    try {
        if (!$process.WaitForExit(20000)) { $process.Kill(); throw 'Installer process timed out.' }
        Assert ($process.ExitCode -eq 0) 'Installer process failed.'
    } finally { $process.Dispose() }
}
Push-Location $project
try {
    & $NsisCompiler /V2 /INPUTCHARSET UTF8 "/DCLASSES_ROOT=$scope\Classes" "/DUNINSTALL_ROOT=$scope\Uninstall" "/DOUTPUT=$installer" 'CopyPath.nsi'
    if ($LASTEXITCODE -ne 0) { throw 'Isolated installer compilation failed.' }
    Assert ((Get-Item -LiteralPath "$project\build\CopyPath.exe").Length -lt 16384) 'Helper footprint exceeds 16 KiB.'
    Assert ((Get-Item -LiteralPath $installer).Length -lt 524288) 'Installer footprint exceeds 512 KiB.'
    $helperHash=(Get-FileHash -LiteralPath "$project\build\CopyPath.exe").Hash
    foreach ($language in @('en','zh-CN')) {
        $label=if($language -eq 'en'){'Copy Path'}else{ConvertFrom-Json '"\u590d\u5236\u8def\u5f84"'}
        $languageId=if($language -eq 'en'){'1033'}else{'2052'}
        for($i=0;$i -lt 2;$i++) {
            $key=$registry.CreateSubKey($menus[$i]+'\command')
            try { $key.SetValue('','Original-'+$i) } finally { $key.Dispose() }
        }
        $destination=Join-Path $run ('install with spaces '+$language)
        Execute $installer "/S /LANG=$language /D=$destination"
        foreach($menu in $menus) {
            Assert ((Value $menu 'MUIVerb') -eq $label) 'Localized menu label is incorrect.'
            Assert ((Value $menu 'Position') -eq 'Top') 'Menu position is incorrect.'
        }
        Assert ((Get-FileHash -LiteralPath "$destination\CopyPath.exe").Hash -eq $helperHash) 'Installed payload differs from the build.'
        Assert ((Get-Content -LiteralPath "$destination\state.ini" -Raw) -match ('language='+$languageId)) 'Uninstall language was not saved.'
        Assert (Test-Path -LiteralPath "$destination\USAGE.txt") 'Usage file was not installed.'
        $backups=@("$destination\backup\files.reg","$destination\backup\background.reg")
        $before=@(Get-FileHash -LiteralPath $backups | ForEach-Object Hash)
        Execute $installer "/S /LANG=$language /D=$destination"
        Assert ((@(Get-FileHash -LiteralPath $backups | ForEach-Object Hash) -join ',') -eq ($before -join ',')) 'Reinstall replaced original backups.'
        Set-Content -LiteralPath "$destination\keep-user-file.txt" -Value 'Unrelated fixture.'
        Execute "$destination\Uninstall.exe" '/S'
        $timer=[Diagnostics.Stopwatch]::StartNew()
        while((Value ($menus[0]+'\command')) -ne 'Original-0' -or (Value ($menus[1]+'\command')) -ne 'Original-1' -or (Value "$scope\Uninstall" 'DisplayName')) {
            if($timer.ElapsedMilliseconds -gt 15000){throw 'Uninstall restoration timed out.'}
            Start-Sleep -Milliseconds 50
        }
        Assert (Test-Path -LiteralPath "$destination\keep-user-file.txt") 'Uninstall removed an unrelated file.'
        Write-Output "PASS $language install, reinstall, payload integrity, backup retention and uninstall restoration."
    }
} finally {
    Pop-Location
    $registry.DeleteSubKeyTree($scope,$false)
}
