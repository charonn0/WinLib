#tag Class
Protected Class FileItem
Inherits FolderItem
	#tag Method, Flags = &h0
		Function ADS(StreamIndex As Integer) As String
		  //Accesses the data stream of the target FolderItem at StreamIndex. If target has fewer than StreamIndex data streams, or if the target
		  //is not on an NTFS volume, an OutOfBoundsException is raised. If the file is not readable, an IOException is raised.
		  //Otherwise, a String corresponding to the name of the requested data stream is Returned.
		  //Raises a PlatformNotSupportedException on versions of Windows prior to Windows 2000.
		  //Call FolderItem.StreamCount to get the number of streams. The main data stream is always at StreamIndex zero and does
		  //not have a name.
		  
		  
		  #If TargetWin32 Then
		    If StreamIndex = 0 Then Return ""  //Stream zero is the unnamed main stream
		    
		    If WinLib.KernelVersion < 6.0 And WinLib.KernelVersion >= 5.0 Then
		      Dim fHandle As Integer = WinLib.Kernel32.CreateFile(Self.AbsolutePath, 0,  FILE_SHARE_READ Or FILE_SHARE_WRITE, 0, OPEN_EXISTING, 0, 0)
		      If fHandle > 0 Then
		        Dim mb As New MemoryBlock(64 * 1024)
		        Dim status As IO_STATUS_BLOCK
		        WinLib.NTDLL.NtQueryInformationFile(fHandle, status, mb, mb.Size, 22)
		        Dim currentOffset As Integer
		        For i As Integer = 0 To StreamIndex
		          If mb.UInt32Value(currentOffset) > 0 Then
		            currentOffset = mb.UInt32Value(currentOffset)
		            If i = StreamIndex Then
		              Call WinLib.Kernel32.CloseHandle(fHandle)
		              Return mb.WString(24)
		            End If
		          Else
		            Call WinLib.Kernel32.CloseHandle(fHandle)
		            Raise New OutOfBoundsException
		          End If
		        Next
		        Call WinLib.Kernel32.CloseHandle(fHandle)
		      Else
		        Raise New IOException
		      End If
		    ElseIf WinLib.KernelVersion >= 6.0 Then
		      Dim buffer As WIN32_FIND_STREAM_DATA
		      Dim sHandle As Integer = WinLib.Kernel32.FindFirstStream(Self.AbsolutePath, 0, buffer, 0)
		      Dim ret As String
		      
		      If sHandle > 0 Then
		        Dim i As Integer = 1
		        If WinLib.Kernel32.FindNextStream(sHandle, buffer) Then
		          Do
		            If i = StreamIndex Then
		              ret = DefineEncoding(buffer.StreamName, Encodings.UTF16)
		              ret = NthField(ret, ":", 2)
		              Exit
		            ElseIf i >= StreamIndex Then
		              Raise New OutOfBoundsException
		            Else
		              i = i + 1
		            End If
		          Loop Until Not WinLib.Kernel32.FindNextStream(sHandle, buffer)
		        Else
		          Raise New OutOfBoundsException
		        End If
		        
		        Call WinLib.Kernel32.FindClose(sHandle)
		        Return ret
		      Else
		        Raise New IOException
		      End If
		    Else
		      Raise New PlatformNotSupportedException
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ADS(StreamName As String, CreateNew As Boolean = False) As FolderItem
		  //Opens the named stream for the file or directory specified in target. If CreateNew=True then the stream
		  //is created if it doesn't exist. Returns a FolderItem corresponding to the stream. On error returns Nil.
		  //Failure reasons may be: the volume is not NTFS, access to the file or directory was denied, or the target does not exist.
		  
		  #If TargetWin32 Then
		    If Self = Nil Then Return Nil
		    If Not Self.Exists Then Return Nil
		    Dim target As FolderItem
		    Dim fHandle As Integer = WinLib.Kernel32.CreateFile(Self.AbsolutePath + ":" + StreamName + ":$DATA", 0, _
		    FILE_SHARE_READ Or FILE_SHARE_WRITE, 0, CREATE_NEW, 0, 0)
		    If fHandle > 0 Then
		      target = GetFolderItem(Self.AbsolutePath + ":" + StreamName + ":$DATA")
		      Call WinLib.Kernel32.CloseHandle(fHandle)
		      Return target
		    Else
		      If WinLib.GetLastError = 80 And CreateNew Then  //ERROR_FILE_EXISTS
		        target = GetFolderItem(Self.AbsolutePath + ":" + StreamName + ":$DATA")
		        Return target
		      End If
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ADSCount() As Integer
		  //Counts the number of data streams attached to a file or directory on an NTFS volume. This count includes the default main stream.
		  //Windows Vista and newer have much better APIs for handling streams than previous versions, so we use those when possible.
		  //On error, returns -1
		  
		  #If TargetWin32 Then
		    If WinLib.KernelVersion >= 5.0 And WinLib.KernelVersion < 6.0 Then
		      
		      Dim fHandle As Integer = WinLib.Kernel32.CreateFile(Self.AbsolutePath, 0,  FILE_SHARE_READ Or FILE_SHARE_WRITE, 0, OPEN_EXISTING, 0, 0)
		      If fHandle > 0 Then
		        Dim mb As New MemoryBlock(64 * 1024)
		        Dim status As IO_STATUS_BLOCK
		        WinLib.NTDLL.NtQueryInformationFile(fHandle, status, mb, mb.Size, 22)
		        Dim ret, currentOffset As Integer
		        While True
		          If mb.UInt32Value(currentOffset) > 0 Then
		            currentOffset = currentOffset + mb.UInt32Value(currentOffset)
		            ret = ret + 1
		          Else
		            Exit While
		          End If
		        Wend
		        Return ret
		        
		      Else
		        Return -1
		      End If
		    ElseIf WinLib.KernelVersion >= 6.0 Then
		      Dim buffer As WIN32_FIND_STREAM_DATA
		      Dim sHandle As Integer = WinLib.Kernel32.FindFirstStream(Self.AbsolutePath, 0, buffer, 0)
		      Dim ret As Integer
		      
		      If sHandle > 0 Then
		        Do
		          ret = ret + 1
		        Loop Until Not WinLib.Kernel32.FindNextStream(sHandle, buffer)
		      Else
		        Return -1
		      End If
		      Call WinLib.Kernel32.FindClose(sHandle)
		      Return ret
		    Else
		      Return -1
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor()
		  // Calling the overridden superclass constructor.
		  // Constructor() -- From FolderItem
		  Super.Constructor()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(source As FolderItem)
		  // Calling the overridden superclass constructor.
		  // Constructor(source As FolderItem) -- From FolderItem
		  Super.Constructor(source)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(Path As String, pathMode As Integer = 0)
		  // Calling the overridden superclass constructor.
		  // Constructor(Path As String, pathMode As Integer = 0) -- From FolderItem
		  Super.Constructor(Path, pathMode)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CreateHardLink(source As FolderItem, destination As FolderItem) As Boolean
		  //Creates an NTFS Hard Link. Source is the existing file, destination is the new Hard Link
		  //This function will fail if the source and destination are not on the same volume or if the source or destination are directories.
		  //Use CreateSymLink (or CreateShortcut) for files on different volumes.
		  //Raises a PlatformNotSupportedException on versions of Windows not supporting hard links.
		  
		  #If TargetWin32 Then
		    If System.IsFunctionAvailable("CreateHardLinkW", "Kernel32") Then
		      Return WinLib.Kernel32.CreateHardLink(destination.AbsolutePath, source.AbsolutePath, Nil)
		    Else
		      Raise New PlatformNotSupportedException
		    End If
		  #endif
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CreateShortcut(ShortcutName As String) As FolderItem
		  //Creates a shortcut (.lnk file) in the users %TEMP% directory named scName and pointing to scTarget. Returns
		  //a FolderItem corresponding to the shortcut file. You must move the returned Shortcut file to the desired directory.
		  //On error, returns Nil.
		  
		  #If TargetWin32 Then
		    Dim lnkObj As OLEObject
		    Dim scriptShell As New OLEObject("{F935DC22-1CF0-11D0-ADB9-00C04FD58A0B}")
		    
		    If scriptShell <> Nil then
		      lnkObj = scriptShell.CreateShortcut(SpecialFolder.Temporary.AbsolutePath + ShortcutName + ".lnk")
		      If lnkObj <> Nil then
		        lnkObj.Description = ShortcutName
		        lnkObj.TargetPath = Self.AbsolutePath
		        lnkObj.WorkingDirectory = Self.AbsolutePath
		        lnkObj.Save
		        Return SpecialFolder.Temporary.TrueChild(ShortcutName + ".lnk")
		      End If
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CreateSymLink(source As FolderItem, destination As FolderItem) As Boolean
		  //Creates an NTFS Symbolic Link.
		  //Source is the existing file or directory, destination is the new Symbolic Link
		  //Use this function if the source and destination are not on the same volume, otherwise use CreateHardLink
		  //This feature is not available in Windows prior to Windows Vista, and will always fail in older versions.
		  
		  #If TargetWin32 Then
		    If System.IsFunctionAvailable("CreateSymbolicLinkW", "Kernel32") Then
		      Dim flags As Integer
		      If source.Directory Then
		        flags = &h1
		      End If
		      
		      Return WinLib.Kernel32.CreateSymbolicLink(destination.AbsolutePath, source.AbsolutePath, flags)
		    Else
		      Return False
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DeleteOnReboot() As Boolean
		  //Schedules the source file to be deleted on the next system reboot
		  //This function will fail if the user does not have write access to the
		  //HKEY_LOCAL_MACHINE registry hive (HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations)
		  //Or if the user does not have write access to the Target file.
		  
		  #If TargetWin32
		    Return WinLib.Kernel32.MoveFileEx(Self.AbsolutePath, Nil, MOVEFILE_DELAY_UNTIL_REBOOT)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DeleteStream(StreamName As String) As Boolean
		  //Deletes the named stream of the file or directory specified in target. If deletion was successful, returns True. Otherwise, returns False.
		  //Failure reasons may be: access to the file or directory was denied or the target or named stream does not exist. Passing "" as the
		  //StreamName will delete the file altogether (same as FolderItem.Delete)
		  
		  #If TargetWin32 Then
		    Return WinLib.Kernel32.DeleteFile(Self.AbsolutePath + ":" + StreamName + ":$DATA")
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  'Returns a read/write file handle if the FileItem has been locked.
		  Return LockHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HardLink(Index As Integer) As FolderItem
		  //Returns an array of folderitems which are actually NTFS hard links which point to the same file as the specified folderitem
		  //Windows Vista and newer only.
		  //Returns an empty array on error.
		  
		  #If TargetWin32 Then
		    Dim findHandle, buffSize As Integer
		    Dim linkname As New MemoryBlock(4096)
		    Dim ret As FolderItem
		    Dim i As Integer
		    buffSize = linkname.Size
		    linkname = New MemoryBlock(buffSize)
		    findHandle = WinLib.Kernel32.FindFirstFileNameW(Self.AbsolutePath, 0, buffSize, linkname)
		    If findHandle <> INVALID_HANDLE_VALUE Then
		      Do
		        ret = GetFolderItem(Left(Self.AbsolutePath, 2) + linkname.WString(0))
		        buffSize = linkname.Size
		      Loop Until i = index Or Not WinLib.Kernel32.FindNextFileNameW(findHandle, buffSize, linkname)
		    End If
		    Call WinLib.Kernel32.FindClose(findHandle)
		    Return ret
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HardLinkCount() As Integer
		  //Returns the number of NTFS hard links which point to the same file as the specified folderitem
		  //Windows Vista and newer only.
		  //Returns 0 on error.
		  
		  #If TargetWin32 Then
		    Dim findHandle, buffSize, linkCount As Integer
		    Dim linkname As New MemoryBlock(4096)
		    buffSize = linkname.Size
		    linkname = New MemoryBlock(buffSize)
		    findHandle = WinLib.Kernel32.FindFirstFileNameW(Self.AbsolutePath, 0, buffSize, linkname)
		    If findHandle <> INVALID_HANDLE_VALUE Then
		      Do
		        linkCount = linkCount + 1
		        buffSize = linkname.Size
		      Loop Until Not WinLib.Kernel32.FindNextFileNameW(findHandle, buffSize, linkname)
		    End If
		    Call WinLib.Kernel32.FindClose(findHandle)
		    Return linkCount
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasFlag(MatchFlag As Integer) As Boolean
		  Return BitwiseAnd(attribs, MatchFlag) = MatchFlag
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsExecutable() As Boolean
		  //Returns True if the file is executable or contains executable code (e.g. EXE, VBS, BAT)
		  //See: http://msdn.microsoft.com/en-us/library/windows/desktop/ms722429%28v=vs.85%29.aspx
		  
		  #If TargetWin32 Then
		    Return WinLib.AdvApi32.SaferiIsExecutableFileType(Self.AbsolutePath, False)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Lock() As Boolean
		  //Locks the file for exclusive use. You must call Unlock to unlock the file.
		  //Returns True on success, False on error.
		  //Once the file is locked you can pass the FileItem.Handle property
		  //to the constructor methods of the TextInputStream, TextOutputStream, and BinaryStream classes
		  //Calling FileItem.Unlock will close any Stream class opened with the FileItem.Handle property.
		  
		  #If TargetWin32 Then
		    LockHandle = WinLib.Kernel32.CreateFile(Self.AbsolutePath, GENERIC_READ Or GENERIC_WRITE, FILE_SHARE_READ, 0, OPEN_EXISTING, 0, 0)
		    If LockHandle > 0 Then
		      If WinLib.Kernel32.LockFile(LockHandle, 0, 0, 1, 0) Then
		        Return True
		      End If
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReplaceFileOnReboot(ReplacementFile As FolderItem) As Boolean
		  //Schedules the source file to be replaced by the destination file on the next system reboot
		  //Cannot be used if the source and destination are on different volumes or if the source or destination
		  //are on a network share. This function will also fail if the user does not have write access to the
		  //HKEY_LOCAL_MACHINE registry hive (HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations)
		  
		  #If TargetWin32
		    Return WinLib.Kernel32.MoveFileEx(Self.AbsolutePath, ReplacementFile.AbsolutePath, MOVEFILE_DELAY_UNTIL_REBOOT Or MOVEFILE_REPLACE_EXISTING)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReplaceWith(ReplacementFile As FolderItem, FlushToDisk As Boolean = False, BackupTo As FolderItem = Nil) As Boolean
		  //Replaces the source file with the destination file.
		  //If forceSync is true then the disk buffers are forced to flush all changes to the disk
		  //Specify the backupFile parameter to create a backup copy of the source file
		  //If this function fails, look at GetLastError for the error reason.
		  
		  #If TargetWin32
		    If Self.Directory Or ReplacementFile.Directory Then Return False
		    Dim rpFlags As Integer
		    If FlushToDisk Then rpFlags = REPLACEFILE_WRITE_THROUGH
		    Dim backupPath As MemoryBlock
		    If BackupTo = Nil Then
		      backupPath = New MemoryBlock(LenB(BackupTo.AbsolutePath) * 2 + 2)
		      backupPath.WString(0) = BackupTo.AbsolutePath
		    End If
		    Return WinLib.Kernel32.ReplaceFile(Self.AbsolutePath, ReplacementFile.AbsolutePath, backupPath, rpFlags, 0, 0)
		    
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ShowInExplorer()
		  //Shows the file in Windows Explorer
		  
		  #If TargetWin32 Then
		    Dim param As String = "/select, """ + Self.AbsolutePath + """"
		    Call WinLib.Shell32.ShellExecute(0, "open", "explorer", param, "", SW_SHOW)
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Unlock() As Boolean
		  //See the LockFile function
		  #If TargetWin32 Then
		    If WinLib.Kernel32.UnlockFile(LockHandle, 0, 0, 1, 0) Then
		      Call WinLib.Kernel32.CloseHandle(LockHandle)
		      Return True
		    End If
		  #endif
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //Returns true if the file has the archive attribute
			  Return HasFlag(FILE_ATTRIBUTE_ARCHIVE)
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  //Sets or clears the archive attibute of the file
			  If Me.Archive = value Then Return
			  If value Then
			    Me.Attribs = Me.Attribs Or FILE_ATTRIBUTE_ARCHIVE
			  Else
			    Me.Attribs = Me.Attribs Or FILE_ATTRIBUTE_ARCHIVE
			    Me.Attribs = Me.Attribs Xor FILE_ATTRIBUTE_ARCHIVE
			  End If
			End Set
		#tag EndSetter
		Archive As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Return WinLib.Kernel32.GetFileAttributes(Self.AbsolutePath)
			  #endif
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If TargetWin32 Then
			    Call WinLib.Kernel32.SetFileAttributes(Self.AbsolutePath, value)
			  #endif
			End Set
		#tag EndSetter
		Attribs As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //Returns true if the file has the compressed attribute
			  Return HasFlag(FILE_ATTRIBUTE_COMPRESSED)
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  //Sets or clears the compressed attribute of the file
			  If Me.Compressed = value Then Return
			  If value Then
			    Me.Attribs = Me.Attribs Or FILE_ATTRIBUTE_COMPRESSED
			  Else
			    Me.Attribs = Me.Attribs Or FILE_ATTRIBUTE_COMPRESSED
			    Me.Attribs = Me.Attribs Xor FILE_ATTRIBUTE_COMPRESSED
			  End If
			End Set
		#tag EndSetter
		Compressed As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //Returns true if the file has the encrypted attribute
			  Return HasFlag(FILE_ATTRIBUTE_ENCRYPTED)
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  //Sets or clears the encrypted attibute of the file
			  If Me.Encrypted = value Then Return
			  If value Then
			    Me.Attribs = Me.Attribs Or FILE_ATTRIBUTE_ENCRYPTED
			  Else
			    Me.Attribs = Me.Attribs Or FILE_ATTRIBUTE_ENCRYPTED
			    Me.Attribs = Me.Attribs Xor FILE_ATTRIBUTE_ENCRYPTED
			  End If
			End Set
		#tag EndSetter
		Encrypted As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //Returns true if the file has the hidden attribute
			  Return HasFlag(FILE_ATTRIBUTE_HIDDEN)
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  //Sets or clears the hidden attribute of the file
			  If Me.Hidden = value Then Return
			  If value Then
			    Me.Attribs = Me.Attribs Or FILE_ATTRIBUTE_HIDDEN
			  Else
			    Me.Attribs = Me.Attribs Or FILE_ATTRIBUTE_HIDDEN
			    Me.Attribs = Me.Attribs Xor FILE_ATTRIBUTE_HIDDEN
			  End If
			End Set
		#tag EndSetter
		Hidden As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected LockHandle As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //Returns true if the file has the normal attribute
			  Return HasFlag(FILE_ATTRIBUTE_NORMAL)
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  //Sets or clears the normal attibute of the file
			  If Me.Hidden = value Then Return
			  If value Then
			    Me.Attribs = Me.Attribs Or FILE_ATTRIBUTE_NORMAL
			  Else
			    Me.Attribs = Me.Attribs Or FILE_ATTRIBUTE_NORMAL
			    Me.Attribs = Me.Attribs Xor FILE_ATTRIBUTE_NORMAL
			  End If
			End Set
		#tag EndSetter
		Normal As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //Returns true if the file has the read only attribute
			  Return HasFlag(FILE_ATTRIBUTE_READONLY)
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  //Sets or clears the read only attibute of the file
			  If Me.Hidden = value Then Return
			  If value Then
			    Me.Attribs = Me.Attribs Or FILE_ATTRIBUTE_READONLY
			  Else
			    Me.Attribs = Me.Attribs Or FILE_ATTRIBUTE_READONLY
			    Me.Attribs = Me.Attribs Xor FILE_ATTRIBUTE_READONLY
			  End If
			End Set
		#tag EndSetter
		ReadOnly As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  //Returns true if the file has the sytem file attribute
			  Return HasFlag(FILE_ATTRIBUTE_SYSTEM)
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  //Sets or clears the system file attibute of the file
			  If Me.Hidden = value Then Return
			  If value Then
			    Me.Attribs = Me.Attribs Or FILE_ATTRIBUTE_SYSTEM
			  Else
			    Me.Attribs = Me.Attribs Or FILE_ATTRIBUTE_SYSTEM
			    Me.Attribs = Me.Attribs Xor FILE_ATTRIBUTE_SYSTEM
			  End If
			End Set
		#tag EndSetter
		SystemFile As Boolean
	#tag EndComputedProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="AbsolutePath"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Alias"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Archive"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Attribs"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Compressed"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Count"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Directory"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DisplayName"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Encrypted"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Exists"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ExtensionVisible"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Group"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Hidden"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsReadable"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsWriteable"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastErrorCode"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Locked"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MacCreator"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MacDirID"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MacType"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MacVRefNum"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Normal"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Owner"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ReadOnly"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ResourceForkLength"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ShellPath"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SystemFile"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Type"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="URLPath"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
			InheritedFrom="FolderItem"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
