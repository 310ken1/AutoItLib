#include-once
#include <Debug.au3>

;===============================================================================
; 関数定義
;===============================================================================
; 改行コードを付加し, コンソールに出力する.
Func __p(Const $str)
	Return ConsoleWrite($str & @CRLF) - StringLen(@CRLF)
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
	_Assert('4 = __p("test")')
	_Assert('7 = __d(True, "_d true")')
	_Assert('0 = __d(False, "_d false")')
EndFunc   ;==>__DebugTest

If "Debug.au3" = @ScriptName Then
	__DebugTest()
EndIf
