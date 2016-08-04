#include-once
#include <GUIConstantsEx.au3>
#include <Debug.au3>
#include <Array.au3>
#include "Debug.au3"
Opt("GUIOnEventMode", 1)

;===============================================================================
; 定数定義
;===============================================================================
Global Const $__CtrlBuilder_INDEX_CTRL = 0
Global Const $__CtrlBuilder_INDEX_TEXT = 1
Global Const $__CtrlBuilder_INDEX_HEIGHT = 2
Global Const $__CtrlBuilder_INDEX_STATE = 3
Global Const $__CtrlBuilder_INDEX_EVENT = 4
Global Const $__CtrlBuilder_INDEX_CHILDE = 5
Global Const $__CtrlBuilder_INDEX_ID = 6
Global Const $__CtrlBuilder_INDEX_END = 7

Global Const $__CtrlBuilder_COL_DELIMITER[$__CtrlBuilder_INDEX_END] = [0, 0, 0, 0, 0, 0, 0]

;===============================================================================
; 変数定義
;===============================================================================
; デバッグフラグ.
Global $__CtrlDebug = False

; グループコントロールのマージン
Global $__CtrlGroupTopMargin = 18
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

; コントロールを定義に従い並べる
Func __CtrlBuilder(ByRef $items, Const $x, Const $y, Const $width, Const $space = 0)
	Local $ctrl_y = $y
	Local $index = 0
	Local $count = ___CtrlColMaxCount($items, 0)
	For $i = 0 To UBound($items) - 1
		$index += 1
		Local $ctrl = $items[$i][$__CtrlBuilder_INDEX_CTRL]
		Local $text = $items[$i][$__CtrlBuilder_INDEX_TEXT]
		Local $height = $items[$i][$__CtrlBuilder_INDEX_HEIGHT]
		Local $state = $items[$i][$__CtrlBuilder_INDEX_STATE]
		Local $event = $items[$i][$__CtrlBuilder_INDEX_EVENT]
		Local $childe = $items[$i][$__CtrlBuilder_INDEX_CHILDE]
		Local $ctrl_x = __CtrlCol($index, $count, $x, $width, $space)
		Local $ctrl_width = __CtrlWidth($count, $width, $space)
		Local $group = "GUICtrlCreateGroup" = $ctrl
		If ___CtrlIsColDelimiter($items, $i) Then
			$index = 0
			$count = ___CtrlColMaxCount($items, $i + 1)
			$ctrl_y += __CtrlBuilderColHeight($items, $i - 1) + $height
		EndIf
		If "" <> $ctrl Then
			Local $ctrl_height = $height
			If $group Then
				$ctrl_height = __CtrlBuilderHeight($childe) _
						 + $__CtrlGroupTopMargin + $__CtrlGroupButtomMargin
			EndIf
			Local $id = Call($ctrl, _
					$text, $ctrl_x, $ctrl_y, $ctrl_width, $ctrl_height)
			GUICtrlSetState($id, $state)
			GUICtrlSetOnEvent($id, $event)
			$items[$i][$__CtrlBuilder_INDEX_ID] = $id
		EndIf
		If IsArray($childe) Then
			Local $group_x = $ctrl_x
			Local $group_y = $ctrl_y
			Local $gorup_width = $ctrl_width
			If $group Then
				$group_x += $__CtrlGroupSideMargin
				$group_y += $__CtrlGroupTopMargin
				$gorup_width -= ($__CtrlGroupSideMargin * 2)
			EndIf
			__CtrlBuilder($items[$i][$__CtrlBuilder_INDEX_CHILDE], $group_x, $group_y, $gorup_width)
		EndIf
		If $group Then
			GUICtrlCreateGroup("", -99, -99, 1, 1)
		EndIf
	Next
EndFunc   ;==>__CtrlBuilder

