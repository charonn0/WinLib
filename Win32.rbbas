#tag Module
Protected Module Win32
	#tag Method, Flags = &h1
		Protected Function CloseHandle(Handle As Integer) As Boolean
		  Return WinLib.Kernel32.CloseHandle(Handle)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function CreateFile(File As FolderItem, Access As Integer = 0, Sharemode As Integer = 0, CreateDisposition As Integer = 0, Flags As Integer = 0) As WinLib.Classes.IOStream
		  #If Not TargetWin32 Then
		    #pragma Warning "This class supports only Win32 applications."
		  #Else
		    Dim tmp As WinLib.Classes.IOStream
		    Dim hFile As Integer
		    
		    If Access = 0 Then Access = GENERIC_ALL
		    If CreateDisposition = 0 Then CreateDisposition = OPEN_EXISTING
		    If sharemode = 0 Then sharemode = FILE_SHARE_READ 'exclusive write access
		    
		    hFile = WinLib.Kernel32.CreateFile("//?/" + ReplaceAll(File.AbsolutePath, "/", "//"), Access, sharemode, 0, CreateDisposition, Flags, 0)
		    
		    If hFile <> INVALID_HANDLE_VALUE Then
		      tmp = New WinLib.Classes.IOStream(hFile)
		    Else
		      hFile = WinLib.GetLastError()
		      Raise New WinLib.Classes.Win32Exception(hFile)
		    End If
		    
		    Return tmp
		  #endif
		End Function
	#tag EndMethod


End Module
#tag EndModule
