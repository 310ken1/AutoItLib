#include-once
#include <GUIConstantsEx.au3>
#include <Debug.au3>
#include <Array.au3>
#include "Debug.au3"
Opt("GUIOnEventMode", 1)

;===============================================================================
; 定数定義
;===============================================================================
Global Const $__Ctrl_ITEM_INDEX_TEXT = 0
Global Const $__Ctrl_ITEM_INDEX_EVENT = 1
Global Const $__Ctrl_ITEM_INDEX_MAX = 2

Global Const $__CtrlBuild_INDEX_CTRL = 0
Global Const $__CtrlBuild_INDEX_CTRL_ITEMS = 1
Global Const $__CtrlBuild_INDEX_CTRL_HEIGHT = 2
Global Const $__CtrlBuild_INDEX_CTRL_IDS = 3
Global Const $__CtrlBuild_INDEX_MAX = 4


;===============================================================================
; 変数定義
;===============================================================================
; デバッグフラグ.
Global $__CtrlDebug = False

; グループコントロールのマージン
Global $__CtrlGroupTopMargin = 15
Global $__CtrlGroupButtomMargin = 8
Global $__CtrlGroupSideMargin = 5

;===============================================================================
; 関数定義
;===============================================================================
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

; コントロールを指定個数敷き詰める.
Func __CtrlTile(ByRef Const $items, Const $ctrl, Const $x, Const $y, _
		Const $width, Const $col_max, Const $ctrl_height)
	Local $ids[0]
	Local $count = UBound($items)

	Local $index = 1
	Local $ctrl_y = $y
	For $i = 0 To $count - 1
		Local $text = $items[$i][$__Ctrl_ITEM_INDEX_TEXT]
		Local $event = $items[$i][$__Ctrl_ITEM_INDEX_EVENT]
		If IsString($text) Then
			Local $ctrl_x = __CtrlCol($index, $col_max, $x, $width)
			Local $ctrl_width = __CtrlWidth($col_max, $width)
			Local $id = Call($ctrl, _
					$text, $ctrl_x, $ctrl_y, $ctrl_width, $ctrl_height)
			GUICtrlSetOnEvent($id, $event)
			__d($__CtrlDebug, "__CtrlTile() text=" & $text & " id=" & $id & " event=" & $event)
			_ArrayAdd($ids, $id)
		Else
			_ArrayAdd($ids, -1)
		EndIf
		$index += 1
		If $col_max < $index Then
			$index = 1
			$ctrl_y += $ctrl_height
		EndIf
	Next
	Return $ids
EndFunc   ;==>__CtrlTile

; __CtrlTile()で生成したコントロールの高さを取得する.
Func __CtrlTileHeight(ByRef Const $items, Const $col_max, Const $ctrl_height)
	Local $count = UBound($items)
	Local $row_max = Ceiling($count / $col_max)
	Local $group_height = $row_max * $ctrl_height
	Return $group_height
EndFunc   ;==>__CtrlTileHeight

; グループ内にコントロールを指定個数敷き詰める.
Func __CtrlGroupTile(Const $name, Const $items, Const $ctrl, Const $x, Const $y, _
		Const $width, Const $col_max, Const $ctrl_height)
	Local $group_height = __CtrlGroupTileHeight($items, $col_max, $ctrl_height)
	Local $ctrl_x = $x + $__CtrlGroupSideMargin
	Local $ctrl_y = $y + $__CtrlGroupTopMargin
	Local $ctrl_width = $width - ($__CtrlGroupSideMargin * 2)

	GUICtrlCreateGroup($name, $x, $y, $width, $group_height)
	Local $ids = __CtrlTile($items, $ctrl, _
			$ctrl_x, $ctrl_y, $ctrl_width, $col_max, $ctrl_height)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Return $ids
EndFunc   ;==>__CtrlGroupTile

; __CtrlGroupTile()で生成したグループの高さを取得する.
Func __CtrlGroupTileHeight(Const $items, Const $col_max, Const $ctrl_height)
	Local $count = UBound($items)
	Local $row_max = Ceiling($count / $col_max)
	Local $group_height = $row_max * $ctrl_height _
			 + $__CtrlGroupTopMargin + $__CtrlGroupButtomMargin
	Return $group_height
