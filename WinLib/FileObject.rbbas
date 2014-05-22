#tag Class
Protected Class FileObject
Implements WinLib.Win32Object
	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the WinLib.Win32Object interface.
		  If Not Win32.Kernel32.CloseHandle(mHandle) Then
		    mLastError = Win32.Kernel32.GetLastError()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Handle As Integer)
		  // Part of the WinLib.Win32Object interface.
		  mHandle = Handle
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function CreateFile(FileName As String, DesiredAccess As Integer, ShareMode As Integer, CreationDisposition As Integer, Flags As Integer, Optional SecurityAttributes As Ptr, Optional TemplateFile As Integer) As Integer
		  Dim hFile As Integer
		  hFile = Win32.Kernel32.CreateFile(Filename, DesiredAccess, Sharemode, SecurityAttributes, CreationDisposition, Flags, TemplateFile)
		  If hFile = INVALID_HANDLE_VALUE Then
		    hFile = Win32.Kernel32.GetLastError
		    Dim err As New IOException
		    err.ErrorNumber = hFile
		    err.Message = WinLib.FormatError(hFile)
		    Raise err
		  End If
		  Return hFile
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function CreateFileObject(FileName As String, DesiredAccess As Integer, ShareMode As Integer, CreationDisposition As Integer, Flags As Integer, Optional SecurityAttributes As Ptr, Optional TemplateFile As Integer) As FileObject
		  Return New FileObject(CreateFile(FileName, DesiredAccess, Sharemode, CreationDisposition, Flags, SecurityAttributes, TemplateFile))
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