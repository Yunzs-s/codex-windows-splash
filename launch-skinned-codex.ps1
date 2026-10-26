[CmdletBinding()]
param([switch]$CheckOnly)

$ErrorActionPreference = 'Stop'
$engineRoot = Join-Path $env:LOCALAPPDATA 'CodexDreamSkin\engine'
$startScript = Join-Path $engineRoot 'scripts\start-dream-skin.ps1'
$trayScript = Join-Path $engineRoot 'scripts\tray-dream-skin.ps1'
$logPath = Join-Path $env:LOCALAPPDATA 'CodexDreamSkin\splash-launch.log'
try {
  if (-not (Test-Path -LiteralPath $startScript -PathType Leaf)) {
    throw 'Install Codex Windows Skin before using the combined splash launcher.'
  }
  if (-not (Get-Command $startScript).Parameters.ContainsKey('Maximize')) {
    throw 'Update the installed skin runtime to the version supporting -Maximize.'
  }
  if ($CheckOnly) {
    [pscustomobject]@{ ready = $true; launcher = $startScript; maximize = $true }
    return
  }
  $arguments = '-NoProfile -ExecutionPolicy RemoteSigned -File "' + $startScript + '" -Maximize -PromptRestart -OperationLockTimeoutMilliseconds 30000'
  $child = Start-Process -FilePath powershell.exe -ArgumentList $arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput $logPath -RedirectStandardError ($logPath + '.error.log')
  try {
    $null = $child.Handle
    # Wait for the launcher process, not its long-lived injector descendants or inherited output pipes.
    if (-not $child.WaitForExit(240000)) { throw "Skin launch has not finished. See $logPath" }
    if ($child.ExitCode -ne 0) { throw "Skin launch failed. See $logPath and its .error.log file." }
  } finally { $child.Dispose() }
  $trayArguments = '-NoProfile -STA -WindowStyle Hidden -ExecutionPolicy RemoteSigned -File "' + $trayScript + '"'
  Start-Process -FilePath powershell.exe -ArgumentList $trayArguments -WindowStyle Hidden | Out-Null
  exit 0
} catch {
  if ($CheckOnly) { throw }
  $_ | Out-String | Add-Content -LiteralPath ($logPath + '.error.log')
  $shell = New-Object -ComObject WScript.Shell
  $null = $shell.Popup($_.Exception.Message, 0, 'Codex Splash + Skin', 16)
  exit 1
}
