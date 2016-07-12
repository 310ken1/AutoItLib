#include-once
#include <Debug.au3>
#include <Array.au3>
#include "Debug.au3"

;===============================================================================
; 変数定義
;===============================================================================
; デバッグフラグ.
Global $__EventDebug = False

;===============================================================================
; 関数定義
;===============================================================================
; イベントリスナ用のハンドルを生成する
Func __EventCreateHandle()
	Local $handle[0]
	Return $handle
EndFunc   ;==>__EventCreateHandle

; イベントリスナを登録する
Func __EventRegister(ByRef $handle, Const $func)
	Local $index = _ArraySearch($handle, $func)
	If - 1 = $index Then
		_ArrayAdd($handle, $func)
	EndIf
	Return UBound($handle)
EndFunc   ;==>__EventRegister

; イベントリスナの登録を解除する
Func __EventUnregister(ByRef $handle, Const $func)
	Local $index = _ArraySearch($handle, $func)
	If Not @error Then
		_ArrayDelete($handle, $index)
	EndIf
	Return UBound($handle)
EndFunc   ;==>__EventUnregister

; イベントを通知する
Func __EventNotify(Const ByRef $handle)
	Local $count = 0
	For $i = 0 To UBound($handle) - 1
		Local $func = $handle[$i]
		__d($__EventDebug, $func)
		Call($func)
		$count += 1
	Next
	Return $count
EndFunc   ;==>__EventNotify

;===============================================================================
; テスト
;===============================================================================
Func ___EventTest1()
EndFunc   ;==>___EventTest1

Func ___EventTest2()
EndFunc   ;==>___EventTest2

Func ___EventTest()
	Global $___EventTestHandle = __EventCreateHandle()
	; 1件登録
	_Assert('1 = __EventRegister($___EventTestHandle, "___EventTest1")')

	; 2件登録
	_Assert('2 = __EventRegister($___EventTestHandle, "___EventTest2")')

	; 重複登録
	_Assert('2 = __EventRegister($___EventTestHandle, "___EventTest1")')

	; 2件通知
	_Assert('2 = __EventNotify($___EventTestHandle)')

	; 1件削除
	_Assert('1 = __EventUnregister($___EventTestHandle, "___EventTest1")')

	; 2件削除
	_Assert('0 = __EventUnregister($___EventTestHandle, "___EventTest2")')

	; 重複削除
	_Assert('0 = __EventUnregister($___EventTestHandle, "___EventTest2")')

	; 0件通知
	_Assert('0 = __EventNotify($___EventTestHandle)')
EndFunc   ;==>___EventTest

If "Event.au3" = @ScriptName Then
	___EventTest()
EndIf
