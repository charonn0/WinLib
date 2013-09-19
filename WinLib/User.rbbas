#tag Module
Protected Module User
	#tag Method, Flags = &h1
		Protected Function IsAdministrator() As Boolean
		  //Returns true if the application is running with administrative privileges
		  
		  #If TargetWin32 Then
		    Return Win32.Shell32.IsUserAnAdmin()
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Name() As String
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
		      If Win32.AdvApi32.OpenProcessToken(WinLib.System.CurrentProcessID, TOKEN_ADJUST_PRIVILEGES Or TOKEN_QUERY, TokenHandle) Then
		        Return Win32.AdvApi32.AdjustTokenPrivileges(TokenHandle, False, newState, newState.Size, prevPrivs, retLen)
		      End If
		    End If
		  #endif
		End Function
	#tag EndMethod


End Module
#tag EndModule
