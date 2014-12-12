#tag Class
Protected Class Waiter
Implements Win32.Win32Object
	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the Win32Object interface.
		  If Not Win32.Libs.Kernel32.UnregisterWait(Me.Handle) Then
		    mLastError = Win32.LastError()
		  Else
		    mLastError = 0
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  // Part of the Win32Object interface.
		  Return
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Handle As Integer)
		  // Part of the Win32Object interface.
		  mHandle = Handle
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Sub DefWaitProc(Parameter As Ptr, WaitFired As Boolean)
		  #pragma X86CallingConvention StdCall
		  System.DebugLog(CurrentMethodName)
		  Dim token As Integer = Integer(Parameter)
		  System.DebugLog(Str(token))
		  If Waiters.HasKey(token) Then
		    System.DebugLog("Has token")
		    Dim w As Win32.Utils.Waiter = Waiters.Value(token)
		    System.DebugLog(Str(w.Handle))
		    'Waiters.Remove(token)
		    w.WaitProc(WaitFired)
		  Else
		    System.DebugLog("ERROR: Token not found!")
		    'Raise New RuntimeException
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  Return mHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  // Part of the Win32Object interface.
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function WaitOn(Waitable As Integer) As Boolean
		  If Waiters = Nil Then Waiters = New Dictionary
		  Dim rand As New Random
		  Do
		    token = Rand.InRange(&hFF, &hFFFFFFFF)
		  Loop Until Not Waiters.HasKey(token)
		  Waiters.Value(token) = Me
		  Return Win32.Libs.Kernel32.RegisterWaitForSingleObject(mHandle, Waitable, AddressOf DefWaitProc, Ptr(token), Timeout, 0)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function WaitOnce(Waitable As Integer) As Boolean
		  If Waiters = Nil Then Waiters = New Dictionary
		  Dim rand As New Random
		  Do
		    token = Rand.InRange(&hFF, &hFFFFFFFF)
		  Loop Until Not Waiters.HasKey(token)
		  Waiters.Value(token) = Me
		  If Not Win32.Libs.Kernel32.RegisterWaitForSingleObject(mHandle, Waitable, AddressOf DefWaitProc, Ptr(token), Timeout, WT_EXECUTEONLYONCE) Then
		    mLastError = Win32.LastError()
		  Else
		    mLastError = 0
		  End If
		  Return Me.LastError = 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WaitProc(WaitFired As Boolean)
		  System.DebugLog(CurrentMethodName)
		  RaiseEvent WaitSignalled(WaitFired)
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event WaitSignalled(TimeoutElapsed As Boolean)
	#tag EndHook


	#tag Property, Flags = &h1
		Protected mHandle As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Timeout As Integer = INFINITE
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Token As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared Waiters As Dictionary
	#tag EndProperty


	#tag Constant, Name = INFINITE, Type = Double, Dynamic = False, Default = \"&hFFFFFFFF", Scope = Protected
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
			Name="Timeout"
			Group="Behavior"
			InitialValue="INFINITE"
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