EndFunc   ;==>__CtrlGroupTileHeight

; コントロールを構成する
Func __CtrlBuild(ByRef $ctrls, Const $start_x, Const $start_y, Const $width)
	Local $y = $start_y
	For $i = 0 To UBound($ctrls) - 1
		Local $ctrl = $ctrls[$i][$__CtrlBuild_INDEX_CTRL]
		Local $ctrl_items = $ctrls[$i][$__CtrlBuild_INDEX_CTRL_ITEMS]
		Local $ctrl_height = $ctrls[$i][$__CtrlBuild_INDEX_CTRL_HEIGHT]
		Local $ctrl_count = UBound($ctrl_items)
		$ctrls[$i][$__CtrlBuild_INDEX_CTRL_IDS] = _
				__CtrlTile($ctrl_items, $ctrl, $start_x, $y, $width, $ctrl_count, $ctrl_height)
		$y += $ctrl_height
	Next
EndFunc   ;==>__CtrlBuild

; __CtrlBuild()で生成したコントロールの高さを取得する.
Func __CtrlBuildHeight(ByRef Const $ctrls)
	Local $height = 0
	For $i = 0 To UBound($ctrls) - 1
		Local $ctrl_items = $ctrls[$i][$__CtrlBuild_INDEX_CTRL_ITEMS]
		Local $ctrl_height = $ctrls[$i][$__CtrlBuild_INDEX_CTRL_HEIGHT]
		Local $ctrl_count_max = UBound($ctrl_items)
		$height += __CtrlTileHeight($ctrl_items, $ctrl_count_max, $ctrl_height)
	Next
	Return $height
EndFunc   ;==>__CtrlBuildHeight

; コントロールグループを構成する
Func __CtrlGroupBuild(Const $group_name, ByRef $ctrls, Const $start_x, Const $start_y, Const $width)
	Local $group_height = __CtrlGroupBuildHeight($ctrls)
	Local $ctrl_x = $start_x + $__CtrlGroupSideMargin
	Local $ctrl_y = $start_y + $__CtrlGroupTopMargin
	Local $ctrl_width = $width - ($__CtrlGroupSideMargin * 2)

	GUICtrlCreateGroup($group_name, $start_x, $start_y, $width, $group_height)
	Local $y = $ctrl_y
	For $i = 0 To UBound($ctrls) - 1
		Local $ctrl = $ctrls[$i][$__CtrlBuild_INDEX_CTRL]
		Local $ctrl_items = $ctrls[$i][$__CtrlBuild_INDEX_CTRL_ITEMS]
		Local $ctrl_height = $ctrls[$i][$__CtrlBuild_INDEX_CTRL_HEIGHT]
		Local $ctrl_count_max = UBound($ctrl_items)
		$ctrls[$i][$__CtrlBuild_INDEX_CTRL_IDS] = _
				__CtrlTile($ctrl_items, $ctrl, _
				$ctrl_x, $y, $ctrl_width, $ctrl_count_max, $ctrl_height)
		$y += $ctrl_height
	Next
	GUICtrlCreateGroup("", -99, -99, 1, 1)
EndFunc   ;==>__CtrlGroupBuild

; __CtrlGroupBuild()で生成したコントロールの高さを取得する.
Func __CtrlGroupBuildHeight(ByRef Const $ctrls)
	Local $height = 0
	For $i = 0 To UBound($ctrls) - 1
		Local $ctrl_items = $ctrls[$i][$__CtrlBuild_INDEX_CTRL_ITEMS]
		Local $ctrl_height = $ctrls[$i][$__CtrlBuild_INDEX_CTRL_HEIGHT]
		Local $ctrl_count_max = UBound($ctrl_items)
		$height += __CtrlTileHeight($ctrl_items, $ctrl_count_max, $ctrl_height)
	Next
	Return $height + $__CtrlGroupTopMargin + $__CtrlGroupButtomMargin
EndFunc   ;==>__CtrlGroupBuildHeight

; チェックされたハンドル配列を取得する.
Func __CtrlChecked(Const $ids)
	Local $checked[0]
	If IsArray($ids) Then
		For $id In $ids
			If BitAND(GUICtrlRead($id), $GUI_CHECKED) Then
				_ArrayAdd($checked, $id)
			EndIf
		Next
	EndIf
	Return $checked
