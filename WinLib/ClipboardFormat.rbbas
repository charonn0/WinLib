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
		  Select Case Me.Handle
		  Case 2
		    Return "CF_BITMAP"
		  Case 8
		    Return "CF_DIB"
		  Case 17
		    Return "CF_DIBV5"
		  Case &h0082
		    Return "CF_DSPBITMAP"
		  Case &h008E
		    Return "CF_DSPENHMETAFILE"
		  Case &h0083
		    Return "CF_DSPMETAFILEPICT"
		  Case &h0081
		    Return "CF_DSPTEXT"
		  Case 14
		    Return "CF_ENHMETAFILE"
		  Case &h0300
		    Return "CF_GDIOBJFIRST"
		  Case &h03FF
		    Return "CF_GDIOBJLAST"
		  Case 15
		    Return "CF_HDROP"
		  Case 16
		    Return "CF_LOCALE"
		  Case 3
		    Return "CF_METAFILEPICT"
		  Case 7
		    Return "CF_OEMTEXT"
		  Case &h0080
		    Return "CF_OWNERDISPLAY"
		  Case 9
		    Return "CF_PALETTE"
		  Case 10
		    Return "CF_PENDATA"
		  Case &h0200
		    Return "CF_PRIVATEFIRST"
		  Case &h02FF
		    Return "CF_PRIVATELAST"
		  Case 11
		    Return "CF_RIFF"
		  Case 4
		    Return "CF_SYLK"
		  Case 1
		    Return "CF_TEXT"
		  Case 6
		    Return "CF_TIFF"
		  Case 13
		    Return "CF_UNICODETEXT"
		  Case 12
		    Return "CF_WAVE"
		  Else
		    Dim mb As MemoryBlock
		    Dim sz As Integer = Win32.User32.GetClipboardFormatName(mhandle, Nil, 0)
		    If sz > 0 Then
		      mb = New MemoryBlock(sz * 2)
		      Call Win32.User32.GetClipboardFormatName(mhandle, mb, sz)
		      Return mb.WString(0)
		    End If
		  End Select
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
