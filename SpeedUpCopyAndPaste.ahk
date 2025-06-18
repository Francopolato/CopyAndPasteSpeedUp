;----------------------------------------------------------------
; Script requires AutoHotkey version 2.0 or higher
;----------------------------------------------------------------
#Requires AutoHotkey v2.0

;----------------------------------------------------------------
; Global variables initialization
;----------------------------------------------------------------
input_box_title := "Paste Tab-Separated Table"
global contenuto := []

;----------------------------------------------------------------
; GUI creation
;----------------------------------------------------------------
; Create GUI
tableGui := Gui("+AlwaysOnTop", input_box_title)
tableGui.Add("Text",, "Paste your tab-separated data here:")
tableGui.Add("Edit", "w400 h200 vUserText WantTab")  ; Multiline Edit control
tableGui.Add("Button", "w180 Default", "Convert and Send").OnEvent("Click", Convert)
tableGui.Add("Button", "x+10 w70", "Cancel").OnEvent("Click", (*) => tableGui.Destroy())
tableGui.Show()

; Keyboard hook: intercepts Ctrl+Enter while the GUI is active
#HotIf WinActive(input_box_title)
^Enter::Convert()  ; Ctrl+Enter calls the Convert() function
#HotIf

;----------------------------------------------------------------
; Function to convert and send data
;----------------------------------------------------------------
; Function to convert and send data
Convert(*) {
    global tableGui, contenuto

    userText := tableGui.Submit(false).UserText

    if (userText = "") {
        MsgBox("No input provided.", "Error")
        return
    }

    lines := StrSplit(userText, "`n", "`r")
    dataArray := []

    for line in lines {
        fields := StrSplit(line, "`t")
        dataArray.Push(fields)
    }

    contenuto := dataArray
    tableGui.Destroy()

    ; Store the current clipboard content
    oldclip := A_Clipboard
    A_Clipboard := ""

    ; Iterate through the data array
    for arr in contenuto {
        for subvalue in arr {
            ; Wait for Ctrl+V
            Loop {
                if GetKeyState("Control", "P") && GetKeyState("v", "P") {
                    break
                }
                Sleep(10)
            }

            ; Send the subvalue
            Send(subvalue)
            Sleep(350)
            Send('^a')  ; Select all (for subsequent replacement?)
        }
    }

    ; Restore the original clipboard content
    A_Clipboard := oldclip
    MsgBox("Processo completato")
    ExitApp ;closes the script completely
}

;----------------------------------------------------------------
; Function to repeat a string
;----------------------------------------------------------------
; Function to repeat a string
RepeatString(str, count) {
    result := ""
    Loop count
        result .= str
    return result
}

;----------------------------------------------------------------
; Function to format array (if you ever want to see it)
;----------------------------------------------------------------
; Function to format array (if you ever want to see it)
FormatArray(arr, indent := 0) {
    local s := ""
    local indentStr := RepeatString("  ", indent)
    if !IsObject(arr)
        return indentStr . arr . "`n"

    s .= indentStr . "[" . "`n"
    ; Iterate through the array items
    for item in arr {
        if IsObject(item)
            s .= FormatArray(item, indent + 1)
        else
            s .= indentStr . "  " . item . "`n"
    }
    s .= indentStr . "]`n"
    return s
}
