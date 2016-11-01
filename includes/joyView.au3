#include <GUIConstants.au3>
Global Const $WINMM        = DllOpen("Winmm.dll")
Global Const $_joyHnd      = 0
Global Const $_joyView     = 1
Global Const $_joyJoyLb    = 2
Global Const $_joyDataLb   = 3
Global Const $_joyEventLb  = 4
Global Const $_joyEvent    = 5
Global Const $_joyMinusBn  = 6
Global Const $_joyPlusBn   = 7
Global Const $_joyData     = 8
Global Const $_joySize     = 8 + 8

Dim $joy[$_joySize]

Func _mjJoyInit(ByRef $_joy)
   DllCall($WINMM, "UINT", "joyConfigChanged", "DWORD", 0)

   Global $JOYINFOEX_struct = "dword[13]"
   $_joy[$_joyHnd] = DllStructCreate($JOYINFOEX_struct)

   If @error Then Return False

   DllStructSetData($_joy[$_joyHnd], 1, DllStructGetSize($_joy[$_joyHnd]), 1)
   DllStructSetData($_joy[$_joyHnd], 1, 255, 2)
   Return True
EndFunc

Func _mjJoyInitView(ByRef $_joy)
   Local Const $x = 10
   $_joy[$_joyView] = GUICreate('JoyData', 170, 200)
   GUISetFont(8.5, 400, 0, "Courier New")
   GUICtrlCreateLabel("Joystick", 6 + $x, 20, 80, 20, $SS_LEFT)
   $_joy[$_joyJoyLb] = GUICtrlCreateLabel("01", 66 + $x, 20, 14, 20, $SS_LEFT)
   GUICtrlCreateLabel('X(1):' & @CRLF & 'Y(2):' & @CRLF & 'Z(3):' & @CRLF & 'R(4):' & @CRLF & 'U(5):' & @CRLF & 'V(6):' & @CRLF & 'POV(7):' & @CRLF & 'Button(8):', 5 + $x, 40, 80, 140, $SS_RIGHT)
   $_joy[$_joyDataLb] = GUICtrlCreateLabel('', 90 + $x, 40, 50, 140, $SS_LEFT)
   GUICtrlCreateLabel('Port/Event:', 5 + $x, 160, 80, 20, $SS_RIGHT)
   $_joy[$_joyEventLb] = GUICtrlCreateLabel('', 90 + $x, 160, 50, 20, $SS_LEFT)
   $_joy[$_joyMinusBn] = GUICtrlCreateButton("<", 89 + $x, 20, 14, 14)
   $_joy[$_joyPlusBn] = GUICtrlCreateButton(">", 105 + $x, 20, 14, 14)
   GUISetState()
EndFunc

Func _mjJoyUpdateView(ByRef $_joy)
   GUICtrlSetData($_joy[$_joyDataLb], _
         $_joy[$_joyData] & @CRLF & $_joy[$_joyData + 1] & @CRLF & $_joy[$_joyData + 2] & @CRLF & $_joy[$_joyData + 3] & @CRLF & _
         $_joy[$_joyData + 4] & @CRLF & $_joy[$_joyData + 5] & @CRLF & $_joy[$_joyData + 6] & @CRLF & $_joy[$_joyData + 7])
   GUICtrlSetData($_joy[$_joyEventLb], $_joy[$_joyEvent])
EndFunc

Func _mjJoyUpdateData(ByRef $_joy, $iJoyPort)
   Local $ret = DllCall($WINMM, "int", "joyGetPosEx", _
         "int", $iJoyPort, _
         "ptr", DllStructGetPtr($_joy[$_joyHnd]))

   If @error Or ($ret[0] <> 0) Then
      For $i = 0 To 7
         $_joy[$_joyData + $i] = 0
      Next
      Return False
   EndIf

   $_joy[$_joyData + 0] = DllStructGetData($_joy[$_joyHnd], 1, 3)
   $_joy[$_joyData + 1] = DllStructGetData($_joy[$_joyHnd], 1, 4)
   $_joy[$_joyData + 2] = DllStructGetData($_joy[$_joyHnd], 1, 5)
   $_joy[$_joyData + 3] = DllStructGetData($_joy[$_joyHnd], 1, 6)
   $_joy[$_joyData + 4] = DllStructGetData($_joy[$_joyHnd], 1, 7)
   $_joy[$_joyData + 5] = DllStructGetData($_joy[$_joyHnd], 1, 8)
   $_joy[$_joyData + 7] = DllStructGetData($_joy[$_joyHnd], 1, 9)
   $_joy[$_joyData + 6] = DllStructGetData($_joy[$_joyHnd], 1, 11)

   Return True
EndFunc
