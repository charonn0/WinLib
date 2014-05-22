#tag Class
Protected Class Mapping
Inherits FileObject
	#tag Method, Flags = &h0
		Sub Close()
		  For i As Integer = UBound(MappedViews) DownTo 0
		    UnMapView(MappedViews(i))
		  Next
		  If Not Win32.Kernel32.CloseHandle(MapHandle) Then
		    mLastError = Win32.Kernel32.GetLastError
		  End If
		  Super.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor(hFile As FileObject, Mapping As Integer)
		  // Calling the overridden superclass constructor.
		  Super.Constructor(hFile.Handle)
		  MapHandle = Mapping
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1001
		Protected Sub Constructor(Mapping As Integer)
		  // Calling the overridden superclass constructor.
		  Super.Constructor(INVALID_HANDLE_VALUE)
		  MapHandle = Mapping
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		 Shared Function CreateFileMapping(File As FileObject, PageProtection As Integer, MaximumSize As Int64 = 0, Name As String = "") As Mapping
		  Dim hi, lo, hFile As Integer
		  hi = MaximumSize.HighBits
		  lo = MaximumSize.LowBits
		  If File = Nil Then
		    hFile = INVALID_HANDLE_VALUE ' a pagefile-backed mapping
		  Else
		    hFile = File.Handle
		  End If
		  Dim hMap As Integer = Win32.Kernel32.CreateFileMapping(hFile, Nil, PageProtection, hi, lo, Name)
		  If hMap > 0 Then
		    Return New Mapping(File, hMap)
		  Else
		    hMap = Win32.Kernel32.GetLastError
		    Dim err As New IOException
		    err.ErrorNumber = hMap
		    err.Message = WinLib.FormatError(hMap)
		    Raise err
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  Me.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MapView(DesiredAccess As Integer, Offset As Int64, Length As Integer) As WinMB
		  Dim hi, lo As Integer
		  hi = Offset.HighBits
		  lo = Offset.LowBits
		  Dim p As Ptr = Win32.Kernel32.MapViewOfFile(MapHandle, DesiredAccess, hi, lo, Length)
		  If p <> Nil Then
		    Dim mb As WinMB = WinMB.Acquire(Integer(p), WinMB.TypeVirtual)
		    MappedViews.Append(mb)
		    Return mb
		  Else
		    mLastError = Win32.Kernel32.GetLastError()
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		 Shared Function OpenFileMapping(DesiredAccess As Integer, Name As String) As Mapping
		  Dim hMap As Integer = Win32.Kernel32.OpenFileMapping(DesiredAccess, False, Name)
		  If hMap > 0 Then
		    Return New Mapping(hMap)
		  Else
		    hMap = Win32.Kernel32.GetLastError
		    Dim err As New IOException
		    err.ErrorNumber = hMap
		    err.Message = WinLib.FormatError(hMap)
		    Raise err
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UnMapView(Map As WinMB)
		  For i As Integer = UBound(MappedViews) DownTo 0
		    If MappedViews(i) Is Map Then
		      MappedViews.Remove(i)
		    End If
		  Next
		  
		  If Not Win32.Kernel32.UnmapViewOfFile(Ptr(Map.Handle)) Then
		    mLastError = Win32.Kernel32.GetLastError
		  End If
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected MapHandle As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected MappedViews() As WinMB
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
