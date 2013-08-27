#tag Class
Protected Class FindFileIterator
Implements WinLib.Classes.Win32Object
	#tag Method, Flags = &h0
		Sub Close()
		  Call WinLib.Kernel32.FindClose(FindHandle)
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
		Attributes( deprecated = "Constructor(FolderItem,String)", hidden )  Sub Constructor(Handle As Integer)
		  FindHandle = Handle
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  Me.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  Return FindHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NextFolderItem(DirectoriesOnly As Boolean = False) As FolderItem
		  //This function returns a folderitem representing the next file or directory (starting with the first) in the RootDirectory
		  //If there are no more files, this function sets LastError=18 (ERROR_NO_MORE_FILES). If no more files or an error occurred,
		  //returns Nil.
		  
		  Dim data As WIN32_FIND_DATA = Me.NextItem
		  If data.FileName.Trim = "." Or data.FileName.Trim = ".." Then Return NextFolderItem(DirectoriesOnly)
		  
		  Dim result As FolderItem = Me.RootDirectory.TrueChild(data.FileName)
		  If Me.LastError = 0 Then
		    If Result.Directory Or Not DirectoriesOnly Then
		      Return result
		    Else
		      Return Me.NextFolderItem(DirectoriesOnly)
		    End If
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NextItem() As WIN32_FIND_DATA
		  //This function returns the WIN32_FIND_DATA structure of the next file or directory (starting with the first) in the RootDirectory
		  //If there are no more files, this function sets LastError=18 (ERROR_NO_MORE_FILES).
		  
		  
		  Dim data As WIN32_FIND_DATA
		  Dim namepattern As WString = "//?/" + ReplaceAll(RootDirectory.AbsolutePath, "/", "//") + SearchPattern + Chr(0)
		  If FindHandle <= 0 Then
		    If System.IsFunctionAvailable("FindFirstFileExW", "Kernel32") Then
		      FindHandle = WinLib.Kernel32.FindFirstFileEx(namepattern, 0, data, 0, Nil, FIND_FIRST_EX_LARGE_FETCH)
		    Else
		      FindHandle = WinLib.Kernel32.FindFirstFile(NamePattern, data)
		    End If
		    mLastError = GetLastError()
		  ElseIf WinLib.Kernel32.FindNextFile(FindHandle, data) Then
		    mLastError = 0
		  Else
		    mLastError = WinLib.GetLastError()
		  End If
		  
		  Return data
		End Function
	#tag EndMethod


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
