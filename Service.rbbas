#tag Class
Protected Class Service
Implements WinLib.Win32Object
	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the WinLib.Win32Object interface.
		  Call Win32.AdvApi32.CloseServiceHandle(Me.ServiceHandle)
		  
		  Dim d As Dictionary = SCHandles.Value(Me.SCRef)
		  d.Value("Count") = d.Value("Count") - 1
		  If d.Value("Count") <= 0 Then
		    Dim h As Integer = d.Value("Handle")
		    Call Win32.AdvApi32.CloseServiceHandle(h)
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Constructor(Handle As Integer)
		  ServiceHandle = Handle
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DisplayName() As String
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return ServiceHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Name() As String
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function OpenService(ServiceName As String, MachineName As String = "", DatabaseName As String = "", DesiredAccess As Integer = SC_MANAGER_ALL_ACCESS) As Service
		  If SCHandles = Nil Then SCHandles = New Dictionary
		  Dim sHandle, mhandle, err As Integer
		  If SCHandles.HasKey(MachineName:DatabaseName:DesiredAccess) Then
		    Dim d As Dictionary = SCHandles.Value(MachineName:DatabaseName:DesiredAccess)
		    sHandle = d.Value("Handle")
		    err = 0
		  Else
		    sHandle = Win32.AdvApi32.OpenSCManager(MachineName, DatabaseName, SC_MANAGER_ALL_ACCESS)
		    err = WinLib.GetLastError
		    If err = 0 Then
		      Dim d As New Dictionary
		      d.Value("Handle") = sHandle
		      d.Value("Count") = d.Value("Count") + 1
		      SCHandles.Value(MachineName:DatabaseName:DesiredAccess) = d
		    End If
		  End If
		  If err <> 0 Then Return Nil
		  mhandle = Win32.AdvApi32.OpenService(sHandle, ServiceName, DesiredAccess)
		  err = WinLib.GetLastError
		  If err = 0 Then
		    Return New Service(mhandle)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function QueryConfig() As MemoryBlock
		  #If TargetWin32 Then
		    Dim sz As Integer
		    Call Win32.AdvApi32.QueryServiceConfig(Me.ServiceHandle, Nil, 0, sz)
		    Dim mb As New MemoryBlock(sz)
		    Call Win32.AdvApi32.QueryServiceConfig(Me.ServiceHandle, mb, mb.Size, sz)
		    Return mb
		  #endif
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Shared SCHandles As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected SCRef As Variant
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected ServiceHandle As Integer = INVALID_HANDLE_VALUE
	#tag EndProperty


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
End Class
#tag EndClass
