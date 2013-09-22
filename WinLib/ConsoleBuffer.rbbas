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
		Function StdErr() As Writeable
		  #If TargetHasGUI And TargetWin32 Then
		    Return New WinLib.IOStream(mHandle)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StdIn() As Readable
		  #If TargetHasGUI And TargetWin32 Then
		    Return New WinLib.IOStream(mHandle)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StdOut() As Writeable
		  #If Not TargetHasGUI And TargetWin32 Then
		    Return New WinLib.IOStream(mHandle)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Write(Text As String, Row As Integer = -1, Column As Integer = -1) As Integer
		  #If Not TargetHasGUI And TargetWin32 Then
		    Dim written As Integer
		    Dim txt As MemoryBlock = Text
		    Dim currentpos As New REALbasic.Point(CursorColumn, CursorRow)
		    If Row <> -1 Then
		      Me.CursorRow = Row
		    End If
		    If Column <> -1 Then
		      Me.CursorColumn = Column
		    End If
		    Call Win32.Kernel32.WriteConsole(mHandle, txt, txt.Size, written, Nil)
		    mLastError = GetLastError
		    If Row <> -1 Then
		      Me.CursorRow = currentpos.Y
		    End If
		    If Column <> -1 Then
		      Me.CursorColumn = currentpos.X
		    End If
		    Return written
		  #else
		    #pragma Unused Text
		    #pragma Unused Row
		    #pragma Unused Column
		  #endif
		End Function
	#tag EndMethod


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


	#tag ViewBehavior
		#tag ViewProperty
			Name="CursorX"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="CursorY"
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
