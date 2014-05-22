#tag Class
Protected Class IOStream
Inherits FileObject
Implements Readable, Writeable
	#tag Method, Flags = &h0
		Function EOF() As Boolean
		  // Part of the Readable interface.
		  Return Me.Position >= Me.Length
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Flush()
		  // Part of the Writeable interface.
		  #If TargetWin32 Then
		    If Win32.Kernel32.FlushFileBuffers(Me.Handle) Then
		      mLastError = 0
		    Else
		      mLastError = Win32.Kernel32.GetLastError()
		    End If
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Read(Count As Integer, encoding As TextEncoding = Nil) As String
		  // Part of the Readable interface.
		  #pragma BoundsChecking Off
		  #If TargetWin32 Then
		    Dim mb As New MemoryBlock(Count)
		    Dim read As Integer
		    If Win32.Kernel32.ReadFile(Me.Handle, mb, mb.Size, read, Nil) Then
		      mLastError = 0
		    Else
		      mLastError = Win32.Kernel32.GetLastError
		      Dim err As New IOException
		      err.ErrorNumber = Me.LastError
		      err.Message = WinLib.FormatError(Me.LastError)
		      Raise err
		    End If
		    
		    Return DefineEncoding(mb.StringValue(0, read), encoding)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReadError() As Boolean
		  // Part of the Readable interface.
		  Return LastError <> 0
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Write(text As String)
		  // Part of the Writeable interface.
		  #If TargetWin32 Then
		    Dim mb As MemoryBlock = text
		    Dim written As Integer
		    If Win32.Kernel32.WriteFile(Me.Handle, mb, mb.Size, written, Nil) Then
		      mLastError = 0
		    Else
		      mLastError = Win32.Kernel32.GetLastError()
		      Dim err As New IOException
		      err.ErrorNumber = Me.LastError
		      err.Message = WinLib.FormatError(Me.LastError)
		      Raise err
		    End If
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function WriteError() As Boolean
		  // Part of the Writeable interface.
		  Return LastError <> 0
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Dim value, oldvalue As Integer
			    oldvalue = Me.Position
			    value = Win32.Kernel32.SetFilePointer(Me.Handle, 0, Nil, FILE_END)
			    Me.Position = oldvalue
			    mLastError = Win32.Kernel32.GetLastError()
			    Return value
			  #endif
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  'Sets the position of the EOF. The file is truncated or expanded on-disk as needed to meet the new EOF.
			  'If the current Position of the file pointer is outside the new length, then then Position is moved to
			  'the new EOF. Otherwise thefile pointer position relative to the beginning of the file remains the same.
			  
			  #If TargetWin32 Then
			    Dim oldvalue As Integer = Me.Position
			    Me.Position = value
			    If Not Win32.Kernel32.SetEndOfFile(Me.Handle) Then
			      mLastError = Win32.Kernel32.GetLastError()
			    Else
			      mLastError = 0
			    End If
			    If oldvalue <= Me.Position Then Me.Position = oldvalue
			  #endif
			End Set
		#tag EndSetter
		Length As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Dim value As Integer = Win32.Kernel32.SetFilePointer(Me.Handle, 0, Nil, FILE_CURRENT)
			    mLastError = Win32.Kernel32.GetLastError()
			    Return value
			  #endif
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If TargetWin32 Then
			    Call Win32.Kernel32.SetFilePointer(Me.Handle, value, Nil, FILE_BEGIN)
			    mLastError = Win32.Kernel32.GetLastError()
			  #endif
			End Set
		#tag EndSetter
		Position As Integer
	#tag EndComputedProperty


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
			Name="Length"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Position"
			Group="Behavior"
			Type="Integer"
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
