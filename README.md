# macroJoy
Control programs by joystick or joypad - Autoit script (Windows)

In the configuration file macroJoy.cfg you can define your macros. A macro has two parts, a button sequence-line and the commands-line. If all buttons of a sequence-line (one by one or simultaneously, depending on pushType) are pressed, the functions in the commands-line will be invoked. The following functions are currently available: sendkey, run, focus, killproc, cursor, sleep. If you like you can add some custom functions in includes/functions.au3. Below you will find a configuration example and a brief description.
The program resides in the system tray. Use the menu item Check JoyData to test your macros or see the joystick button codes. 


