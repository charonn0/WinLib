#tag Class
Class FindFileIterator
Implements WinLib.Win32Object
	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the Win32.Win32Object interface.
		  // This method closes the current FindFile operation and makes the class ready to begin another.
		  #If TargetWin32 Then
		    If FindHandle <> INVALID_HANDLE_VALUE Then  Call Win32.Kernel32.FindClose(FindHandle)
		  #endif
		  FindHandle = INVALID_HANDLE_VALUE
		  mLastError = 0
		  mCurrentItem = Nil
		  mCaseSensitive = False
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

	#tag Method, Flags = &h0
		Function CurrentItem() As FolderItem
		  Return mCurrentItem
		End Function
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
		Function NextItem() As Boolean
		  //This function advances the search position by 1 and stores a folderitem representing the next file or directory (starting with the first)
		  //in FindFileIterator.CurrentItem and returns True
		  //If no more files or an error occurred, returns False and sets LastError
		  
		  mCurrentItem = Nil
		  Dim data As WIN32_FIND_DATA = Me.NextItemRaw
		  If Me.LastError = 0 Then
		    ' if the next item is either the current directory (".") or parent directory (".."), then skip it.
		    If data.FileName.Trim = "." Or data.FileName.Trim = ".." Then Return NextItem()
		    ' otherwise, return it.
		    mCurrentItem = Me.RootDirectory.TrueChild(data.FileName)
		    Return mCurrentItem <> Nil
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
		        Dim flags As Integer
		        If Win32.KernelVersion >= 6.1 Then flags = FIND_FIRST_EX_LARGE_FETCH
		        If CaseSensitive Then flags = flags Or FIND_FIRST_EX_CASE_SENSITIVE
		        FindHandle = Win32.Kernel32.FindFirstFileEx(namepattern, 0, data, 0, Nil, flags)
		      Else
		        FindHandle = Win32.Kernel32.FindFirstFile(NamePattern, data)
		      End If
		      mLastError = GetLastError()
		    ElseIf Win32.Kernel32.FindNextFile(FindHandle, data) Then
		      mLastError = 0
		    Else
		      mLastError = GetLastError()
		    End If
		    
		    Return data
		  #endif
		End Function
	#tag EndMethod


	#tag Note, Name = About this class
		Create a new instance of the FindFileIterator class passing the directory to be examined and a search pattern to match 
		file/folder names against. The search patterns allowed are the same as those accepted by the cmd.exe 'dir' command, 
		e.g. "*.*" matches all names; "*.EXE" matches all .exe files; etc.
		
		Call NextItem to advance the search position by 1. The first call to NextItem will find the first matching item. If a
		matching file or folder is found, NextItem returns True and stores the item in FindFileIterator.CurrentItem. Otherwise, 
		CurrentItem will be set to Nil.
		
		Example, finding all EXE files in a user selected folder:
		
		  Dim fe As New FindFileIterator(SelectFolder, "*.exe")
		  Dim files() As FolderItem
		  Do Until Not fe.NextItem
		      files.Append(fe.CurrentItem)
		  Loop
		
		Using this class to enumerate a folder can be much faster than FolderItem.Item, especially on large directories. 
		Execution time of FolderItem.Item rises exponentially relative to the number of items in the directory. FindFileIterator
		implements a faster, single-pass search.
	#tag EndNote


	#tag ComputedProperty, Flags = &h0
		#tag Note
			Note that the user must have enabled case sensitivity in the registry for this feature to be available.
			If the feature is unavailable then searches are not case sensitive.
		#tag EndNote
		#tag Getter
			Get
			  return mCaseSensitive
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Me.Close
			  mCaseSensitive = value
			End Set
		#tag EndSetter
		CaseSensitive As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private FindHandle As Integer = INVALID_HANDLE_VALUE
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCaseSensitive As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCurrentItem As FolderItem
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
			Name="CaseSensitive"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
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
