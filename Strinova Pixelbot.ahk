init:
#NoEnv
#SingleInstance, Force
#Persistent
#InstallKeybdHook
#UseHook
#KeyHistory, 0
#HotKeyInterval 1
#MaxHotkeysPerInterval 127

RunAsAdmin()

if (FileExist("pixelbotcfg.ini")) 
{
}
Else
{
    IniWrite, 0xA5A528, pixelbotcfg.ini, main, EMCol
    IniWrite, 20, pixelbotcfg.ini, main, ColVn
}

IniRead, EMCol, pixelbotcfg.ini, main, EMCol
IniRead, ColVn, pixelbotcfg.ini, main, ColVn

toggle = 1
toggle2 = 1

; Variables for toggling Mouse4 and Mouse5
XButton1Active := false
XButton2Active := false

AntiShakeX := (A_ScreenHeight // 160)
AntiShakeY := (A_ScreenHeight // 128)
ZeroX := (A_ScreenWidth // 2)
ZeroY := (A_ScreenHeight // 2)
CFovX := (A_ScreenWidth // 40)
CFovY := (A_ScreenHeight // 64)
ScanL := ZeroX - CFovX
ScanT := ZeroY
ScanR := ZeroX + CFovX
ScanB := ZeroY + CFovY
NearAimScanL := ZeroX - AntiShakeX
NearAimScanT := ZeroY - AntiShakeY
NearAimScanR := ZeroX + AntiShakeX
NearAimScanB := ZeroY + AntiShakeY

Gui Add, Text, cBlue, Strinova Pixelbot
Gui Add, Text, cPurple, Press F2 to activate
Gui Add, Text, cBlack, Toggle Mouse4 for aimbot
Gui Add, Text, cBlack, Toggle Mouse5 for triggerbot
Gui show

Gui 2: Color, EEAA99
Gui 2: Font, S72, Arial Black

Gui 2: Add, GroupBox, w100 h250 cFFB10F BackgroundTrans,
Gui 2: +LastFound +AlwaysOnTop +ToolWindow
WinSet, TransColor, EEAA99
Gui 2: -Caption

~F2::
SoundBeep, 750, 500

SetKeyDelay,-1, 1
SetControlDelay, -1
SetMouseDelay, -1
SendMode, InputThenPlay
SetBatchLines,-1
SetWinDelay,-1
ListLines, Off
CoordMode, Pixel, Screen, RGB
CoordMode, Mouse, Screen
PID := DllCall("GetCurrentProcessId")
Process, Priority, %PID%, High

Loop {
    ; Triggerbot logic (Mouse5 toggle)
    if (XButton2Active) {
        PixelSearch, AimPixelX, AimPixelY, NearAimScanL, NearAimScanT, NearAimScanR, NearAimScanB, EMCol, ColVn, Fast RGB
        if (ErrorLevel = 0) {
            Loop, 1 {
                Send {Lbutton down}
                Sleep, 1
                Send {Lbutton up}
            }
        }
    }

    ; Aimbot logic (Mouse4 toggle)
    if (XButton1Active) {
        PixelSearch, AimPixelX, AimPixelY, ScanL, ScanT, ScanR, ScanB, EMCol, ColVn, Fast RGB
        if (ErrorLevel = 0) {
            AimX := AimPixelX - ZeroX
            AimY := AimPixelY - ZeroY
            DirX := (AimX > 0 ? 1 : -1)
            DirY := (AimY > 0 ? 1 : -1)
            AimOffsetX := Abs(AimX)
            AimOffsetY := Abs(AimY)
            MoveX := Floor(Sqrt(AimOffsetX)) * DirX
            MoveY := Floor(Sqrt(AimOffsetY)) * DirY
            DllCall("mouse_event", uint, 1, int, MoveX * 1, int, MoveY, uint, 0, int, 0)
        }
    }
}
return

; Toggle Mouse4 (Aimbot)
~XButton1::
XButton1Active := !XButton1Active
SoundBeep, % (XButton1Active ? 1000 : 500), 200
return

; Toggle Mouse5 (Triggerbot)
~XButton2::
XButton2Active := !XButton2Active
SoundBeep, % (XButton2Active ? 1000 : 500), 200
return

Home::
if (toggle2 = 0) {
    toggle2 := 1
    Gui Hide
} Else {
    toggle2 := 0
    Gui Show
}
return

action1:
if (toggle = 0) {
    toggle := 1
    Gui 2: Hide
} Else {
    toggle := 0
    Gui 2: Show
}
return

RunAsAdmin() {
    Global 0
    IfEqual, A_IsAdmin, 1, Return 0

    Loop, %0%
        params .= A_Space . %A_Index%

    DllCall("shell32\ShellExecute" (A_IsUnicode ? "" : "A"), uint, 0, str, "RunAs", str, (A_IsCompiled ? A_ScriptFullPath : A_AhkPath), str, (A_IsCompiled ? "" : """" . A_ScriptFullPath . """" . A_Space) params, str, A_WorkingDir, int, 1)
    ExitApp
}

end::
ExitApp
return

Quitter:
ExitApp

GuiClose:
ExitApp
