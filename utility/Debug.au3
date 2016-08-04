#include-once
#include <Debug.au3>

;===============================================================================
; 変数定義
;===============================================================================
; テスト用のグローバル変数
Global $__DebugGlobal

;===============================================================================
; 関数定義
;===============================================================================
; 改行コードを付加し, コンソールに出力する.
Func __p(Const $str)
	Local $time = @HOUR & ":" & @MIN & ":" & @SEC & ":" & @MSEC & " "
	Return ConsoleWrite($time & $str & @CRLF) - StringLen(@CRLF)
EndFunc   ;==>__p

; デバッグ用のログを, 改行コードを付加し, コンソールに出力する.
Func __d(Const $enable, Const $str)
	Local $strlen = 0
	If $enable Then
		$strlen = __p($str)
	EndIf
	Return $strlen
EndFunc   ;==>__d

;===============================================================================
; テスト
;===============================================================================
Func __DebugTest()
	_Assert('17 = __p("test")')
	_Assert('20 = __d(True, "_d true")')
	_Assert('0 = __d(False, "_d false")')
EndFunc   ;==>__DebugTest

If "Debug.au3" = @ScriptName Then
	__DebugTest()
EndIf
