#tag Class
Protected Class Context
	#tag CompatibilityFlags = TargetHasGUI
	#tag Method, Flags = &h1
		Protected Shared Function AcquireProvider(ProviderID As String, ProviderType As Integer) As Integer
		  Dim lasterr, cprovider As Integer
		  If Not Win32.AdvApi32.CryptAcquireContext(cprovider, 0, ProviderID, ProviderType, 0) Then
		    lasterr = Win32.LastError
		    Select Case lasterr
		    Case 0
		      ' no error
		    Case NTE_BAD_KEYSET
		      If Not Win32.AdvApi32.CryptAcquireContext(cprovider, 0, ProviderID, ProviderType, CRYPT_NEWKEYSET) Then
		        lasterr = Win32.LastError
		        Dim err As New IOException
		        err.ErrorNumber = lasterr
		        err.Message = WinLib.FormatError(lasterr)
		        Raise err
		      End If
		    Else
		      lasterr = Win32.LastError
		      Dim err As New IOException
		      err.ErrorNumber = lasterr
		      err.Message = WinLib.FormatError(lasterr)
		      Raise err
		    End Select
		  End If
		  Return cprovider
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function AESProvider() As WinLib.Crypto.Context
		  If mAESProvider = Nil Then
		    mAESProvider = New WinLib.Crypto.Context(AcquireProvider(MS_ENH_RSA_AES_PROV, PROV_RSA_AES))
		  End If
		  Return New WinLib.Crypto.Context(mAESProvider)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function BaseProvider() As WinLib.Crypto.Context
		  If mBaseProvider = Nil Then
		    mBaseProvider = New WinLib.Crypto.Context(AcquireProvider(MS_DEF_PROV, PROV_RSA_FULL))
		  End If
		  Return New WinLib.Crypto.Context(mBaseProvider)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(CryptoProvider As Integer)
		  mProvider = CryptoProvider
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(DuplicateContext As WinLib.Crypto.Context)
		  Dim lasterr As Integer
		  If Win32.AdvApi32.CryptContextAddRef(DuplicateContext.Provider, Nil, 0) Then ' increment ref count
		    mProvider = DuplicateContext.Provider
		    
		  Else
		    
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  If Not Win32.AdvApi32.CryptReleaseContext(mProvider, 0) Then
		    mLastError = Win32.LastError
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetProviderParam(Type As Integer, Buffer As MemoryBlock, Flags As Integer) As Boolean
		  Dim buffersz As Integer = buffer.Size
		  If Not Win32.AdvApi32.CryptGetProvParam(mProvider, Type, buffer, buffersz, Flags) Then
		    mLastError = Win32.LastError
		    Return False
		  Else
		    Return True
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Provider() As Integer
		  Return mProvider
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function SetProviderParam(Type As Integer, Buffer As MemoryBlock, Flags As Integer) As Boolean
		  If Not Win32.AdvApi32.CryptSetProvParam(mProvider, Type, buffer, Flags) Then
		    mLastError = Win32.LastError
		    Return False
		  Else
		    Return True
		  End If
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Shared mAESProvider As WinLib.Crypto.Context
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mBaseProvider As WinLib.Crypto.Context
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mProvider As Integer
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
