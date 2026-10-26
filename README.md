# Codex Windows Splash

An independent Windows splash window that plays the first five seconds of your own MP4 while opening Codex through its registered Windows app entry. It fades out automatically and can be skipped with Esc. It does not modify the Codex installation, use a debugging port, or inject code into the app. This project is **Windows only**.

## Install and use

1. Download the `Codex-Windows-Splash-v0.1.0.zip` file from Releases and extract it to a folder you can keep.
2. Supply **your own MP4**. Copy it into the extracted `assets` folder. H.264 video in an MP4 container is recommended; AAC audio is optional. Use a source you have the right to use.
3. Create a text file named `current.txt` inside `assets`. Its only line must be the MP4 filename, such as `my-splash.mp4`. Do not write a full path.
4. Double-click `启动 Codex.cmd`. The video plays while Codex starts, then stops after five seconds and the splash fades. If no video is configured or it cannot play, a plain "Codex" splash appears instead.

The video stays intact in `assets`: only the first five seconds are played. To switch later, place another MP4 in `assets` and change the filename in `current.txt`. The launch shortcut can be pinned in place of your usual Codex shortcut. Launching the original Codex icon still opens Codex normally without this splash.

The splash is silent by default. To hear an MP4's soundtrack, run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\startup.ps1 -WithAudio` from the extracted folder. Volume starts at 35%. To preview without launching Codex, run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\startup.ps1 -Preview`.

## Why the release has no video

The example animation used during development came from a third-party Steam Workshop item. Its copyright and redistribution rights are not granted to this repository, so **the MP4 is not uploaded to GitHub or included in Releases**. Downloading this repository gives you the launcher only. Bring a legally usable MP4 yourself and follow the steps above. The code is MIT licensed; that license does not apply to anyone else's video.

## Limitations

The handoff is time based: it does not know when the Codex page finishes loading, so the page may still be loading after the splash disappears. Windows must be able to decode your MP4. The launcher uses Windows PowerShell and WPF; it queries the installed `OpenAI.Codex_*!App` entry each time rather than calling an executable in `WindowsApps` directly. The PowerShell execution-policy override is scoped to this launch process. No background service remains after the splash closes.

This is an independent community project, not an official OpenAI or Codex release.

## 中文说明

这是 **仅支持 Windows** 的独立 Codex 开屏程序：播放自备 MP4 的前 5 秒，同时通过 Windows 官方注册入口启动 Codex，然后淡出。按 Esc 可跳过。它不修改 Codex 安装文件，也不使用 CDP 或页面注入。

从 Releases 下载 `Codex-Windows-Splash-v0.1.0.zip` 并解压。把你有权使用的 MP4 放入 `assets` 文件夹，再新建 `assets/current.txt`，其中只写 MP4 文件名（例如 `my-splash.mp4`），最后双击 `启动 Codex.cmd`。以后可在 `assets` 保存多个视频，只需修改 `current.txt` 切换。默认静音；需要声音可在该文件夹运行 `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\startup.ps1 -WithAudio`。

开发时使用的示例视频来自第三方 Steam Workshop。**由于版权及再分发授权不明，仓库和 Release 均不上传该视频。**下载后请自行准备有使用权的 MP4。MIT 许可证只覆盖本项目代码，不覆盖任何第三方视频。
