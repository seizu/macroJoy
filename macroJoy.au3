#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=macroJoy.ico
#AutoIt3Wrapper_Outfile=macroJoy.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_Res_Description=Control programs by joystick
#AutoIt3Wrapper_Res_Fileversion=1.0.0.6
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductVersion=%Fileversion%
#AutoIt3Wrapper_Res_LegalCopyright=(c) Erich Pribitzer
#AutoIt3Wrapper_Res_Field=ProductName|%scriptfile%
#AutoIt3Wrapper_Run_Au3Stripper=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Constants.au3>
#include <TrayConstants.au3>
#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include <WinAPIFiles.au3>
#include <Misc.au3>
#include <StaticConstants.au3>

#include "includes/readConfig.au3"
#include "includes/joyView.au3"
#include "includes/functions.au3"

_Singleton("SpringBoard")

Global $version = FileGetVersion(@ScriptDir & '\' & @ScriptName)
Global $written = FileGetVersion(@ScriptDir & '\' & @ScriptName, $FV_LEGALCOPYRIGHT)
Global $hTimer = TimerInit()
Local $seq[0], $cmd[0]

Opt("MustDeclareVars", 1)
Opt("TrayMenuMode", 3)
Opt("TrayOnEventMode", 0)

;OnAutoItExitRegister("QuitProg")

Local $ckJoyData = TrayCreateItem("Check JoyData")
Local $edConfig = TrayCreateItem("Edit Config")
Local $rlConfig = TrayCreateItem("Reload Data")
TrayCreateItem("")
Local $ab = TrayCreateItem("About")
Local $ex = TrayCreateItem("Exit")
TraySetState()
TraySetToolTip(" macroJoy " & $version & " ")


Global $macros = _mjInitConfig($seq, $cmd)

If ($macros = 0) Or ($macros > $maxMacros) Then errorMsg("Config Error")
_mjJoyInit($joy)

Local $npid = 0
Local $msg
Local $doMacros = True

While 1
   $msg = TrayGetMsg()
   Select
      Case $ckJoyData = $msg
         CheckJoyData()
      Case $edConfig = $msg
         If ProcessExists($npid) = False Then
            $npid = Run("notepad macroJoy.cfg")
         EndIf
      Case $rlConfig = $msg
         _mjJoyInit($joy)
         _mjInitConfig($seq, $cmd)
      Case $ex = $msg
         ExitIt()
      Case $ab = $msg
         About()
   EndSelect
   If $doMacros = True Then
      processMacros($seq, $cmd)
   EndIf
   Sleep(10)
WEnd

Func processMacros(ByRef $seq, ByRef $cmd)
   Local $joyPort

   For $t = 0 To $macros - 1
      $joyPort = Int($seq[$t * $_mjSize + $_mjJoyPort])

      If _mjJoyUpdateData($joy, $joyPort - 1) Then
         If isSequencePressed($joy, $seq, $t) = True Then
            startCommands($cmd, $t)
         EndIf
      EndIf
   Next
EndFunc

Func startCommands(ByRef $cmd, $inx)
   Local $lim = UBound($cmd[$inx]) - 1
   Local $func, $cominx, $param, $params, $minpar, $maxpar
   For $t = 0 To $lim
      $param = StringSplit(($cmd[$inx])[$t], ",", $STR_NOCOUNT)
      $params = UBound($param) -1
      If $params >= 0 Then
         $cominx = _ArraySearch($_mjCommands, $param[0])
         If @error = 0 Then
            $func = $_mjCommands[$cominx + 1]
            $minpar = $_mjCommands[$cominx + 2]
            $maxpar = $_mjCommands[$cominx + 3]
            If $params >= $minpar AND $params <= $maxpar Then
               Switch $params
                  Case 0
                     Call($func)
                  Case 1
                     Call($func, $param[1])
                  Case 2
                     Call($func, $param[1], $param[2])
                  Case 3
                     Call($func, $param[1], $param[2], $param[3])
                  Case 4
                     Call($func, $param[1], $param[2], $param[3], $param[4])
               EndSwitch
            EndIf
         EndIf
      EndIf
   Next
EndFunc

Func isSequencePressed($joy, ByRef $seq, $inx)
   $inx = $inx * $_mjSize
   Local $lim = UBound($seq[$inx + $_mjSequence]) - 1
   Local $btn
   Local $count = 0
   If $seq[$inx + $_mjProcess] <> '0' Then
      If Not ProcessExists($seq[$inx + $_mjProcess]) Then Return False
   EndIf

   If $seq[$inx + $_mjPushType] = 1 Then
      For $i = 0 To $lim
         $btn = StringSplit(($seq[$inx + $_mjSequence])[$i], ",", $STR_NOCOUNT) ; split button-id and value
         If $joy[$_joyData + $btn[0] - 1] = Int($btn[1]) Then ; check joyid.code is pressed
            $count += 1
         Else
            $seq[$inx + $_mjDeltaTime] = 0 ; reset timing
            $count = 0
            ExitLoop
         EndIf
      Next
      If ($count = $lim + 1) Then
         If ($seq[$inx + $_mjTime] = 0 And $seq[$inx + $_mjDeltaTime] = 0) Or _
               ($seq[$inx + $_mjTime] > 0 And (TimerDiff($hTimer) - $seq[$inx + $_mjDeltaTime] > $seq[$inx + $_mjTime])) Or _
               $seq[$inx + $_mjDeltaTime] = 0 Then
            ConsoleWrite("seq1=" & $seq[$inx + $_mjTime] & "  seq2=" & $seq[$inx + $_mjDeltaTime] & @CRLF)
            $seq[$inx + $_mjDeltaTime] = TimerDiff($hTimer)
            Return True
         EndIf
      EndIf
   ElseIf $seq[$inx + $_mjPushType] = 2 Then
      $btn = StringSplit(($seq[$inx + $_mjSequence])[$seq[$inx + $_mjCount]], ",", $STR_NOCOUNT)
      If ($seq[$inx + $_mjDeltaTime]) = 0 Then
         $seq[$inx + $_mjDeltaTime] = TimerDiff($hTimer)
      ElseIf ((TimerDiff($hTimer) - $seq[$inx + $_mjDeltaTime]) > $seq[$inx + $_mjTime]) Then
         $seq[$inx + $_mjCount] = 0
         $seq[$inx + $_mjDeltaTime] = 0
         Return False
      EndIf
      If $joy[$_joyData + $btn[0] - 1] = Int($btn[1]) Then ; check joyid.code is pressed
         $seq[$inx + $_mjCount] += 1
         If $seq[$inx + $_mjCount] > $lim Then
            $seq[$inx + $_mjCount] = 0
            $seq[$inx + $_mjDeltaTime] = 0
            Return True
         EndIf
      ElseIf $seq[$inx + $_mjCount] > 0 Then
         $btn = StringSplit(($seq[$inx + $_mjSequence])[$seq[$inx + $_mjCount] - 1], ",", $STR_NOCOUNT)
         If ($joy[$_joyData + $btn[0] - 1] <> Int($btn[1])) Then
            $seq[$inx + $_mjCount] = 0
            $seq[$inx + $_mjDeltaTime] = 0
         EndIf
      EndIf
   EndIf
   Return False
EndFunc

Func CheckJoyData()
   Local $event
   Local $jp = 0
   _mjJoyInitView($joy)
   Local $clr = 0
   While 1
      For $t = 0 To $macros - 1
         Local $joyPort = Int($seq[$t * $_mjSize + $_mjJoyPort])

         If _mjJoyUpdateData($joy, $joyPort - 1) Then
            If isSequencePressed($joy, $seq, $t) = True Then
               $joy[$_joyEvent] = $joyPort & '/' & $t + 1
               $clr = 50
            EndIf
         EndIf
      Next
      If $clr < 0 Then
         $clr = 0
         $joy[$_joyEvent] = ""
      Else
         $clr -= 1
      EndIf

      _mjJoyUpdateData($joy, $jp)
      _mjJoyUpdateView($joy)
      $event = GUIGetMsg()
      Switch $event
         Case $GUI_EVENT_CLOSE
            ExitLoop
         Case $joy[$_joyMinusBn]
            $jp -= ($jp > 0 ? 1 : 0)
            GUICtrlSetData($joy[$_joyJoyLb], StringFormat("%02d", $jp + 1))
         Case $joy[$_joyPlusBn]
            $jp += ($jp + 1 < 15 ? 1 : 0)
            GUICtrlSetData($joy[$_joyJoyLb], StringFormat("%02d", $jp + 1))
      EndSwitch
      Sleep(10)
   WEnd
   GUIDelete($joy[$_joyView])
EndFunc

Func About()
   MsgBox(0, _
         "About", _
         "macroJoy v" & $version & @CRLF & $written)
EndFunc

Func errorMsg($msg)
   MsgBox(16, "Error", $msg)
   ExitIt()
EndFunc

Func ExitIt()
   Exit
EndFunc

