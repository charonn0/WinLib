#tag Module
Protected Module System
	#tag Method, Flags = &h1
		Protected Function CurrentProcessID() As Integer
		  #If TargetWin32 Then
		    Return Win32.Kernel32.GetCurrentProcess()
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
		    If WinLib.User.SetPrivilege(SE_SHUTDOWN_NAME, True) Then
		      Call Win32.User32.ExitWindowsEx(mode, reason)
		    End If
		    Return WinLib.GetLastError()
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


End Module
#tag EndModule
