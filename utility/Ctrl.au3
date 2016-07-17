#include-once
#include <GUIConstantsEx.au3>
#include <Debug.au3>
#include <Array.au3>
#include "Debug.au3"

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
Func __CtrlTile(ByRef Const $texts, Const $ctrl, Const $x, Const $y, _
		Const $width, Const $col_max, Const $ctrl_height)
	Local $handles[0]
	Local $count = UBound($texts)

	Local $index = 1
	Local $ctrl_y = $y
	For $i = 0 To $count - 1
		If "" <> $texts[$i] Then
			Local $ctrl_x = __CtrlCol($index, $col_max, $x, $width)
			Local $ctrl_width = __CtrlWidth($col_max, $width)
			Local $handle = Call($ctrl, _
					$texts[$i], $ctrl_x, $ctrl_y, $ctrl_width, $ctrl_height)
			_ArrayAdd($handles, $handle)
		Else
			_ArrayAdd($handles, -1)
		EndIf
		$index += 1
		If $col_max < $index Then
			$index = 1
			$ctrl_y += $ctrl_height
		EndIf
	Next
	Return $handles
EndFunc   ;==>__CtrlTile

; __CtrlTile()で生成したコントロールの高さを取得する.
Func __CtrlTileHeight(ByRef Const $texts, Const $col_max, Const $ctrl_height)
	Local $count = UBound($texts)
	Local $row_max = Ceiling($count / $col_max)
	Local $group_height = $row_max * $ctrl_height
	Return $group_height
EndFunc   ;==>__CtrlTileHeight

; グループ内にコントロールを指定個数敷き詰める.
Func __CtrlGroupTile(Const $name, Const $texts, Const $ctrl, Const $x, Const $y, _
		Const $width, Const $col_max, Const $ctrl_height)
	Local $group_height = __CtrlGroupTileHeight($texts, $col_max, $ctrl_height)
	Local $ctrl_x = $x + $__CtrlGroupSideMargin
	Local $ctrl_y = $y + $__CtrlGroupTopMargin
	Local $ctrl_width = $width - ($__CtrlGroupSideMargin * 2)

	GUICtrlCreateGroup($name, $x, $y, $width, $group_height)
	Local $handles = __CtrlTile($texts, $ctrl, _
			$ctrl_x, $ctrl_y, $ctrl_width, $col_max, $ctrl_height)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Return $handles
EndFunc   ;==>__CtrlGroupTile

; __CtrlGroupTile()で生成したグループの高さを取得する.
Func __CtrlGroupTileHeight(Const $texts, Const $col_max, Const $ctrl_height)
	Local $count = UBound($texts)
	Local $row_max = Ceiling($count / $col_max)
	Local $group_height = $row_max * $ctrl_height _
			 + $__CtrlGroupTopMargin + $__CtrlGroupButtomMargin
	Return $group_height
EndFunc   ;==>__CtrlGroupTileHeight

; チェックされたハンドル配列を取得する.
Func __CtrlChecked(Const $ctrlIDs)
	Local $checked[0]
	If IsArray($ctrlIDs) Then
		For $id In $ctrlIDs
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
Func ___CtrlTest()
	GUICreate("Ctrl.au3 Test", 500, 500)
	Local $texts[6] = ["aaa", "bbb", "ccc", "ddd", "", "eee"]
	Local $start_x = 5
	Local $start_y = 5
	Local $width = 490
	Local $col_max = 3
	Local $ctrl_height = 30
	Local $margin = 5

	; コントロールを敷き詰める
	Global $___CtrlTest_ids = __CtrlTile($texts, "GUICtrlCreateCheckbox", _
			$start_x, $start_y, $width, $col_max, $ctrl_height)
	GUICtrlSetState($___CtrlTest_ids[0], $GUI_CHECKED)
	GUICtrlSetState($___CtrlTest_ids[1], $GUI_CHECKED)

	; グループコントロール内にコントロールを敷き詰める
	Local $group_start_y = $start_y + __CtrlTileHeight($texts, _
			$col_max, $ctrl_height) + $margin
	__CtrlGroupTile("グループ1", $texts, "GUICtrlCreateButton", _
			$start_x, $group_start_y, $width, $col_max, $ctrl_height)

	; グループコントロールを２つ並べる
	Local $space = 2
	Local $col_width = __CtrlWidth(2, $width, $space)
	Local $group1_start_x = __CtrlCol(1, 2, $start_x, $width, $space)
	Local $group2_start_x = __CtrlCol(2, 2, $start_x, $width, $space)
	Local $group1_start_y = $group_start_y + __CtrlGroupTileHeight($texts, _
			$col_max, $ctrl_height) + $margin
	__CtrlGroupTile("グループ 1-2", $texts, "GUICtrlCreateButton", _
			$group1_start_x, $group1_start_y, $col_width, $col_max, $ctrl_height)
	__CtrlGroupTile("グループ 2-2", $texts, "GUICtrlCreateButton", _
			$group2_start_x, $group1_start_y, $col_width, $col_max, $ctrl_height)

	_Assert('2 = UBound(__CtrlChecked($___CtrlTest_ids))')

	GUISetState(@SW_SHOW)
	While 1
		$msg = GUIGetMsg()
		If $msg = $GUI_EVENT_CLOSE Then
			ExitLoop
		EndIf
	WEnd
EndFunc   ;==>___CtrlTest

If "Ctrl.au3" = @ScriptName Then
	___CtrlTest()
EndIf
