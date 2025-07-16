
    ^E:: return ; Blocks Ctrl+E in case Hotkey() shouldn't work

;----------------------------------------------------------------
; Script requires AutoHotkey version 2.0 or higher
;----------------------------------------------------------------
#Requires AutoHotkey v2.0

;----------------------------------------------------------------
; Global variables initialization
;----------------------------------------------------------------
input_box_title := "Paste Tab-Separated Table"
global contenuto := []
 ; Store the current clipboard content
 global oldclip 
 global notifGui := ""
 
 ;----------------------------------------------------------------
; GUI creation
;----------------------------------------------------------------
; Create GUI
tableGui := Gui("+AlwaysOnTop", input_box_title)
tableGui.OnEvent("Close", CancelAndExit) 
tableGui.Add("Text",, "Paste your tab-separated data here:")
tableGui.Add("Edit", "w400 h200 vUserText WantTab")  ; Multiline Edit control
tableGui.Add("Button", "w180 Default", "Convert and Send").OnEvent("Click", Convert)
tableGui.Add("Button", "x+10 w70", "Cancel").OnEvent("Click", CancelAndExit)
tableGui.Show()


; Keyboard hook: intercepts Ctrl+Enter while the GUI is active
#HotIf WinActive(input_box_title)
^Enter::Convert()  ; Ctrl+Enter calls the Convert() function
Esc::{
    if IsSet(oldclip)
        A_Clipboard := oldclip
    ExitApp
} ;exit From GUI 

#HotIf

;----------------------------------------------------------------
; Function to convert and send data
;----------------------------------------------------------------
; Function to convert and send data
Convert(*) {
    global tableGui, contenuto

 

     oldclip := A_Clipboard


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
    

   ShowNotification(msg) {
    global notifGui

    ; Se esiste una notifica precedente, distruggila
    if IsObject(notifGui)
        notifGui.Destroy()
    ;winactive:= WinGetTitle("A")
    notifGui := Gui("-Caption +AlwaysOnTop +ToolWindow", "")
    notifGui.BackColor := "313131"
    ;notifGui.Add("Text", "w300 h50 Center", msg)
    notifGui.SetFont("s10", "Segoe UI")  ; Font più grande: s14 = size 14, puoi aumentare a piacere
    notifGui.Add("Text", "Left cWhite", msg)
    

    ; Primo Show con AutoSize per calcolare larghezza e altezza reali
    notifGui.Show("AutoSize NA")  ; NA = NoActivate

    ; Ottieni dimensioni reali della GUI
    WinGetPos(,, &winW, &winH, notifGui.Hwnd)

    ; Calcola nuova posizione: basso a destra
    x := A_ScreenWidth - winW - 20
    y := A_ScreenHeight - winH - 50

    ; Sposta la finestra nella nuova posizione
    notifGui.Move(x, y)

   

    ;SetTimer(() => notifGui.Destroy(), -3000)  ; Chiude dopo 3 secondi
}
     global totalitems := 0
 
    for arrcount in contenuto{
       
        global totalItems += arrcount.Length
    }
    

    ; Iterate through the data array
    for index,arr in contenuto {
        ;Calcolo del numero totale di item (somma di tutti gli elementi nei sotto-array)
           sleep 100
   
        for subvalue in arr {
            ShowNotification("Waiting Ctrl+E to be pressed, remaining items: " totalitems ", next item: " subvalue)
            totalitems -= 1
            ; Wait for Ctrl+E
            Loop {
                if GetKeyState("Control", "P") && GetKeyState("e", "P") {
                    break
                }
                Sleep(10)
            }
            ; Mostra banner in basso a destra
            ;TrayTip("Waiting for Ctrl+E", "Remaining items: " totalItems, "1")  ; L'ultimo parametro è l'icon type, 1=info
            
            ShowNotification("Waiting Ctrl+E to be pressed, remaining items: " totalitems)
 
            ; Store the subvalue
            A_Clipboard := subvalue
            SendText(subvalue)
            Sleep(200)
            Send('^a')  ; Select all (for subsequent replacement?)
        }
    }

    ; Restore the original clipboard content
    A_Clipboard := oldclip
    MsgBox("Processo completato")
    ExitApp ;closes the script completely
}

CancelAndExit(*) {
    tableGui.Destroy()
    ExitApp
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


^Esc::{
    if IsSet(oldclip)
        A_Clipboard := oldclip
    ExitApp
}