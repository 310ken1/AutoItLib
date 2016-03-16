#include-once
#include <Debug.au3>
#include "..\utility\Debug.au3"

;===============================================================================
; 定数定義
;===============================================================================
; デバッグログフラグ.
Global $UriDebug = False

;===============================================================================
; 関数定義
;===============================================================================
; URLからユーザ名を取得する
Func __UrlUser(Const $uri)
	Local $array = StringRegExp($uri, "(\w+:\w+@)", 1)
	Local $user = ""
	If IsArray($array) Then
		$user = StringRegExp($array[0], "\w+", 3)[0]
	EndIf
	__d($UriDebug, "__UrlUser(" & $uri & ") return=" & $user)
	Return $user
EndFunc   ;==>__UrlUser

; URLからパスワードを取得する
Func __UrlPassword(Const $uri)
	Local $array = StringRegExp($uri, "(\w+:\w+@)", 1)
	Local $password = ""
	If IsArray($array) Then
		$password = StringRegExp($array[0], "\w+", 3)[1]
	EndIf
	__d($UriDebug, "__UrlPassword(" & $uri & ") return=" & $password)
	Return $password
EndFunc   ;==>__UrlPassword

; URLからドメイン名（サーバ名）を取得する
Func __UrlDomain(Const $uri)
	Local $server = StringRegExpReplace($uri, "(\w+:\w+@)", "")
	$server = StringRegExpReplace($server, "(:[0-9]{1,5})?((\/\w*)+)?", "")
	__d($UriDebug, "__UrlDomain(" & $uri & ") return=" & $server)
	Return $server
EndFunc   ;==>__UrlDomain

; URLからポート番号を取得する
Func __UrlPort(Const $uri)
	Local $array = StringRegExp($uri, ":[0-9]{1,5}", 2)
	Local $port = ""
	If IsArray($array) Then
		$port = StringRegExpReplace($array[0], ":", "")
	EndIf
	__d($UriDebug, "__UrlPort(" & $uri & ") return=" & $port)
	Return $port
EndFunc   ;==>__UrlPort

; URLからパスを取得する
Func __UrlPath(Const $uri)
	Local $array = StringRegExp($uri, "(\/\w*)+", 2)
	Local $path = ""
	If IsArray($array) Then
		$path = $array[0]
	EndIf
	__d($UriDebug, "__UrlPath(" & $uri & ") return=" & $path)
	Return $path
EndFunc   ;==>__UrlPath

;===============================================================================
; テスト
;===============================================================================
Func __UrlTest()
	_Assert('"user" = __UrlUser("user:pass@server:80/path1/path2")')
	_Assert('"pass" = __UrlPassword("user:pass@server:80/path1/path2")')
	_Assert('"server" = __UrlDomain("user:pass@server:80/path1/path2")')
	_Assert('"80" = __UrlPort("user:pass@server:80/path1/path2")')
	_Assert('"/path1/path2" = __UrlPath("user:pass@server:80/path1/path2")')

	_Assert('"aaa" = __UrlUser("aaa:bbb@server:80")')
	_Assert('"bbb" = __UrlPassword("aaa:bbb@server:80")')
	_Assert('"server" = __UrlDomain("aaa:bbb@server:80")')
	_Assert('"80" = __UrlPort("aaa:bbb@server:80")')
	_Assert('"" = __UrlPath("aaa:bbb@server:80")')

	_Assert('"aaa" = __UrlUser("aaa:bbb@server")')
	_Assert('"bbb" = __UrlPassword("aaa:bbb@server")')
	_Assert('"server" = __UrlDomain("aaa:bbb@server")')
	_Assert('"" = __UrlPort("aaa:bbb@server")')
	_Assert('"" = __UrlPath("aaa:bbb@server")')

	_Assert('"" = __UrlUser("server:80/path1/path2/")')
	_Assert('"" = __UrlPassword("server:80/path1/path2/")')
	_Assert('"server" = __UrlDomain("server:80/path1/path2/")')
	_Assert('"80" = __UrlPort("server:80/path1/path2/")')
	_Assert('"/path1/path2/" = __UrlPath("server:80/path1/path2/")')

	_Assert('"" = __UrlUser("server:80")')
	_Assert('"" = __UrlPassword("server:80")')
	_Assert('"server" = __UrlDomain("server:80")')
	_Assert('"80" = __UrlPort("server:80")')
	_Assert('"" = __UrlPath("server:80")')

	_Assert('"" = __UrlUser("server")')
	_Assert('"" = __UrlPassword("server")')
	_Assert('"server" = __UrlDomain("server")')
	_Assert('"" = __UrlPort("server")')
	_Assert('"" = __UrlPath("server")')


	_Assert('"" = __UrlUser("server/path1/")')
	_Assert('"" = __UrlPassword("server/path1/")')
	_Assert('"server" = __UrlDomain("server/path1/")')
	_Assert('"" = __UrlPort("server/path1/")')
	_Assert('"/path1/" = __UrlPath("server/path1/")')
EndFunc   ;==>__UrlTest

If "Uri.au3" = @ScriptName Then
	__UrlTest()
EndIf
