Global $maxMacros    = 30
Global $_mjProcess   = 0
Global $_mjPushType  = 1
Global $_mjJoyPort   = 2
Global $_mjTime      = 3
Global $_mjSequence  = 4
Global $_mjDeltaTime = 5
Global $_mjCount     = 6
Global $_mjSize      = 7

Func _mjInitConfig(ByRef $seq, ByRef $cmd)
   Local $settings = 'macroJoy.cfg'
   Local $s, $c
   Local $tmp

   For $t = 0 To $maxMacros - 1
      $s = IniRead($settings, "config", "sequence" & StringFormat("%02d", $t + 1), "")
      $c = IniRead($settings, "config", "command" & StringFormat("%02d", $t + 1), "")
      If ($s = "") Or ($c = "") Then ExitLoop
      $c = _mjPrepFile($c)
      ConsoleWrite($s & @CRLF & $c & @CRLF)
      $tmp = StringSplit($s, ";", $STR_NOCOUNT)
      ReDim $seq[($t + 1) * $_mjSize]

      $seq[$t * $_mjSize + $_mjProcess] = $tmp[$_mjProcess]
      $seq[$t * $_mjSize + $_mjPushType] = $tmp[$_mjPushType]
      $seq[$t * $_mjSize + $_mjJoyPort] = $tmp[$_mjJoyPort]
      $seq[$t * $_mjSize + $_mjTime] = $tmp[$_mjTime]
      Local $ff[0]
      _ArrayConcatenate($ff, $tmp, $_mjSequence)
      $seq[$t * $_mjSize + $_mjSequence] = $ff
      $seq[$t * $_mjSize + $_mjDeltaTime] = 0 ; add extra space for timing
      $seq[$t * $_mjSize + $_mjCount] = 0 ; add extra space for count

      $tmp = StringSplit($c, ";", $STR_NOCOUNT)
      ReDim $cmd[$t + 1]
      $cmd[$t] = $tmp
   Next
   Return $t
EndFunc

;-------

Func _mjPrepFile($file)
   $file = StringReplace($file, '%USERPROFILE%', @UserProfileDir)
   $file = StringReplace($file, '%APPDATA%', @AppDataDir)
   $file = StringReplace($file, '%TEMP%', @TempDir)
   $file = StringReplace($file, '%PROGRAMFILES%', @ProgramFilesDir)
   $file = StringReplace($file, '%PROGRAMFILES(X86)%', @ProgramFilesDir & ' (x86)')
   Return $file
EndFunc