#tag Module
Protected Module Console
	#tag Method, Flags = &h1
		Protected Function GetCurrentBuffer() As WinLib.ConsoleBuffer
		  #If TargetWin32 Then
		    Return New WinLib.ConsoleBuffer(StdOutHandle)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetOriginalTitle() As String
		  //Returns the console window's original title. Only Windows Vista and later support this,
		  //so for earlier versions we emulate it.
		  
		  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
		    If System.IsFunctionAvailable("GetConsoleOriginalTitleW", "Kernel32") Then
		      Dim mb As New MemoryBlock(0)
		      mb = New MemoryBlock(Win32.Kernel32.GetConsoleOriginalTitle(mb, 0))
		      Call Win32.Kernel32.GetConsoleOriginalTitle(mb, mb.Size)
		      Return mb.Wstring(0)
		    Else  //WinXP and earlier
		      If OriginalTitle = "" Then
		        Return WindowTitle
		      Else
		        Return OriginalTitle
		      End If
		    End If
		  #endif
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private OriginalTitle As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  //Gets the console buffer stdin handle.
			  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
			    Return Win32.Kernel32.GetStdHandle(STD_ERROR_HANDLE)
			  #endif
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  //Sets the console buffer stdin handle.
			  //See Notes: http://msdn.microsoft.com/en-us/library/windows/desktop/ms686244%28v=vs.85%29.aspx
			  
			  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
			    Dim e As Integer
			    If Not Win32.Kernel32.SetStdHandle(STD_ERROR_HANDLE, value) Then
			      e = GetLastError
			      Dim err As New RuntimeException
			      err.ErrorNumber = e
			      err.Message = FormatError(e)
			      Raise err
			    End If
			  #else
			    #pragma Unused value
			  #endif
			End Set
		#tag EndSetter
		Protected StdErrHandle As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  //Gets the console buffer stdin handle.
			  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
			    Return Win32.Kernel32.GetStdHandle(STD_INPUT_HANDLE)
			  #endif
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
			    If Not Win32.Kernel32.SetStdHandle(STD_INPUT_HANDLE, value) Then
			      Raise Win32Exception(GetLastError)
			    End If
			  #else
			    #pragma Unused value
			  #endif
			End Set
		#tag EndSetter
		Protected StdInHandle As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  //Gets the console buffer stdout handle.
			  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
			    Return Win32.Kernel32.GetStdHandle(STD_OUTPUT_HANDLE)
			  #endif
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If Not TargetHasGUI And TargetWin32 Then  //Windows Console Applications only
			    If Not Win32.Kernel32.SetStdHandle(STD_OUTPUT_HANDLE, value) Then
			      Raise Win32Exception(GetLastError)
			    End If
			  #else
			    #pragma Unused value
			  #endif
			End Set
		#tag EndSetter
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
			    If Not Win32.Kernel32.SetConsoleTitle(value) Then
			      Raise Win32Exception(GetLastError)
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
