#tag Module
Protected Module IO
	#tag Method, Flags = &h1
		Protected Function FILE_ALL_ACCESS() As Integer
		  Return STANDARD_RIGHTS_REQUIRED Or SYNCHRONIZE Or &h1FF
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function FILE_GENERIC_READ() As Integer
		  Return STANDARD_RIGHTS_READ Or FILE_READ_DATA Or FILE_READ_ATTRIBUTES Or FILE_READ_EA Or SYNCHRONIZE
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Dim mb As New MemoryBlock(1024)
			    Dim i As Integer
			    Do
			      i = Win32.Libs.Kernel32.GetCurrentDirectory(mb.Size, mb)
			    Loop Until i <= mb.Size And i > 0
			    
			    Return GetFolderItem(mb.WString(0), FolderItem.PathTypeAbsolute)
			  #endif
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If TargetWin32 Then
			    Dim path As String = value.AbsolutePath
			    If Not Win32.Libs.Kernel32.SetCurrentDirectory(path) Then
			      Dim e As Integer = Win32.LastError
			      Dim err As New IOException
			      err.Message = CurrentMethodName + ": " + FormatError(e)
			      err.ErrorNumber = e
			      Raise err
			    End If
			  #endif
			End Set
		#tag EndSetter
		Protected CurrentDirectory As FolderItem
	#tag EndComputedProperty


	#tag Constant, Name = CREATE_ALWAYS, Type = Double, Dynamic = False, Default = \"2", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CREATE_NEW, Type = Double, Dynamic = False, Default = \"1", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = DUPLICATE_CLOSE_SOURCE, Type = Double, Dynamic = False, Default = \"&h00000001", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = DUPLICATE_SAME_ACCESS, Type = Double, Dynamic = False, Default = \"&h00000002", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = ERROR_HANDLE_EOF, Type = Double, Dynamic = False, Default = \"&h26", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_BEGIN, Type = Double, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant

	#tag Constant, Name = FILE_CURRENT, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = FILE_END, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = FILE_EXECUTE, Type = Double, Dynamic = False, Default = \"&h0020", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_FLAG_BACKUP_SEMANTICS, Type = Double, Dynamic = False, Default = \"&h02000000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_FLAG_DELETE_ON_CLOSE, Type = Double, Dynamic = False, Default = \"&h04000000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_FLAG_FIRST_PIPE_INSTANCE, Type = Double, Dynamic = False, Default = \"&h00080000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_FLAG_NO_BUFFERING, Type = Double, Dynamic = False, Default = \"&h20000000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_FLAG_OPEN_NO_RECALL, Type = Double, Dynamic = False, Default = \"&h00100000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_FLAG_OPEN_REPARSE_POINT, Type = Double, Dynamic = False, Default = \"&h00200000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_FLAG_OVERLAPPED, Type = Double, Dynamic = False, Default = \"&h40000000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_FLAG_POSIX_SEMANTICS, Type = Double, Dynamic = False, Default = \"&h0100000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_FLAG_RANDOM_ACCESS, Type = Double, Dynamic = False, Default = \"&h10000000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_FLAG_SEQUENTIAL_SCAN, Type = Double, Dynamic = False, Default = \"&h08000000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_FLAG_SESSION_AWARE, Type = Double, Dynamic = False, Default = \"&h00800000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_FLAG_WRITE_THROUGH, Type = Double, Dynamic = False, Default = \"&h80000000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_READ_ACCESS, Type = Double, Dynamic = False, Default = \"&h0001", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_READ_ATTRIBUTES, Type = Double, Dynamic = False, Default = \"&h0080", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_READ_DATA, Type = Double, Dynamic = False, Default = \"&h0001", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_READ_EA, Type = Double, Dynamic = False, Default = \"&h0008", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_SHARE_DELETE, Type = Double, Dynamic = False, Default = \"&h00000004", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_SHARE_READ, Type = Double, Dynamic = False, Default = \"&h00000001", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_SHARE_WRITE, Type = Double, Dynamic = False, Default = \"&h2", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_WRITE_ATTRIBUTES, Type = Double, Dynamic = False, Default = \"&h0100", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_WRITE_DATA, Type = Double, Dynamic = False, Default = \"&h0002", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_WRITE_EA, Type = Double, Dynamic = False, Default = \"&h0010", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = GENERIC_ALL, Type = Double, Dynamic = False, Default = \"&h10000000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = GENERIC_EXECUTE, Type = Double, Dynamic = False, Default = \"&h20000000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = GENERIC_READ, Type = Double, Dynamic = False, Default = \"&h80000000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = GENERIC_WRITE, Type = Double, Dynamic = False, Default = \"&h40000000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = OPEN_ALWAYS, Type = Double, Dynamic = False, Default = \"4", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = OPEN_EXISTING, Type = Double, Dynamic = False, Default = \"3", Scope = Protected
	#tag EndConstant


	#tag Structure, Name = FILETIME, Flags = &h1
		HighDateTime As Integer
		LowDateTime As Integer
	#tag EndStructure

	#tag Structure, Name = IO_STATUS_BLOCK, Flags = &h1
		Status As Int32
		Info As Int32
	#tag EndStructure

	#tag Structure, Name = OVERLAPPED, Flags = &h1
		Internal As Integer
		  InternalHigh As Integer
		  Offset As UInt64
		hEvent As Integer
	#tag EndStructure

	#tag Structure, Name = WIN32_FIND_DATA, Flags = &h1
		Attribs As Integer
		  CreationTime As FILETIME
		  LastAccess As FILETIME
		  LastWrite As FILETIME
		  sizeHigh As Integer
		  sizeLow As Integer
		  Reserved1 As Integer
		  Reserved2 As Integer
		  FileName As WString*260
		AlternateName As String*14
	#tag EndStructure

	#tag Structure, Name = WIN32_FIND_STREAM_DATA, Flags = &h1
		StreamSize As Int64
		StreamName As String*1024
	#tag EndStructure


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
