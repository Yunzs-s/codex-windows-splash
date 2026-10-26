param(
  [switch]$Preview,
  [switch]$WithAudio
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

$assetDirectory = Join-Path $PSScriptRoot 'assets'
$selection = Join-Path $assetDirectory 'current.txt'
$asset = $null
if (Test-Path -LiteralPath $selection -PathType Leaf) {
  $filename = (Get-Content -LiteralPath $selection -Raw).Trim()
  if ($filename -notmatch '^[^\\/:*?"<>|]+\.mp4$') { throw 'current.txt must contain only an MP4 filename from the assets folder.' }
  $asset = Join-Path $assetDirectory $filename
}
$app = Get-StartApps | Where-Object AppID -Like 'OpenAI.Codex_*!App' | Select-Object -First 1
if (-not $Preview -and -not $app) { throw 'The registered Codex app entry was not found.' }

$window = New-Object Windows.Window
$window.Title = 'Codex Splash'
$window.Width = 880
$window.Height = 500
$window.MinWidth = 500
$window.MinHeight = 300
$window.WindowStyle = 'None'
$window.ResizeMode = 'NoResize'
$window.WindowStartupLocation = 'CenterScreen'
$window.Background = [Windows.Media.Brushes]::Black
$window.Topmost = $true
$window.ShowInTaskbar = $false

$grid = New-Object Windows.Controls.Grid
$grid.Background = [Windows.Media.BrushConverter]::new().ConvertFromString('#1F1631')
$window.Content = $grid
$caption = New-Object Windows.Controls.TextBlock
$caption.Text = 'Codex'
$caption.FontFamily = 'Segoe UI'
$caption.FontSize = 54
$caption.FontWeight = 'Light'
$caption.Foreground = [Windows.Media.Brushes]::White
$caption.HorizontalAlignment = 'Center'
$caption.VerticalAlignment = 'Center'
$grid.Children.Add($caption) | Out-Null

$video = $null
$mediaOpened = $false
$mediaFailed = $false
$mediaEnded = -not ($asset -and (Test-Path -LiteralPath $asset -PathType Leaf))
if (-not $mediaEnded) {
  $video = New-Object Windows.Controls.MediaElement
  $video.LoadedBehavior = 'Manual'
  $video.UnloadedBehavior = 'Stop'
  $video.Stretch = 'UniformToFill'
  $video.IsMuted = -not $WithAudio
  $video.Volume = 0.35
  $video.Source = [Uri]::new($asset)
  $grid.Children.Add($video) | Out-Null
  $caption.Visibility = 'Collapsed'
  $video.Add_MediaOpened({ $script:mediaOpened = $true })
  $video.Add_MediaEnded({ $script:mediaEnded = $true })
  $video.Add_MediaFailed({
    $script:mediaFailed = $true
    $script:mediaEnded = $true
    $video.Visibility = 'Collapsed'
    $caption.Visibility = 'Visible'
  })
}

$started = [Diagnostics.Stopwatch]::new()
$closing = $false
$timer = New-Object Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds(150)
$fade = {
  if ($script:closing) { return }
  $script:closing = $true
  $timer.Stop()
  if ($video) { $video.Stop() }
  $animation = New-Object Windows.Media.Animation.DoubleAnimation
  $animation.From = 1
  $animation.To = 0
  $animation.Duration = [Windows.Duration]::new([TimeSpan]::FromMilliseconds(450))
  $animation.Add_Completed({ $window.Close() })
  $window.BeginAnimation([Windows.Window]::OpacityProperty, $animation)
}

$window.Add_KeyDown({ if ($_.Key -eq 'Escape') { & $fade } })
$window.Add_ContentRendered({
  $started.Start()
  if ($video) { $video.Play() }
  if (-not $Preview) {
    try {
      Start-Process -FilePath 'explorer.exe' -ArgumentList ('shell:AppsFolder\' + $app.AppID) | Out-Null
    } catch {
      [Windows.MessageBox]::Show('Could not start Codex: ' + $_.Exception.Message) | Out-Null
      & $fade
    }
  }
  $timer.Start()
})
$timer.Add_Tick({
  $seconds = $started.Elapsed.TotalSeconds
  if ($Preview) {
    if ($seconds -ge 3 -and $mediaEnded) { & $fade; return }
    if ($seconds -ge 5) { & $fade }
    return
  }
  if ($seconds -ge 5) { & $fade }
})

try { $window.ShowDialog() | Out-Null }
finally { $timer.Stop(); if ($video) { $video.Stop() } }
if ($Preview) { Write-Output ('VideoOpened=' + $mediaOpened + '; VideoFailed=' + $mediaFailed) }
