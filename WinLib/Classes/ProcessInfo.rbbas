#tag Class
Protected Class ProcessInfo
	#tag Method, Flags = &h0
		Sub Constructor(ProcInfo As PROCESSENTRY32)
		  mProcessID = ProcInfo.ProcessID
		  mParentID = ProcInfo.ParentProcessID
		  If Executable <> Nil Then
		    mName = Executable.Name
		  Else
		    Dim f As FolderItem = GetFolderItem(ProcInfo.EXEPath, FolderItem.PathTypeAbsolute)
		    If f <> Nil Then mName = f.Name
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Executable() As FolderItem
		  If mExecutable = Nil Then
		    mExecutable = FileFromProcessID(Me.ProcessID)
		  End If
		  Return mExecutable
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Attributes( hidden )  Shared Function FileFromProcessID(processID As Integer) As FolderItem
		  //Given a processID number of an active process, tries to resolve the executable file for the program.
		  //Returns Nil if it cannot resolve the file. Most likely this would be due to insufficient access rights
		  
		  #If TargetWin32 Then
		    Dim cleanup As Boolean = WinLib.CurrentPrivileges.Enable(SE_DEBUG_PRIVILEGE)
		    
		    If WinLib.KernelVersion >= 5.1 Then
		      Dim Modules As New MemoryBlock(255)  // 255 = SIZE_MINIMUM * sizeof(HMODULE)
		      Dim ModuleName As New MemoryBlock(255)
		      Dim nSize As Integer
		      
		      Dim hProcess As Integer = WinLib.Kernel32.OpenProcess(PROCESS_QUERY_INFORMATION Or PROCESS_VM_READ, False, processID)
		      Dim Result As String
		      If hProcess <> 0 Then
		        ModuleName = New MemoryBlock(255)
		        nSize = 255
		        Call WinLib.PSAPI.GetModuleFileNameEx(hProcess, Modules.Int32Value(0), ModuleName, 255)
		        Result=Result+ModuleName.WString(0)
		      Else
		        Return Nil
		      End If
		      Call WinLib.Kernel32.CloseHandle(hProcess)
		      
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
		    If cleanup Then Call WinLib.CurrentPrivileges.Disable(SE_DEBUG_PRIVILEGE)
		  #endif
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function GetProcessList() As WinLib.Classes.ProcessInfo()
		  Dim snaphandle As Integer = WinLib.Kernel32.CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
		  Dim info As PROCESSENTRY32
		  Dim list() As WinLib.Classes.ProcessInfo
		  info.Ssize = Info.Size
		  If WinLib.Kernel32.Process32First(snaphandle, info) Then
		    Do
		      list.Append(New WinLib.Classes.ProcessInfo(info))
		    Loop Until Not WinLib.Kernel32.Process32Next(snaphandle, info)
		  End If
		  Call WinLib.Kernel32.CloseHandle(snaphandle)
		  Return list
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  Return mLastWin32Error
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Name() As String
		  Return mName
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ParentID() As Integer
		  Return mParentID
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ProcessID() As Integer
		  Return mProcessID
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Terminate(ExitCode As Integer = 0) As Boolean
		  Dim prochandle As Integer = WinLib.Kernel32.OpenProcess(PROCESS_TERMINATE, False, Me.ProcessID)
		  mLastWin32Error = GetLastError()
		  If prochandle <> 0 Then
		    Dim success As Boolean = WinLib.Kernel32.TerminateProcess(prochandle, ExitCode)
		    mLastWin32Error = GetLastError()
		    Call WinLib.Kernel32.CloseHandle(prochandle)
		    Return success
		  End If
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim prochandle, priority As Integer
			  prochandle = WinLib.Kernel32.OpenProcess(PROCESS_QUERY_INFORMATION, False, Me.ProcessID)
			  mLastWin32Error = GetLastError()
			  If mLastWin32Error = 0 Then
			    priority = WinLib.Kernel32.GetPriorityClass(prochandle)
			    mLastWin32Error = WinLib.GetLastError()
			  End If
			  Call WinLib.Kernel32.CloseHandle(prochandle)
			  Return priority
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Dim prochandle As Integer = WinLib.Kernel32.OpenProcess(PROCESS_SET_INFORMATION, False, Me.ProcessID)
			  mLastWin32Error = WinLib.GetLastError()
			  If mLastWin32Error = 0 Then
			    Call WinLib.Kernel32.SetPriorityClass(prochandle, value)
			    mLastWin32Error = WinLib.GetLastError()
			  End If
			  Call WinLib.Kernel32.CloseHandle(prochandle)
			End Set
		#tag EndSetter
		BasePriority As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mExecutable As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLastWin32Error As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mName As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mParentID As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mProcessID As Integer
	#tag EndProperty


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
