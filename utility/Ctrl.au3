#include-once
#include <GUIConstantsEx.au3>
#include <Debug.au3>
#include <Array.au3>
#include "Debug.au3"
Opt("GUIOnEventMode", 1)

;===============================================================================
; 定数定義
;===============================================================================
; __CtrlBuilder()で指定するコントロール定義のインデックス
Global Const $__CtrlBuilder_INDEX_CTRL = 0
Global Const $__CtrlBuilder_INDEX_TEXT = 1
Global Const $__CtrlBuilder_INDEX_FUNC = 2
Global Const $__CtrlBuilder_INDEX_KEY = 3
Global Const $__CtrlBuilder_INDEX_CHILD = 4
Global Const $__CtrlBuilder_INDEX_STATE = 5
Global Const $__CtrlBuilder_INDEX_WEIGHT = 6
Global Const $__CtrlBuilder_INDEX_HEIGHT = 7
Global Const $__CtrlBuilder_INDEX_ID = 8
Global Const $__CtrlBuilder_INDEX_MAX = 9

; コントロール定義の行の範囲インデックス
Local Const $___CtrlBuilder_INDEX_RANGE_START = 0
Local Const $___CtrlBuilder_INDEX_RANGE_END = 1
Local Const $___CtrlBuilder_INDEX_RANGE_MAX = 2

; Save/Restore対象のインデックス
Local Const $__CtrlSave_INDEX_ID = 0
Local Const $__CtrlSave_INDEX_CTRL = 1
Local Const $__CtrlSave_INDEX_FILE = 2
Local Const $__CtrlSave_INDEX_SECTION = 3
Local Const $__CtrlSave_INDEX_KEY = 4
Local Const $__CtrlSave_INDEX_MAX = 5

;===============================================================================
; 変数定義
;===============================================================================
; デバッグフラグ
Global $__CtrlDebug = False

; コントロールの高さのデフォルト値
Global $__CtrlHeight = 30

; 区切りの高さのデフォルト値
Global $__CtrlDelimiterHeight = 0

; コントロールの重みのデフォルト値
Global $__CtrlWeight = 1

; グループコントロールのマージン
Global $__CtrlGroupTopMargin = 18
Global $__CtrlGroupButtomMargin = 8
Global $__CtrlGroupSideMargin = 5

; 設定値保存用のiniファイル名
Global $__CtrlIniFile = @ScriptDir & "\" & @ScriptName & ".ini"
Global $__CtriIniSection = "CtrlBuilder"

; Save/Restore対象
Local $__CtrlSaveItem[0]

;===============================================================================
; 関数定義
;===============================================================================
; コントロール定義に従いコントロールを配置する.
; コントロール定義は, 以下の順に記述した配列を指定する.
;   Control Text Function Key Child State Weight Height
;     Control  : Control名
;     Text     : テキスト
;     Function : イベント発生時のコールバック関数名
;     Key      : 設定値を保存するキー名
;     Child    : 子のコントロール定義
;     State    : コントロールの状態
;     Weight   : コントロールの横幅の割合
;     Height   : コントロールの高さ
; 次の指定は特殊な配置が行われる.
;   [-1] : 行区切り
;   []   : 空所
Func __CtrlBuilder(ByRef $items, Const $x, Const $y, Const $width, Const $space = 0)
	Local $ctrl_x = $x
	Local $ctrl_y = $y
	Local $ctrl_count = ___CtrlColCount($items, 0)
	Local $weight_max = ___CtrlColWeightMax($items, 0)
	Local $index = 0
	For $i = 0 To UBound($items) - 1
		$index += 1
		Local $ctrl = $items[$i][$__CtrlBuilder_INDEX_CTRL]
		Local $text = $items[$i][$__CtrlBuilder_INDEX_TEXT]
		Local $weight = ___CtrlItemWeight($items, $i)
		Local $height = ___CtrlItemHeight($items, $i)
		Local $state = $items[$i][$__CtrlBuilder_INDEX_STATE]
		Local $key = $items[$i][$__CtrlBuilder_INDEX_KEY]
		Local $func = $items[$i][$__CtrlBuilder_INDEX_FUNC]
		Local $child = $items[$i][$__CtrlBuilder_INDEX_CHILD]
		Local $ctrl_width = $width / $weight_max * $weight - (($space * ($ctrl_count - 1)) / $ctrl_count)
		Local $group = "GUICtrlCreateGroup" = $ctrl
		__d($__CtrlDebug, "==== " & $ctrl & " " & $text & " =====")
		If ___CtrlIsColDelimiter($items, $i) Then
			$index = 0
			$ctrl_x = $x
			$ctrl_y += ___CtrlBuilderColHeight($items, $i - 1) + $height
			$weight_max = ___CtrlColWeightMax($items, $i + 1)
		EndIf
		If "" <> $ctrl Then
			Local $ctrl_height = $height
			If $group Then
				$ctrl_height = __CtrlBuilderHeight($child) _
						 + $__CtrlGroupTopMargin + $__CtrlGroupButtomMargin
			EndIf
			Local $id = Call($ctrl, _
					"", $ctrl_x, $ctrl_y, $ctrl_width, $ctrl_height)
			GUICtrlSetData($id, $text)
			GUICtrlSetState($id, $state)
			GUICtrlSetOnEvent($id, $func)
			$items[$i][$__CtrlBuilder_INDEX_ID] = $id
			If IsString($key) And "" <> $key Then
				__CtrlAddSaveItem($id, $ctrl, $__CtrlIniFile, $__CtriIniSection, $key)
			EndIf
		EndIf
		If IsArray($child) Then
			Local $group_x = $ctrl_x
			Local $group_y = $ctrl_y
			Local $gorup_width = $ctrl_width
			If $group Then
				$group_x += $__CtrlGroupSideMargin
				$group_y += $__CtrlGroupTopMargin
				$gorup_width -= ($__CtrlGroupSideMargin * 2)
			EndIf
			__CtrlBuilder($items[$i][$__CtrlBuilder_INDEX_CHILD], $group_x, $group_y, $gorup_width)
			$ctrl_x += $ctrl_width + $space
		EndIf
		If $group Then
			GUICtrlCreateGroup("", -99, -99, 1, 1)
		Else
			$ctrl_x += $ctrl_width + $space
		EndIf
	Next
