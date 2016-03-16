#include-once
#include <Debug.au3>
#include "..\utility\Debug.au3"

;===============================================================================
; 定数定義
;===============================================================================
; デバッグログフラグ.
Global $TemplateDebug = False

;===============================================================================
; 関数定義
;===============================================================================
Func __TemplateCompile(ByRef $template, Const ByRef $rule)
	Local $count = UBound($rule)
	Local $t = $template
	__d($TemplateDebug, $template)
	For $i = 0 To $count - 1
		Local $pattern = '\{\{' & $rule[$i][0] & '\}\}'
		$t = StringRegExpReplace($t, $pattern, $rule[$i][1])
		__d($TemplateDebug, "  {{" & $rule[$i][0] & "}} : " & $rule[$i][1] & " => " & $t)
	Next
	Return $t
EndFunc   ;==>__TemplateCompile

;===============================================================================
; テスト
;===============================================================================
Func __TemplateTest()
	Global $__TemplateRule[2][2] = [ _
			["a", "aa"], _
			["bb", "bbb"] _
			]
	_Assert('"aa__bbb" = __TemplateCompile("{{a}}__{{bb}}", $__TemplateRule)')
	_Assert('"{{aa}}__bbb" = __TemplateCompile("{{aa}}__{{bb}}", $__TemplateRule)')
	_Assert('"{{}}__bbb" = __TemplateCompile("{{}}__{{bb}}", $__TemplateRule)')
EndFunc   ;==>__TemplateTest

If "Template.au3" = @ScriptName Then
	__TemplateTest()
EndIf
