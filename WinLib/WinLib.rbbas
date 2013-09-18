#tag Module
Protected Module WinLib
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
		Protected Function CloseHandle(Handle As Integer) As Boolean
		  #If TargetWin32 Then
		    Return Win32.Kernel32.CloseHandle(Handle)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function CurrentProcessID() As Integer
		  #If TargetWin32 Then
		    Return Win32.Kernel32.GetCurrentProcess()
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function CurrentUser() As String
		  //Returns the username of the account under which the application is running.
		  //On Error, returns an empty string
		  //Do not use this function to determine if the user is the Administrator. Use IsAdmin instead.
		  
		  #If TargetWin32 Then
		    Dim mb As New MemoryBlock(0)
		    Dim nmLen As Integer = mb.Size
		    If Not Win32.AdvApi32.GetUserName(mb, nmLen) Then Return ""
		    mb = New MemoryBlock(nmLen * 2)
		    nmLen = mb.Size
		    If Win32.AdvApi32.GetUserName(mb, nmLen) Then
		      Return mb.WString(0)
		    Else
		      Return ""
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function DesktopComposition() As Boolean
		  ' Vista and newer. Returns true if desktop composition is enabled.
		  #If TargetWin32 Then
		    If System.IsFunctionAvailable("DwmIsCompositionEnabled", "Dwmapi") Then
		      Dim isenabled As Boolean
		      If Win32.Dwmapi.DwmIsCompositionEnabled(isenabled) = S_OK Then
		        Return isenabled
		      Else
		        Return False
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
		Protected Function ExitWindows(Mode As Integer, Reason As Integer, ForceIfHung As Boolean) As Integer
		  //Shuts down, reboots, or logs off the computer. Returns 0 on success, or a Win32 error code on error.
		  // The reason code may be any code(s) documented here: http://msdn.microsoft.com/en-us/library/aa376885%28v=vs.85%29.aspx
		  // If ForceIfHung=True then Windows forces processes to terminate if they do not respond to end-of-session messages within a timeout interval.
		  // Mode can be one of the following:
		  // EWX_LOGOFF  (all Windows versions)
		  // EWX_REBOOT  (all Windows versions)
		  // EWX_SHUTDOWN  (all Windows versions)
		  // EWX_HYBRID_SHUTDOWN
		  // EWX_POWEROFF
		  // EWX_RESTARTAPPS
		  
		  If ForceIfHung Then Mode = Mode Or EWX_FORCEIFHUNG
		  #If TargetWin32 Then
		    If SetPrivilege(SE_SHUTDOWN_NAME, True) Then
		      Call Win32.User32.ExitWindowsEx(mode, reason)
		    End If
		    Return WinLib.GetLastError()
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function FormatError(WinErrorNumber As Integer) As String
		  //Returns the error message corresponding to a given windows error number.
		  
		  #If TargetWin32 Then
		    Dim buffer As New MemoryBlock(2048)
		    If Win32.Kernel32.FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, 0, WinErrorNumber, 0 , Buffer, Buffer.Size, 0) <> 0 Then
		      Return Buffer.WString(0)
		    Else
		      Return "Unknown error number: " + Str(WinErrorNumber)
		    End If
		  #Else
		    Return "Not a Windows system. Error number: " + Str(WinErrorNumber)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetLastError() As Integer
		  #If TargetWin32 Then
		    Return Win32.Kernel32.GetLastError()
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetSystemMetric(Index As Integer) As Integer
		  #If TargetWin32 Then
		    Return Win32.User32.GetSystemMetrics(Index)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function KernelVersion() As Double
		  //Returns the Kernel version of Windows as a Double (MajorVersion.MinorVersion)
		  //For example, Windows 2000 returns 5.0, XP Returns 5.1, Vista Returns 6.0 and Windows 7 returns 6.1
		  //On error, returns 0.0
		  
		  #If TargetWin32 Then
		    Return Win32.OSVersion.MajorVersion + (Win32.OSVersion.MinorVersion / 10)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function LoadFontFile(FontFile As FolderItem) As Boolean
		  Dim flags As Integer = FR_PRIVATE
		  Return Win32.GDI32.AddFontResourceEx(FontFile.AbsolutePath, flags, 0) > 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function SetPrivilege(PrivilegeName As String, Enabled As Boolean) As Boolean
		  //Modifies the calling process' security token
		  //See the SE_* Constants for privilege names.
		  //Returns 0 on success, or a Win32 error number on failure.
		  #If TargetWin32 Then
		    Dim luid As New MemoryBlock(8)
		    Dim mode As Integer
		    If Enabled Then
		      mode = SE_PRIVILEGE_ENABLED
		    Else
		      mode = SE_PRIVILEGE_ENABLED
		    End If
		    If Win32.AdvApi32.LookupPrivilegeValue(Nil, PrivilegeName, luid) Then
		      Dim newState As New MemoryBlock(16)
		      newState.UInt32Value(0) = 1
		      newState.UInt32Value(4) = luid.UInt32Value(0)
		      newState.UInt32Value(8) = luid.UInt32Value(4)
		      newState.UInt32Value(12) = mode  //mode can be enable, disable, or remove. See: Enable, Disable, and Drop.
		      Dim retLen As Integer
		      Dim prevPrivs As Ptr
		      Dim TokenHandle As Integer
		      If Win32.AdvApi32.OpenProcessToken(CurrentProcessID, TOKEN_ADJUST_PRIVILEGES Or TOKEN_QUERY, TokenHandle) Then
		        Return Win32.AdvApi32.AdjustTokenPrivileges(TokenHandle, False, newState, newState.Size, prevPrivs, retLen)
		      End If
		    End If
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
		  Return Win32.GDI32.RemoveFontResourceEx(FontFile.AbsolutePath, flags, 0)
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Dim mb As New MemoryBlock(1024)
			    Dim i As Integer
			    Do
			      i = Win32.Kernel32.GetCurrentDirectory(mb.Size, mb)
			    Loop Until i <= mb.Size And i > 0
			    
			    Return GetFolderItem(mb.WString(0), FolderItem.PathTypeAbsolute)
			  #endif
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If TargetWin32 Then
			    Dim path As String = value.AbsolutePath
			    If Not Win32.Kernel32.SetCurrentDirectory(path) Then
			      Dim e As Integer = WinLib.GetLastError
			      Dim err As New IOException
			      err.Message = CurrentMethodName + ": " + WinLib.FormatError(e)
			      err.ErrorNumber = e
			      Raise err
			    End If
			  #endif
			End Set
		#tag EndSetter
		Protected CurrentDirectory As FolderItem
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  ' Returns a Rectangle within which the mouse cursor is currently allowed move.
			  Dim r As RECT
			  If Win32.User32.GetClipCursor(r) Then
			    Return New REALbasic.Rect(r.left, r.top, r.right - r.left, r.bottom - r.top)
			  End If
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  ' Pass a Rectangle whose dimensions the mouse cursor should be confined within.
			  ' Passing NIL will remove any restrictions imposed by previous calls.
			  ' Only works as long as your app is frontmost
			  ' See: http://msdn.microsoft.com/en-us/library/ms648383.aspx
			  ' Call WinLib.GetLastError to determine whether this method succeeded (GetLastError=0).
			  
			  Dim r As Win32.RECT
			  If value <> Nil Then
			    r.top = value.Top
			    r.left = value.Left
			    r.bottom = value.Bottom
			    r.right = value.Right
			  End If
			  Call Win32.User32.ClipCursor(r)
			End Set
		#tag EndSetter
		Protected CursorConfinementArea As REALbasic.Rect
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
