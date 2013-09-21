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
		    Return GetLastError()
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
		Protected Function HeapAlloc(Size As Integer, ZeroMemory As Boolean = True) As MemoryBlock
		  ' Use this method to allocate a block of memory from the default heap. You MUST call HeapFree with the same value returned from HeapAlloc
		  ' in order to free the memory. If ZeroMemory=True, all needed pages are securely zeroed-out before allocation.
		  ' Allocating memoryblocks from the heap should only be done if the memory will be passed back to the app by the OS (e.g. for the WParam 
		  ' and LParam parameters to a window message.)
		  ' The size of the allocated MemoryBlock will be *at least* the size requested.
		  ' NOTE: The memory allocated by this method cannot be paged out
		  
		  Dim heap As Integer = Win32.Kernel32.GetProcessHeap
		  Dim flags As Integer
		  If ZeroMemory Then
		    flags = HEAP_ZERO_MEMORY
		  End If
		  Return Win32.Kernel32.HeapAlloc(heap, flags, Size)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HeapFree(HMB As Ptr) As Boolean
		  Dim heap As Integer = Win32.Kernel32.GetProcessHeap
		  Return Win32.Kernel32.HeapFree(heap, 0, HMB)
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
