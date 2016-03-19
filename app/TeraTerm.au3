#include-once
#include <Debug.au3>
#include "..\utility\Debug.au3"

;===============================================================================
; 定数定義
;===============================================================================
; デバッグログフラグ.
Global $TeraTermDebug = False

; ttpmacro.exe へのパス.
Global $TeraTermMacro = "ttpmacro.exe"

; Macro実行ダイアログのウィンドウ名(接頭文字列).
Const $TeraTermMacroTitle = "MACRO - "

;===============================================================================
; 関数定義
;===============================================================================
; TeraTermを実行ファイルに同梱する.
Func __TeraTermInclude(Const $path)
	DirCreate($path)
	FileInstall("ttermpro.exe", $path)
	FileInstall("ttpmacro.exe", $path)
	FileInstall("ttpcmn.dll", $path)
	FileInstall("ttpdlg.dll", $path)
	FileInstall("ttpfile.dll", $path)
	FileInstall("ttpset.dll", $path)
	FileInstall("ttxssh.dll", $path)
	FileInstall("TERATERM.INI", $path)
	$TeraTermMacro = $path & "\ttpmacro.exe"
EndFunc   ;==>__TeraTermInclude

; TeraTerm Macroを実行する.
; Macro実行中はダイアログが表示され, Macro実行完了後にクローズされる.
Func __TeraTermMacroRun(Const $ttl)
	Local $cmd = StringFormat("%s %s", $TeraTermMacro, $ttl)
	__d($TeraTermDebug, $cmd)
	Run($cmd)
	WinWaitActive($TeraTermMacroTitle)
EndFunc   ;==>__TeraTermMacroRun

; TeraTerm Macroを実行し、実行が完了するまでスクリプト処理を一時停止する.
; Macro実行中はダイアログが表示され, Macro実行完了後にクローズされる.
Func __TeraTermMacroRunWait(Const $ttl)
	Local $cmd = StringFormat("%s %s", $TeraTermMacro, $ttl)
	__d($TeraTermDebug, $cmd)
	RunWait($cmd)
EndFunc   ;==>__TeraTermMacroRunWait

; TeraTerm Macroの実行が終了するまで待つ.
Func __TeraTermMacroWaitClose()
	WinWaitClose($TeraTermMacroTitle)
EndFunc   ;==>__TeraTermMacroWaitClose

;===============================================================================
; テスト
;===============================================================================
Func __TeraTermTestMacroRun()
	Local $time = TimerInit()
	Local $ttl = '"' & @ScriptDir & '\test.ttl' & '"'
	__TeraTermMacroRun($ttl)
	__TeraTermMacroWaitClose()
	Return Ceiling(TimerDiff($time) / 1000)
EndFunc   ;==>__TeraTermTestMacroRun

Func __TeraTermTestMacroRunWait()
	Local $time = TimerInit()
	Local $ttl = '"' & @ScriptDir & '\test.ttl' & '"'
	__TeraTermMacroRunWait($ttl)
	Return Ceiling(TimerDiff($time) / 1000)
EndFunc   ;==>__TeraTermTestMacroRunWait

Func __TeraTermTest()
	_Assert('1 < __TeraTermTestMacroRun()')
	_Assert('1 < __TeraTermTestMacroRunWait()')
EndFunc   ;==>__TeraTermTest

If "TeraTerm.au3" = @ScriptName Then
	__TeraTermTest()
EndIf
