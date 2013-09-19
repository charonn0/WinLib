#tag Class
Class ClipboardMonitor
Inherits WinLib.MessageMonitor
	#tag Event
		Function WindowMessage(HWND As WinLib.WindowRef, Message As Integer, WParam As Ptr, LParam As Ptr) As Boolean
		  #pragma Unused HWND
		  #If TargetWin32 Then
		    Select Case Message
		    Case WM_CHANGECBCHAIN
		      'A window is being removed
		      If Integer(WParam) = NextViewerWindow Then
		        NextViewerWindow = Integer(LParam)
		        Return True
		      Else
		        Call Win32.User32.SendMessage(NextViewerWindow, Message, WParam, LParam)
		        Return True
		      End If
		    Case WM_DRAWCLIPBOARD
		      'clipboard changed, pass it on
		      Call Win32.User32.SendMessage(NextViewerWindow, Message, WParam, LParam)
		      RaiseEvent ClipboardChanged()
		      Return True
		    End Select
		  #endif
		  
		End Function
	#tag EndEvent


	#tag Method, Flags = &h1000
		Sub Constructor(ParentHandle As Integer = 0)
		  // Calling the overridden superclass constructor.
		  Super.Constructor(ParentHandle)
		  Me.AddMessageFilter(WM_CHANGECBCHAIN, WM_DRAWCLIPBOARD)
		  #If TargetWin32 Then
		    NextViewerWindow = Win32.User32.SetClipboardViewer(Me.ParentWindow.Handle)
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Destructor()
		  #If TargetWin32 Then
		    ' We must unlink ourselves from the Clipboard chain without breaking it!
		    Call Win32.User32.ChangeClipboardChain(Me.ParentWindow.Handle, Me.NextViewerWindow)
		  #endif
		  Super.Destructor()
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event ClipboardChanged()
	#tag EndHook


	#tag Note, Name = About this class
		http://msdn.microsoft.com/en-us/library/windows/desktop/ms649052%28v=vs.85%29.aspx
		
		Monitors the system-wide clipboard for changes.
	#tag EndNote


	#tag Property, Flags = &h1
		Protected NextViewerWindow As Integer
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
