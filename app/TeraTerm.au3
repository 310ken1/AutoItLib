#include-once
#include <Debug.au3>
#include "..\utility\Debug.au3"

;===============================================================================
; 定数定義
;===============================================================================
; Macro実行ダイアログのウィンドウ名(接頭文字列).
Local Const $___TeraTermMacroTitle = "MACRO - "

;===============================================================================
; 変数定義
;===============================================================================
; デバッグフラグ.
Global $__TeraTermDebug = False

; ttpmacro.exe へのパス.
Global $__TeraTermMacro = "ttpmacro.exe"

;===============================================================================
; 関数定義
;===============================================================================
; TeraTerm Macroを実行する.
; Macro実行中はダイアログが表示され, Macro実行完了後にクローズされる.
Func __TeraTermMacroRun(Const $ttl)
	Local $cmd = StringFormat("%s %s", $__TeraTermMacro, $ttl)
	__d($__TeraTermDebug, $cmd)
	Run($cmd)
	WinWaitActive($___TeraTermMacroTitle)
EndFunc   ;==>__TeraTermMacroRun

; TeraTerm Macroを実行し、実行が完了するまでスクリプト処理を一時停止する.
; Macro実行中はダイアログが表示され, Macro実行完了後にクローズされる.
Func __TeraTermMacroRunWait(Const $ttl)
	Local $cmd = StringFormat("%s %s", $__TeraTermMacro, $ttl)
	__d($__TeraTermDebug, $cmd)
	RunWait($cmd)
EndFunc   ;==>__TeraTermMacroRunWait

; TeraTerm Macroの実行が終了するまで待つ.
Func __TeraTermMacroWaitClose()
	WinWaitClose($___TeraTermMacroTitle)
EndFunc   ;==>__TeraTermMacroWaitClose

;===============================================================================
; テスト
;===============================================================================
Func ___TeraTermTestMacroRun()
	Local $time = TimerInit()
	Local $ttl = '"' & @ScriptDir & '\test.ttl' & '"'
	__TeraTermMacroRun($ttl)
	__TeraTermMacroWaitClose()
	Return Ceiling(TimerDiff($time) / 1000)
EndFunc   ;==>___TeraTermTestMacroRun

Func ___TeraTermTestMacroRunWait()
	Local $time = TimerInit()
	Local $ttl = '"' & @ScriptDir & '\test.ttl' & '"'
	__TeraTermMacroRunWait($ttl)
	Return Ceiling(TimerDiff($time) / 1000)
EndFunc   ;==>___TeraTermTestMacroRunWait

Func ___TeraTermTest()
	_Assert('1 < ___TeraTermTestMacroRun()')
	_Assert('1 < ___TeraTermTestMacroRunWait()')
EndFunc   ;==>___TeraTermTest

If "TeraTerm.au3" = @ScriptName Then
	___TeraTermTest()
EndIf
