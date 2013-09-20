#tag Class
Class MessageWindow
Inherits WinLib.MessageMonitor
Implements WinLib.Win32Object
	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the WinLib.Win32Object interface.
		  Super.Close
		  Call Win32.User32.DestroyWindow(Me.Handle)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(ClassName As String, WindowName As String)
		  mClassName = ClassName
		  mWindowName = WindowName
		  Dim exflags, flags As Integer
		  exflags = WS_EX_NOREDIRECTIONBITMAP
		  flags = WS_VISIBLE
		  Dim HWND As Integer = Win32.User32.CreateWindowEx(exflags, mClassName, mWindowName, flags, 0, 0, 0, 0, HWND_MESSAGE, 0, 0, Nil)
		  mLastError = WinLib.GetLastError
		  Super.Constructor(HWND)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Destructor()
		  Me.Close
		  ' don't invoke the super's destructor
		End Sub
	#tag EndMethod


	#tag Note, Name = About this class
		This class provides an invisible message-reception window.
		
	#tag EndNote


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mClassName
			End Get
		#tag EndGetter
		ClassName As String
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected mClassName As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mWindowName As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mWindowName
			End Get
		#tag EndGetter
		WindowName As String
	#tag EndComputedProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="ClassName"
			Group="Behavior"
			Type="String"
		#tag EndViewProperty
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
		#tag ViewProperty
			Name="WindowName"
			Group="Behavior"
			Type="String"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
