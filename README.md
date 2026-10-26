# Codex Windows Splash + Skin

Windows-only fullscreen splash, connected to the installed Codex Windows Skin launcher.
This development branch requires the skin runtime with `start-dream-skin.ps1 -Maximize` support.
It has not been published as a new Release.

## Use

1. Install/update Codex Windows Skin first.
2. Put your own MP4 in `assets/`, then write only its filename in `assets/current.txt`.
3. Double-click `启动 Codex.vbs` (or the existing shortcut pointing to it).

The splash plays for about eight seconds. In parallel, `launch-skinned-codex.ps1` calls
`%LOCALAPPDATA%\CodexDreamSkin\engine\scripts\start-dream-skin.ps1`
with `-Maximize -PromptRestart -OperationLockTimeoutMilliseconds 30000`.
The skin launcher starts or reuses the verified CDP session, maximizes the verified Codex
main window, and applies the skin. A normal existing session requires restart confirmation.
The launcher does not use the old `OpenAI Codex.lnk` or silently fall back to a plain instance.

Esc skips the splash. A splash ending does not guarantee skin readiness; the skin launcher
continues independently and reports failure in a dialog. Its log is stored locally at
`%LOCALAPPDATA%\CodexDreamSkin\splash-launch.log`.
No startup monitor is enabled. The normal skin tray and injector remain running.

Preview without launching Codex:

```powershell
powershell.exe -NoProfile -STA -ExecutionPolicy RemoteSigned -File .\startup.ps1 -Preview
```

Add `-WithAudio` for audio (35% initial volume). Preview never launches the skin helper.
Restore the official appearance using the installed `Codex Dream Skin - Restore` shortcut.
Maximization preserves normal window chrome and is different from F11 fullscreen.

## 中文说明

先安装或更新换肤引擎，然后双击「启动 Codex.vbs」即可同时播放开屏并带皮肤启动 Codex。
现有指向此 VBS 的「启动codex」快捷方式可继续使用。
换肤启动器会最大化经过身份校验的 Codex 主窗口。已有带皮肤实例直接复用；
已有普通实例会询问是否重启，不会未经确认强制重启。

开屏约 8 秒后结束，换肤过程独立继续。普通 `OpenAI Codex.lnk` 不再参与这条路径。
本次不会启用普通入口自动接管监控。失败时会单独弹窗，可查看上述本机日志。
开屏视频与 `assets/current.txt` 只保留本机。

## Media and license

Bring a video you have the right to use. The development video came from a third-party
Steam Workshop item and is not distributed in Git or Releases. The MIT license covers
this project's code, not third-party media. This is an independent community project.
