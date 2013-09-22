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
		Protected Function ExtractIcon(Resource as FolderItem, Index As Integer, pixSize As Integer = 32) As Picture
		  //Extracts the specified Icon resource into a RB Picture. Returns Nil on error.
		  //Icons are located in EXE, DLL, etc. type files, and are referenced by their index.
		  
		  #If TargetWin32 Then
		    Dim theIcon As Picture = New Picture(pixsize, pixsize, 32)
		    theIcon.Transparent = 1
		    
		    Dim largeIco As New MemoryBlock(4)
		    Try
		      Call Win32.Shell32.ExtractIconEx(resource.AbsolutePath, Index, largeIco, Nil, 1)
		      Call Win32.User32.DrawIconEx(theIcon.Graphics.Handle(Graphics.HandleTypeHDC), 0, 0, largeIco.Int32Value(0), pixsize, pixsize, 0, 0, &h3)
		    Catch
		      Call Win32.User32.DestroyIcon(largeIco.Int32Value(0))
		      Return Nil
		    End Try
		    Call Win32.User32.DestroyIcon(largeIco.Int32Value(0))
		    Return theIcon
		  #endif
		  
		Exception
		  Return Nil
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function FindFirstWindow(WindowName As String, WindowClass As String = "") As WindowRef
		  #If TargetWin32 Then
		    Dim HWND, err as integer
		    Dim mbclass, mbname As MemoryBlock
		    mbclass = WindowClass
		    mbname = WindowName
		    HWND = Win32.User32.FindWindow(mbname, mbclass)
		    err = GetLastError
		    If err = 0 Then Return New WindowRef(HWND)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function FindNextWindow(FindRef As WindowRef) As WindowRef
		  #If TargetWin32 Then
		    Dim HWND, err as integer
		    HWND = Win32.User32.GetWindow(FindRef.Handle, GW_HWNDNEXT)
		    err = GetLastError
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
		Protected Function ListWindows(PartialTitle As String = "") As WindowRef()
		  #If TargetWin32 Then
		    Dim wins() As WindowRef
		    Dim ret as integer
		    ret = Win32.User32.FindWindow(Nil, Nil)
		    Dim hidden() As String = Split("MSCTFIME UI,Default IME,Jump List,Start Menu,Start,Program Manager", ",")
		    while ret > 0
		      Dim pw As New WindowRef(ret)
		      If pw.Text.Trim <> "" And hidden.IndexOf(pw.Text.Trim) <= -1 And pw.Visible Then
		        If PartialTitle.Trim = "" Or InStr(pw.Text, PartialTitle) > 0 Then
		          wins.Append(pw)
		        End If
		      End If
		      ret = Win32.User32.GetWindow(ret, GW_HWNDNEXT)
		    wend
		    Return wins
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
		Protected Function Pixel(X As Integer, Y As Integer) As Color
		  // This method replaces System.Pixel which has been removed from RB as of RS2012R2
		  
		  Dim p As Picture = CaptureRect(X, Y, 2, 2)
		  If p <> Nil Then
		    Return p.RGBSurface.Pixel(1, 1)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function PostMessage(Recipient As Win32Object, Message As Integer, WParam As Ptr, LParam As Ptr) As Boolean
		  'Posts the Window Message to the target window's message queue and returns immediately
		  #If TargetWin32 Then
		    Return Win32.User32.PostMessage(Recipient.Handle, Message, WParam, LParam)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function SendMessage(Recipient As Win32Object, Message As Integer, WParam As Ptr, LParam As Ptr) As Integer
		  'Sends the Window Message to the target window and waits for a response
		  #If TargetWin32 Then
		    Return Win32.User32.SendMessage(Recipient.Handle, Message, WParam, LParam)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub SetWindowStyle(HWND As Integer, flag As Integer, Assigns b As Boolean)
		  #If TargetWin32 Then
		    Dim oldFlags as Integer
		    Dim newFlags as Integer
		    
		    oldFlags = Win32.User32.GetWindowLong(HWND, GWL_STYLE)
		    
		    If Not b Then
		      newFlags = BitAnd(oldFlags, Bitwise.OnesComplement(flag))
		    Else
		      newFlags = BitOr(oldFlags, flag)
		    End
		    
		    Call Win32.User32.SetWindowLong(HWND, GWL_STYLE, newFlags)
		    Call Win32.User32.SetWindowPos(HWND, 0, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED)
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub SetWindowStyleEx(HWND As Integer, flag As Integer, Assigns b As Boolean)
		  #If TargetWin32 Then
		    Dim oldFlags as Integer
		    Dim newFlags as Integer
		    
		    oldFlags = Win32.User32.GetWindowLong(HWND, GWL_EXSTYLE)
		    
		    If Not b Then
		      newFlags = BitAnd(oldFlags, Bitwise.OnesComplement(flag)) 'turn off
		    Else
		      newFlags = BitOr(oldFlags, flag)  'turn on
		    End
		    
		    Call Win32.User32.SetWindowLong(HWND, GWL_EXSTYLE, newFlags)
		    Call Win32.User32.SetWindowPos(HWND, 0, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED)
		  #endif
		End Sub
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
		Protected Function TestWindowStyle(HWND As Integer, flag As Integer) As Boolean
		  #if TargetWin32
		    Dim oldFlags as Integer
		    oldFlags = Win32.User32.GetWindowLong(HWND, GWL_STYLE)
		    
		    Return BitAnd(oldFlags, flag) = flag
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function TestWindowStyleEx(HWND As Integer, flag As Integer) As Boolean
		  #if TargetWin32
		    Dim oldFlags as Integer
		    oldFlags = Win32.User32.GetWindowLong(HWND, GWL_EXSTYLE)
		    
		    Return BitAnd(oldFlags, flag) = flag
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

	#tag Method, Flags = &h1
		Protected Function WindowFromXY(X As Integer, Y As Integer) As WindowRef
		  #If TargetWin32 Then
		    Dim p As Win32.POINT
		    p.X = X
		    p.Y = Y
		    Dim hwnd As Integer = Win32.User32.WindowFromPoint(p)
		    If hwnd > 0 Then
		      If Win32.User32.ChildWindowFromPoint(hwnd, p) > 0 Then
		        hwnd = Win32.User32.ChildWindowFromPoint(hwnd, p)
		      End If
		    End If
		    Return New WindowRef(hwnd)
		  #endif
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  ' Returns a Rectangle within which the mouse cursor is currently allowed move.
			  #If TargetWin32 Then
			    Dim r As RECT
			    If Win32.User32.GetClipCursor(r) Then
			      Return New REALbasic.Rect(r.left, r.top, r.right - r.left, r.bottom - r.top)
			    End If
			  #endif
			End Get
		#tag EndGetter
		#tag Setter
			Set
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
			End Set
		#tag EndSetter
		Protected CursorConfinementArea As REALbasic.Rect
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  ' Vista and newer. Returns true if desktop composition is enabled.
			  #If TargetWin32 Then
			    If System.IsFunctionAvailable("DwmIsCompositionEnabled", "Dwmapi") Then
			      Dim isenabled As Boolean
			      If Win32.Dwmapi.DwmIsCompositionEnabled(isenabled) = S_OK Then
			        Return isenabled
			      End If
			    End If
			  #endif
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  ' Vista and newer. Temporarily disableds Aero glass and other eye candy. This is system-wide, so use sparingly and
			  ' make sure you revert when your app exits.
			  #If TargetWin32 Then
			    If System.IsFunctionAvailable("DwmEnableComposition", "Dwmapi") Then
			      If value Then
			        Call Win32.Dwmapi.DwmEnableComposition(1)
			      Else
			        Call Win32.Dwmapi.DwmEnableComposition(0)
			      End If
			    End If
			  #endif
			End Set
		#tag EndSetter
		Protected DesktopComposition As Boolean
	#tag EndComputedProperty


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
