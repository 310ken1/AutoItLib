#include-once
#include <Debug.au3>
#include <Array.au3>
#include "Debug.au3"
#include "Event.au3"

;===============================================================================
; 定数定義
;===============================================================================
; 監視対象に関する情報のインデックス.
Local Const $___PROCESS_ID = 0
Local Const $___PROCESS_HANDLE = 1

;===============================================================================
; 変数定義
;===============================================================================
; デバッグフラグ.
Global $__ProcessDebug = False

; 監視対象に関する情報を保持する配列.
; 1つの要素に, プロセス番号とイベントリスナ用のハンドルが格納される.
Local $___ProcessInfo[0]

;===============================================================================
; 関数定義
;===============================================================================
; プロセス終了の監視を依頼する.
; プロセスが終了すると, 引数で指定した関数が呼ばれる.
Func __ProcessObserve(Const $process, Const $func)
	Local $end = UBound($___ProcessInfo)
	Local $index = ___ProcessSearch($process)
	If - 1 < $index Then
		Local $set = $___ProcessInfo[$index]
		__EventRegister($set[$___PROCESS_HANDLE], $func)
	Else
		___ProcessAdd($process, $func)
	EndIf

	If 0 = $end Then
		__d($__ProcessDebug, "___ProcessObserver Start")
		AdlibRegister("___ProcessObserver", 1000)
	EndIf
EndFunc   ;==>__ProcessObserve

;===============================================================================
; 内部関数定義
;===============================================================================
; 監視対象に関する情報へのインデックスを取得する.
Func ___ProcessSearch(Const $process)
	Local $index = -1
	For $i = 0 To UBound($___ProcessInfo) - 1
		Local $set = $___ProcessInfo[$i]
		If $set[$___PROCESS_ID] = $process Then
			$index = $i
			ExitLoop
		EndIf
	Next
	Return $index
EndFunc   ;==>___ProcessSearch

; 監視対象に関する情報を追加する.
Func ___ProcessAdd(Const $process, Const $func)
	Local $end = UBound($___ProcessInfo)
	_ArrayAdd($___ProcessInfo, 0)
	Local $set[2]
	$set[$___PROCESS_ID] = $process
	$set[$___PROCESS_HANDLE] = __EventCreateHandle()
	__EventRegister($set[$___PROCESS_HANDLE], $func)
	$___ProcessInfo[$end] = $set
EndFunc   ;==>___ProcessAdd

; 監視対象に関する情報を削除する.
Func ___ProcessObserver()
	For $i = UBound($___ProcessInfo) - 1 To 0 Step -1
		Local $set = $___ProcessInfo[$i]
		If Not ProcessExists($set[$___PROCESS_ID]) Then
			__EventNotify($set[$___PROCESS_HANDLE], $set[$___PROCESS_ID])
			_ArrayDelete($___ProcessInfo, $i)
		EndIf
	Next

	If 0 = UBound($___ProcessInfo) Then
		AdlibUnRegister("___ProcessObserver")
		__d($__ProcessDebug, "___ProcessObserver Stop")
	EndIf
EndFunc   ;==>___ProcessObserver

;===============================================================================
; テスト
;===============================================================================
Local $___ProcessTestCount = 0
Func ___ProcessTestObserveOne()
	$___ProcessTestCount = 0

	Local $process = Run("timeout 3")
	__ProcessObserve($process, "___ProcessTestCallback")

	Sleep(5000)
	Return $___ProcessTestCount
EndFunc   ;==>___ProcessTestObserveOne

Func ___ProcessTestObserveTwo()
	$___ProcessTestCount = 0
	Local $process

	$process = Run("timeout 3")
	__ProcessObserve($process, "___ProcessTestCallback")

	$process = Run("timeout 3")
	__ProcessObserve($process, "___ProcessTestCallback")

	Sleep(5000)
	Return $___ProcessTestCount
EndFunc   ;==>___ProcessTestObserveTwo

Func ___ProcessTestCallback(Const $process)
	__d($__ProcessDebug, "___ProcessTestCallback(" & $process & ")")
	$___ProcessTestCount += 1
EndFunc   ;==>___ProcessTestCallback

Func ___ProcessTest()
	; 1件登録
	_Assert('1 = ___ProcessTestObserveOne()')

	; 2件登録
	_Assert('2 = ___ProcessTestObserveTwo()')
EndFunc   ;==>___ProcessTest

If "Process.au3" = @ScriptName Then
	___ProcessTest()
EndIf