EndFunc   ;==>__CtrlChecked

;===============================================================================
; 内部関数定義
;===============================================================================


;===============================================================================
; テスト
;===============================================================================
Func ___CtrlTestEvent()
	ConsoleWrite("___CtrlTestEvent()" & @CRLF)
EndFunc   ;==>___CtrlTestEvent

Func ___CtrlTestOnExit()
	Exit
EndFunc   ;==>___CtrlTestOnExit

Func ___CtrlTest()
	GUICreate("Ctrl.au3 Test", 500, 500)
	Local $items[6][$__Ctrl_ITEM_INDEX_MAX] = [ _
			["aaa", "___CtrlTestEvent"], ["bbb", "___CtrlTestEvent"], ["ccc", "___CtrlTestEvent"], _
			["ddd", "___CtrlTestEvent"], [0, 0], ["eee", "___CtrlTestEvent"]]
	Local $start_x = 5
	Local $start_y = 5
	Local $width = 490
	Local $col_max = 3
	Local $ctrl_height = 30
	Local $margin = 5

	; コントロールを敷き詰める
	Global $___CtrlTest_ids = __CtrlTile($items, "GUICtrlCreateCheckbox", _
			$start_x, $start_y, $width, $col_max, $ctrl_height)
	GUICtrlSetState($___CtrlTest_ids[0], $GUI_CHECKED)
	GUICtrlSetState($___CtrlTest_ids[1], $GUI_CHECKED)

	; グループコントロール内にコントロールを敷き詰める
	Local $group_start_y = $start_y + __CtrlTileHeight($items, _
			$col_max, $ctrl_height) + $margin
	__CtrlGroupTile("グループ1", $items, "GUICtrlCreateButton", _
			$start_x, $group_start_y, $width, $col_max, $ctrl_height)

	; グループコントロールを２つ並べる
	Local $space = 2
	Local $col_width = __CtrlWidth(2, $width, $space)
	Local $group1_start_x = __CtrlCol(1, 2, $start_x, $width, $space)
	Local $group2_start_x = __CtrlCol(2, 2, $start_x, $width, $space)
	Local $group1_start_y = $group_start_y + __CtrlGroupTileHeight($items, _
			$col_max, $ctrl_height) + $margin
	__CtrlGroupTile("グループ 1-2", $items, "GUICtrlCreateButton", _
			$group1_start_x, $group1_start_y, $col_width, $col_max, $ctrl_height)
	__CtrlGroupTile("グループ 2-2", $items, "GUICtrlCreateButton", _
			$group2_start_x, $group1_start_y, $col_width, $col_max, $ctrl_height)
	Local $group_height = __CtrlGroupTileHeight($items, $col_max, $ctrl_height)

	; コントロールを構成する
	Local $build_y = $group1_start_y + $group_height + $margin
	Local $check_items[3][$__Ctrl_ITEM_INDEX_MAX] = _
			[["check1", 0], ["check2", 0], ["check3", 0]]
	Local $button_items[2][$__Ctrl_ITEM_INDEX_MAX] = [ _
			["button1", "___CtrlTestEvent"], ["button2", "___CtrlTestEvent"]]
	Local $ctrls[2][$__CtrlBuild_INDEX_MAX] = [ _
			["GUICtrlCreateCheckbox", $check_items, $ctrl_height, 0], _
			["GUICtrlCreateButton", $button_items, $ctrl_height, 0] _
			]
	__CtrlBuild($ctrls, $start_x, $build_y, $width)
	Local $build_height = __CtrlBuildHeight($ctrls)

	; コントロールグループを構成する
	Local $build_group_y = $build_y + $build_height + $margin
	__CtrlGroupBuild("グループビルド", $ctrls, $start_x, $build_group_y, $width)

	_Assert('2 = UBound(__CtrlChecked($___CtrlTest_ids))')

	GUISetOnEvent($GUI_EVENT_CLOSE, "___CtrlTestOnExit")
	GUISetState(@SW_SHOW)
	While 1
		Sleep(10000)
	WEnd
EndFunc   ;==>___CtrlTest

If "Ctrl.au3" = @ScriptName Then
	___CtrlTest()
EndIf
