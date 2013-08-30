#tag Class
Class WMListener
Implements Win32Object
	#tag Method, Flags = &h0
		Sub AddMessageFilter(ParamArray MsgIDs() As Integer)
		  For Each MsgID As Integer In MsgIDs
		    Me.MessageFilter.Value(MsgID) = "&h" + Hex(MsgID)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the WinLib.Win32Object interface.
		  UnSubclass(Me.ParentWindow)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(HWND As Integer = 0)
		  If HWND = 0 Then HWND = Window(0).Handle
		  Me.ParentWindow = HWND
		  Subclass(ParentWindow, Me)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function DefWindowProc(HWND as Integer, msg as Integer, wParam as Ptr, lParam as Ptr) As Integer
		  #If TargetWin32 Then
		    For Each wndclass As Dictionary In Subclasses
		      If wndclass.HasKey(HWND) Then
		        Dim subclass As WMListener = wndclass.Value(HWND)
		        If subclass <> Nil And subclass.WndProc(HWND, msg, wParam, lParam) Then
		          Return 1
		        End If
		      End
		    Next
		    Dim nextWndProc As Integer
		    nextWndProc = WndProcs.Lookup(HWND, INVALID_HANDLE_VALUE)
		    If nextWndProc <> INVALID_HANDLE_VALUE Then
		      Return WinLib.User32.CallWindowProc(nextWndProc, HWND, msg, wParam, lParam)
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Destructor()
		  Me.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return Me.ParentWindow
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveMessageFilter(ParamArray MsgIDs() As Integer)
		  For Each MsgID As Integer In MsgIDs
		    If Me.MessageFilter.HasKey(MsgID) Then Me.MessageFilter.Remove(MsgID)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Sub Subclass(SuperWin As Integer, SubWin As WMListener)
		  #If TargetWin32 Then
		    If WndProcs.HasKey(SuperWin) Then
		      Dim d As New Dictionary
		      d.Value(SuperWin) = SubWin
		      Subclasses.Append(d)
		      Return
		    End
		    Dim windproc As Ptr = AddressOf DefWindowProc
		    Dim oldWndProc As Integer = WinLib.User32.SetWindowLong(SuperWin, GWL_WNDPROC, windproc)
		    WndProcs.Value(SuperWin) = oldWndProc
		    Dim d As New Dictionary
		    d.Value(SuperWin) = SubWin
		    Subclasses.Append(d)
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Sub UnSubclass(SuperWin As Integer)
		  #If TargetWin32 Then
		    If Not WndProcs.HasKey(SuperWin) Then Return
		    Dim oldWndProc As Ptr = WndProcs.Value(SuperWin)
		    Call WinLib.User32.SetWindowLong(SuperWin, GWL_WNDPROC, oldWndProc)
		    WndProcs.Remove(SuperWin)
		    Dim wndclass As Dictionary
		    For i As Integer = UBound(Subclasses) DownTo 0
		      wndclass = Subclasses(i)
		      If wndclass.HasKey(SuperWin) Then
		        Subclasses.Remove(i)
		      End
		    Next
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function WndProc(HWND as Integer, msg as Integer, wParam as Ptr, lParam as Ptr) As Boolean
		  #pragma Unused HWND
		  If Me.MessageFilter.HasKey(msg) Then
		    Return WindowMessage(HWND, msg, wParam, lParam)
		  End If
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event WindowMessage(HWND As Integer, Message As Integer, WParam As Ptr, LParam As Ptr) As Boolean
	#tag EndHook


	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  If mMessageFilter = Nil Then mMessageFilter = New Dictionary
			  return mMessageFilter
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mMessageFilter = value
			End Set
		#tag EndSetter
		Protected MessageFilter As Dictionary
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMessageFilter As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mWndProcs As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected ParentWindow As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared Subclasses() As Dictionary
	#tag EndProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  If mWndProcs = Nil Then mWndProcs = New Dictionary
			  return mWndProcs
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mWndProcs = value
			End Set
		#tag EndSetter
		Protected Shared WndProcs As Dictionary
	#tag EndComputedProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
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
