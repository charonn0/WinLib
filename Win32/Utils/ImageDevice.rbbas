#tag Class
Protected Class ImageDevice
Implements Win32.Win32Object
	#tag CompatibilityFlags = TargetHasGUI
	#tag Method, Flags = &h0
		Sub Close()
		  If CapWin <> 0 Then
		    Call Win32.Libs.User32.SendMessage(CapWin, WM_CAP_DRIVER_DISCONNECT, mIndex, 0)
		    mLastError = Win32.LastError()
		    If Not Win32.Libs.User32.DestroyWindow(CapWin) Then mLastError = Win32.LastError()
		    CapWin = 0
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Constructor(Index As Integer)
		  mIndex = Index
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Destructor()
		  Me.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function DeviceCount() As Integer
		  Dim i As Integer
		  While Win32.Libs.AviCap32.capGetDriverDescription(i, Nil, 0, Nil, 0)
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
		  CapWin = Win32.Libs.AviCap32.capCreateCaptureWindow(Me.Name, Win32.GUI.WS_VISIBLE Or Win32.GUI.WS_CHILD, X, Y, W, H, Parent, 0)
		  If CapWin <= 0 Then
		    mLastError = Win32.LastError()
		    Return
		  End If
		  If Win32.Libs.User32.SendMessage(CapWin, WM_CAP_DRIVER_CONNECT, mIndex, 0) > 0 Then
		    'Dim parms As CAPTUREPARMS
		    'parms.CaptureAudio = True
		    'parms.MakeUserHitOKToCapure = True
		    'parms.RequestMicroSecPerFrame = 333
		    'parms.Yield = True
		    'Dim mb As MemoryBlock = parms.StringValue(TargetLittleEndian)
		    'If Win32.Libs.User32.SendMessage(CapWin, WM_CAP_SET_SEQUENCE_SETUP, Ptr(mb.Size), mb) = 0 Then Break
		  End If
		  mLastError = Win32.LastError()
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EmbedPreviewWithin(Parent As RectControl, X As Integer = -1, Y As Integer = -1, W As Integer = - 1, H As Integer = - 1)
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
		 Shared Function GetDeviceByIndex(Index As Integer) As Win32.Utils.ImageDevice
		  ' Index may be 0 to DeviceCount-1
		  If Index < DeviceCount And Index >= 0 Then
		    Return New ImageDevice(Index)
		  Else
		    Dim err As New OutOfBoundsException
		    err.Message = "There is no image device at that index."
		    err.ErrorNumber = Index
		    Raise err
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GrabFrame() As Picture
		  Dim win As New Win32.GUI.WindowRef(CapWin)
		  Dim p As Picture = win.Capture(False)
		  mLastError = win.LastError
		  Return p
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
		  If Win32.Libs.AviCap32.capGetDriverDescription(mIndex, nm, nm.Size, Nil, 0) Then
		    Return nm.WString(0)
		  Else
		    mLastError = Win32.LastError()
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PreviewRate(Assigns Millisecs As Integer)
		  Call Win32.Libs.User32.SendMessage(CapWin, WM_CAP_SET_PREVIEWRATE, Millisecs, 0)
		  mLastError = Win32.LastError()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ScalePreview(Assigns NewBool As Boolean)
		  If NewBool Then
		    Call Win32.Libs.User32.SendMessage(CapWin, WM_CAP_SET_SCALE, 1, 0)
		  Else
		    Call Win32.Libs.User32.SendMessage(CapWin, WM_CAP_SET_SCALE, 0, 0)
		  End If
		  mLastError = Win32.LastError()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StartPreview() As Boolean
		  If Win32.Libs.User32.SendMessage(CapWin, WM_CAP_SET_PREVIEW, 1, 0) = 0 Then
		    mLastError = Win32.LastError()
		    Return False
		  Else
		    mLastError = 0
		    Return True
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StopPreview()
		  Call Win32.Libs.User32.SendMessage(CapWin, WM_CAP_SET_PREVIEW, 0, 0)
		  mLastError = Win32.LastError()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Version() As String
		  Dim ver As New MemoryBlock(1024)
		  If Win32.Libs.AviCap32.capGetDriverDescription(mIndex, Nil, 0, ver, ver.Size) Then
		    Return ver.WString(0)
		  Else
		    mLastError = Win32.LastError()
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


	#tag Constant, Name = WM_CAP_DLG_VIDEOFORMAT, Type = Double, Dynamic = False, Default = \"1065", Scope = Private
	#tag EndConstant

	#tag Constant, Name = WM_CAP_DLG_VIDEOSOURCE, Type = Double, Dynamic = False, Default = \"1066", Scope = Private
	#tag EndConstant

	#tag Constant, Name = WM_CAP_DRIVER_CONNECT, Type = Double, Dynamic = False, Default = \"1034", Scope = Private
	#tag EndConstant

	#tag Constant, Name = WM_CAP_DRIVER_DISCONNECT, Type = Double, Dynamic = False, Default = \"1035", Scope = Private
	#tag EndConstant

	#tag Constant, Name = WM_CAP_EDIT_COPY1, Type = Double, Dynamic = False, Default = \"1054", Scope = Private
	#tag EndConstant

	#tag Constant, Name = WM_CAP_GRAB_FRAME, Type = Double, Dynamic = False, Default = \"1084", Scope = Private
	#tag EndConstant

	#tag Constant, Name = WM_CAP_SET_PREVIEW, Type = Double, Dynamic = False, Default = \"1074", Scope = Private
	#tag EndConstant

	#tag Constant, Name = WM_CAP_SET_PREVIEWRATE, Type = Double, Dynamic = False, Default = \"1076", Scope = Private
	#tag EndConstant

	#tag Constant, Name = WM_CAP_SET_SCALE, Type = Double, Dynamic = False, Default = \"1077", Scope = Private
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
