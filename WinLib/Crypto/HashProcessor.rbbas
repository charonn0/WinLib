#tag Class
Protected Class HashProcessor
Inherits WinLib.Crypto.Context
	#tag CompatibilityFlags = TargetHasGUI
	#tag Method, Flags = &h0
		Function Algorithm() As Integer
		  Dim alg As New MemoryBlock(4)
		  If Not Me.GetHashParam(HP_ALGID, alg) Then
		    Dim err As New IOException
		    err.ErrorNumber = mLastError
		    err.Message = WinLib.FormatError(mLastError)
		    Raise err
		  End If
		  Return alg.Int32Value(0)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Algorithm As Integer, Key As WinLib.Crypto.KeyContainer = Nil)
		  Dim CryptoProvider As WinLib.Crypto.Context
		  Select Case Algorithm
		  Case CALG_MD2, CALG_MD4, CALG_MD5, CALG_SHA1
		    CryptoProvider = EnhancedProvider
		  Case CALG_SHA256, CALG_SHA384, CALG_SHA512
		    CryptoProvider = AESProvider
		  Else
		    Raise New UnsupportedFormatException
		  End Select
		  // Calling the overridden superclass constructor.
		  // Constructor(DuplicateContext As WinLib.Crypto.Context) -- From Context
		  Super.Constructor(CryptoProvider)
		  
		  Dim kh As Integer
		  If Key <> Nil Then kh = Key.Handle
		  If Not Win32.AdvApi32.CryptCreateHash(Me.Provider, Algorithm, kh, 0, mHandle) Then
		    mLastError = Win32.LastError
		    Dim err As New IOException
		    err.ErrorNumber = mLastError
		    err.Message = WinLib.FormatError(mLastError)
		    Raise err
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetHashParam(Type As Integer, Buffer As MemoryBlock) As Boolean
		  Dim buffersz As Integer = buffer.Size
		  If Not Win32.AdvApi32.CryptGetHashParam(mHandle, Type, buffer, buffersz, 0) Then
		    mLastError = Win32.LastError
		    Return False
		  Else
		    Return True
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Process(NewData As MemoryBlock)
		  If Not Win32.AdvApi32.CryptHashData(mHandle, NewData, NewData.Size, 0) Then
		    mLastError = Win32.LastError
		    Dim err As New IOException
		    err.ErrorNumber = mLastError
		    err.Message = WinLib.FormatError(mLastError)
		    Raise err
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value() As String
		  Dim buffer As New MemoryBlock(4)
		  If Not Me.GetHashParam(HP_HASHSIZE, buffer) Then
		    Dim err As New IOException
		    err.ErrorNumber = mLastError
		    err.Message = WinLib.FormatError(mLastError)
		    Raise err
		  End If
		  buffer = New MemoryBlock(buffer.Int32Value(0))
		  If Not Me.GetHashParam(HP_HASHVAL, buffer) Then
		    Dim err As New IOException
		    err.ErrorNumber = mLastError
		    err.Message = WinLib.FormatError(mLastError)
		    Raise err
		  End If
		  Return buffer
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
