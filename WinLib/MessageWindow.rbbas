#tag Class
Class MessageWindow
Inherits WinLib.MessageMonitor
Implements Win32Object
	#tag Method, Flags = &h0
		Sub Close()
		  Super.Close
		  #If TargetWin32 Then
		    Call Win32.User32.DestroyWindow(Me.Handle)
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor()
		  Me.Constructor("WinLibMessageWindow")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(ClassName As String)
		  Dim HWND As Integer
		  #If TargetWin32 Then
		    Dim info As WNDCLASSEX
		    Dim mbClass As New MemoryBlock(512)
		    mbClass.WString(0) = ClassName
		    info.ClassName = mbClass
		    info.cbSize = info.Size
		    info.Instance = Win32.Kernel32.GetModuleHandle("")
		    info.WndProc = AddressOf Me.DefWindowProc
		    If Win32.User32.RegisterClassEx(info) > 0 Then
		      HWND = Win32.User32.CreateWindowEx(0, mbClass.WString(0), "", 0, 0, 0, 0, 0, HWND_MESSAGE, 0, 0, Nil)
		    End If
		  #endif
		  mLastError = GetLastError
		  If HWND <> 0 Then
		    Super.Constructor(HWND)
		  Else
		    Raise Win32Exception(GetLastError)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function DefWindowProc(HWND as Integer, msg as Integer, wParam as Ptr, lParam as Ptr) As Integer
		  #pragma X86CallingConvention StdCall
		  #If TargetWin32 Then
		    Select Case msg
		    Case WM_CREATE, WM_NCCREATE, WM_NCCALCSIZE, WM_GETMINMAXINFO
		      ' Windows sends these three messages when the window is first created, but before this class
		      ' is fully initialized. We must return success else Windows will consider the creation to have failed.
		      Return 1
		    Else
		      ' Let the subclass handle all other messages
		      Return Super.DefWindowProc(HWND, msg, wParam, lParam)
		    End Select
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Destructor()
		  Me.Close
		End Sub
	#tag EndMethod


	#tag Note, Name = About this class
		This class provides an invisible message-reception window.
	#tag EndNote


	#tag ViewBehavior
		#tag ViewProperty
			Name="ClassName"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
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
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
