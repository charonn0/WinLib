#tag Class
Protected Class Context
	#tag CompatibilityFlags = TargetHasGUI
	#tag Method, Flags = &h1
		Protected Shared Function AcquireProvider(ProviderID As String, ProviderType As Integer) As Integer
		  ' See: http://msdn.microsoft.com/en-us/library/windows/desktop/aa386983%28v=vs.85%29.aspx
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
		 Shared Function AESProvider(FreeProvider As Boolean = False) As WinLib.Crypto.Context
		  ' See: http://msdn.microsoft.com/en-us/library/windows/desktop/aa386979%28v=vs.85%29.aspx
		  If mAESProvider = Nil Then
		    mAESProvider = New WinLib.Crypto.Context(AcquireProvider(MS_ENH_RSA_AES_PROV, PROV_RSA_AES))
		  End If
		  If FreeProvider Then
		    mAESProvider = Nil
		  Else
		    Return New WinLib.Crypto.Context(mAESProvider)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function BaseProvider(FreeProvider As Boolean = False) As WinLib.Crypto.Context
		  'See: http://msdn.microsoft.com/en-us/library/windows/desktop/aa386980%28v=vs.85%29.aspx
		  If mBaseProvider = Nil Then
		    mBaseProvider = New WinLib.Crypto.Context(AcquireProvider(MS_DEF_PROV, PROV_RSA_FULL))
		  End If
		  If FreeProvider Then
		    mBaseProvider = Nil
		  Else
		    Return New WinLib.Crypto.Context(mBaseProvider)
		  End If
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

	#tag Method, Flags = &h0
		 Shared Function DHProvider(FreeProvider As Boolean = False) As WinLib.Crypto.Context
		  ' For diffie-hellman key exchanges
		  ' See: http://msdn.microsoft.com/en-us/library/windows/desktop/bb394802%28v=vs.85%29.aspx
		  If mDHProvider = Nil Then
		    mDHProvider = New WinLib.Crypto.Context(AcquireProvider(MS_ENH_DSS_DH_PROV, PROV_DSS_DH))
		  End If
		  If FreeProvider Then
		    mDHProvider = Nil
		  Else
		    Return New WinLib.Crypto.Context(mDHProvider)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function EnhancedProvider(FreeProvider As Boolean = False) As WinLib.Crypto.Context
		  ' See: http://msdn.microsoft.com/en-us/library/windows/desktop/aa386986%28v=vs.85%29.aspx
		  If mEnhancedProvider = Nil Then
		    mEnhancedProvider = New WinLib.Crypto.Context(AcquireProvider(MS_ENHANCED_PROV, PROV_RSA_FULL))
		  End If
		  If FreeProvider Then
		    mEnhancedProvider = Nil
		  Else
		    Return New WinLib.Crypto.Context(mEnhancedProvider)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetProviderParam(Type As Integer, ByRef Buffer As MemoryBlock, Flags As Integer) As Boolean
		  ' If Buffer is Nil and no error occurs, on return Buffer will be instantiated with the correct size of the data.
		  ' Call this method again with the same parameters to fill the Buffer.
		  Dim buffersz As Integer
		  Dim p As Ptr
		  If Buffer <> Nil Then
		    p = Buffer
		    buffersz = buffer.Size
		  End If
		  If Not Win32.AdvApi32.CryptGetProvParam(mProvider, Type, p, buffersz, Flags) Then
		    mLastError = Win32.LastError
		    Return False
		  Else
		    If Buffer = Nil Then Buffer = New MemoryBlock(buffersz)
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
		Function Operator_Compare(OtherContext As WinLib.Crypto.Context) As Integer
		  Select Case True
		  Case OtherContext Is Nil
		    Return 1
		  Case OtherContext.Provider > mProvider
		    Return -1
		  Case OtherContext.Provider < mProvider
		    Return 1
		  Case OtherContext.Provider = mProvider
		    Return 0
		  End Select
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Provider() As Integer
		  Return mProvider
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ProviderName() As String
		  Dim mb As MemoryBlock
		  ' first call allocates a buffer big enough for the second call
		  If Me.GetProviderParam(PP_NAME, mb, 0) Then ' on in mb is Nil
		    If Me.GetProviderParam(PP_NAME, mb, 0) Then ' on in mb is a MemoryBlock of correct size
		      Return mb.CString(0)
		    Else
		      mLastError = Win32.LastError
		    End If
		  Else
		    mLastError = Win32.LastError
		  End If
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

	#tag Method, Flags = &h0
		 Shared Function StrongProvider(FreeProvider As Boolean = False) As WinLib.Crypto.Context
		  ' See: http://msdn.microsoft.com/en-us/library/windows/desktop/aa386989%28v=vs.85%29.aspx
		  If mStrongProvider = Nil Then
		    mStrongProvider = New WinLib.Crypto.Context(AcquireProvider(MS_STRONG_PROV, PROV_RSA_FULL))
		  End If
		  If FreeProvider Then
		    mStrongProvider = Nil
		  Else
		    Return New WinLib.Crypto.Context(mStrongProvider)
		  End If
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Shared mAESProvider As WinLib.Crypto.Context
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mBaseProvider As WinLib.Crypto.Context
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mDHProvider As WinLib.Crypto.Context
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mEnhancedProvider As WinLib.Crypto.Context
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mProvider As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mStrongProvider As WinLib.Crypto.Context
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
