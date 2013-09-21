#tag Module
Protected Module Console
	#tag Method, Flags = &h1
		Protected Function ClearScreen() As Boolean
		  //Clears the screen and moves the cursor to the top left corner (0,0)
		  
		  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
		    Dim cord As Win32.COORD = Buffer.dwSize
		    Dim charCount As Integer = cord.X * cord.Y
		    cord.X = 0
		    cord.Y = 0
		    
		    If Win32.Kernel32.FillConsoleOutputCharacter(StdOutHandle, 0, charCount, cord, charCount) Then
		      Return Win32.Kernel32.SetConsoleCursorPosition(StdOutHandle, cord)
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetChar(x As Integer, y As Integer) As String
		  //Returns the character from the specified character cell in the screen buffer.
		  //On error, raises a Win32Exception with the Last Win32 error code
		  
		  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
		    Dim mb As New MemoryBlock(4)
		    Dim p As New MemoryBlock(4)
		    Dim cords As COORD
		    cords.X = x
		    cords.Y = y
		    Dim e As Integer
		    If Win32.Kernel32.ReadConsoleOutputCharacter(StdOutHandle, mb, mb.Size, cords, p) Then
		      Return mb.CString(0)
		    Else
		      e = GetLastError
		      Dim err As New RuntimeException
		      err.ErrorNumber = e
		      err.Message = FormatError(e)
		      Raise err
		    End If
		    
		  #Else
		    #pragma Unused x
		    #pragma Unused y
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetOriginalTitle() As String
		  //Returns the console window's original title. Only Windows Vista and later support this,
		  //so for earlier versions we work around it.
		  
		  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
		    If System.IsFunctionAvailable("GetConsoleOriginalTitleW", "Kernel32") Then
		      Dim mb As New MemoryBlock(0)
		      mb = New MemoryBlock(Win32.Kernel32.GetConsoleOriginalTitle(mb, 0))
		      Call Win32.Kernel32.GetConsoleOriginalTitle(mb, mb.Size)
		      Return mb.Wstring(0)
		    Else  //WinXP and earlier
		      If OriginalTitle = "" Then  //The title was NOT previously changed using Console.ConsoleTitle
		        Return WindowTitle  //Just return the current title.
		      Else
		        Return OriginalTitle //Return the saved title
		      End If
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub PutChar(x As Integer, y As Integer, char As String)
		  //Writes the character specified to the character cell specified in the screen buffer
		  //On error, raises a Win32Exception with the Last Win32 error code
		  
		  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
		    Dim mb As New MemoryBlock(4)
		    Dim p As New MemoryBlock(4)
		    Dim cords As COORD
		    cords.X = x
		    cords.Y = y
		    mb.CString(0) = char
		    Dim e As Integer
		    If Not Win32.Kernel32.WriteConsoleOutputCharacter(StdOutHandle, mb, mb.Size, cords, p) Then
		      e = GetLastError
		      Dim err As New RuntimeException
		      err.ErrorNumber = e
		      err.Message = FormatError(e)
		      Raise err
		    End If
		  #Else
		    #pragma Unused x
		    #pragma Unused y
		    #pragma Unused char
		  #endif
		End Sub
	#tag EndMethod


	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  //Returns a CONSOLE_SCREEN_BUFFER_INFO structure for the current process's screen buffer
			  
			  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
			    Dim buffInfo As CONSOLE_SCREEN_BUFFER_INFO
			    If Win32.Kernel32.GetConsoleScreenBufferInfo(stdOutHandle, buffInfo) Then
			      Return buffInfo
			    End If
			  #endif
			End Get
		#tag EndGetter
		Protected Buffer As CONSOLE_SCREEN_BUFFER_INFO
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  //Gets the X (horizontal) position of the cursor
			  Return Buffer.CursorPosition.X
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  //Sets the X (horizontal) position of the cursor
			  Dim cord As COORD = Buffer.CursorPosition
			  cord.X = value
			  Call Win32.Kernel32.SetConsoleCursorPosition(StdOutHandle, cord)
			End Set
		#tag EndSetter
		Protected CursorX As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  //Gets the Y (vertical) position of the cursor
			  Return Buffer.CursorPosition.Y
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  //Sets the Y (vertical) position of the cursor
			  Dim cord As COORD = Buffer.CursorPosition
			  cord.Y = value
			  Call Win32.Kernel32.SetConsoleCursorPosition(StdOutHandle, cord)
			End Set
		#tag EndSetter
		Protected CursorY As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private OriginalTitle As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  //Gets the console buffer stdin handle.
			  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
			    Static stdHandle As Integer
			    If stdHandle = INVALID_HANDLE_VALUE Then
			      stdHandle = Win32.Kernel32.GetStdHandle(STD_ERROR_HANDLE)
			    End If
			    Return stdHandle
			  #endif
			End Get
		#tag EndGetter
		Protected StdErrHandle As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  //Gets the console buffer stdin handle.
			  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
			    Static stdHandle As Integer
			    If stdHandle <= 0 Then stdHandle = Win32.Kernel32.GetStdHandle(STD_INPUT_HANDLE)
			    Return stdHandle
			  #endif
			End Get
		#tag EndGetter
		Protected StdInHandle As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  //Gets the console buffer stdout handle.
			  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
			    Static stdOutHandle As Integer
			    If stdOutHandle <= 0 Then stdOutHandle = Win32.Kernel32.GetStdHandle(STD_OUTPUT_HANDLE)
			    Return stdOutHandle
			  #endif
			End Get
		#tag EndGetter
		Protected StdOutHandle As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  //Returns the console window title.
			  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
			    Dim mb As New MemoryBlock(256)
			    Call Win32.Kernel32.GetConsoleTitle(mb, mb.Size)
			    If mb.Size = 0 Then Return ""
			    Return mb.Wstring(0)
			  #endif
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  //Sets the console window title.
			  
			  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
			    If OriginalTitle = "" Then OriginalTitle = WindowTitle
			    Dim e As Integer
			    If Not Win32.Kernel32.SetConsoleTitle(value) Then
			      e = GetLastError
			      Dim err As New RuntimeException
			      err.ErrorNumber = e
			      err.Message = FormatError(e)
			      Raise err
			    End If
			  #Else
			    #pragma Unused value
			  #endif
			End Set
		#tag EndSetter
		Protected WindowTitle As String
	#tag EndComputedProperty


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
End Module
#tag EndModule
