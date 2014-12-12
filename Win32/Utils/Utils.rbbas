#tag Module
Protected Module Utils
	#tag Method, Flags = &h1
		Protected Function Compress(Data As MemoryBlock, ChunkLen As Integer = 4096) As MemoryBlock
		  ' based on WFS
		  #If TargetWin32 Then
		    Dim engine As Integer = COMPRESSION_FORMAT_LZNT1
		    Dim sz, outsize  As Integer
		    If Win32.Libs.NTDLL.RtlGetCompressionWorkSpaceSize(engine, sz, outsize) = 0 Then
		      Dim workspace As New MemoryBlock(sz)
		      Dim output As New MemoryBlock(sz)
		      If Win32.Libs.NTDLL.RtlCompressBuffer(engine, data, data.Size, output, output.Size, ChunkLen, outsize, workspace) <> 0 Then
		        Break
		      Else
		        Return output.StringValue(0, outsize)
		      End If
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Decompress(Data As MemoryBlock) As MemoryBlock
		  #If TargetWin32 Then
		    Dim sizeneeded As Integer
		    Dim output As New MemoryBlock(data.Size)
		    Dim engine As Integer = COMPRESSION_FORMAT_LZNT1
		    
		    If Win32.Libs.NTDLL.RtlDecompressBuffer(engine, output, output.Size, Data, Data.Size, sizeneeded) <> 0 Then
		      output = New MemoryBlock(sizeneeded)
		      If Win32.Libs.NTDLL.RtlDecompressBuffer(engine, output, output.Size, Data, Data.Size, sizeneeded) <> 0 Then
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
		    If Win32.Utils.SetPrivilege(SE_SHUTDOWN_NAME, True) Then
		      Call Win32.Libs.User32.ExitWindowsEx(mode, reason)
		    End If
		    Return Win32.LastError
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GenerateUUID() As String
		  #If TargetWin32 Then
		    Return Win32.Utils.UUID.NewUUID
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsAdministrator() As Boolean
		  //Returns true if the application is running with administrative privileges
		  
		  #If TargetWin32 Then
		    Return Win32.Libs.Shell32.IsUserAnAdmin()
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function LockWorkstation() As Boolean
		  #If TargetWin32 Then
		    Return Win32.Libs.User32.LockWorkStation()
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ProcessorCount() As Integer
		  //Returns the number of LOGICAL processor cores. e.g. a quad core processor with hyperthreading will have 8 logical cores.
		  
		  #If TargetWin32 Then
		    Return Win32.GetSystemInfo.numberOfProcessors
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function SetPrivilege(PrivilegeName As String, Enabled As Boolean) As Boolean
		  //Modifies the calling process' security token
		  //See the SE_* Constants for privilege names.
		  //Returns True on success
		  #If TargetWin32 Then
		    Dim luid As New MemoryBlock(8)
		    If Win32.Libs.AdvApi32.LookupPrivilegeValue(Nil, PrivilegeName, luid) Then
		      Dim newState As New MemoryBlock(16)
		      newState.UInt32Value(0) = 1
		      newState.UInt32Value(4) = luid.UInt32Value(0)
		      newState.UInt32Value(8) = luid.UInt32Value(4)
		      If Enabled Then
		        newState.UInt32Value(12) = SE_PRIVILEGE_ENABLED
		      Else
		        newState.UInt32Value(12) = 0
		      End If
		      
		      Dim retLen As Integer
		      Dim prevPrivs As Ptr
		      Dim TokenHandle As Integer
		      If Win32.Libs.AdvApi32.OpenProcessToken(Win32.CurrentProcessID, TOKEN_ADJUST_PRIVILEGES Or TOKEN_QUERY, TokenHandle) Then
		        Return Win32.Libs.AdvApi32.AdjustTokenPrivileges(TokenHandle, False, newState, newState.Size, prevPrivs, retLen)
		      End If
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Function ShutdownAbort() As Boolean
		  #If TargetWin32 Then
		    Return Win32.Libs.AdvApi32.AbortSystemShutdown("")
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Function ShutdownBlock(Reason As String, OwnerWindow As Window = Nil) As Boolean
		  #If TargetWin32 Then
		    ' Blocks system shutdown for the specified reason. The user may override a block.
		    ' Note that blocks only apply to shutdown operations started with InitiateShutdown,
		    ' not those started by calling ExitWindows
		    If OwnerWindow = Nil Then OwnerWindow = Window(0)
		    If Not System.IsFunctionAvailable("ShutdownBlockReasonCreate", "User32") Then Return False ' Vista and newer only
		    Return Win32.Libs.User32.ShutdownBlockReasonCreate(OwnerWindow.Handle, Reason)
		  #else
		    #pragma Unused Reason
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Function ShutdownBlockQuery(OwnerWindow As Window = Nil) As String
		  #If TargetWin32 Then
		    If Not System.IsFunctionAvailable("ShutdownBlockReasonQuery", "User32") Then Return "" ' Vista and newer only
		    If OwnerWindow = Nil Then OwnerWindow = Window(0)
		    Dim mb As New MemoryBlock(MAX_STR_BLOCKREASON)
		    Dim sz As Integer = mb.Size
		    If Win32.Libs.User32.ShutdownBlockReasonQuery(OwnerWindow.Handle, mb, sz) Then
		      Return mb.WString(0)
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Function ShutdownInitiate(Message As String = "", Reboot As Boolean = False, Timeout As Integer = 0, ForceQuit As Boolean = False, Reason As Integer = - 1) As Boolean
		  #If TargetWin32 Then
		    If Reason = -1 Then
		      Return Win32.Libs.AdvApi32.InitiateSystemShutdown("", Message.Trim, Timeout, ForceQuit, Reboot)
		    Else
		      Return Win32.Libs.AdvApi32.InitiateSystemShutdownEx("", Message.Trim, Timeout, ForceQuit, Reboot, Reason)
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, CompatibilityFlags = TargetHasGUI
		Protected Function ShutdownUnblock(OwnerWindow As Window = Nil) As Boolean
		  #If TargetWin32 Then
		    If Not System.IsFunctionAvailable("ShutdownBlockReasonDestroy", "User32") Then Return False ' Vista and newer only
		    If OwnerWindow = Nil Then OwnerWindow = Window(0)
		    Return Win32.Libs.User32.ShutdownBlockReasonDestroy(OwnerWindow.Handle)
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
		      Dim args As String = Win32.Libs.Shlwapi.PathGetArgs(cmdLine)
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


	#tag Constant, Name = COMPRESSION_ENGINE_MAXIMUM, Type = Double, Dynamic = False, Default = \"&h0100", Scope = Private
	#tag EndConstant

	#tag Constant, Name = COMPRESSION_ENGINE_STANDARD, Type = Double, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant

	#tag Constant, Name = COMPRESSION_FORMAT_LZNT1, Type = Double, Dynamic = False, Default = \"&h0002", Scope = Private
	#tag EndConstant

	#tag Constant, Name = EWX_FORCEIFHUNG, Type = Double, Dynamic = False, Default = \"&h00000010", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = GMEM_MOVEABLE, Type = Double, Dynamic = False, Default = \"&h0002", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = MAX_STR_BLOCKREASON, Type = Double, Dynamic = False, Default = \"256", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_ASSIGNPRIMARYTOKEN_NAME, Type = String, Dynamic = False, Default = \"SeAssignPrimaryTokenPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_AUDIT_NAME, Type = String, Dynamic = False, Default = \"SeAuditPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_BACKUP_NAME, Type = String, Dynamic = False, Default = \"SeBackupPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_CHANGE_NOTIFY_NAME, Type = String, Dynamic = False, Default = \"SeChangeNotifyPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_CREATE_GLOBAL_PRIVILEGE_NAME, Type = String, Dynamic = False, Default = \"SeCreateGlobalPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_CREATE_PAGEFILE_NAME, Type = String, Dynamic = False, Default = \"SeCreatePagefilePrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_CREATE_PERMANENT_NAME, Type = String, Dynamic = False, Default = \"SeCreatePermanentPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_CREATE_SYMBOLIC_LINK_NAME, Type = String, Dynamic = False, Default = \"SeCreateSymbolicLinkPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_CREATE_TOKEN_NAME, Type = String, Dynamic = False, Default = \"SeCreateTokenPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_DEBUG_PRIVILEGE, Type = String, Dynamic = False, Default = \"SeDebugPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_ENABLE_DELEGATAION_NAME, Type = String, Dynamic = False, Default = \"SeEnableDelegationPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_IMPERSONATE_NAME, Type = String, Dynamic = False, Default = \"SeImpersonatePrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_INCREASE_QUOTA_NAME, Type = String, Dynamic = False, Default = \"SeIncreaseQuotaPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_INC_BASE_PRIORITY_NAME, Type = String, Dynamic = False, Default = \"SeIncreaseBasePriorityPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_INC_WORKING_SET_NAME, Type = String, Dynamic = False, Default = \"SeIncreaseWorkingSetPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_LOAD_DRIVER_NAME, Type = String, Dynamic = False, Default = \"SeLoadDriverPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_LOCK_MEMORY_NAME, Type = String, Dynamic = False, Default = \"SeLockMemoryPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_MACHINE_ACCOUNT_NAME, Type = String, Dynamic = False, Default = \"SeMachineAccountPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_MANAGE_VOLUME_NAME, Type = String, Dynamic = False, Default = \"SeManageVolumePrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_PRIVILEGE_ENABLED, Type = Double, Dynamic = False, Default = \"&h00000002", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_PRIVILEGE_REMOVED, Type = Double, Dynamic = False, Default = \"&h00000004", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_PROF_SINGLE_PROCESS_NAME, Type = String, Dynamic = False, Default = \"SeProfileSingleProcessPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_RELABLE_NAME, Type = String, Dynamic = False, Default = \"SeRelabelPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_REMOTE_SHUTDOWN_NAME, Type = String, Dynamic = False, Default = \"SeRemoteShutdownPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_RESTORE_NAME, Type = String, Dynamic = False, Default = \"SeRestorePrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_SECURITY_NAME, Type = String, Dynamic = False, Default = \"SeSecurityPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_SHUTDOWN_NAME, Type = String, Dynamic = False, Default = \"SeShutdownPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_SYNC_AGENT_NAME, Type = String, Dynamic = False, Default = \"SeSyncAgentPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_SYSTEMTIME_NAME, Type = String, Dynamic = False, Default = \"SeSystemtimePrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_SYSTEM_ENVIRONMENT_NAME, Type = String, Dynamic = False, Default = \"SeSystemEnvironmentPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_SYSTEM_PROFILE_NAME, Type = String, Dynamic = False, Default = \"SeSystemProfilePrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_TAKE_OWNERSHIP_NAME, Type = String, Dynamic = False, Default = \"SeTakeOwnershipPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_TCB_NAME, Type = String, Dynamic = False, Default = \"SeTcbPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_TIME_ZONE_NAME, Type = String, Dynamic = False, Default = \"SeTimeZonePrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_TRUSTED_CREDMAN_ACCESS_NAME, Type = String, Dynamic = False, Default = \"SeTrustedCredManAccessPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_UNDOCK_NAME, Type = String, Dynamic = False, Default = \"SeUndockPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SE_UNSOLICITED_INPUT_NAME, Type = String, Dynamic = False, Default = \"SeUnsolicitedInputPrivilege", Scope = Private
	#tag EndConstant

	#tag Constant, Name = TOKEN_ADJUST_PRIVILEGES, Type = Double, Dynamic = False, Default = \"&h00000020", Scope = Private
	#tag EndConstant

	#tag Constant, Name = TOKEN_QUERY, Type = Double, Dynamic = False, Default = \"&h00000008", Scope = Private
	#tag EndConstant


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
