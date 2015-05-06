#tag Module
Protected Module User32
	#tag ExternalMethod, Flags = &h1
		Protected Soft Declare Function AddClipboardFormatListener Lib "User32" (HWND As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Declare Function AdjustWindowRect Lib "User32" (ByRef WindowRect As Win32 . Libs . RECT, Style As Integer, bMenu As Boolean) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Declare Function AdjustWindowRectEx Lib "User32" (ByRef WindowRect As Win32 . Libs . RECT, Style As Integer, bMenu As Boolean, ExStyle As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function AllowSetForegroundWindow Lib "User32" (ProcessID As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function AnimateWindow Lib "User32" (HWND As Integer, duration As Integer, animation As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function BringWindowToTop Lib "User32" (HWND As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function CallWindowProc Lib "User32" Alias "CallWindowProcW" (WindowProc As Integer, HWND As Integer, msg As Integer, wParam As Ptr, lParam As Ptr) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function ChangeClipboardChain Lib "User32" (Removed As Integer, NextWindow As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Declare Function ChildWindowFromPoint Lib "User32" (HWND As Integer, Coordinates As Win32 . Libs . POINT) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Declare Function ClipCursor Lib "User32" (ByRef Area As Win32 . Libs . RECT) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function CloseClipboard Lib "User32" () As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function CloseDesktop Lib "User32" (hDesktop As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function CloseWindow Lib "User32" (HWND As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function CreateDesktop Lib "User32" Alias "CreateDesktopW" (Name As WString, Device As Integer, DevMode As Integer, Flags As Integer, Access As Integer, Security As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function CreateWindowEx Lib "User32" Alias "CreateWindowExW" (ExStyle As Integer, ClassNameAtom As Integer, WindowName As WString, Style As Integer, X As Integer, Y As Integer, Width As Integer, Height As Integer, Parent As Integer, Menu As Integer, Instance As Integer, Param As Ptr) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function CreateWindowEx Lib "User32" Alias "CreateWindowExW" (ExStyle As Integer, ClassName As WString, WindowName As WString, Style As Integer, X As Integer, Y As Integer, Width As Integer, Height As Integer, Parent As Integer, Menu As Integer, Instance As Integer, Param As Ptr) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function DestroyIcon Lib "User32" (hIcon As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function DestroyWindow Lib "User32" (HWND As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function DrawIcon Lib "User32" (hDC As Integer, xLeft As Integer, yTop As Integer, hIcon As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function DrawIconEx Lib "User32" (hDC As Integer, xLeft As Integer, yTop As Integer, hIcon As Integer, cxWidth As Integer, cyWidth As Integer, istepIfAniCur As Integer, hbrFlickerFreeDraw As Integer, diFlags As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function EmptyClipboard Lib "User32" () As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function EnumClipboardFormats Lib "User32" (format As UInt32) As UInt32
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function ExitWindowsEx Lib "User32" (flags As Integer, reason As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function FindWindow Lib "User32" Alias "FindWindowW" (ClassName As Ptr, WindowName As Ptr) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function FindWindowEx Lib "User32" Alias "FindWindowExW" (ParentHWND As Integer, ChildHWND As Integer, ClassName As WString, WindowName As WString) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function FlashWindow Lib "User32" (HWND As Integer, invert As Boolean) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Declare Function FlashWindowEx Lib "User32" (Flashinfo As Win32 . Libs . FLASHWINFO) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function GetAncestor Lib "User32" (HWND As Integer, Flags As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Declare Function GetClientRect Lib "User32" (HWND As Integer, ByRef Dimensions As Win32 . Libs . RECT) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function GetClipboardData Lib "User32" (format As UInt32) As UInt32
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function GetClipboardFormatName Lib "User32" Alias "GetClipboardFormatNameW" (format As UInt32, Buffer As Ptr, MaxCount As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Declare Function GetClipCursor Lib "User32" (ByRef Area As Win32 . Libs . RECT) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Declare Function GetCursorInfo Lib "User32" (ByRef Info As Win32 . Libs . CURSORINFO) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function GetDC Lib "User32" (HWND As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function GetDesktopWindow Lib "User32" () As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function GetKeyNameText Lib "User32" Alias "GetKeyNameTextW" (LParam As Integer, Buffer As Ptr, BufferSize As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function GetLayeredWindowAttributes Lib "User32" (hwnd As Integer, ByRef TransparentColor As Integer, ByRef Alpha As Integer, Flags As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function GetParent Lib "User32" (HWND As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function GetSystemMetrics Lib "User32" (nIndex As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function GetThreadDesktop Lib "User32" (ThreadID As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function GetUserObjectInformation Lib "User32" (Handle As Integer, Index As Integer, Info As Ptr, InfoLen As Integer, ByRef LenNeeded As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function GetWindow Lib "User32" (HWND As Integer, CMD As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Declare Function GetWindowInfo Lib "User32" (HWND As Integer, ByRef Info As Win32 . Libs . WINDOWINFO) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function GetWindowLong Lib "User32" Alias "GetWindowLongW" (HWND As Integer, Index As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Declare Function GetWindowPlacement Lib "User32" (HWND As Integer, ByRef WinPlacement As WINDOWPLACEMENT) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Declare Function GetWindowRect Lib "User32" (HWND As Integer, ByRef sm As Win32 . Libs . RECT) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function GetWindowText Lib "User32" Alias "GetWindowTextW" (HWND As integer, lpString As Ptr, cch As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function GlobalDeleteAtom Lib "Kernel32" (Atom As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function IsClipboardFormatAvailable Lib "User32" (format As UInt32) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function IsIconic Lib "User32" (HWND As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function IsWindow Lib "User32" (HWND As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function IsWindowVisible Lib "User32" (HWND As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function LoadImage Lib "User32" Alias "LoadImageW" (Instance As Integer, FileName As WString, ImageType As Integer, DesiredWidth As UInt32, DesiredHeight As UInt32, Flags As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function LockWorkStation Lib "User32" () As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function MapVirtualKey Lib "User32" Alias "MapVirtualKeyW" (key As Integer, type As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function MessageBeep Lib "User32" (Type As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function MessageBox Lib "User32" Alias "MessageBoxW" (HWND As Integer, text As WString, caption As WString, type As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function MoveWindow Lib "User32" (HWND As Integer, X As Integer, Y As Integer, Width As Integer, Height As Integer, Repaint As Boolean) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function OpenClipboard Lib "User32" (HWND As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function OpenDesktop Lib "User32" Alias "OpenDesktopW" (Desktop As WString, Flags As Integer, InheritHandle As Boolean, AccessMask As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function OpenInputDesktop Lib "User32" (flags As Integer, inherit As Boolean, access As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function PostMessage Lib "User32" Alias "PostMessageW" (HWND As Integer, Message As Integer, WParam As Ptr, LParam As Ptr) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Declare Function RegisterClass Lib "User32" Alias "RegisterClassW" (ByRef Info As Win32 . Libs . WNDCLASS) As UInt32
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Declare Function RegisterClassEx Lib "User32" Alias "RegisterClassExW" (ByRef Info As Win32 . Libs . WNDCLASSEX) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function RegisterClipboardFormat Lib "User32" Alias "RegisterClipboardFormatW" (FormatName As WString) As UInt32
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function RegisterHotKey Lib "User32" (HWND As Integer, ID As Integer, Modifiers As Integer, VirtualKey As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function RegisterWindowMessage Lib "User32" Alias "RegisterWindowMessageW" (MessageName As WString) As UInt16
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function ReleaseDC Lib "User32" (HWND As Integer, DC As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Soft Declare Function RemoveClipboardFormatListener Lib "User32" (HWND As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Declare Function ScreenToClient Lib "User32" (HWND As Integer, ByRef Point As Win32 . Libs . POINT) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function SendMessage Lib "User32" Alias "SendMessageW" (HWND As Integer, Message As UInt32, WParam As Integer, LParam As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function SendMessage Lib "User32" Alias "SendMessageW" (HWND As Integer, Message As UInt32, WParam As Ptr, LParam As Ptr) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function SetClipboardData Lib "User32" (format As UInt32, hMem As Ptr) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function SetClipboardViewer Lib "User32" (NewViewerWindow As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function SetForegroundWindow Lib "User32" (HWND As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function SetLayeredWindowAttributes Lib "User32" (hwnd As Integer, thecolor As Integer, bAlpha As integer, alpha As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function SetParent Lib "User32" (Child As Integer, NewParent As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function SetThreadDesktop Lib "User32" (hDesktop As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function SetWindowLong Lib "User32" Alias "SetWindowLongW" (HWND As Integer, Index As Integer, NewLong As Integer) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function SetWindowLong Lib "User32" Alias "SetWindowLongW" (HWND As Integer, Index As Integer, NewLong As Ptr) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function SetWindowPos Lib "User32" (HWND As Integer, hWndInstertAfter As Integer, x As Integer, y As Integer, cx As Integer, cy As Integer, flags As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function SetWindowRgn Lib "User32" (hWnd As Integer, hRgn As Integer, bRedraw As Boolean) As Integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function SetWindowText Lib "User32" Alias "SetWindowTextW" (WND As Integer, Buffer As WString) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function ShowWindow Lib "User32" (HWND As Integer, Command As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Soft Declare Function ShutdownBlockReasonCreate Lib "User32" (HWND As Integer, Reason As WString) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Soft Declare Function ShutdownBlockReasonDestroy Lib "User32" (HWND As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Soft Declare Function ShutdownBlockReasonQuery Lib "User32" (HWND As Integer, Buffer As Ptr, ByRef BufferSz As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function SwitchDesktop Lib "User32" (hDesktop As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function SystemParametersInfo Lib "User32" Alias "SystemParametersInfoW" (action as UInt32, param1 as UInt32, param2 as Ptr, change as UInt32) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function UnregisterHotKey Lib "User32" (HWND As Integer, ID As Integer) As Boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1
		Protected Declare Function VkKeyScan Lib "User32" Alias "VkKeyScanW" (Key As Integer) As Short
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Declare Function WindowFromPoint Lib "User32" (Coordinates As Win32 . Libs . POINT) As Integer
	#tag EndExternalMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
