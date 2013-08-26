#tag Class
Protected Class Win32Process
	#tag Method, Flags = &h0
		Sub Constructor(ProcInfo As PROCESSENTRY32)
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
		 Shared Function GetProcessList() As Win32Process()
		  Dim snaphandle As Integer = WinLib.Kernel32.CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
		  Dim info As PROCESSENTRY32
		  Dim list() As Win32Process
		  info.Ssize = Info.Size
		  If WinLib.Kernel32.Process32First(snaphandle, info) Then
		    Do
		      list.Append(New Win32Process(info))
		    Loop Until Not WinLib.Kernel32.Process32Next(snaphandle, info)
		  End If
		  Call WinLib.Kernel32.CloseHandle(snaphandle)
		  Return list
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Terminate(ExitCode As Integer = 0) As Boolean
		  Dim prochandle As Integer = WinLib.Kernel32.OpenProcess(PROCESS_TERMINATE, False, Me.ProcessID)
		  mLastWin32Error = WinLib.GetLastError()
		  If prochandle <> 0 Then
		    Dim success As Boolean = WinLib.Kernel32.TerminateProcess(prochandle, ExitCode)
		    mLastWin32Error = WinLib.GetLastError()
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
			  mLastWin32Error = WinLib.GetLastError()
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

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mLastWin32Error
			End Get
		#tag EndGetter
		LastWin32Error As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mExecutable As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastWin32Error As Integer
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
			Name="LastWin32Error"
			Group="Behavior"
			Type="Integer"
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
