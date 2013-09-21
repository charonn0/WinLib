#tag Class
Class WindowRef
Implements Win32Object
	#tag Method, Flags = &h0
		Sub BringToFront()
		  #If TargetWin32 Then
		    Call Win32.User32.ShowWindow(Me.Handle, SW_SHOWNORMAL)
		    mLastError = GetLastError
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Capture(IncludeBorder As Boolean = True) As Picture
		  'Calls CaptureRect on the specified Window.
		  'If the optional IncludeBorder parameter is False, then only the client area of the window
		  'is captured; if True then the client area, borders, and titlebar are included in the capture.
		  'If the window is a ContainerControl or similar construct (AKA child windows), only the contents of the container
		  'are captured. To always capture the topmost containing window, use ForeignWindow.TrueParent.Capture
		  'If all or part of the Window is overlapped by other windows, then the capture will include the overlapping
		  'parts of the other windows.
		  
		  Dim l, t, w, h As Integer
		  If Not IncludeBorder Then
		    l = Me.Left
		    t = Me.Top
		    w = Me.Width
		    h = Me.Height
		    
		  Else
		    l = Me.TrueLeft
		    t = Me.TrueTop
		    w = Me.TrueWidth
		    h = Me.TrueHeight
		  End If
		  
		  Return WinLib.Gui.CaptureRect(l, t, w, h)
		  mLastError = GetLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Attributes( hidden ) Protected Sub Close()
		  Return
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(HWND As Integer)
		  Me.mHandle = HWND
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FlashWindow()
		  #If TargetWin32 Then
		    Call Win32.User32.FlashWindow(Me.Handle, True)
		    mLastError = GetLastError
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  return mHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Operator_Compare(OtherWindow As WindowRef) As Integer
		  If OtherWindow.Handle > Me.Handle Then
		    Return 1
		  ElseIf OtherWindow.Handle < Me.Handle Then
		    Return -1
		  Else
		    Return 0
		  End If
		End Function
	#tag EndMethod


	#tag Note, Name = About this class
		
		This class represents any win32 window. The Class Constructor expects a valid Win32 window handle (HWND).
	#tag EndNote


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Dim a As Integer
			    If Win32.User32.GetLayeredWindowAttributes(Me.Handle, 0 , a, LWA_ALPHA) Then
			      Return a / 255.0
			    Else
			      Return 255.0
			    End If
			  #endif
			  
			  
			  Finally
			    mLastError = GetLastError
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If TargetWin32 Then
			    If Not WinLib.GUI.TestWindowStyleEx(Me.Handle, WS_EX_LAYERED) Then
			      WinLib.GUI.SetWindowStyleEx(Me.Handle, WS_EX_LAYERED) = True
			    End If
			    Call Win32.User32.SetLayeredWindowAttributes(Handle, 0 , value * 255, LWA_ALPHA)
			  #endif
			  
			  Finally
			    mLastError = GetLastError
			    
			End Set
		#tag EndSetter
		Alpha As Single
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Me.WindowInfo.cxWindowBorders
			End Get
		#tag EndGetter
		BorderSizeX As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Me.WindowInfo.cyWindowBorders
			End Get
		#tag EndGetter
		BorderSizeY As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim size As RECT = Me.WindowInfo.ClientArea
			  Return size.bottom - size.top
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If TargetWin32 Then
			    Dim flags As Integer = SWP_NOZORDER Or SWP_ASYNCWINDOWPOS Or SWP_NOACTIVATE
			    If Win32.User32.SetWindowPos(Me.Handle, 0, Me.TrueLeft, Me.TrueTop, Me.TrueWidth, value, flags) Then
			      mLastError = 0
			    Else
			      mLastError = GetLastError
			    End If
			  #endif
			End Set
		#tag EndSetter
		Height As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim size As RECT = Me.WindowInfo.ClientArea
			  Return size.left
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If TargetWin32 Then
			    Dim flags As Integer = SWP_NOZORDER Or SWP_ASYNCWINDOWPOS Or SWP_NOACTIVATE
			    If Win32.User32.SetWindowPos(Me.Handle, 0, value, Me.TrueTop, Me.TrueWidth, Me.TrueHeight, flags) Then
			      mLastError = 0
			    Else
			      mLastError = GetLastError
			    End If
			  #endif
			End Set
		#tag EndSetter
		Left As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Dim wp As WINDOWPLACEMENT
			    wp.Length = wp.Size
			    If Win32.User32.GetWindowPlacement(Me.Handle, wp) Then
			      Return wp.ShowCmd = SW_SHOWMAXIMIZED
			    End If
			  #endif
			  
			  Finally
			    mLastError = GetLastError
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If TargetWin32 Then
			    If value Then
			      Call Win32.User32.ShowWindow(Me.Handle, SW_MAXIMIZE)
			    Else
			      Call Win32.User32.ShowWindow(Me.Handle, SW_SHOWDEFAULT)
			    End If
			    mLastError = GetLastError
			  #endif
			End Set
		#tag EndSetter
		Maximized As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mHandle As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Dim wp As WINDOWPLACEMENT
			    wp.Length = wp.Size
			    If Win32.User32.GetWindowPlacement(Me.Handle, wp) Then
			      Return wp.ShowCmd = SW_SHOWMINIMIZED
			    End If
			  #endif
			  
			  Finally
			    mLastError = GetLastError
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If TargetWin32 Then
			    If value Then
			      Call Win32.User32.ShowWindow(Me.Handle, SW_MINIMIZE)
			    Else
			      Call Win32.User32.ShowWindow(Me.Handle, SW_SHOWDEFAULT)
			    End If
			    mLastError = GetLastError
			  #endif
			End Set
		#tag EndSetter
		Minimized As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mLastError As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Dim h As Integer = Win32.User32.GetWindow(Me.Handle, GW_OWNER)
			    mLastError = GetLastError
			    Return New WindowRef(h)
			  #endif
			End Get
		#tag EndGetter
		Owner As WindowRef
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Dim h As Integer = Win32.User32.GetParent(Me.Handle)
			    mLastError = GetLastError
			    Return New WindowRef(h)
			  #endif
			End Get
		#tag EndGetter
		Parent As WindowRef
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Dim buffer As New MemoryBlock(2048)
			    Dim sz As New MemoryBlock(4)
			    sz.Int32Value(0) = buffer.Size
			    If WinLib.GUI.SendMessage(Self, WM_GETTEXT, sz, buffer) <= 0 Then 'We ask nicely
			      Call Win32.User32.GetWindowText(Me.Handle, buffer, buffer.Size)  'otherwise we try to peek (sometimes crashy!)
			    End If
			    mLastError = GetLastError
			    Return buffer.WString(0).Trim
			  #endif
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If TargetWin32 Then
			    value = DefineEncoding(value, Encodings.UTF8)
			    Dim mb As New MemoryBlock(value.Len * 2 + 2)
			    mb.WString(0) = value
			    If WinLib.GUI.SendMessage(Self, WM_SETTEXT, Nil, mb) <= 0 Then 'We ask nicely
			      Call Win32.User32.SetWindowText(Me.Handle, mb)  'otherwise we try to peek (sometimes crashy!)
			    End If
			  #endif
			End Set
		#tag EndSetter
		Text As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim size As RECT = Me.WindowInfo.ClientArea
			  Return size.top
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If TargetWin32 Then
			    Dim flags As Integer = SWP_NOZORDER Or SWP_ASYNCWINDOWPOS Or SWP_NOACTIVATE
			    If Win32.User32.SetWindowPos(Me.Handle, 0, Me.TrueLeft, value, Me.TrueWidth, Me.TrueHeight, flags) Then
			      mLastError = 0
			    Else
			      mLastError = GetLastError
			    End If
			  #endif
			End Set
		#tag EndSetter
		Top As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim size As RECT = Me.WindowInfo.WindowArea
			  Return size.bottom - size.top
			End Get
		#tag EndGetter
		TrueHeight As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  
			  Dim size As RECT = Me.WindowInfo.WindowArea
			  Return size.Left
			End Get
		#tag EndGetter
		TrueLeft As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Dim h As Integer = Win32.User32.GetAncestor(Me.Handle, GA_ROOTOWNER)
			    mLastError = GetLastError
			    Return New WindowRef(h)
			  #endif
			End Get
		#tag EndGetter
		TrueOwner As WindowRef
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Dim h As Integer = Win32.User32.GetAncestor(Me.Handle, GA_ROOT)
			    mLastError = GetLastError
			    Return New WindowRef(h)
			  #endif
			End Get
		#tag EndGetter
		TrueParent As WindowRef
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim size As RECT = Me.WindowInfo.WindowArea
			  Return size.right
			End Get
		#tag EndGetter
		TrueRight As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  
			  Dim size As RECT = Me.WindowInfo.WindowArea
			  Return size.top
			End Get
		#tag EndGetter
		TrueTop As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  
			  Dim size As RECT = Me.WindowInfo.WindowArea
			  Return size.Right - size.Left
			End Get
		#tag EndGetter
		TrueWidth As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Return Win32.User32.IsWindowVisible(Me.Handle)
			  #endif
			  
			  Finally
			    mLastError = GetLastError
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If TargetWin32 Then
			    If value Then
			      Call Win32.User32.ShowWindow(Me.Handle, SW_SHOW)
			    Else
			      Call Win32.User32.ShowWindow(Me.Handle, SW_FORCEMINIMIZE)
			    End If
			  #endif
			  mLastError = GetLastError
			End Set
		#tag EndSetter
		Visible As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim size As RECT = Me.WindowInfo.ClientArea
			  Return size.right - size.left
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If TargetWin32 Then
			    Dim flags As Integer = SWP_NOZORDER Or SWP_ASYNCWINDOWPOS Or SWP_NOACTIVATE
			    If Win32.User32.SetWindowPos(Me.Handle, 0, Me.TrueLeft, Me.TrueTop, value, Me.TrueHeight, flags) Then
			      mLastError = 0
			    Else
			      mLastError = GetLastError
			    End If
			  #endif
			End Set
		#tag EndSetter
		Width As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim info As WINDOWINFO
			  #If TargetWin32 Then
			    If Win32.User32.GetWindowInfo(Me.Handle, info) Then
			      mLastError = 0
			    Else
			      mLastError = GetLastError
			    End If
			  #endif
			  Return info
			End Get
		#tag EndGetter
		WindowInfo As WINDOWINFO
	#tag EndComputedProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Alpha"
			Group="Behavior"
			Type="Single"
		#tag EndViewProperty
		#tag ViewProperty
			Name="BorderSizeX"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="BorderSizeY"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Maximized"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Minimized"
			Group="Behavior"
			Type="Boolean"
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
			Name="Text"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TrueHeight"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TrueLeft"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TrueRight"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TrueTop"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TrueWidth"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
