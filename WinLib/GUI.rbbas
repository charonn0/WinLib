#tag Module
Protected Module GUI
	#tag Method, Flags = &h1
		Protected Function CaptureRect(X As Integer, Y As Integer, Width As Integer, Height As Integer) As Picture
		  'Performs a screen capture on the specified on-screen rectangle. All screen contents in that
		  'rectangle will be captured as they appear to the user on screen.
		  If Width = 0 Or Height = 0 Then Return Nil
		  Dim screenCap As Picture
		  
		  #If TargetWin32 Then
		    screenCap = New Picture(Width, Height, 24)
		    Dim deskHWND As Integer = Win32.User32.GetDesktopWindow()
		    Dim deskHDC As Integer = Win32.User32.GetDC(deskHWND)
		    Call Win32.GDI32.BitBlt(screenCap.Graphics.Handle(Graphics.HandleTypeHDC), 0, 0, Width, Height, DeskHDC, X, Y, SRCCOPY Or CAPTUREBLT)
		    Call Win32.User32.ReleaseDC(DeskHWND, deskHDC)
		  #Endif
		  
		  Return screenCap
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function CursorConfinementArea() As REALbasic.Rect
		  ' Returns a Rectangle within which the mouse cursor is currently allowed move.
		  #If TargetWin32 Then
		    Dim r As RECT
		    If Win32.User32.GetClipCursor(r) Then
		      Return New REALbasic.Rect(r.left, r.top, r.right - r.left, r.bottom - r.top)
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub CursorConfinementArea(Assigns value As REALbasic.Rect)
		  ' Pass a Rectangle whose dimensions the mouse cursor should be confined within.
		  ' Passing NIL will remove any restrictions imposed by previous calls.
		  ' Only works as long as your app is frontmost
		  ' See: http://msdn.microsoft.com/en-us/library/ms648383.aspx
		  ' Call WinLib.GetLastError to determine whether this method succeeded (GetLastError=0).
		  
		  #If TargetWin32 Then
		    Dim r As Win32.RECT
		    If value <> Nil Then
		      r.top = value.Top
		      r.left = value.Left
		      r.bottom = value.Bottom
		      r.right = value.Right
		    End If
		    Call Win32.User32.ClipCursor(r)
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function DesktopComposition() As Boolean
		  ' Vista and newer. Returns true if desktop composition is enabled.
		  #If TargetWin32 Then
		    If System.IsFunctionAvailable("DwmIsCompositionEnabled", "Dwmapi") Then
		      Dim isenabled As Boolean
		      If Win32.Dwmapi.DwmIsCompositionEnabled(isenabled) = S_OK Then
		        Return isenabled
		      End If
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DesktopComposition(Assigns Enabled As Boolean)
		  ' Vista and newer. Temporarily disableds Aero glass and other eye candy. This is system-wide, so use sparingly and
		  ' make sure you revert when your app exits.
		  #If TargetWin32 Then
		    If System.IsFunctionAvailable("DwmEnableComposition", "Dwmapi") Then
		      If Enabled Then
		        Call Win32.Dwmapi.DwmEnableComposition(1)
		      Else
		        Call Win32.Dwmapi.DwmEnableComposition(0)
		      End If
		    End If
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function FindWindow(WindowName As String, WindowClass As String) As WindowRef
		  #If TargetWin32 Then
		    Dim HWND, err as integer
		    Dim mbclass, mbname As MemoryBlock
		    mbclass = WindowClass
		    mbname = WindowName
		    HWND = Win32.User32.FindWindow(mbname, mbclass)
		    err = GetLastError
		    While HWND <= 0 And err = 0
		      HWND = Win32.User32.GetWindow(HWND, GW_HWNDNEXT)
		      err = GetLastError
		    wend
		    If err = 0 Then Return New WindowRef(HWND)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetDesktopWindow() As WindowRef
		  #If TargetWin32 Then
		    Dim HWND As Integer = Win32.User32.GetDesktopWindow
		    Return New WindowRef(HWND)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function LoadFontFile(FontFile As FolderItem) As Boolean
		  Dim flags As Integer = FR_PRIVATE
		  #If TargetWin32 Then
		    Return Win32.GDI32.AddFontResourceEx(FontFile.AbsolutePath, flags, 0) > 0
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function PostMessage(Recipient As WindowRef, Message As Integer, WParam As Ptr, LParam As Ptr) As Boolean
		  'Posts the Window Message to the target window's message queue and returns immediately
		  #If TargetWin32 Then
		    Return Win32.User32.PostMessage(Recipient.Handle, Message, WParam, LParam)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function SendMessage(Recipient As WindowRef, Message As Integer, WParam As Ptr, LParam As Ptr) As Integer
		  'Sends the Window Message to the target window and waits for a response
		  #If TargetWin32 Then
		    Return Win32.User32.SendMessage(Recipient.Handle, Message, WParam, LParam)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ShellExecute(Target As String, Parameters As String = "", Operation As String = "open", WorkingDirectory As String = "", ParentWindow As Integer = 0, ShowCommand As Integer = SW_SHOW) As Boolean
		  #If TargetWin32 Then
		    If WorkingDirectory = "" Then WorkingDirectory = CurrentDirectory.AbsolutePath
		    Return Win32.Shell32.ShellExecute(ParentWindow, Operation, Target, Parameters, WorkingDirectory, ShowCommand) > 32
		    
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function UnloadFontFile(FontFile As FolderItem) As Boolean
		  Dim flags As Integer = FR_PRIVATE
		  #If TargetWin32 Then
		    Return Win32.GDI32.RemoveFontResourceEx(FontFile.AbsolutePath, flags, 0)
		  #endif
		End Function
	#tag EndMethod


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
