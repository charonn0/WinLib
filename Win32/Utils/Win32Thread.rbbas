#tag Class
Protected Class Win32Thread
	#tag Method, Flags = &h0
		Sub Constructor()
		  
		  ' init shared variables
		  If Threads = Nil Then Threads = New Dictionary
		  If ThreadProcLock = Nil Then ThreadProcLock = New CriticalSection
		  mLocalStorage = Win32.Libs.Kernel32.TlsAlloc()
		  mLastError = Win32.LastError
		  If mLocalStorage = TLS_OUT_OF_INDEXES Then
		    Dim err As New OutOfMemoryException
		    err.Message = "Thread local storage is out of indexes"
		    err.ErrorNumber = mLastError
		  End If
		  
		  ' select an identifier
		  Dim rand As New Random
		  Do
		    token = Rand.InRange(0, &hFFFFFFFF)
		  Loop Until Not Threads.HasKey(token)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function DefThreadProc(Parameter As Ptr) As Integer
		  
		  While Not ThreadProcLock.TryEnter
		    Win32.Libs.Kernel32.SleepCurrentThread(100)
		  Wend
		  Try
		    Dim i As Integer = Integer(Parameter)
		    If Threads.HasKey(i) Then
		      Dim t As Win32Thread = Threads.Value(i)
		      i = t.ThreadProc()
		      Return i
		    End If
		  Finally
		    ThreadProcLock.Leave
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  
		  Return mHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Kill(ExitCode As Integer = 0)
		  Call Win32.Libs.Kernel32.TerminateThread(Me.Handle, ExitCode)
		  mLastError = Win32.LastError
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Resume() As Integer
		  Dim suspending As Integer = Win32.Libs.Kernel32.ResumeThread(Me.Handle)
		  mLastError = Win32.LastError
		  Return suspending - 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Run()
		  
		  ' create the thread in a suspended state
		  mHandle = Win32.Libs.Kernel32.CreateThread(Nil, 0, AddressOf DefThreadProc, Ptr(token), CREATE_SUSPENDED, mThreadID)
		  mLastError = Win32.LastError
		  If Me.Handle > 0 Then
		    ' store a reference to the instance
		    Threads.Value(token) = Me
		    Dim count As Integer
		    Do
		      count = Me.Resume
		    Loop Until count <= 0
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Sleep(Milliseconds As Integer)
		  
		  Win32.Libs.Kernel32.SleepCurrentThread(Milliseconds)
		  mLastError = Win32.LastError
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Suspend() As Integer
		  Dim Suspending As Integer = Win32.Libs.Kernel32.SuspendThread(Me.Handle)
		  mLastError = Win32.LastError
		  Return Suspending - 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ThreadID() As Integer
		  
		  Return mThreadID
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ThreadProc() As Integer
		  Return RaiseEvent Run()
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Run() As Integer
	#tag EndHook


	#tag Note, Name = About this class
		WARNING: This class is experimental and should not be used in production!
		
		This class represents a *preemptive* Win32 thread.
		
		Notes:
		
		* Breakpoints in code call on a Win32Thread will break execution and show
		the debugger, but the IDE will not be able to show the breakpoint or read
		any runtime variables.
	#tag EndNote


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Win32.Libs.Kernel32.TlsGetValue(mLocalStorage)
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Call Win32.Libs.Kernel32.TlsSetValue(mLocalStorage, value)
			End Set
		#tag EndSetter
		LocalStorage As Ptr
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected mHandle As Integer = INVALID_HANDLE_VALUE
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLocalStorage As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mThreadID As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared ThreadProcLock As CriticalSection
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared Threads As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Token As Integer
	#tag EndProperty


	#tag Constant, Name = CREATE_SUSPENDED, Type = Double, Dynamic = False, Default = \"&h00000004", Scope = Private
	#tag EndConstant

	#tag Constant, Name = TLS_OUT_OF_INDEXES, Type = Double, Dynamic = False, Default = \"&hFFFFFFFF", Scope = Private
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
End Class
#tag EndClass
