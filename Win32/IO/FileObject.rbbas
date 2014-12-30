#tag Class
Protected Class FileObject
Implements Win32.Win32Object
	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the Win32Object interface.
		  If Not Win32.Libs.Kernel32.CloseHandle(mHandle) Then
		    mLastError = Win32.LastError()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(DuplicateFrom As BinaryStream)
		  Dim proc As Integer = Win32.Libs.Kernel32.GetCurrentProcess
		  If Not Win32.Libs.Kernel32.DuplicateHandle(proc, DuplicateFrom.Handle(BinaryStream.HandleTypeWin32Handle), proc, mHandle, 0, True, DUPLICATE_SAME_ACCESS) Then
		    mLastError = Win32.LastError
		    mHandle = INVALID_HANDLE_VALUE
		    Dim err As New IOException
		    err.ErrorNumber = Me.LastError
		    err.Message = Win32.FormatError(Me.LastError)
		    Raise err
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Handle As Integer)
		  // Part of the Win32Object interface.
		  mHandle = Handle
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function Create(FileName As String, DesiredAccess As Integer, ShareMode As Integer, CreationDisposition As Integer, Flags As Integer, Optional SecurityAttributes As Ptr, Optional TemplateFile As Integer) As FileObject
		  Return New FileObject(CreateFile(FileName, DesiredAccess, Sharemode, CreationDisposition, Flags, SecurityAttributes, TemplateFile))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function CreateFile(FileName As String, DesiredAccess As Integer, ShareMode As Integer, CreationDisposition As Integer, Flags As Integer, Optional SecurityAttributes As Ptr, Optional TemplateFile As Integer) As Integer
		  Dim hFile As Integer
		  hFile = Win32.Libs.Kernel32.CreateFile(Filename, DesiredAccess, Sharemode, SecurityAttributes, CreationDisposition, Flags, TemplateFile)
		  If hFile = INVALID_HANDLE_VALUE Then
		    hFile = Win32.LastError
		    Dim err As New IOException
		    err.ErrorNumber = hFile
		    err.Message = Win32.FormatError(hFile)
		    Raise err
		  End If
		  Return hFile
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Descriptor(Flags As Integer = _O_RDWR) As Integer
		  ' unreliable
		  If Win32.Libs.msvcrt.IsAvailable Then
		    Return Win32.Libs.msvcrt._open_osfhandle(Me.Handle, Flags)
		    Dim fd As Integer = Win32.Libs.msvcrt._open_osfhandle(Me.Handle, Flags)
		    If fd <> 0 Then
		      Dim mode As String
		      Select Case Flags
		      Case _O_APPEND
		        mode = "b"
		      Case _O_TEXT
		        mode = "t"
		      Case _O_RDONLY
		        mode = "r"
		      Case _O_RDWR
		        mode = "r+"
		      Case _O_WRONLY
		        mode = "w"
		      Case _O_BINARY
		        mode = "b"
		      Else
		        mode = "r+"
		      End Select
		      Return Win32.Libs.msvcrt._fdopen(fd, mode)
		    Else
		      Call Win32.Libs.msvcrt._get_errno(mLastError)
		      Return INVALID_HANDLE_VALUE
		    End If
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  // Part of the Win32Object interface.
		  Return mHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  // Part of the Win32Object interface.
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Operator_Convert(File As Win32.IO.FileObject)
		  Me.Constructor(File.Handle)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected mHandle As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty


	#tag Constant, Name = _O_APPEND, Type = Double, Dynamic = False, Default = \"&h0008", Scope = Private
	#tag EndConstant

	#tag Constant, Name = _O_BINARY, Type = Double, Dynamic = False, Default = \"&h8000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = _O_RDONLY, Type = Double, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant

	#tag Constant, Name = _O_RDWR, Type = Double, Dynamic = False, Default = \"&h0002", Scope = Private
	#tag EndConstant

	#tag Constant, Name = _O_TEXT, Type = Double, Dynamic = False, Default = \"&h4000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = _O_WRONLY, Type = Double, Dynamic = False, Default = \"&h0001", Scope = Private
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