EndFunc   ;==>__CtrlBuilder

; コントロールの高さを取得する.
Func __CtrlBuilderHeight(ByRef Const $items, Const $start = 0, Const $end = UBound($items) - 1)
	Local $ctrl_height = 0
	Local $child_height = 0
	Local $col_height = 0
	For $i = $start To $end
		Local $child = $items[$i][$__CtrlBuilder_INDEX_CHILD]
		Local $height = ___CtrlItemHeight($items, $i)
		If IsArray($child) Then
			Local $h = __CtrlBuilderHeight($child)
			$h += $__CtrlGroupTopMargin + $__CtrlGroupButtomMargin
			If $child_height < $h Then
				$child_height = $h
			EndIf
		EndIf
		If $col_height < $height Then
			$col_height = $height
		EndIf
		If ___CtrlIsColDelimiter($items, $i) Or ($i = $end) Then
			If ___CtrlIsColDelimiter($items, $i) Then
				$ctrl_height += $height
			EndIf
			If $col_height < $child_height Then
				$ctrl_height += $child_height
			Else
				$ctrl_height += $col_height
			EndIf
			$col_height = 0
			$child_height = 0
		EndIf
	Next
	__d($__CtrlDebug, "__CtrlBuilderHeight(start=" & $start & ", end=" & $end & ") return=" & $ctrl_height)
	Return $ctrl_height
EndFunc   ;==>__CtrlBuilderHeight

; Save/Restore対象を登録する.
Func __CtrlAddSaveItem(Const $id, Const $ctrl, Const $file, Const $section, Const $key)
	Local $end = UBound($__CtrlSaveItem)
	_ArrayAdd($__CtrlSaveItem, 0)
	Local $item[$__CtrlSave_INDEX_MAX]
	$item[$__CtrlSave_INDEX_ID] = $id
	$item[$__CtrlSave_INDEX_CTRL] = $ctrl
	$item[$__CtrlSave_INDEX_FILE] = $file
	$item[$__CtrlSave_INDEX_SECTION] = $section
	$item[$__CtrlSave_INDEX_KEY] = $key
	$__CtrlSaveItem[$end] = $item

	If 1 = UBound($__CtrlSaveItem) Then
		OnAutoItExitRegister("__CtrlSave")
	EndIf
EndFunc   ;==>__CtrlAddSaveItem

; Save/Restore対象を削除する.
Func __CtrlRemoveSaveItem(Const $id, Const $ctrl)
	For $i = UBound($__CtrlSaveItem) - 1 To 0 Step -1
		If ($id = ($__CtrlSaveItem[$i])[$__CtrlSave_INDEX_ID]) And _
				($ctrl = ($__CtrlSaveItem[$i])[$__CtrlSave_INDEX_CTRL]) Then
			_ArrayDelete($__CtrlSaveItem, $i)
		EndIf
	Next

	If 0 = UBound($__CtrlSaveItem) Then
		OnAutoItExitUnRegister("__CtrlSave")
	EndIf
