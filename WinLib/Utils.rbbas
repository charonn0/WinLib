#tag Module
Protected Module Utils
	#tag Method, Flags = &h1
		Protected Function Compress(Data As MemoryBlock, ChunkLen As Integer = 4096) As MemoryBlock
		  ' based on WFS
		  #If TargetWin32 Then
		    Dim engine As Integer = COMPRESSION_FORMAT_LZNT1
		    Dim sz, outsize  As Integer
		    If Win32.NTDLL.RtlGetCompressionWorkSpaceSize(engine, sz, outsize) = 0 Then
		      Dim workspace As New MemoryBlock(sz)
		      Dim output As New MemoryBlock(sz)
		      If Win32.NTDLL.RtlCompressBuffer(engine, data, data.Size, output, output.Size, ChunkLen, outsize, workspace) <> 0 Then
		        Break
		      Else
		        Return output.StringValue(0, outsize)
		      End If
		    End If
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
		Protected Function Decompress(Data As MemoryBlock) As MemoryBlock
		  #If TargetWin32 Then
		    Dim sizeneeded As Integer
		    Dim output As New MemoryBlock(data.Size)
		    Dim engine As Integer = COMPRESSION_FORMAT_LZNT1
		    
		    If Win32.NTDLL.RtlDecompressBuffer(engine, output, output.Size, Data, Data.Size, sizeneeded) <> 0 Then
		      output = New MemoryBlock(sizeneeded)
		      If Win32.NTDLL.RtlDecompressBuffer(engine, output, output.Size, Data, Data.Size, sizeneeded) <> 0 Then
		        Break
		      End If
		    End If
		    
		    Return output.StringValue(0, sizeneeded)
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
		    If WinLib.Utils.SetPrivilege(SE_SHUTDOWN_NAME, True) Then
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
		Protected Function IsAdministrator() As Boolean
		  //Returns true if the application is running with administrative privileges
		  
		  #If TargetWin32 Then
		    Return Win32.Shell32.IsUserAnAdmin()
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
		Protected Function SetPrivilege(PrivilegeName As String, Enabled As Boolean) As Boolean
		  //Modifies the calling process' security token
		  //See the SE_* Constants for privilege names.
		  //Returns 0 on success, or a Win32 error number on failure.
		  #If TargetWin32 Then
		    Dim luid As New MemoryBlock(8)
		    If Win32.AdvApi32.LookupPrivilegeValue(Nil, PrivilegeName, luid) Then
		      Dim newState As New MemoryBlock(16)
		      newState.UInt32Value(0) = 1
		      newState.UInt32Value(4) = luid.UInt32Value(0)
		      newState.UInt32Value(8) = luid.UInt32Value(4)
		      If Enabled Then
		        newState.UInt32Value(12) = SE_PRIVILEGE_ENABLED
		      Else
		        newState.UInt32Value(12) = SE_PRIVILEGE_REMOVED
		      End If
		      
		      Dim retLen As Integer
		      Dim prevPrivs As Ptr
		      Dim TokenHandle As Integer
		      If Win32.AdvApi32.OpenProcessToken(WinLib.Utils.CurrentProcessID, TOKEN_ADJUST_PRIVILEGES Or TOKEN_QUERY, TokenHandle) Then
		        Return Win32.AdvApi32.AdjustTokenPrivileges(TokenHandle, False, newState, newState.Size, prevPrivs, retLen)
		      End If
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Tokenize(Input As String) As String()
		  //Returns a String array containing the space-delimited members of the Input string.
		  //Like `String.Split(" ")` but honoring quotes
		  
		  #If TargetWin32 Then
		    Dim ret() As String
		    Dim cmdLine As String = Input
		    While cmdLine.Len > 0
		      Dim tmp As String
		      Dim args As String = Win32.Shlwapi.PathGetArgs(cmdLine)
		      If Len(args) = 0 Then
		        tmp = ReplaceAll(cmdLine.Trim, Chr(34), "")
		        ret.Append(tmp)
		        Exit While
		      Else
		        tmp = Left(cmdLine, cmdLine.Len - args.Len).Trim
		        tmp = ReplaceAll(tmp, Chr(34), "")
		        ret.Append(tmp)
		        cmdLine = args
		      End If
		    Wend
		    Return ret
		  #endif
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function UserName() As String
		  //Returns the username of the account under which the application is running.
		  //On Error, returns an empty string
		  
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
		Protected Function UUID() As String
		  Dim mUUID As String
		  #If TargetWin32 Then
		    Static mb As New MemoryBlock(16)
		    Call Win32.Rpcrt4.UuidCreate(mb) //can compare to RPC_S_UUID_LOCAL_ONLY and RPC_S_UUID_NO_ADDRESS for more info
		    Static ptrUUID As New MemoryBlock(16)
		    Dim ppAddr As ptr
		    Call Win32.Rpcrt4.UuidToString(mb, ppAddr)
		    Dim mb2 As MemoryBlock = ppAddr
		    mUUID = mb2.CString(0)
		    Call Win32.Rpcrt4.RpcStringFree(ptrUUID)
		  #endif
		  Return mUUID
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
