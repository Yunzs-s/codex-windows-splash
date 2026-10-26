Set shell = CreateObject("WScript.Shell")
Set files = CreateObject("Scripting.FileSystemObject")
script = files.BuildPath(files.GetParentFolderName(WScript.ScriptFullName), "startup.ps1")
command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File """ & script & """"
If WScript.Arguments.Count > 0 Then
  If LCase(WScript.Arguments(0)) = "/preview" Then command = command & " -Preview"
End If
exitCode = shell.Run(command, 0, True)
If exitCode <> 0 Then MsgBox "Codex splash failed (exit code " & exitCode & ").", vbExclamation, "Codex Splash"
