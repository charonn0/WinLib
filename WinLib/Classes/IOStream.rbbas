#tag Class
Protected Class IOStream
Implements Readable,Writeable,Win32Object
	#tag Method, Flags = &h0
		Sub Close()
		  Me.Flush()
		  #If TargetWin32 Then Call WinLib.Kernel32.CloseHandle(Me.Handle)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(FileHandle As Integer)
		  #If Not TargetWin32 Then
		    #pragma Warning "This class supports only Win32 applications."
		  #endif
		  Me.mHandle = FileHandle
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Destructor()
		  Me.Close()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EOF() As Boolean Implements Readable.EOF
		  Return LastError = ERROR_HANDLE_EOF
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Flush() Implements Writeable.Flush
		  #If Not TargetWin32 Then
		    #pragma Warning "This class supports only Win32 applications."
		    
		  #Else
		    If WinLib.Kernel32.FlushFileBuffers(Me.Handle) Then
		      mLastError = 0
		    Else
		      mLastError = WinLib.Kernel32.GetLastError()
		    End If
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  // Part of the Win32Object interface.
		  return mHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  // Part of the Win32Object interface.
		  return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Read(Count As Integer, encoding As TextEncoding = Nil) As String Implements Readable.Read
		  #pragma BoundsChecking Off
		  #If Not TargetWin32 Then
		    #pragma Warning "This class supports only Win32 applications."
		  #Else
		    Dim mb As New MemoryBlock(Count)
		    Dim read As Integer
		    If WinLib.Kernel32.ReadFile(Me.Handle, mb, mb.Size, read, Nil) Then
		      If read = mb.Size Then
		        mLastError = 0
		      Else
		        mLastError = ERROR_HANDLE_EOF
		      End If
		    Else
		      mLastError = WinLib.GetLastError
		    End If
		    
		    If encoding = Nil Then encoding = Encodings.UTF8
		    Dim data As String = DefineEncoding(mb.StringValue(0, mb.Size), encoding)
		    Return data
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReadError() As Boolean Implements Readable.ReadError
		  Return LastError <> 0
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Write(text As String) Implements Writeable.Write
		  #If Not TargetWin32 Then
		    #pragma Warning "This class supports only Win32 applications."
		  #Else
		    Dim mb As MemoryBlock = text
		    Dim written As Integer
		    If WinLib.Kernel32.WriteFile(Me.Handle, mb, mb.Size, written, Nil) Then
		      mLastError = 0
		    Else
		      mLastError = WinLib.GetLastError()
		    End If
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function WriteError() As Boolean Implements Writeable.WriteError
		  Return LastError <> 0
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #If Not TargetWin32 Then
			    #pragma Warning "This class supports only Win32 applications."
			  #Else
			    Dim value, oldvalue As Integer
			    oldvalue = Me.Position
			    value = WinLib.Kernel32.SetFilePointer(Me.Handle, 0, Nil, FILE_END)
			    Me.Position = oldvalue
			    mLastError = WinLib.GetLastError()
			    Return value
			  #endif
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  'Sets the position of the EOF. The file is truncated or expanded on-disk as needed to meet the new EOF.
			  'If the current Position of the file pointer is outside the new length, then then Position is moved to
			  'the new EOF. Otherwise thefile pointer position relative to the beginning of the file remains the same.
			  
			  #If Not TargetWin32 Then
			    Dim err As New RuntimeException
			    err.Message = "This class supports only Win32 applications."
			    Raise err
			    #pragma Warning "This class supports only Win32 applications."
			  #Else
			    Dim oldvalue As Integer = Me.Position
			    Me.Position = value
			    If Not WinLib.Kernel32.SetEndOfFile(Me.Handle) Then
			      mLastError = GetLastError()
			    Else
			      mLastError = 0
			    End If
			    If oldvalue <= Me.Position Then Me.Position = oldvalue
			  #endif
			End Set
		#tag EndSetter
		Length As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected mHandle As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #If Not TargetWin32 Then
			    #pragma Warning "This class supports only Win32 applications."
			  #Else
			    Dim value As Integer = WinLib.Kernel32.SetFilePointer(Me.Handle, 0, Nil, FILE_CURRENT)
			    mLastError = WinLib.GetLastError()
			    Return value
			  #endif
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If Not TargetWin32 Then
			    Dim err As New RuntimeException
			    err.Message = "This class supports only Win32 applications."
			    Raise err
			    #pragma Warning "This class supports only Win32 applications."
			  #Else
			    Call WinLib.Kernel32.SetFilePointer(Me.Handle, value, Nil, FILE_BEGIN)
			    mLastError = WinLib.GetLastError()
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
			Name="Length"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
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
