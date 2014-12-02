#tag Class
Protected Class KeyContainer
Inherits WinLib.Crypto.Context
	#tag Method, Flags = &h0
		Function BitLength() As Integer
		  Dim mb As MemoryBlock
		  ' first call allocates a buffer big enough for the second call
		  If Me.GetKeyParam(KP_KEYLEN, mb, 0) Then ' on in mb is Nil
		    If Me.GetKeyParam(KP_KEYLEN, mb, 0) Then ' on in mb is a MemoryBlock of correct size
		      Return mb.Int32Value(0)
		    Else
		      mLastError = Win32.LastError
		    End If
		  Else
		    mLastError = Win32.LastError
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor()
		  // Calling the overridden superclass constructor.
		  // Constructor(DuplicateContext As WinLib.Crypto.Context) -- From Context
		  Super.Constructor(EnhancedProvider)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetKeyParam(Type As Integer, ByRef Buffer As MemoryBlock, Flags As Integer) As Boolean
		  ' If Buffer is Nil and no error occurs, on return Buffer will be instantiated with the correct size of the data.
		  ' Call this method again with the same parameters to fill the Buffer.
		  Dim buffersz As Integer
		  Dim p As Ptr
		  If Buffer <> Nil Then
		    p = Buffer
		    buffersz = buffer.Size
		  End If
		  If Not Win32.AdvApi32.CryptGetKeyParam(mHandle, Type, p, buffersz, Flags) Then
		    mLastError = Win32.LastError
		    Return False
		  Else
		    If Buffer = Nil Then Buffer = New MemoryBlock(buffersz)
		    Return True
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  Return mHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Permissions() As Integer
		  Dim mb As MemoryBlock
		  ' first call allocates a buffer big enough for the second call
		  If Me.GetKeyParam(KP_PERMISSIONS, mb, 0) Then ' on in mb is Nil
		    If Me.GetKeyParam(KP_PERMISSIONS, mb, 0) Then ' on in mb is a MemoryBlock of correct size
		      Return mb.Int32Value(0)
		    Else
		      mLastError = Win32.LastError
		    End If
		  Else
		    mLastError = Win32.LastError
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Permissions(Assigns NewPermissionsMask As Integer)
		  Dim mb As New MemoryBlock(4)
		  mb.Int32Value(0) = NewPermissionsMask
		  If Not Me.SetKeyParam(KP_PERMISSIONS, mb, 0) Then
		    Dim err As New IOException
		    err.ErrorNumber = mLastError
		    err.Message = WinLib.FormatError(mLastError)
		    Raise err
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function SetKeyParam(Type As Integer, Buffer As MemoryBlock, Flags As Integer) As Boolean
		  If Not Win32.AdvApi32.CryptSetKeyParam(mHandle, Type, buffer, Flags) Then
		    mLastError = Win32.LastError
		    Return False
		  Else
		    Return True
		  End If
		End Function
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected mHandle As Integer
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