EndFunc   ;==>__CtrlRemoveSaveItem

; Save/Restore対象の設定値をSaveする.
Func __CtrlSave()
	For $i = 0 To UBound($__CtrlSaveItem) - 1
		Local $id = ($__CtrlSaveItem[$i])[$__CtrlSave_INDEX_ID]
		Local $file = ($__CtrlSaveItem[$i])[$__CtrlSave_INDEX_FILE]
		Local $section = ($__CtrlSaveItem[$i])[$__CtrlSave_INDEX_SECTION]
		Local $key = ($__CtrlSaveItem[$i])[$__CtrlSave_INDEX_KEY]
		IniWrite($file, $section, $key, GUICtrlRead($id))
	Next
EndFunc   ;==>__CtrlSave

; Save/Restore対象の設定値をRestoreする.
Func __CtrlRestore()
	For $i = 0 To UBound($__CtrlSaveItem) - 1
		Local $id = ($__CtrlSaveItem[$i])[$__CtrlSave_INDEX_ID]
		Local $ctrl = ($__CtrlSaveItem[$i])[$__CtrlSave_INDEX_CTRL]
		Local $file = ($__CtrlSaveItem[$i])[$__CtrlSave_INDEX_FILE]
		Local $section = ($__CtrlSaveItem[$i])[$__CtrlSave_INDEX_SECTION]
		Local $key = ($__CtrlSaveItem[$i])[$__CtrlSave_INDEX_KEY]
		Local $value = IniRead($file, $section, $key, "")
		If "" <> $value Then
			Switch $ctrl
				Case "GUICtrlCreateCheckbox"
					GUICtrlSetState($id, $value)
				Case "GUICtrlCreateRadio"
					GUICtrlSetState($id, $value)
				Case Else
					GUICtrlSetData($id, $value)
			EndSwitch
		EndIf
	Next
EndFunc   ;==>__CtrlRestore

; コントロールを横に指定個並べた場合の
; コントロールの横幅を取得する.
Func __CtrlWidth(Const $count, Const $width, Const $space = 0)
	Return ($width - ($space * ($count - 1))) / $count
EndFunc   ;==>__CtrlWidth

; コントロールを横に指定個並べた場合の
; コントロールの配置位置(x座標)を取得する.
Func __CtrlCol(Const $index, Const $count, Const $start_x, Const $width, Const $space = 0)
	Return $start_x + (__CtrlWidth($count, $width, $space) * ($index - 1)) _
			 + ($space * ($index - 1))
EndFunc   ;==>__CtrlCol

; グループ内にコントロールを横に指定個並べた場合の
; コントロールの横幅を取得する.
Func __CtrlGroupWidth(Const $count, Const $width, Const $side_margin)
	Return ($width - ($side_margin * 2)) / $count
EndFunc   ;==>__CtrlGroupWidth

; グループ内にコントロールを横に指定個並べた場合の
; コントロールの配置位置(x座標)を取得する.
Func __CtrlGroupCol(Const $index, Const $count, Const $start_x, Const $width, Const $side_margin)
	Return $start_x _
			 + (__CtrlGroupWidth($count, $width, $side_margin) * ($index - 1)) _
			 + $side_margin
EndFunc   ;==>__CtrlGroupCol

;===============================================================================
; 内部関数定義
;===============================================================================
; アイテムの高さを取得する.
Func ___CtrlItemHeight(ByRef Const $items, Const $index)
	Local $height = 0
	If ___CtrlIsColDelimiter($items, $index) Then
		$height = $__CtrlDelimiterHeight
	Else
		$height = $__CtrlHeight
	EndIf
	If "" <> $items[$index][$__CtrlBuilder_INDEX_HEIGHT] Then
		$height = $items[$index][$__CtrlBuilder_INDEX_HEIGHT]
	EndIf
	Return $height
EndFunc   ;==>___CtrlItemHeight

; アイテムの重みを取得する.
Func ___CtrlItemWeight(ByRef Const $items, Const $index)
	Local $weight = 0
	If Not ___CtrlIsColDelimiter($items, $index) Then
		$weight = $__CtrlWeight
		If "" <> $items[$index][$__CtrlBuilder_INDEX_WEIGHT] Then
			$weight = $items[$index][$__CtrlBuilder_INDEX_WEIGHT]
		EndIf
	EndIf
	Return $weight
