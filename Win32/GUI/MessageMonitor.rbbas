#tag Class
Protected Class MessageMonitor
Inherits Win32.GUI.HWND
Implements Win32.Win32Object
	#tag CompatibilityFlags = TargetHasGUI
	#tag Method, Flags = &h0
		Sub AddMessageFilter(ParamArray MsgIDs() As Integer)
		  For Each MsgID As Integer In MsgIDs
		    Me.MessageFilter.Value(MsgID) = "&h" + Hex(MsgID)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the Win32Object interface.
		  #If TargetWin32 Then
		    If Not WndProcs.HasKey(mHandle) Then Return
		    Dim oldWndProc As Ptr = WndProcs.Value(mHandle)
		    Call Win32.Libs.User32.SetWindowLong(mHandle, GWL_WNDPROC, oldWndProc)
		    WndProcs.Remove(mHandle)
		    Dim wndclass As Dictionary
		    For i As Integer = UBound(Subclasses) DownTo 0
		      wndclass = Subclasses(i)
		      If wndclass.HasKey(mHandle) Then
		        Subclasses.Remove(i)
		      End
		    Next
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(HWND As Integer)
		  #If TargetHasGUI Then
		    If HWND = 0 Then HWND = Window(0).Handle
		    Super.Constructor(HWND)
		    If WndProcs = Nil Then WndProcs = New Dictionary
		    
		    If WndProcs.HasKey(mHandle) Then
		      Dim d As New Dictionary
		      d.Value(mHandle) = Me
		      Subclasses.Append(d)
		    Else
		      Dim windproc As Ptr = AddressOf DefWindowProc
		      Dim oldWndProc As Integer = Me.SetLong(GWL_WNDPROC, windproc)
		      WndProcs.Value(mHandle) = oldWndProc
		      Dim d As New Dictionary
		      d.Value(mHandle) = New WeakRef(Me)
		      Subclasses.Append(d)
		    End If
		    MessageFilter = New Dictionary
		  #Else
		    ' Console and Web apps are not supported
		    #pragma Unused HWND
		    Raise New PlatformNotSupportedException
		  #endif
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function DefWindowProc(HWND as Integer, msg as Integer, wParam as Ptr, lParam as Ptr) As Integer
		  #pragma X86CallingConvention StdCall
		  #If TargetWin32 Then
		    For Each wndclass As Dictionary In Subclasses
		      If wndclass.HasKey(HWND) Then
		        Dim w As WeakRef = wndclass.Value(HWND)
		        Dim subclass As MessageMonitor = MessageMonitor(w.Value)
		        If subclass <> Nil And subclass.WndProc(HWND, msg, wParam, lParam) Then
		          Return 1
		        End If
		      End
		    Next
		    Dim nextWndProc As Integer
		    nextWndProc = WndProcs.Lookup(HWND, INVALID_HANDLE_VALUE)
		    If nextWndProc <> INVALID_HANDLE_VALUE Then
		      Return Win32.Libs.User32.CallWindowProc(nextWndProc, HWND, msg, wParam, lParam)
		    End If
		    Select Case msg
		    Case WM_CREATE, WM_NCCREATE
		      ' Windows sends these messages when the window is first created, but before this class is fully initialized.
		      ' We must return success else Windows will consider the creation to have failed.
		      Return 1
		    Else
		      #If DebugBuild Then
		        Break ' !!!
		      #endif
		    End Select
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Destructor()
		  Me.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveMessageFilter(ParamArray MsgIDs() As Integer)
		  For Each MsgID As Integer In MsgIDs
		    If Me.MessageFilter.HasKey(MsgID) Then Me.MessageFilter.Remove(MsgID)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function WndProc(HWND as Integer, msg as Integer, wParam as Ptr, lParam as Ptr) As Boolean
		  If Me.MessageFilter.HasKey(msg) Then
		    Return WindowMessage(New WindowRef(HWND), msg, wParam, lParam)
		  End If
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event WindowMessage(HWND As WindowRef, Message As Integer, WParam As Ptr, LParam As Ptr) As Boolean
	#tag EndHook


	#tag Note, Name = About this class
		This class allows RB applications to capture Window Messages sent by the system to a window or control.
		Window Messages are used to inform applications of user actions, events, and other useful things. For example
		the WM_PAINT message tells a window to repaint itself and WM_HOTKEY indicates that a global hotkey combo was 
		pressed. See the HotKeyMonitor class for using Hotkeys.
		
		By default, all window messages are immediately passed on to the RB framework for normal processing. Use the 
		AddMessageFilter method to specify which window messages you would like to receive. Return True from the 
		WindowMessage event to prevent the message from being passed on to the framework.
		
		Each MessageMonitor instance must belong to a window or a control. If no window/control is specified to the 
		Constructor (specifically, the handle property of the Window/Control) then your app's frontmost window will 
		be used (AKA Window(0)  See: http://docs.realsoftware.com/index.php/Window_Method)
		
		Each instance can handle any number of message types, but can only have one owning window/control.
		
		See: http://msdn.microsoft.com/en-us/library/windows/desktop/ff381405%28v=vs.85%29.aspx
		
		
		CAUTION:
		Avoid performing any lengthy actions directly in the WindowMessage event. Otherwise Windows may report that
		the application is "Not Responding."
	#tag EndNote


	#tag Property, Flags = &h21
		Private MessageFilter As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared Subclasses() As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared WndProcs As Dictionary
	#tag EndProperty


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
