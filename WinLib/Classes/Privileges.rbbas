#tag Class
Protected Class Privileges
	#tag Method, Flags = &h1
		Protected Sub AdjustPrivilegeToken(PrivilegeName As String, Mode As Integer)
		  //Modifies the calling process' security token
		  //See the SE_* Constants in Win32Constants for privilege names.
		  //Returns 0 on success, or a Win32 error number on failure.
		  #If TargetWin32 Then
		    Dim luid As New MemoryBlock(8)
		    If WinLib.AdvApi32.LookupPrivilegeValue(Nil, PrivilegeName, luid) Then
		      Dim newState As New MemoryBlock(16)
		      newState.UInt32Value(0) = 1
		      newState.UInt32Value(4) = luid.UInt32Value(0)
		      newState.UInt32Value(8) = luid.UInt32Value(4)
		      newState.UInt32Value(12) = mode  //mode can be enable, disable, or remove. See: Enable, Disable, and Drop.
		      Dim retLen As Integer
		      Dim prevPrivs As Ptr
		      If Not WinLib.AdvApi32.AdjustTokenPrivileges(TokenHandle, False, newState, newState.Size, prevPrivs, retLen) Then
		        Raise New Win32Exception(GetLastError)
		      End If
		      Break
		    Else
		      Raise New Win32Exception(GetLastError)
		    End If
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Constructor(ProcessID As Integer)
		  mProcessID = ProcessID
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Disable(PrivilegeName As String) As Boolean
		  //This function attempts to disable the privilege designated by PrivilegeName in the process' security token.
		  //Privilege names are documented here: http://msdn.microsoft.com/en-us/library/windows/desktop/bb530716%28v=vs.85%29.aspx
		  //This function will fail and return False if the processes security token did not already posess the requested privilege, if the privilege
		  //requested does not exist, if the process does not have TOKEN_ADJUST_PRIVILEGES and TOKEN_QUERY access to itself, or if the Privilege was not
		  //previously enabled.
		  
		  #If TargetWin32 Then
		    AdjustPrivilegeToken(PrivilegeName, 0)
		    Return  WinLib.GetLastError = 0
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Drop(PrivilegeName As String) As Boolean
		  //This function attempts remove the privilege designated by PrivilegeName in the process' security token. This is different
		  //from merely disabling the Privilege since future attempts to enable it will fail with ERROR_PRIVILEGE_NOT_HELD.
		  //Once a privilege is dropped, it cannot be reacquired.
		  //On Windows XP SP1 and earlier, privileges cannot be dropped.
		  //Privilege names are documented here: http://msdn.microsoft.com/en-us/library/windows/desktop/bb530716%28v=vs.85%29.aspx
		  //This function will fail and return False if the processes security token did not already posess the requested privilege, if the privilege
		  //requested does not exist, or if the process does not have TOKEN_ADJUST_PRIVILEGES and TOKEN_QUERY access to itself.
		  
		  #If TargetWin32 Then
		    AdjustPrivilegeToken(PrivilegeName, SE_PRIVILEGE_REMOVED)
		    Return WinLib.GetLastError = 0
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Enable(PrivilegeName As String) As Boolean
		  //This function attempts to enable the privilege designated by PrivilegeName in the process' security token.
		  //Privilege names are documented here: http://msdn.microsoft.com/en-us/library/windows/desktop/bb530716%28v=vs.85%29.aspx
		  //This function will fail and return False if the processes security token did not already posess the requested privilege, if the privilege
		  //requested does not exist, or if the process does not have TOKEN_ADJUST_PRIVILEGES and TOKEN_QUERY access to itself.
		  
		  #If TargetWin32 Then
		    AdjustPrivilegeToken(PrivilegeName, SE_PRIVILEGE_ENABLED)
		    Return WinLib.GetLastError = 0
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function IsAdmin() As Boolean
		  //Returns true if the application is running with administrative privileges
		  //Note that even if this Returns True, that not all privileges many be enabled. See: Enable
		  
		  #If TargetWin32 Then
		    Return WinLib.Shell32.IsUserAnAdmin()
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function IsServiceAccount(Accountname As String) As Boolean
		  #If TargetWin32 Then
		    If System.IsFunctionAvailable("NetIsServiceAccount", "Netapi") Then
		      Dim ret As Boolean
		      Call WinLib.Netapi32.NetIsServiceAccount(Nil, Accountname, ret)
		      Return ret
		    End If
		  #endif
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If mInstance = Nil Then mInstance = New WinLib.Classes.Privileges(WinLib.CurrentProcessID)
			  Return mInstance
			End Get
		#tag EndGetter
		Shared Instance As WinLib.Classes.Privileges
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private Shared mInstance As WinLib.Classes.Privileges
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mProcessID As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTokenHandle As Integer = INVALID_HANDLE_VALUE
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mProcessID
			End Get
		#tag EndGetter
		ProcessID As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #If TargetWin32 Then
			    If mTokenHandle = INVALID_HANDLE_VALUE Then
			      If Not WinLib.AdvApi32.OpenProcessToken(WinLib.CurrentProcessID, TOKEN_ADJUST_PRIVILEGES Or TOKEN_QUERY, mTokenHandle) Then Return INVALID_HANDLE_VALUE
			    End If
			  #endif
			  Return mTokenHandle
			End Get
		#tag EndGetter
		TokenHandle As Integer
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
			Name="ProcessID"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TokenHandle"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
