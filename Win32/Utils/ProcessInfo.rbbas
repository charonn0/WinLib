#tag Class
Protected Class ProcessInfo
Implements Win32.Win32Object
	#tag Method, Flags = &h0
		Attributes( hidden )  Sub Close()
		  ' nothing to close; just satisfying Win32Object
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Handle As Integer)
		  Me.ProcessID = Handle
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(ProcInfo As Win32.Utils.PROCESSENTRY32)
		  Me.ProcessID = ProcInfo.ProcessID
		  Me.ParentID = ProcInfo.ParentProcessID
		  If Executable <> Nil Then
		    Me.Name = Executable.Name
		  Else
		    Dim f As FolderItem = GetFolderItem(ProcInfo.EXEPath, FolderItem.PathTypeAbsolute)
		    If f <> Nil Then Me.Name = f.Name
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function FileFromProcessID(processID As Integer) As FolderItem
		  //Given a processID number of an active process, tries to resolve the executable file for the program.
		  //Returns Nil if it cannot resolve the file. Most likely this would be due to insufficient access rights
		  
		  #If TargetWin32 Then
		    Dim cleanup As Boolean = Win32.Utils.SetPrivilege(SE_DEBUG_PRIVILEGE, True)
		    
		    If Win32.KernelVersion >= 5.1 Then
		      Dim Modules As New MemoryBlock(255)  // 255 = SIZE_MINIMUM * sizeof(HMODULE)
		      Dim ModuleName As New MemoryBlock(255)
		      Dim nSize As Integer
		      
		      Dim hProcess As Integer = Win32.Libs.Kernel32.OpenProcess(PROCESS_QUERY_INFORMATION Or PROCESS_VM_READ, False, processID)
		      Dim Result As String
		      If hProcess <> 0 Then
		        ModuleName = New MemoryBlock(255)
		        nSize = 255
		        Call Win32.Libs.PSAPI.GetModuleFileNameEx(hProcess, Modules.Int32Value(0), ModuleName, 255)
		        Result=Result+ModuleName.WString(0)
		      Else
		        Return Nil
		      End If
		      Call Win32.Libs.Kernel32.CloseHandle(hProcess)
		      
		      Result = Replace(Result, "\??\", "")
		      Result = Replace(Result, "\SystemRoot\", SpecialFolder.Windows.AbsolutePath)
		      Dim ret As FolderItem
		      
		      If Result <> "" Then
		        ret = GetFolderItem(Result)
		      End If
		      Return ret
		      'ElseIf KernelVersion > 5.2 Then
		      'Dim pHandle As Integer
		      'Dim realsize As Integer
		      'Dim path As New MemoryBlock(255)
		      '
		      'pHandle = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, processID)
		      '
		      'If System.IsFunctionAvailable("GetProcessImageFileNameW", "Kernel32") Then
		      'If pHandle <> 0 Then
		      'realsize = Kernel32.GetProcessImageFileName(pHandle, path, path.Size)
		      'Else
		      'Return Nil
		      'End If
		      'Else
		      'If pHandle <> 0 Then
		      'realsize = Kernel32.GetProcessImageFileName(pHandle, path, path.Size)
		      'Else
		      'Return Nil
		      'End If
		      'End If
		      '
		      'If realsize > 0 Then
		      'Dim retpath As String = path.WString(0)
		      'Dim t As String = "\Device\" + NthField(retpath, "\", 3)
		      'retpath = retpath.Replace(t, "")
		      '
		      'For i As Integer = 65 To 90  //A-Z in ASCII
		      'Dim mb As New MemoryBlock(255)
		      'Call QueryDosDevice(Chr(i) + ":", mb, mb.Size)
		      'If mb.Wstring(0) = t Then
		      'retpath = Chr(i) + ":" + retpath
		      'Return GetFolderItem(retpath)
		      'End If
		      'Next
		      'End If
		    End If
		    If cleanup Then Call Win32.Utils.SetPrivilege(SE_DEBUG_PRIVILEGE, False)
		  #endif
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function GetProcessList() As Win32.Utils.ProcessInfo()
		  Dim snaphandle As Integer = Win32.Libs.Kernel32.CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
		  Dim info As Win32.Utils.PROCESSENTRY32
		  Dim list() As Win32.Utils.ProcessInfo
		  info.Ssize = Info.Size
		  If Win32.Libs.Kernel32.Process32First(snaphandle, info) Then
		    Do
		      list.Append(New Win32.Utils.ProcessInfo(info))
		    Loop Until Not Win32.Libs.Kernel32.Process32Next(snaphandle, info)
		  End If
		  Call Win32.Libs.Kernel32.CloseHandle(snaphandle)
		  Return list
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  Return Me.ProcessID
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OpenedFiles() As FolderItem
		  #If TargetWin32 Then
		    Dim mb As New MemoryBlock(SYSTEM_HANDLE_TABLE_ENTRY_INFO.Size * 64)
		    Dim newSize, tries As Integer
		    While Win32.Libs.NTDLL.NtQuerySystemInformation(SYSTEM_HANDLE_INFORMATION, mb, mb.Size, newSize) <> 0
		      tries = tries + 1
		      If tries > 10 Then Exit While
		    Wend
		    
		    Dim info() As SYSTEM_HANDLE_TABLE_ENTRY_INFO
		    For i As Integer = 0 To newSize Step SYSTEM_HANDLE_TABLE_ENTRY_INFO.Size
		      Dim item As SYSTEM_HANDLE_TABLE_ENTRY_INFO
		      item.StringValue(TargetLittleEndian) = mb.StringValue(i, SYSTEM_HANDLE_TABLE_ENTRY_INFO.Size)
		      info.Append(item)
		    Next
		    
		    Break
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function PROCESS_QUERY_LIMITED_INFORMATION() As Integer
		  #If TargetWin32 Then
		    If OSVersion.MajorVersion >= 6 Then
		      Return &h1000  'PROCESS_QUERY_LIMITED_INFORMATION
		    Else
		      Return PROCESS_QUERY_INFORMATION  'On old Windows, use the old API
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Terminate(ExitCode As Integer = 0) As Boolean
		  Dim prochandle As Integer = Win32.Libs.Kernel32.OpenProcess(PROCESS_TERMINATE, False, Me.ProcessID)
		  mLastError = Win32.LastError()
		  If prochandle <> 0 Then
		    Dim success As Boolean = Win32.Libs.Kernel32.TerminateProcess(prochandle, ExitCode)
		    mLastError = Win32.LastError()
		    Call Win32.Libs.Kernel32.CloseHandle(prochandle)
		    Return success
		  End If
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim prochandle, priority As Integer
			  prochandle = Win32.Libs.Kernel32.OpenProcess(PROCESS_QUERY_INFORMATION, False, Me.ProcessID)
			  mLastError = Win32.LastError()
			  If mLastError = 0 Then
			    priority = Win32.Libs.Kernel32.GetPriorityClass(prochandle)
			    mLastError = Win32.LastError()
			  End If
			  Call Win32.Libs.Kernel32.CloseHandle(prochandle)
			  Return priority
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Dim prochandle As Integer = Win32.Libs.Kernel32.OpenProcess(PROCESS_SET_INFORMATION, False, Me.ProcessID)
			  mLastError = Win32.LastError()
			  If mLastError = 0 Then
			    Call Win32.Libs.Kernel32.SetPriorityClass(prochandle, value)
			    mLastError = Win32.LastError()
			  End If
			  Call Win32.Libs.Kernel32.CloseHandle(prochandle)
			End Set
		#tag EndSetter
		BasePriority As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If mExecutable = Nil Then
			    mExecutable = FileFromProcessID(Me.ProcessID)
			  End If
			  Return mExecutable
			End Get
		#tag EndGetter
		Executable As FolderItem
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mExecutable As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastError As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ParentID As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		ProcessID As Integer
	#tag EndProperty


	#tag Constant, Name = PROCESS_QUERY_INFORMATION, Type = Double, Dynamic = False, Default = \"&h400", Scope = Private
	#tag EndConstant

	#tag Constant, Name = PROCESS_SET_INFORMATION, Type = Double, Dynamic = False, Default = \"&h200", Scope = Private
	#tag EndConstant

	#tag Constant, Name = PROCESS_TERMINATE, Type = Double, Dynamic = False, Default = \"&h1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = PROCESS_VM_READ, Type = Double, Dynamic = False, Default = \"&h10", Scope = Private
	#tag EndConstant

	#tag Constant, Name = SYSTEM_HANDLE_INFORMATION, Type = Double, Dynamic = False, Default = \"16", Scope = Private
	#tag EndConstant

	#tag Constant, Name = TH32CS_SNAPPROCESS, Type = Double, Dynamic = False, Default = \"&h2", Scope = Private
	#tag EndConstant


	#tag Structure, Name = SYSTEM_HANDLE_TABLE_ENTRY_INFO, Flags = &h1
		ProcessID As Integer
		  ObjectType As Byte
		  Flags As Byte
		  Value As Int16
		  Address As Ptr
		GrantedAccess As Integer
	#tag EndStructure


	#tag ViewBehavior
		#tag ViewProperty
			Name="BasePriority"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
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
			Name="ParentID"
			Group="Behavior"
			Type="Integer"
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
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
