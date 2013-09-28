#tag Class
Class ConsoleBuffer
Implements WinLib.Win32Object
	#tag Method, Flags = &h1
		Protected Function BufferInfo() As CONSOLE_SCREEN_BUFFER_INFO
		  //Returns a CONSOLE_SCREEN_BUFFER_INFO structure for the current process's screen buffer
		  
		  #If Not TargetHasGUI And TargetWin32 Then
		    Dim buffInfo As CONSOLE_SCREEN_BUFFER_INFO
		    If Win32.Kernel32.GetConsoleScreenBufferInfo(mHandle, buffInfo) Then
		      Return buffInfo
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Clear() As Boolean
		  //Clears the screen and moves the cursor to the top left corner (0,0)
		  
		  #If Not TargetHasGUI And TargetWin32 Then
		    Dim cord As Win32.COORD = BufferInfo.dwSize
		    Dim charCount As Integer = cord.X * cord.Y
		    cord.X = 0
		    cord.Y = 0
		    
		    If Win32.Kernel32.FillConsoleOutputCharacter(mHandle, 0, charCount, cord, charCount) Then
		      Return Win32.Kernel32.SetConsoleCursorPosition(mHandle, cord)
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the WinLib.Win32Object interface.
		  #If Not TargetHasGUI And TargetWin32 Then
		    Call Win32.Kernel32.CloseHandle(mHandle)
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  #If Not TargetHasGUI And TargetWin32 Then
		    mHandle = Win32.Kernel32.CreateConsoleScreenBuffer(GENERIC_READ Or GENERIC_WRITE, FILE_SHARE_READ, Nil, CONSOLE_TEXTMODE_BUFFER, Nil)
		    mLastError = WinLib.GetLastError
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Handle As Integer)
		  // Part of the WinLib.Win32Object interface.
		  #If Not TargetHasGUI And TargetWin32 Then
		    mHandle = Handle
		  #else
		    #pragma Unused Handle
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Destructor()
		  Me.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetChar(x As Integer, y As Integer) As String
		  //Returns the character from the specified character cell in the screen buffer.
		  
		  #If Not TargetHasGUI And TargetWin32 Then
		    Dim mb As New MemoryBlock(4)
		    Dim p As New MemoryBlock(4)
		    Dim cords As COORD
		    cords.X = x
		    cords.Y = y
		    Call Win32.Kernel32.ReadConsoleOutputCharacter(mHandle, mb, mb.Size, cords, p)
		    mLastError = GetLastError
		    Return mb.CString(0)
		  #Else
		    #pragma Unused x
		    #pragma Unused y
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return mHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return mLastError
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MakeActive() As Boolean
		  #If Not TargetHasGUI And TargetWin32 Then
		    Return Win32.Kernel32.SetConsoleActiveScreenBuffer(mHandle)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetChar(x As Integer, y As Integer, char As String)
		  //Writes the character specified to the character cell specified in the screen buffer
		  
		  #If Not TargetHasGUI And TargetWin32 Then
		    Dim mb As New MemoryBlock(4)
		    Dim p As New MemoryBlock(4)
		    Dim cords As COORD
		    cords.X = x
		    cords.Y = y
		    mb.CString(0) = char
		    Call Win32.Kernel32.WriteConsoleOutputCharacter(mHandle, mb, mb.Size, cords, p)
		    mLastError = GetLastError
		  #Else
		    #pragma Unused x
		    #pragma Unused y
		    #pragma Unused char
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub SetTextAttribute(TextAttribute As Integer, Combine As Boolean = True)
		  #If Not TargetHasGUI And TargetWin32 Then
		    Dim attribs As Integer
		    If Combine Then
		      attribs = Me.BufferInfo.Attribute
		    End If
		    attribs = attribs Or TextAttribute
		    Call Win32.Kernel32.SetConsoleTextAttribute(mHandle, attribs)
		    mLastError = GetLastError
		  #else
		    #pragma Unused TextAttribute
		    #pragma Unused Combine
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StdInput() As Readable
		  #If TargetHasGUI And TargetWin32 Then
		    Return New WinLib.IOStream(mHandle)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StdOutput() As Writeable
		  #If Not TargetHasGUI And TargetWin32 Then
		    Return New WinLib.IOStream(mHandle)
		  #endif
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return BitAnd(TextStyle, BACKGROUND_BOLD) = BACKGROUND_BOLD
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If value Then
			    Me.TextStyle = Me.TextStyle Or BACKGROUND_BOLD
			  Else
			    Me.TextStyle = Me.TextStyle Or BACKGROUND_BOLD
			    Me.TextStyle = Me.TextStyle Xor BACKGROUND_BOLD
			  End If
			  
			End Set
		#tag EndSetter
		BackgroundBold As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim r, g, b As Byte
			  If BitAnd(TextStyle, BACKGROUND_RED) = BACKGROUND_RED Then
			    r = 255
			  End If
			  
			  If BitAnd(TextStyle, BACKGROUND_GREEN) = BACKGROUND_GREEN Then
			    g = 255
			  End If
			  
			  If BitAnd(TextStyle, BACKGROUND_BLUE) = BACKGROUND_BLUE Then
			    b = 255
			  End If
			  
			  Return RGB(r, g, b)
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Dim flags As UInt16
			  If value.Red > 0 Then
			    flags = flags Or BACKGROUND_RED
			  End If
			  
			  If value.Green > 0 Then
			    flags = flags Or BACKGROUND_GREEN
			  End If
			  
			  If value.Blue > 0 Then
			    flags = flags Or BACKGROUND_BLUE
			  End If
			  
			  Me.TextStyle = Me.TextStyle Or flags
			End Set
		#tag EndSetter
		BackgroundColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Me.BufferInfo.dwSize.Y
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If Not TargetHasGUI And TargetWin32 Then
			    Dim p As COORD
			    p.X = Me.RowCount
			    p.Y = value
			    Call Win32.Kernel32.SetConsoleScreenBufferSize(mHandle, p)
			    mLastError = GetLastError
			  #else
			    #pragma Unused value
			  #endif
			End Set
		#tag EndSetter
		ColumnCount As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //Gets the X (horizontal) position of the cursor
			  Return BufferInfo.CursorPosition.X
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  //Sets the X (horizontal) position of the cursor
			  #If Not TargetHasGUI And TargetWin32 Then
			    Dim cord As COORD = BufferInfo.CursorPosition
			    cord.X = value
			    Call Win32.Kernel32.SetConsoleCursorPosition(mHandle, cord)
			    mLastError = GetLastError
			  #Else
			    #pragma Unused value
			  #endif
			End Set
		#tag EndSetter
		CursorColumn As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //Gets the Y (vertical) position of the cursor
			  Return BufferInfo.CursorPosition.Y
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  //Sets the Y (vertical) position of the cursor
			  #If Not TargetHasGUI And TargetWin32 Then
			    Dim cord As COORD = BufferInfo.CursorPosition
			    cord.Y = value
			    Call Win32.Kernel32.SetConsoleCursorPosition(mHandle, cord)
			    mLastError = GetLastError
			  #Else
			    #pragma Unused value
			  #endif
			End Set
		#tag EndSetter
		CursorRow As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected mHandle As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Me.BufferInfo.dwSize.X
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If Not TargetHasGUI And TargetWin32 Then
			    Dim p As COORD
			    p.X = value
			    p.Y = Me.ColumnCount
			    Call Win32.Kernel32.SetConsoleScreenBufferSize(mHandle, p)
			    mLastError = GetLastError
			  #else
			    #pragma Unused value
			  #endif
			End Set
		#tag EndSetter
		RowCount As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return BitAnd(TextStyle, TEXT_BOLD) = TEXT_BOLD
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If value Then
			    Me.TextStyle = Me.TextStyle Or TEXT_BOLD
			  Else
			    Me.TextStyle = Me.TextStyle Or TEXT_BOLD
			    Me.TextStyle = Me.TextStyle Xor TEXT_BOLD
			  End If
			  
			End Set
		#tag EndSetter
		TextBold As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim r, g, b As Byte
			  If BitAnd(TextStyle, TEXT_RED) = TEXT_RED Then
			    r = 255
			  End If
			  
			  If BitAnd(TextStyle, TEXT_GREEN) = TEXT_GREEN Then
			    g = 255
			  End If
			  
			  If BitAnd(TextStyle, TEXT_BLUE) = TEXT_BLUE Then
			    b = 255
			  End If
			  
			  Return RGB(r, g, b)
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Dim flags As UInt16
			  If value.Red > 0 Then
			    flags = flags Or TEXT_RED
			  End If
			  
			  If value.Green > 0 Then
			    flags = flags Or TEXT_GREEN
			  End If
			  
			  If value.Blue > 0 Then
			    flags = flags Or TEXT_BLUE
			  End If
			  
			  Me.TextStyle = Me.TextStyle Or flags
			End Set
		#tag EndSetter
		TextColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  Return BufferInfo.Attribute
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
			    If Win32.Kernel32.SetConsoleTextAttribute(mHandle, value) Then
			      mLastError = 0
			    Else
			      mLastError = WinLib.GetLastError
			    End If
			  #Else
			    #pragma Unused value
			  #endif
			End Set
		#tag EndSetter
		Protected TextStyle As UInt16
	#tag EndComputedProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="BackgroundBold"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="BackgroundColor"
			Group="Behavior"
			InitialValue="&c000000"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColumnCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="CursorColumn"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="CursorRow"
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
			Name="RowCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TextBold"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TextColor"
			Group="Behavior"
			InitialValue="&c000000"
			Type="Color"
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
