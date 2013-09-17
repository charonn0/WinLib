#tag Class
Class FindFileIterator
Implements Win32Object
	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the Win32.Win32Object interface.
		  // This method closes the current FindFile operation and makes the class ready to begin another.
		  #If TargetWin32 Then
		    Call Win32.Kernel32.FindClose(FindHandle)
		  #endif
		  FindHandle = -1
		  mLastError = 0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Root As FolderItem = Nil, Pattern As String = "*.*")
		  //Root is the directory in which to search
		  //Pattern is a full or partial filename, with support for wildcards (e.g. "*.exe" to enumerate all files ending in .exe)
		  
		  mRootDirectory = Root
		  mSearchPattern = Pattern
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Attributes( hidden )  Sub Constructor(Handle As Integer)
		  // Part of the Win32.Win32Object interface.
		  FindHandle = Handle
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Destructor()
		  Me.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  // Part of the Win32.Win32Object interface.
		  Return FindHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  // Part of the Win32.Win32Object interface.
		  return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NextItem() As FolderItem
		  //This function returns a folderitem representing the next file or directory (starting with the first) in the RootDirectory
		  //If there are no more files, this function sets LastError=18 (ERROR_NO_MORE_FILES). If no more files or an error occurred,
		  //returns Nil.
		  
		  Dim data As WIN32_FIND_DATA = Me.NextItemRaw
		  If Me.LastError = 0 Then
		    ' if the next item is either the current directory (".") or parent directory (".."), then skip it.
		    If data.FileName.Trim = "." Or data.FileName.Trim = ".." Then Return NextItem()
		    ' otherwise, return it.
		    Return Me.RootDirectory.TrueChild(data.FileName)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function NextItemRaw() As WIN32_FIND_DATA
		  //This function returns the WIN32_FIND_DATA structure of the next file or directory (starting with the first) in the RootDirectory
		  //If there are no more files, this function sets LastError=18 (ERROR_NO_MORE_FILES).
		  
		  #If TargetWin32 Then
		    Dim data As WIN32_FIND_DATA
		    Dim namepattern As WString = "//?/" + ReplaceAll(RootDirectory.AbsolutePath, "/", "//") + SearchPattern + Chr(0)
		    If FindHandle <= 0 Then
		      If System.IsFunctionAvailable("FindFirstFileExW", "Kernel32") Then
		        FindHandle = Win32.Kernel32.FindFirstFileEx(namepattern, 0, data, 0, Nil, FIND_FIRST_EX_LARGE_FETCH)
		      Else
		        FindHandle = Win32.Kernel32.FindFirstFile(NamePattern, data)
		      End If
		      mLastError = WinLib.GetLastError()
		    ElseIf Win32.Kernel32.FindNextFile(FindHandle, data) Then
		      mLastError = 0
		    Else
		      mLastError = WinLib.GetLastError()
		    End If
		    
		    Return data
		  #endif
		End Function
	#tag EndMethod


	#tag Note, Name = About this class
		Create a new instance of the FindFileIterator class passing the directory to be examined and a search pattern to match 
		file/folder names against. The search patterns allowed are the same as those accepted by the cmd.exe 'dir' command, 
		e.g. "*.*" matches all names; "*.EXE" matches all .exe files; etc.
		
		Call NextItem to receive the next file's or folder's FolderItem. Calling this function will advance the search 
		position by 1.
		
		Example, finding all EXE files in a user selected folder:
		
		  Dim fe As New FindFileIterator(SelectFolder, "*.exe")
		  Dim files() As FolderItem
		  Do
		    Dim file As FolderItem = fe.NextItem()
		    If file <> Nil Then
		      files.Append(file)
		    End If
		  Loop Until fe.LastError <> 0
		
		Using this class to enumerate a folder can be much faster than FolderItem.Item, especially on large directories. 
		Execution time of FolderItem.Item rises exponentially relative to the number of items in the directory. The execution 
		time of FindFileIterator.NextItem rises only linearly relative to the number of items.
	#tag EndNote


	#tag Property, Flags = &h21
		Private FindHandle As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRootDirectory As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSearchPattern As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mRootDirectory
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Me.Close
			  mRootDirectory = value
			End Set
		#tag EndSetter
		RootDirectory As FolderItem
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mSearchPattern
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Me.Close
			  mSearchPattern = value
			End Set
		#tag EndSetter
		SearchPattern As String
	#tag EndComputedProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SearchPattern"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
