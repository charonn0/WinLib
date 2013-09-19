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
		Protected Function GetDesktopWindow() As WinLib.WindowRef
		  Dim HWND As Integer = Win32.User32.GetDesktopWindow
		  Return New WinLib.WindowRef(HWND)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function LoadFontFile(FontFile As FolderItem) As Boolean
		  Dim flags As Integer = FR_PRIVATE
		  Return Win32.GDI32.AddFontResourceEx(FontFile.AbsolutePath, flags, 0) > 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function UnloadFontFile(FontFile As FolderItem) As Boolean
		  Dim flags As Integer = FR_PRIVATE
		  Return Win32.GDI32.RemoveFontResourceEx(FontFile.AbsolutePath, flags, 0)
		End Function
	#tag EndMethod


End Module
#tag EndModule