EndFunc   ;==>___CtrlItemWeight

; インデックスが属する行の開始インデックスと終了インデックスを取得する.
Func ___CtrlIndexRange(ByRef Const $items, Const $index)
	Local $range[$___CtrlBuilder_INDEX_RANGE_MAX] = [0, UBound($items) - 1]
	For $i = $index To 0 Step -1
		If ___CtrlIsColDelimiter($items, $i) Then
			$range[$___CtrlBuilder_INDEX_RANGE_START] = $i + 1
			ExitLoop
		EndIf
	Next
	For $i = $index To UBound($items) - 1
		If ___CtrlIsColDelimiter($items, $i) Then
			$range[$___CtrlBuilder_INDEX_RANGE_END] = $i - 1
			ExitLoop
		EndIf
	Next
	__d($__CtrlDebug, "___CtrlIndexRange(index=" & $index & ") return=" _
			 & $range[$___CtrlBuilder_INDEX_RANGE_START] & "," & $range[$___CtrlBuilder_INDEX_RANGE_END])
	Return $range
EndFunc   ;==>___CtrlIndexRange

; インデックスが属する行の高さを取得する.
Func ___CtrlBuilderColHeight(ByRef Const $items, Const $index)
	Local $range = ___CtrlIndexRange($items, $index)
	Return __CtrlBuilderHeight($items, $range[$___CtrlBuilder_INDEX_RANGE_START], $range[$___CtrlBuilder_INDEX_RANGE_END])
EndFunc   ;==>___CtrlBuilderColHeight

; インデックスが属する行のコントロール数を取得する.
Func ___CtrlColCount(ByRef Const $items, Const $index)
	Local $range = ___CtrlIndexRange($items, $index)
	Local $count = 0
	For $i = $range[$___CtrlBuilder_INDEX_RANGE_START] To $range[$___CtrlBuilder_INDEX_RANGE_END]
		If ___CtrlIsColDelimiter($items, $i) Then
			ExitLoop
		EndIf
		$count += 1
	Next
	__d($__CtrlDebug, "___CtrlColCount(index=" & $index & ") return=" & $count)
	Return $count
EndFunc   ;==>___CtrlColCount

; コントロールの横方向の比率の合計を取得する.
Func ___CtrlColWeightMax(ByRef Const $items, Const $index)
	Local $range = ___CtrlIndexRange($items, $index)
	Local $weight = 0
	For $i = $range[$___CtrlBuilder_INDEX_RANGE_START] To $range[$___CtrlBuilder_INDEX_RANGE_END]
		If ___CtrlIsColDelimiter($items, $i) Then
			ExitLoop
		EndIf
		$weight += ___CtrlItemWeight($items, $i)
	Next
	__d($__CtrlDebug, "___CtrlColMaxRatio(index=" & $index & ") return=" & $weight)
	Return $weight
EndFunc   ;==>___CtrlColWeightMax

; コントロールの行区切りか取得する.
Func ___CtrlIsColDelimiter(ByRef Const $items, Const $index)
	Return IsNumber($items[$index][$__CtrlBuilder_INDEX_CTRL]) And _
			$items[$index][$__CtrlBuilder_INDEX_CTRL] < 0
EndFunc   ;==>___CtrlIsColDelimiter

;===============================================================================
; テスト
;===============================================================================
Func ___CtrlTestEvent()
	__p("___CtrlTestEvent() id=" & @GUI_CtrlId)
EndFunc   ;==>___CtrlTestEvent

Func ___CtrlTestOnExit()
	Exit
EndFunc   ;==>___CtrlTestOnExit

