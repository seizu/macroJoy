# macroJoy
Control programs by joystick or joypad - Autoit script (Windows)

In the configuration file macroJoy.cfg you can define your macros. A macro has two parts, a button sequence-line and the commands-line. If all buttons of a sequence-line (one by one or simultaneously, depending on pushType) are pressed, the functions in the commands-line will be invoked. The following functions are currently available: sendkey, run, focus, killproc, cursor, sleep. If you like you can add some custom functions in includes/functions.au3. Below you will find a configuration example and a brief description.
The program resides in the system tray. Use the menu item Check JoyData to test your macros or see the joystick button codes. 

Example config

```
[config]

;sequenceNN:        process;pushType;joynum;time;joyid,code;joyid,code,...
    ;process:           0=ignore process / processID or process name e.g.: notepad.exe
    ;pushType:          1=simultaneous, 2=one by one
    ;JoyPort:           1-15
    ;time(pushType 1):  [idle-repeat time in ms] or 0=off / (pushType 2): [timeout in ms] or 0=no timeout
    ;joyid:             1-8
    ;code:              integer value


;commandNN:             func,para1,para2,...;func,para1,para2,...
    ;functions
        ;sleep          pause execution                       para1: time in ms
        ;sendKey        simulate keystrokes                   para1: sequence of keys / para2(opt): 0=default 1=send raw  (see autoit docs "send" for details)
        ;focusA         focus to the specified window name    para1: window name
        ;killpidfile    kill process from pid-file            para1: text file with a process id
        ;focusB         focus to the specified window name    para1: window name (Works better, but may be unavailable in subsequent versions of Windows.)
        ;killproc       kill process by name or process id    para1: process name or process id
        ;run            run a program                         para1: program name / para2(opt): show_flag / para3(opt): opt_flag  (see autoit docs "run" for details)
        ;cursor         hide/set or toggle mouse cursor       para1: 0=hide 1=show 2=toggle

sequence01=0;2;1;2000;8,128;8,0;8,64
command01=sendKey,!{F4},0;sleep,1000;sleep,5000;focusA,Kodi

sequence02=0;2;2;3000;8,128;8,0;8,128;8,0;8,64;8,0;8,64
command02=sendKey,{F2},0

;XINPUT: <Start>
sequence03=ccs64.exe;1;1;0;8,128
command03=sendKey,{ESC down},0;sleep,100;sendKey,{ESC up},0

;XINPUT: <Square>
sequence04=ccs64.exe;1;1;0;8,4
command04=sendKey,{z down},0;sleep,100;sendKey,{z up},0

;XINPUT: <R1>+<D-Up>
sequence05=ccs64.exe;1;1;0;8,32;7,0
command05=sendKey,{F1 down},0;sleep,300;sendKey,{F1 up},0

;XINPUT: <R1>+<D-Right>
sequence06=ccs64.exe;1;1;0;8,32;7,9000
command06=sendKey,{F3 down},0;sleep,300;sendKey,{F3 up},0

;XINPUT: <L3> Toggle Mouse Cursor On/Off
sequence07=0;1;1;0;8,256
command07=cursor,2

;XINPUT: <R3> Run Notepad and open desktop.ini, killproc after 3 seconds
sequence08=0;1;1;0;8,512
command08=run,notepad.exe "%USERPROFILE%\Desktop\desktop.ini",c:\;sleep,3000;killproc,notepad.exe
``` 
