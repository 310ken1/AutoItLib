#include-once
#include <Debug.au3>
#include <Array.au3>

;===============================================================================
; 関数定義
;===============================================================================
; イベントリスナを登録する
Func __EventRegister(ByRef $listener, Const $func)
	Local $index = _ArraySearch($listener, $func)
	If - 1 = $index Then
		_ArrayAdd($listener, $func)
	EndIf
	Return UBound($listener)
EndFunc   ;==>__EventRegister

; イベントリスナの登録を解除する
Func __EventUnregister(ByRef $listener, Const $func)
	Local $index = _ArraySearch($listener, $func)
	If Not @error Then
		_ArrayDelete($listener, $index)
	EndIf
	Return UBound($listener)
EndFunc   ;==>__EventUnregister

; イベントを通知する
Func __EventNotify(Const ByRef $listener)
	For $i = 0 To UBound($listener) - 1
		Call($listener[$i])
	Next
	Return UBound($listener)
EndFunc   ;==>__EventNotify

;===============================================================================
; テスト
;===============================================================================
Func __EventFunc1()
EndFunc   ;==>__EventFunc1
Func __EventFunc2()
EndFunc   ;==>__EventFunc2

Func __EventTest()
	Global $__EventListener[0]
	_Assert('1 = __EventRegister($__EventListener, "__EventFunc1")')
	_Assert('0 = __EventUnregister($__EventListener, "__EventFunc1")')
	_Assert('1 = __EventRegister($__EventListener, "__EventFunc1")')
	_Assert('2 = __EventRegister($__EventListener, "__EventFunc2")')
	_Assert('2 = __EventNotify($__EventListener)')
EndFunc   ;==>__EventTest

If "Event.au3" = @ScriptName Then
	__EventTest()
EndIf
