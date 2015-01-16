#tag Class
Protected Class Mapping
Inherits Win32.IO.FileObject
	#tag Method, Flags = &h0
		Sub Close()
		  For i As Integer = UBound(MappedViews) DownTo 0
		    UnMapView(MappedViews(i))
		  Next
		  If Not Win32.Libs.Kernel32.CloseHandle(mMapHandle) Then
		    mLastError = Win32.LastError
		  End If
		  Super.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1001
		Protected Sub Constructor(hFile As FileObject, Mapping As Integer)
		  // Calling the overridden superclass constructor.
		  Super.Constructor(hFile.Handle)
		  mMapHandle = Mapping
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1001
		Protected Sub Constructor(Mapping As Integer)
		  // Calling the overridden superclass constructor.
		  Super.Constructor(INVALID_HANDLE_VALUE)
		  mMapHandle = Mapping
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		 Shared Function CreateFileMapping(File As FileObject, PageProtection As Integer, MaximumSize As Int64 = 0, Name As String = "") As Mapping
		  If File = Nil Then File = New FileObject(INVALID_HANDLE_VALUE) ' a pagefile-backed mapping
		  
		  Dim hMap As Integer = Win32.Libs.Kernel32.CreateFileMapping(File.Handle, Nil, PageProtection, MaximumSize.HighBits, MaximumSize.LowBits, Name)
		  If hMap > 0 Then
		    Return New Mapping(File, hMap)
		  Else
		    hMap = Win32.LastError
		    Dim err As New IOException
		    err.ErrorNumber = hMap
		    err.Message = Win32.FormatError(hMap)
		    Raise err
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Destructor()
		  Me.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function File() As FolderItem
		  Dim flags As Integer = Win32.Utils.PROCESS_QUERY_INFORMATION Or Win32.Utils.PROCESS_VM_READ
		  Dim h As Integer = Win32.Libs.Kernel32.OpenProcess(flags, False, Win32.CurrentProcessID)
		  If h <> 0 Then
		    Dim sz As Integer = Win32.Libs.Kernel32.GetMappedFileName(h, mMapHandle, Nil, 0)
		    If sz > 0 Then
		      Dim buffer As New MemoryBlock(sz)
		      If Win32.Libs.Kernel32.GetMappedFileName(h, mMapHandle, buffer, buffer.Size) > 0 Then
		        Dim s As String = buffer.WString(0)
		        Call Win32.Libs.Kernel32.CloseHandle(h)
		        Return GetFolderItem(s)
		      End If
		    End If
		  End If
		  mLastError = Win32.LastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MapView(DesiredAccess As Integer, Offset As Int64, Length As Integer) As Win32.Utils.WinMB
		  Dim p As Ptr = Win32.Libs.Kernel32.MapViewOfFile(mMapHandle, DesiredAccess, Offset.HighBits, Offset.LowBits, Length)
		  If p <> Nil Then
		    Dim mb As Win32.Utils.WinMB = Win32.Utils.WinMB.Acquire(Integer(p), Win32.Utils.WinMB.TypeVirtual)
		    MappedViews.Append(mb)
		    Return mb
		  Else
		    mLastError = Win32.LastError()
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		 Shared Function OpenFileMapping(DesiredAccess As Integer, Name As String) As Mapping
		  Dim hMap As Integer = Win32.Libs.Kernel32.OpenFileMapping(DesiredAccess, False, Name)
		  If hMap > 0 Then
		    Return New Mapping(hMap)
		  Else
		    hMap = Win32.LastError
		    Dim err As New IOException
		    err.ErrorNumber = hMap
		    err.Message = Win32.FormatError(hMap)
		    Raise err
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UnMapView(Map As Win32.Utils.WinMB)
		  For i As Integer = UBound(MappedViews) DownTo 0
		    If MappedViews(i) Is Map Then
		      MappedViews.Remove(i)
		    End If
		  Next
		  
		  If Not Win32.Libs.Kernel32.UnmapViewOfFile(Map) Then
		    mLastError = Win32.LastError
		  End If
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected MappedViews() As Win32.Utils.WinMB
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mMapHandle As Integer
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
