#tag Module
Protected Module WinLib
	#tag Method, Flags = &h1
		Protected Function CloseHandle(Handle As Integer) As Boolean
		  #If TargetWin32 Then
		    Return Win32.Kernel32.CloseHandle(Handle)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function FormatError(WinErrorNumber As Integer) As String
		  //Returns the error message corresponding to a given windows error number.
		  
		  #If TargetWin32 Then
		    Dim buffer As New MemoryBlock(2048)
		    If Win32.Kernel32.FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, 0, WinErrorNumber, 0 , Buffer, Buffer.Size, 0) <> 0 Then
		      Return Buffer.WString(0)
		    Else
		      Return "Unknown error number: " + Str(WinErrorNumber)
		    End If
		  #Else
		    Return "Not a Windows system. Error number: " + Str(WinErrorNumber)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetLastError() As Integer
		  #If TargetWin32 Then
		    Return Win32.Kernel32.GetLastError()
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ShellExecute(Target As String, Parameters As String = "", Operation As String = "open", WorkingDirectory As String = "", ParentWindow As Integer = 0, ShowCommand As Integer = SW_SHOW) As Boolean
		  #If TargetWin32 Then
		    If WorkingDirectory = "" Then WorkingDirectory = CurrentDirectory.AbsolutePath
		    Return Win32.Shell32.ShellExecute(ParentWindow, Operation, Target, Parameters, WorkingDirectory, ShowCommand) > 32
		    
		  #endif
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Dim mb As New MemoryBlock(1024)
			    Dim i As Integer
			    Do
			      i = Win32.Kernel32.GetCurrentDirectory(mb.Size, mb)
			    Loop Until i <= mb.Size And i > 0
			    
			    Return GetFolderItem(mb.WString(0), FolderItem.PathTypeAbsolute)
			  #endif
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If TargetWin32 Then
			    Dim path As String = value.AbsolutePath
			    If Not Win32.Kernel32.SetCurrentDirectory(path) Then
			      Dim e As Integer = WinLib.GetLastError
			      Dim err As New IOException
			      err.Message = CurrentMethodName + ": " + WinLib.FormatError(e)
			      err.ErrorNumber = e
			      Raise err
			    End If
			  #endif
			End Set
		#tag EndSetter
		Protected CurrentDirectory As FolderItem
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