If "Ctrl.au3" = @ScriptName Then
	GUICreate("Ctrl.au3 Test", 500, 500)
	Local $start_x = 5
	Local $start_y = 5
	Local $width = 490
	Local $col_max = 3
	Local $ctrl_height = 30
	Local $margin = 5
	Local $space = 2

	; チェックボックスを並べる
	Local $check_items[7][$__CtrlBuilder_INDEX_MAX] = [ _
			["GUICtrlCreateCheckbox", "aaa", "___CtrlTestEvent", "aaa", 0, $GUI_CHECKED], _
			["GUICtrlCreateCheckbox", "bbb", "___CtrlTestEvent", "bbb", 0, $GUI_CHECKED], _
			["GUICtrlCreateCheckbox", "ccc", "___CtrlTestEvent", "ccc", 0, $GUI_UNCHECKED], _
			[-1], _
			["GUICtrlCreateCheckbox", "ddd", "___CtrlTestEvent", "ddd", 0, $GUI_UNCHECKED], _
			[], _
			["GUICtrlCreateCheckbox", "eee", "___CtrlTestEvent", "eee", 0, $GUI_UNCHECKED] _
			]
	__CtrlBuilder($check_items, $start_x, $start_y, $width)
	Local $check_height = __CtrlBuilderHeight($check_items)

	; グループコントロール内にボタンを並べる
	Local $group_start_y = $start_y + $check_height + $margin
	Local $group1_items[5][$__CtrlBuilder_INDEX_MAX] = [ _
			["GUICtrlCreateButton", "aaa", "___CtrlTestEvent"], _
			["GUICtrlCreateButton", "bbb", "___CtrlTestEvent"], _
			["GUICtrlCreateButton", "ccc", "___CtrlTestEvent"], _
			[-1], _
			["GUICtrlCreateButton", "ddd", "___CtrlTestEvent"] _
			]
	Local $group_group[1][$__CtrlBuilder_INDEX_MAX] = [ _
			["GUICtrlCreateGroup", "グループ1", 0, "", $group1_items]]
	__CtrlBuilder($group_group, $start_x, $group_start_y, $width)
	Local $group_height = __CtrlBuilderHeight($group_group)

	; グループコントロールを２つ並べる
	Local $group2_items[4][$__CtrlBuilder_INDEX_MAX] = [ _
			["GUICtrlCreateButton", "aaa", "___CtrlTestEvent", "", 0, 0, 1, 45], _
			["GUICtrlCreateButton", "bbb", "___CtrlTestEvent", "", 0, 0, 2], _
			[-1], _
			["GUICtrlCreateButton", "ddd", "___CtrlTestEvent", "", 0, 0, 1] _
			]
	Local $groups_start_y = $group_start_y + $group_height + $margin
	Local $groups_group[2][$__CtrlBuilder_INDEX_MAX] = [ _
			["GUICtrlCreateGroup", "グループ", 0, "", $group1_items], _
			["GUICtrlCreateGroup", "", 0, "", $group2_items] _
			]
	__CtrlBuilder($groups_group, $start_x, $groups_start_y, $width, $space)
	Local $groups_height = __CtrlBuilderHeight($groups_group)

	; グループコントロールとコントロールを並べる
	Local $composite_y = $groups_start_y + $groups_height + $margin
	Local $composite1_items[7][$__CtrlBuilder_INDEX_MAX] = [ _
			["GUICtrlCreateCombo", "テスト1|テスト2|テスト3", "___CtrlTestEvent"], _
			[-1], _
			["GUICtrlCreateCheckbox", "チェック1", "___CtrlTestEvent"], _
			["GUICtrlCreateCheckbox", "チェック2", "___CtrlTestEvent"], _
			["GUICtrlCreateCheckbox", "チェック3", "___CtrlTestEvent"], _
			[-1], _
			["GUICtrlCreateButton", "ボタン", "___CtrlTestEvent"] _
			]
	Local $composite2_items[7][$__CtrlBuilder_INDEX_MAX] = [ _
			["GUICtrlCreateButton", "ボタン", "___CtrlTestEvent"], _
			[-1, 0, 0, 0, 0, 0, 0, 2], _
			["GUICtrlCreateButton", "ボタン", "___CtrlTestEvent"], _
			[-1, 0, 0, 0, 0, 0, 0, 4], _
			["GUICtrlCreateButton", "ボタン", "___CtrlTestEvent"], _
			[-1, 0, 0, 0, 0, 0, 0, 8], _
			["GUICtrlCreateButton", "ボタン", "___CtrlTestEvent"] _
			]
	Local $composites_items[2][$__CtrlBuilder_INDEX_MAX] = [ _
			["GUICtrlCreateGroup", "グループ", 0, "", $composite1_items], _
			["", "", 0, "", $composite2_items] _
			]
	__CtrlBuilder($composites_items, $start_x, $composite_y, $width, $space)
	__CtrlRestore()

	Local $id = $composites_items[0][$__CtrlBuilder_INDEX_ID]
	_Assert('0 < $id')
	Local $child_id = ($composites_items[0][$__CtrlBuilder_INDEX_CHILD])[0][$__CtrlBuilder_INDEX_ID]
	_Assert('0 < $child_id')

	GUISetOnEvent($GUI_EVENT_CLOSE, "___CtrlTestOnExit")
	GUISetState(@SW_SHOW)
	While 1
		Sleep(10000)
	WEnd
EndIf
