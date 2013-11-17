#tag Class
Protected Class Service
Implements WinLib.Win32Object
	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the WinLib.Win32Object interface.
		  CloseService(ServiceHandle)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Sub CloseService(ServiceHandle As Integer)
		  Call Win32.AdvApi32.CloseServiceHandle(ServiceHandle)
		  
		  Dim ref As String = SCHandles.Lookup(ServiceHandle, "")
		  If ref <> "" Then
		    Dim d As Dictionary = SCHandles.Value(ref)
		    d.Value("Count") = d.Value("Count") - 1
		    If d.Value("Count") <= 0 Then
		      ' No more references to this controller
		      Dim h As Integer = d.Value("Handle")
		      Call Win32.AdvApi32.CloseServiceHandle(h)
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Constructor(Handle As Integer)
		  ServiceHandle = Handle
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Dependencies() As String()
		  Dim qc As MemoryBlock = QueryConfig
		  Dim i As Integer = LenB(qc.WString(12))
		  i = i + LenB(qc.WString(i)) + 4
		  Dim x As Integer = InStrB(i, qc, Chr(0) + Chr(0))
		  Return Split(qc.StringValue(i, x - i))
		  
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DisplayName() As String
		  Dim mb As MemoryBlock
		  Dim sz As Integer
		  Dim h As Integer = ManagerHandle(ServiceHandle)
		  Call Win32.AdvApi32.GetServiceDisplayName(h, Me.KeyName, Nil, sz)
		  mb = New MemoryBlock(sz * 2 + 1)
		  sz = mb.Size
		  If Win32.AdvApi32.GetServiceDisplayName(h, Me.KeyName, mb, sz) Then
		    mLastError = 0
		    Return mb.WString(0)
		  Else
		    mLastError = WinLib.GetLastError()
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ErrorControl() As Integer
		  Return QueryConfig.Int32Value(8)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Executable() As FolderItem
		  Return GetFolderItem(QueryConfig.WString(12))
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
		Function LoadOrderGroup() As String
		  Dim i As Integer = LenB(QueryConfig.WString(12))
		  Return QueryConfig.WString(i)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function ManagerHandle(ServiceHandle As Integer) As Integer
		  Dim ref As String = SCHandles.Lookup(ServiceHandle, "")
		  If ref <> "" Then
		    Dim d As Dictionary = SCHandles.Value(ref)
		    Return d.Value("Handle")
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Name() As String
		  Return KeyName
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function OpenService(ServiceName As String, MachineName As String = "", DatabaseName As String = "", DesiredAccess As Integer = -1) As Service
		  If DesiredAccess = -1 Then DesiredAccess = SC_MANAGER_CONNECT Or SC_MANAGER_ENUMERATE_SERVICE
		  If DatabaseName = "" Then DatabaseName = SERVICES_ACTIVE_DATABASE
		  If SCHandles = Nil Then SCHandles = New Dictionary
		  Dim sHandle, mhandle, err As Integer
		  If SCHandles.HasKey(MachineName + DatabaseName + Str(DesiredAccess)) Then
		    Dim d As Dictionary = SCHandles.Value(MachineName + DatabaseName + Str(DesiredAccess))
		    sHandle = d.Value("Handle")
		    d.Value("Count") = d.Value("Count") + 1
		    err = 0
		  Else
		    sHandle = Win32.AdvApi32.OpenSCManager(MachineName, DatabaseName, DesiredAccess)
		    err = WinLib.GetLastError
		    If err = 0 Then
		      Dim d As New Dictionary
		      d.Value("Handle") = sHandle
		      d.Value("Count") = 1
		      SCHandles.Value(MachineName + DatabaseName + Str(DesiredAccess)) = d
		    End If
		  End If
		  If err <> 0 Then Return Nil
		  mhandle = Win32.AdvApi32.OpenService(sHandle, ServiceName, DesiredAccess)
		  err = WinLib.GetLastError
		  If err = 0 Then
		    Dim s As New Service(mhandle)
		    s.KeyName = ServiceName
		    SCHandles.Value(mHandle) = MachineName + DatabaseName + Str(DesiredAccess)
		    Return s
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function QueryConfig() As MemoryBlock
		  #If TargetWin32 Then
		    Dim sz As Integer
		    Call Win32.AdvApi32.QueryServiceConfig(Me.ServiceHandle, Nil, 0, sz)
		    Dim mb As New MemoryBlock(sz)
		    Call Win32.AdvApi32.QueryServiceConfig(Me.ServiceHandle, mb, mb.Size, sz)
		    Return mb
		  #endif
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StartType() As Integer
		  Return QueryConfig.Int32Value(4)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TagID() As Integer
		  Dim i As Integer = LenB(QueryConfig.WString(12))
		  i = i + LenB(QueryConfig.WString(i))
		  Return QueryConfig.Int32Value(i)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type() As Integer
		  Return QueryConfig.Int32Value(0)
		End Function
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected KeyName As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Shared SCHandles As Dictionary
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
