#tag Class
Protected Class ImageDevice
Implements WinLib.Win32Object
	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the WinLib.Win32Object interface.
		  If CapWin <> 0 Then
		    Call Win32.User32.SendMessage(CapWin, WM_CAP_DRIVER_DISCONNECT, Ptr(mIndex), Nil)
		    Call Win32.User32.DestroyWindow(CapWin)
		    CapWin = 0
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Constructor(Index As Integer)
		  // Part of the WinLib.Win32Object interface.
		  mIndex = Index
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Destructor()
		  Me.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function DeviceCount() As Integer
		  Dim i As Integer
		  While Win32.Avicap32.capGetDriverDescription(i, Nil, 0, Nil, 0)
		    i = i + 1
		  Wend
		  Return i
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DeviceIndex() As Integer
		  Return mIndex
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub EmbedPreviewWithin(Parent As Integer, X As Integer, Y As Integer, W As Integer, H As Integer)
		  Me.Close
		  CapWin = Win32.Avicap32.capCreateCaptureWindow(Me.Name, WS_VISIBLE Or WS_CHILD, 0, 0, W, H, Parent, 0)
		  If CapWin <= 0 Then
		    mLastError = Win32.Kernel32.GetLastError()
		    Return
		  End If
		  If Win32.User32.SendMessage(CapWin, WM_CAP_DRIVER_CONNECT, Ptr(mIndex), Nil) > 0 Then
		    'Dim parms As CAPTUREPARMS
		    'parms.CaptureAudio = True
		    'parms.MakeUserHitOKToCapure = True
		    'parms.RequestMicroSecPerFrame = 333
		    'parms.Yield = True
		    'Dim mb As MemoryBlock = parms.StringValue(TargetLittleEndian)
		    'If Win32.User32.SendMessage(CapWin, WM_CAP_SET_SEQUENCE_SETUP, Ptr(mb.Size), mb) = 0 Then Break
		  End If
		  mLastError = Win32.Kernel32.GetLastError()
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EmbedPreviewWithin(Parent As RectControl, X As Integer = 0, Y As Integer = 0, W As Integer = - 1, H As Integer = - 1)
		  If X = -1 Then X = 0
		  If Y = -1 Then Y = 0
		  If W = -1 Then W = Parent.Width
		  If H = -1 Then H = Parent.Height
		  
		  Me.EmbedPreviewWithin(Parent.Handle, X, Y, W, H)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EmbedPreviewWithin(Parent As Window, X As Integer = - 1, Y As Integer = - 1, W As Integer = - 1, H As Integer = - 1)
		  If X = -1 Then X = 0
		  If Y = -1 Then Y = 0
		  If W = -1 Then W = Parent.Width
		  If H = -1 Then H = Parent.Height
		  
		  Me.EmbedPreviewWithin(Parent.Handle, X, Y, W, H)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function GetDeviceByIndex(Index As Integer) As WinLib.ImageDevice
		  ' Index may be 0 to DeviceCount-1
		  If Index <= DeviceCount Then
		    Return New ImageDevice(Index)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GrabFrame() As Picture
		  Dim win As New WinLib.WindowRef(CapWin)
		  Return win.Capture(False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  Return CapWin
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Name() As String
		  Dim nm As New MemoryBlock(1024)
		  If Win32.Avicap32.capGetDriverDescription(mIndex, nm, nm.Size, Nil, 0) Then
		    Return nm.WString(0)
		  Else
		    mLastError = Win32.Kernel32.GetLastError()
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PreviewRate(Assigns Millisecs As Integer)
		  Call Win32.User32.SendMessage(CapWin, WM_CAP_SET_PREVIEWRATE, Ptr(Millisecs), Nil)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ScalePreview(Assigns NewBool As Boolean)
		  If NewBool Then
		    Call Win32.User32.SendMessage(CapWin, WM_CAP_SET_SCALE, Ptr(1), Nil)
		  Else
		    Call Win32.User32.SendMessage(CapWin, WM_CAP_SET_SCALE, Ptr(0), Nil)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StartPreview()
		  If Win32.User32.SendMessage(CapWin, WM_CAP_SET_PREVIEW, Ptr(1), Nil) = 0 Then Break
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StopPreview()
		  Call Win32.User32.SendMessage(CapWin, WM_CAP_SET_PREVIEW, Ptr(0), Nil)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Version() As String
		  Dim ver As New MemoryBlock(1024)
		  If Win32.Avicap32.capGetDriverDescription(mIndex, Nil, 0, ver, ver.Size) Then
		    Return ver.WString(0)
		  Else
		    mLastError = Win32.Kernel32.GetLastError()
		  End If
		End Function
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected CapWin As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mIndex As Integer
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