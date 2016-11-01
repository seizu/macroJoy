#include <File.au3>

Global Const $_mjCommands[] = [ _
      "sleep", "_mjSleep", 1, 1, _
      "focusA", "_mjFocusA", 1, 1, _
      "focusB", "_mjFocusB", 1, 1, _
      "killpidfile", "_mjKillPidFile", 1, 1, _
      "killproc", "_mjKillProc", 1, 1, _
      "sendkey", "_mjSendKey", 1, 2, _
      "run", "_mjRun", 1, 4, _
      "cursor", "_mjCursor",1 ,1 ]

Global $_mjToggle = 0
Global Const $USER32 = DllOpen("user32.dll")
Global Const $SPI_SETCURSORS = 0x57

Func _mjKillProc($proc)
   If ProcessExists($proc) Then
      ProcessClose($proc)
   EndIf
EndFunc

Func _mjKillPidFile($file)
   If FileExists($file) Then

      Local $fh = FileOpen($file, $FO_READ)
      If $fh Then
         Local $pid = Int(FileReadLine($fh, 1))
         FileClose($fh)
         If $pid > 0 And ProcessExists($pid) Then
            ProcessClose($pid)
         EndIf
      EndIf
   EndIf
EndFunc

Func _mjRun($file, $workdir="", $showflag=@SW_SHOW, $optflag=0)
   ConsoleWrite("_mjRun=>" & $file & " " & $workdir & " " & $showflag & " " & $optflag)
   Run($file, $workdir, $showflag, $optflag)
EndFunc

Func _mjSendKey($key, $flag=0)
   Send($key, Int($flag))
EndFunc

Func _mjSleep($ms)
   Sleep(Int($ms))
EndFunc

Func _mjFocusA($name)
   Local $hWnd = WinGetHandle($name)
   If $hWnd Then
      DllCall($USER32, "BOOL", "SetForegroundWindow", "HWND", $hWnd)
      Sleep(200)
      WinSetState($hWnd, "", @SW_RESTORE)
   EndIf
EndFunc

Func _mjFocusB($name)
   Local $hWnd = WinGetHandle($name)
   If $hWnd Then
      DllCall($USER32, "NONE", "SwitchToThisWindow", "HWND", $hWnd, "BOOL", True)
   EndIf
EndFunc

Func _mjCursor($param)
   $_mjToggle=($param=2?Not $_mjToggle:$param)

   If $_mjToggle Then
      Local $cDll = DllCall($USER32, "hwnd", "LoadCursorFromFile", "str", 'blank.cur')
      If @error = 0 Then
         DllCall($USER32, "int", "SetSystemCursor", "int", $cDll[0], "int", 32512)
         Return
      EndIf
   EndIf

   DllCall($USER32, "int", "SystemParametersInfo", "int", $SPI_SETCURSORS, "int", 0, "int", 0, "int", 0)
EndFunc


