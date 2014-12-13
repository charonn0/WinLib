#tag Class
Protected Class Context
	#tag CompatibilityFlags = TargetHasGUI
	#tag Method, Flags = &h21
		Private Shared Function AcquireProvider(ProviderID As String, ProviderType As Integer) As Integer
		  ' See: http://msdn.microsoft.com/en-us/library/windows/desktop/aa386983%28v=vs.85%29.aspx
		  Dim lasterr, cprovider As Integer
		  If Not Win32.Libs.AdvApi32.CryptAcquireContext(cprovider, 0, ProviderID, ProviderType, 0) Then
		    lasterr = Win32.LastError
		    Select Case lasterr
		    Case 0
		      ' no error
		    Case NTE_BAD_KEYSET
		      If Not Win32.Libs.AdvApi32.CryptAcquireContext(cprovider, 0, ProviderID, ProviderType, CRYPT_NEWKEYSET) Then
		        lasterr = Win32.LastError
		        Dim err As New IOException
		        err.ErrorNumber = lasterr
		        err.Message = Win32.FormatError(lasterr)
		        Raise err
		      End If
		    Else
		      lasterr = Win32.LastError
		      Dim err As New IOException
		      err.ErrorNumber = lasterr
		      err.Message = Win32.FormatError(lasterr)
		      Raise err
		    End Select
		  End If
		  Return cprovider
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function AESProvider(FreeProvider As Boolean = False) As Win32.Crypto.Context
		  ' See: http://msdn.microsoft.com/en-us/library/windows/desktop/aa386979%28v=vs.85%29.aspx
		  If FreeProvider Then
		    mAESProvider = Nil
		    Return Nil
		  ElseIf mAESProvider = Nil Then
		    mAESProvider = New Win32.Crypto.Context(AcquireProvider(MS_ENH_RSA_AES_PROV, PROV_RSA_AES))
		  End If
		  Return New Win32.Crypto.Context(mAESProvider)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function BaseProvider(FreeProvider As Boolean = False) As Win32.Crypto.Context
		  'See: http://msdn.microsoft.com/en-us/library/windows/desktop/aa386980%28v=vs.85%29.aspx
		  If FreeProvider Then
		    mBaseProvider = Nil
		    Return Nil
		  ElseIf mBaseProvider = Nil Then
		    mBaseProvider = New Win32.Crypto.Context(AcquireProvider(MS_DEF_PROV, PROV_RSA_FULL))
		  End If
		  Return New Win32.Crypto.Context(mBaseProvider)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Constructor(CryptoProvider As Integer)
		  mProvider = CryptoProvider
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(DuplicateContext As Win32.Crypto.Context)
		  If Win32.Libs.AdvApi32.CryptContextAddRef(DuplicateContext.Provider, Nil, 0) Then ' increment ref count
		    mProvider = DuplicateContext.Provider
		    
		  Else
		    mLastError = Win32.LastError
		    Dim err As New IOException
		    err.ErrorNumber = mLastError
		    err.Message = Win32.FormatError(mLastError)
		    Raise err
		    
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Destructor()
		  If Not Win32.Libs.AdvApi32.CryptReleaseContext(mProvider, 0) Then
		    mLastError = Win32.LastError
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function DHProvider(FreeProvider As Boolean = False) As Win32.Crypto.Context
		  ' For diffie-hellman key exchanges
		  ' See: http://msdn.microsoft.com/en-us/library/windows/desktop/bb394802%28v=vs.85%29.aspx
		  If FreeProvider Then
		    mDHProvider = Nil
		    Return Nil
		  ElseIf mDHProvider = Nil Then
		    mDHProvider = New Win32.Crypto.Context(AcquireProvider(MS_ENH_DSS_DH_PROV, PROV_DSS_DH))
		  End If
		  Return New Win32.Crypto.Context(mDHProvider)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function EnhancedProvider(FreeProvider As Boolean = False) As Win32.Crypto.Context
		  ' See: http://msdn.microsoft.com/en-us/library/windows/desktop/aa386986%28v=vs.85%29.aspx
		  If FreeProvider Then
		    mEnhancedProvider = Nil
		    Return Nil
		  ElseIf mEnhancedProvider = Nil Then
		    mEnhancedProvider = New Win32.Crypto.Context(AcquireProvider(MS_ENHANCED_PROV, PROV_RSA_FULL))
		  End If
		  Return New Win32.Crypto.Context(mEnhancedProvider)
		  
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
		  If Not Win32.Libs.AdvApi32.CryptGetProvParam(mProvider, Type, p, buffersz, Flags) Then
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
		  // Part of the Win32Object interface.
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function MS_ENH_RSA_AES_PROV() As String
		  If KernelVersion < 6.0 Then ' XP used a different name
		    Return "Microsoft Enhanced RSA and AES Cryptographic Provider (Prototype)"
		  Else
		    Return "Microsoft Enhanced RSA and AES Cryptographic Provider"
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Operator_Compare(OtherContext As Win32.Crypto.Context) As Integer
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
		  If Not Win32.Libs.AdvApi32.CryptSetProvParam(mProvider, Type, buffer, Flags) Then
		    mLastError = Win32.LastError
		    Return False
		  Else
		    Return True
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function StrongProvider(FreeProvider As Boolean = False) As Win32.Crypto.Context
		  ' See: http://msdn.microsoft.com/en-us/library/windows/desktop/aa386989%28v=vs.85%29.aspx
		  If FreeProvider Then
		    mStrongProvider = Nil
		    Return Nil
		  ElseIf mStrongProvider = Nil Then
		    mStrongProvider = New Win32.Crypto.Context(AcquireProvider(MS_STRONG_PROV, PROV_RSA_FULL))
		  End If
		  Return New Win32.Crypto.Context(mStrongProvider)
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Shared mAESProvider As Win32.Crypto.Context
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mBaseProvider As Win32.Crypto.Context
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mDHProvider As Win32.Crypto.Context
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mEnhancedProvider As Win32.Crypto.Context
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mProvider As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mStrongProvider As Win32.Crypto.Context
	#tag EndProperty


	#tag Constant, Name = MS_DEF_DH_SCHANNEL_PROV, Type = String, Dynamic = False, Default = \"Microsoft DH Schannel Cryptographic Provider", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = MS_DEF_DSS_DH_PROV, Type = String, Dynamic = False, Default = \"Microsoft Base DSS and Diffie-Hellman Cryptographic Provider", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = MS_DEF_DSS_PROV, Type = String, Dynamic = False, Default = \"Microsoft Base DSS Cryptographic Provider", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = MS_DEF_PROV, Type = String, Dynamic = False, Default = \"Microsoft Base Cryptographic Provider v1.0", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = MS_DEF_RSA_SCHANNEL_PROV, Type = String, Dynamic = False, Default = \"Microsoft RSA Schannel Cryptographic Provider", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = MS_ENHANCED_PROV, Type = String, Dynamic = False, Default = \"Microsoft Enhanced Cryptographic Provider v1.0", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = MS_ENH_DSS_DH_PROV, Type = String, Dynamic = False, Default = \"Microsoft Enhanced DSS and Diffie-Hellman Cryptographic Provider", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = MS_SCARD_PROV, Type = String, Dynamic = False, Default = \"Microsoft Base Smart Card Crypto Provider", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = MS_STRONG_PROV, Type = String, Dynamic = False, Default = \"Microsoft Strong Cryptographic Provider", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = NTE_BAD_KEYSET, Type = Double, Dynamic = False, Default = \"&h80090016", Scope = Private
	#tag EndConstant

	#tag Constant, Name = NTE_BAD_UID, Type = Double, Dynamic = False, Default = \"&h80090001", Scope = Private
	#tag EndConstant

	#tag Constant, Name = PP_NAME, Type = Double, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant

	#tag Constant, Name = PROV_DSS, Type = Double, Dynamic = False, Default = \"3", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = PROV_DSS_DH, Type = Double, Dynamic = False, Default = \"13", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = PROV_RSA_AES, Type = Double, Dynamic = False, Default = \"24", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = PROV_RSA_FULL, Type = Double, Dynamic = False, Default = \"1", Scope = Protected
	#tag EndConstant


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
