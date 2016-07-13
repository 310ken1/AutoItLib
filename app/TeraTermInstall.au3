#include-once
#include "TeraTerm.au3"

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
