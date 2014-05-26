#tag Class
Protected Class ClipboardFormat
Implements WinLib.Win32Object
	#tag CompatibilityFlags = TargetHasGUI
	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the WinLib.Win32Object interface.
		  Return ' Not closeable
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(hClipFormat As Integer)
		  // Part of the WinLib.Win32Object interface.
		  mHandle = hClipFormat
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return mHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsAvailable() As Boolean
		  Return Win32.User32.IsClipboardFormatAvailable(Me.Handle)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Name() As String
		  Dim mb As MemoryBlock
		  Dim sz As Integer = Win32.User32.GetClipboardFormatName(mhandle, Nil, 0)
		  If sz > 0 Then
		    mb = New MemoryBlock(sz * 2)
		    Call Win32.User32.GetClipboardFormatName(mhandle, mb, sz)
		    Return mb.WString(0)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function RegisterFormat(Name As String) As WinLib.ClipboardFormat
		  Static formats As Dictionary
		  If formats = Nil Then formats = New Dictionary
		  If formats.HasKey(Name) Then
		    Return New WinLib.ClipboardFormat(formats.Value(Name))
		  Else
		    Dim hClipFormat As Integer = Win32.User32.RegisterClipboardFormat(Name)
		    If hClipFormat <> 0 Then
		      formats.Value(Name) = hClipFormat
		      Return New WinLib.ClipboardFormat(hClipFormat)
		    End If
		  End If
		End Function
	#tag EndMethod

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Function RenderHandler(Sender As WinLib . ClipboardFormat, RawClipboard As Ptr) As Boolean
	#tag EndDelegateDeclaration


	#tag Hook, Flags = &h0
		Event RenderClipboard(RawClipboard As Ptr) As Boolean
	#tag EndHook


	#tag Property, Flags = &h1
		Protected mHandle As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty


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
