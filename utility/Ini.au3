#include-once
#include <Debug.au3>
#include <Array.au3>
#include <GuiComboBox.au3>

;===============================================================================
; 関数定義
;===============================================================================
; iniファイルからコンボリスト用のアイテムリストを読み出す
Func __IniReadComboItemList(Const $ini, Const $section, Const $key)
	Local $list = ""
	Local $count = 0
	$config = IniReadSection($ini, $section)
	If Not @error Then
		For $i = 1 To $config[0][0]
			If $config[$i][0] = $key Then
				If 0 = $count Then
					$list = $config[$i][1]
				Else
					$list = $list & "|" & $config[$i][1]
				EndIf
				$count += 1
			EndIf
		Next
	EndIf
	Return $list
EndFunc   ;==>__IniReadComboItemList

; iniファイルにコンボリスト用のアイテムリストを書き込む
Func __IniWriteComboItemList(Const $ini, Const $list, Const $section, Const $key)
	Local $item[0]
	_ArrayAdd($item, $list)
	Local $count = UBound($item)
	Local $array[$count][2]
	For $i = 0 To $count - 1
		$array[$i][0] = $key
		$array[$i][1] = $item[$i]
	Next
	IniWriteSection($ini, $section, $array, 0)
	Return $count
EndFunc   ;==>__IniWriteComboItemList

; iniファイルに定義されたアイテムをコンボリストの選択肢として設定する
Func __IniSetComboItem($hWnd, Const $ini, Const $section, Const $key)
	GUICtrlSetData($hWnd, __IniReadComboItemList($ini, $section, $key))
EndFunc   ;==>__IniSetComboItem

; iniファイルに保存された初期値をコンボリストで選択されている値にする
Func __IniReadComboItemDefault(Const $hWnd, Const $ini, Const $section, Const $key = "default")
	Local $index = _GUICtrlComboBox_FindString($hWnd, IniRead($ini, $section, $key, ""))
	_GUICtrlComboBox_SetCurSel($hWnd, $index)
EndFunc   ;==>__IniReadComboItemDefault

; iniファイルにコンボリストで選択されている値を初期値として保存する
Func __IniWriteComboItemDefault($hWnd, Const $ini, Const $section, Const $key = "default")
	IniWrite($ini, $section, $key, GUICtrlRead($hWnd))
EndFunc   ;==>__IniWriteComboItemDefault

; iniファイルに保存された初期値をチェックボックの値にする
Func __IniReadCheckDefault(Const $hWnd, Const $ini, Const $section, Const $key = "default")
	GUICtrlSetState($hWnd, IniRead($ini, $section, $key, $GUI_UNCHECKED))
EndFunc   ;==>__IniReadCheckDefault

; iniファイルにチェックボックの値を初期値として保存する
Func __IniWriteCheckDefault($hWnd, Const $ini, Const $section, Const $key = "default")
	IniWrite($ini, $section, $key, GUICtrlRead($hWnd))
EndFunc   ;==>__IniWriteCheckDefault


;===============================================================================
; テスト
;===============================================================================
Func __IniTest()
	_Assert('"value1|value2|value3" = __IniReadComboItemList("test.ini", "section1", "key")')
	_Assert('"value1||value3" = __IniReadComboItemList("test.ini", "section2", "key")')

	_Assert('3 = __IniWriteComboItemList("tmp.ini", "value1|value2|value3", "write", "key")')
	_Assert('"value1|value2|value3" = __IniReadComboItemList("tmp.ini", "write", "key")')
	FileDelete("tmp.ini")
EndFunc   ;==>__IniTest

If "Ini.au3" = @ScriptName Then
	__IniTest()
EndIf