; コントロールの高さを取得する
Func __CtrlBuilderHeight(ByRef Const $items, Const $start = 0, Const $end = UBound($items) - 1)
	__d($__CtrlDebug, "__CtrlBuilderHeight(" & $start & ", " & $end & ")")
	Local $ctrl_height = 0
	Local $childe_height = 0
	Local $col_height = 0
	For $i = $start To $end
		Local $childe = $items[$i][$__CtrlBuilder_INDEX_CHILDE]
		Local $height = $items[$i][$__CtrlBuilder_INDEX_HEIGHT]
		If IsArray($childe) Then
			Local $h = __CtrlBuilderHeight($childe)
			$h += $__CtrlGroupTopMargin + $__CtrlGroupButtomMargin
			If $childe_height < $h Then
				$childe_height = $h
			EndIf
		EndIf
		If $col_height < $height Then
			$col_height = $height
		EndIf
		If ___CtrlIsColDelimiter($items, $i) Or ($i = $end) Then
			__d($__CtrlDebug, "__CtrlBuilderHeight() col=" & $col_height & " childe=" & $childe_height)
			If ___CtrlIsColDelimiter($items, $i) Then
				$ctrl_height += $height
			EndIf
			If $col_height < $childe_height Then
				$ctrl_height += $childe_height
			Else
				$ctrl_height += $col_height
			EndIf
			$col_height = 0
			$childe_height = 0
		EndIf
	Next
	__d($__CtrlDebug, "__CtrlBuilderHeight() Return=" & $ctrl_height)
	Return $ctrl_height
EndFunc   ;==>__CtrlBuilderHeight

;===============================================================================
; 内部関数定義
;===============================================================================
; インデックスが属する行の高さを取得する
Func __CtrlBuilderColHeight(ByRef Const $items, Const $index)
	Local $start = 0
	Local $end = UBound($items) - 1
	For $i = $index To 0 Step -1
		If ___CtrlIsColDelimiter($items, $i) Then
			$start = $i + 1
			ExitLoop
		EndIf
	Next
	For $i = $index To UBound($items) - 1
		If ___CtrlIsColDelimiter($items, $i) Then
			$end = $i - 1
			ExitLoop
		EndIf
	Next
	Return __CtrlBuilderHeight($items, $start, $end)
EndFunc   ;==>__CtrlBuilderColHeight

; コントロールの横方向の最大個数を取得する
Func ___CtrlColMaxCount(ByRef Const $items, Const $index)
	__d($__CtrlDebug, "___CtrlColMaxCount() Start")
	Local $count = 0
	For $i = $index To UBound($items) - 1
		If ___CtrlIsColDelimiter($items, $i) Then
			ExitLoop
		EndIf
		$count += 1
	Next
	__d($__CtrlDebug, "___CtrlColMaxCount() End Return=" & $count)
	Return $count
EndFunc   ;==>___CtrlColMaxCount

; コントロールの行区切りか取得する
Func ___CtrlIsColDelimiter(ByRef Const $items, Const $index)
	Local $result = True
	Local $count = $__CtrlBuilder_INDEX_END - 1
	For $i = 0 To $count
		If $i = $__CtrlBuilder_INDEX_HEIGHT Then
			ContinueLoop
		EndIf
		If IsString($items[$index][$i]) Or $__CtrlBuilder_COL_DELIMITER[$i] <> $items[$index][$i] Then
			$result = False
			ExitLoop
		EndIf
	Next
	__d($__CtrlDebug, "___CtrlIsColDelimiter(" & $items[$index][$__CtrlBuilder_INDEX_TEXT] & ") Return=" & $result)
	Return $result
