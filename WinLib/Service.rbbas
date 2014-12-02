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
		      SCHandles.Remove(ref)
		    End If
		    If SCHandles.HasKey(ServiceHandle) Then SCHandles.Remove(ServiceHandle)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Constructor(Handle As Integer)
		  ServiceHandle = Handle
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Control(Command As Integer, ByRef Status As SERVICE_STATUS) As Boolean
		  #If TargetWin32 Then
		    If Not Win32.AdvApi32.ControlService(Me.Handle, Command, status) Then
		      mLastError = Win32.LastError()
		    Else
		      mLastError = 0
		    End If
		    Return LastError = 0
		  #endif
		End Function
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

	#tag Method, Flags = &h21
		Private Sub Destructor()
		  Me.Close()
		End Sub
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
		    mLastError = Win32.LastError()
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
		  Dim mb As MemoryBlock = QueryConfig
		  If mb.WString(36).Trim <> "" Then
		    Return GetFolderItem(mb.WString(36))'12))
		  End If
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
		 Shared Function OpenService(ServiceName As String, MachineName As String = "", DatabaseName As String = "", DesiredAccess As Integer = - 1) As Service
		  If DesiredAccess = -1 Then DesiredAccess = SC_MANAGER_CONNECT Or SC_MANAGER_ENUMERATE_SERVICE Or SERVICE_START Or SERVICE_STOP' Or SERVICE_PAUSE_CONTINUE
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
		    err = Win32.LastError
		    If err = 0 Then
		      Dim d As New Dictionary
		      d.Value("Handle") = sHandle
		      d.Value("Count") = 1
		      SCHandles.Value(MachineName + DatabaseName + Str(DesiredAccess)) = d
		    End If
		  End If
		  If err <> 0 Then Return Nil
		  mhandle = Win32.AdvApi32.OpenService(sHandle, ServiceName, DesiredAccess)
		  err = Win32.LastError()
		  If err = 0 Then
		    Dim s As New Service(mhandle)
		    s.KeyName = ServiceName
		    SCHandles.Value(mHandle) = MachineName + DatabaseName + Str(DesiredAccess)
		    Return s
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Pause() As Boolean
		  #If TargetWin32 Then
		    Dim status As SERVICE_STATUS
		    Return Me.Control(SERVICE_CONTROL_PAUSE, status)
		  #endif
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
		Function QueryStatus() As SERVICE_STATUS
		  #If TargetWin32 Then
		    Dim stat As SERVICE_STATUS
		    If Not Win32.AdvApi32.QueryServiceStatus(Me.Handle, stat) Then
		      mLastError = Win32.LastError()
		      Exit Function
		    End If
		    Return stat
		  #endif
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Resume() As Boolean
		  #If TargetWin32 Then
		    Dim status As SERVICE_STATUS
		    Return Me.Control(SERVICE_CONTROL_CONTINUE, status)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Start(Optional Arguments() As String) As Boolean
		  #If TargetWin32 Then
		    Dim args As String = Join(Arguments, Chr(0))
		    Dim mb As New MemoryBlock(0)
		    Dim count As Integer
		    If Arguments <> Nil And UBound(Arguments) > -1 Then
		      mb = New MemoryBlock(LenB(args) * 2)
		      mb.WString(0) = Join(Arguments, Chr(0))
		      count = UBound(Arguments) + 1
		    End If
		    If Not Win32.AdvApi32.StartService(Me.Handle, count, mb) Then
		      mLastError = Win32.LastError()
		    Else
		      mLastError = 0
		    End If
		    Return LastError = 0 Or LastError = 1056 ' 1056=ERROR_SERVICE_ALREADY_RUNNING
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StartType() As Integer
		  Return QueryConfig.Int32Value(4)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function State() As WinLib.Service.States
		  Return States(QueryStatus.CurrentState)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Stop() As Boolean
		  #If TargetWin32 Then
		    Dim status As SERVICE_STATUS
		    Return Me.Control(SERVICE_CONTROL_STOP, status)
		  #endif
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


	#tag Enum, Name = States, Type = Integer, Flags = &h0
		Stopped=1
		  StartPending
		  StopPending
		  Running
		  ContinuePending
		  PausePending
		Paused
	#tag EndEnum


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
