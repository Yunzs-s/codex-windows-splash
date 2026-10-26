$ErrorActionPreference = 'Stop'
$tokens = $null
$errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile(
  (Join-Path $PSScriptRoot 'startup.ps1'), [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw ($errors | Out-String) }
$event = $ast.Find({ param($node)
  $node -is [Management.Automation.Language.InvokeMemberExpressionAst] -and
  $node.Member.Value -eq 'Add_ContentRendered'
}, $true)
$text = $event.Arguments[0].ScriptBlock.Extent.Text
$handler = [scriptblock]::Create($text.Substring(1, $text.Length - 2))
$started = [Diagnostics.Stopwatch]::new()
$video = $null
$timer = [pscustomobject]@{}
$timer | Add-Member ScriptMethod Start {}
$skinLauncher = Join-Path $PSScriptRoot 'launch-skinned-codex.ps1'
$script:launchCount = 0
function Start-Process {
  param($FilePath, $ArgumentList, $WindowStyle)
  if ($FilePath -ne 'powershell.exe' -or $WindowStyle -ne 'Hidden' -or
      $ArgumentList -notlike '*launch-skinned-codex.ps1*') { throw 'Wrong launch command.' }
  $script:launchCount++
}
$Preview = $true
& $handler
if ($script:launchCount -ne 0) { throw 'Preview launched Codex.' }
$Preview = $false
& $handler
if ($script:launchCount -ne 1) { throw 'Expected exactly one skin helper launch.' }
Write-Output 'PASS: preview launches nothing; splash starts exactly one hidden skin helper.'
