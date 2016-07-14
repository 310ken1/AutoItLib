#include-once
#include <Debug.au3>
#include "Debug.au3"
#include "Process.au3"

;===============================================================================
; 変数定義
;===============================================================================
; デバッグフラグ.
Global $__CmdDebug = False

;===============================================================================
; 関数定義
;===============================================================================
; コマンドプロンプトからプログラムを実行し、プロセス番号を取得する.
Func __CmdRun(Const $command, Const $func = "")
	Local $cmd = @ComSpec & ' /c "' & $command & '"'
	__d($__CmdDebug, $cmd)
	Local $process = Run($cmd, "", @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD + $STDERR_CHILD)
	If "" <> $func Then
		__ProcessObserve($process, $func)
	EndIf
	Return $process
EndFunc   ;==>__CmdRun

; コマンドプロンプトから実行したプログラムの終了処理を行う.
Func __CmdClose(Const $process)
	StdioClose($process)
EndFunc   ;==>__CmdClose

; コマンドプロンプトから実行したプログラムの終了処理を行い、
; コマンドのレスポンスを返す.
Func __CmdResp(Const $process)
	Local $out = ""
	Do
		$out &= StdoutRead($process)
	Until @error
	__CmdClose($process)
	__d($__CmdDebug, $out)
	Return $out
EndFunc   ;==>__CmdResp

; コマンドプロンプトからプログラムを実行し、レスポンスを取得する.
Func __CmdRunWait(Const $command)
	Local $process = __CmdRun($command)
	ProcessWaitClose($process)
	Return __CmdResp($process)
EndFunc   ;==>__CmdRunWait

;===============================================================================
; テスト
;===============================================================================
Func ___CmdTestEnd(Const $process)
	__d($__CmdDebug, "___CmdEnd(" & $process & ")")
EndFunc   ;==>___CmdEnd

Func ___CmdTest()
	; 非同期実行(終了通知なし)
	_Assert("0 < __CmdRun('echo test')")

	; 非同期実行(終了通知あり)
	_Assert("0 < __CmdRun('echo test', '___CmdTestEnd')")

	Sleep(1000)

	; 同期実行
	_Assert("'test' & @CRLF = __CmdRunWait('echo test')")
EndFunc   ;==>___CmdTest

If "Cmd.au3" = @ScriptName Then
	___CmdTest()
EndIf