EndFunc   ;==>___CtrlIsColDelimiter

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
	Local $start_x = 5
	Local $start_y = 5
	Local $width = 490
	Local $col_max = 3
	Local $ctrl_height = 30
	Local $margin = 5
	Local $space = 2

	; チェックボックスを並べる
	Local $check_items[7][$__CtrlBuilder_INDEX_END] = [ _
			["GUICtrlCreateCheckbox", "aaa", $ctrl_height, $GUI_CHECKED, "___CtrlTestEvent", 0, 0], _
			["GUICtrlCreateCheckbox", "bbb", $ctrl_height, $GUI_CHECKED, "___CtrlTestEvent", 0, 0], _
			["GUICtrlCreateCheckbox", "ccc", $ctrl_height, $GUI_UNCHECKED, "___CtrlTestEvent", 0, 0], _
			[0, 0, 0, 0, 0, 0, 0], _
			["GUICtrlCreateCheckbox", "bbb", $ctrl_height, $GUI_UNCHECKED, "___CtrlTestEvent", 0, 0], _
			["", 0, 0, 0, 0, 0, 0], _
			["GUICtrlCreateCheckbox", "eee", $ctrl_height, $GUI_UNCHECKED, "___CtrlTestEvent", 0, 0] _
			]
	__CtrlBuilder($check_items, $start_x, $start_y, $width)
	Local $check_height = __CtrlBuilderHeight($check_items)

	; グループコントロール内にボタンを並べる
	Local $group_start_y = $start_y + $check_height + $margin
	Local $group_items[5][$__CtrlBuilder_INDEX_END] = [ _
			["GUICtrlCreateButton", "aaa", $ctrl_height, 0, "___CtrlTestEvent", 0, 0], _
			["GUICtrlCreateButton", "bbb", $ctrl_height, 0, "___CtrlTestEvent", 0, 0], _
			["GUICtrlCreateButton", "ccc", $ctrl_height, 0, "___CtrlTestEvent", 0, 0], _
			[0, 0, 0, 0, 0, 0, 0], _
			["GUICtrlCreateButton", "ddd", $ctrl_height, 0, "___CtrlTestEvent", 0, 0] _
			]
	Local $group_group[1][$__CtrlBuilder_INDEX_END] = [ _
			["GUICtrlCreateGroup", "グループ1", 0, 0, 0, $group_items, 0]]
	__CtrlBuilder($group_group, $start_x, $group_start_y, $width)
	Local $group_height = __CtrlBuilderHeight($group_group)

	; グループコントロールを２つ並べる
	Local $groups_start_y = $group_start_y + $group_height + $margin
	Local $groups_group[2][$__CtrlBuilder_INDEX_END] = [ _
			["GUICtrlCreateGroup", "グループ", 0, 0, 0, $group_items, 0], _
			["GUICtrlCreateGroup", "", 0, 0, 0, $group_items, 0] _
			]
	__CtrlBuilder($groups_group, $start_x, $groups_start_y, $width, $space)
	Local $groups_height = __CtrlBuilderHeight($groups_group)

	; グループコントロールとコントロールを並べる
	Local $composite_y = $groups_start_y + $groups_height + $margin
	Local $composite1_items[7][$__CtrlBuilder_INDEX_END] = [ _
			["GUICtrlCreateCombo", "テスト1", $ctrl_height, 0, "___CtrlTestEvent", 0, 0], _
			[0, 0, 0, 0, 0, 0, 0], _
			["GUICtrlCreateCheckbox", "チェック1", $ctrl_height, 0, "___CtrlTestEvent", 0, 0], _
			["GUICtrlCreateCheckbox", "チェック2", $ctrl_height, 0, "___CtrlTestEvent", 0, 0], _
			["GUICtrlCreateCheckbox", "チェック3", $ctrl_height, 0, "___CtrlTestEvent", 0, 0], _
			[0, 0, 0, 0, 0, 0, 0], _
			["GUICtrlCreateButton", "ボタン", $ctrl_height, 0, "___CtrlTestEvent", 0, 0] _
			]
	Local $composite2_items[7][$__CtrlBuilder_INDEX_END] = [ _
			["GUICtrlCreateButton", "ボタン", $ctrl_height, 0, "___CtrlTestEvent", 0, 0], _
			[0, 0, 2, 0, 0, 0, 0], _
			["GUICtrlCreateButton", "ボタン", $ctrl_height, 0, "___CtrlTestEvent", 0, 0], _
			[0, 0, 4, 0, 0, 0, 0], _
			["GUICtrlCreateButton", "ボタン", $ctrl_height, 0, "___CtrlTestEvent", 0, 0], _
			[0, 0, 8, 0, 0, 0, 0], _
			["GUICtrlCreateButton", "ボタン", $ctrl_height, 0, "___CtrlTestEvent", 0, 0] _
			]
	Local $composites_items[2][$__CtrlBuilder_INDEX_END] = [ _
			["GUICtrlCreateGroup", "グループ", 0, 0, 0, $composite1_items, 0], _
			["", "", 0, 0, 0, $composite2_items, 0] _
			]
	__CtrlBuilder($composites_items, $start_x, $composite_y, $width, $space)

	$__DebugGlobal = $composites_items[0][$__CtrlBuilder_INDEX_ID]
	_Assert('0 < $__DebugGlobal')
	$__DebugGlobal = ($composites_items[0][$__CtrlBuilder_INDEX_CHILDE])[0][$__CtrlBuilder_INDEX_ID]
	_Assert('0 < $__DebugGlobal')

	GUISetOnEvent($GUI_EVENT_CLOSE, "___CtrlTestOnExit")
	GUISetState(@SW_SHOW)
	While 1
		Sleep(10000)
	WEnd
EndFunc   ;==>___CtrlTest

If "Ctrl.au3" = @ScriptName Then
	___CtrlTest()
EndIf

