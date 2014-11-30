#tag Class
Protected Class HashProcessor
	#tag CompatibilityFlags = TargetHasGUI
	#tag Method, Flags = &h1
		Protected Shared Function AcquireProvider(ProviderID As String, ProviderType As Integer) As Integer
		  //Returns 0 on error, positive integer on success
		  
		  Dim lasterr, cprovider As Integer
		  If Not Win32.AdvApi32.CryptAcquireContext(cprovider, 0, ProviderID, ProviderType, 0) Then
		    lasterr = Win32.LastError
		    Dim s As String = WinLib.FormatError(lasterr)
		    If Not Win32.AdvApi32.CryptAcquireContext(cprovider, 0, ProviderID, ProviderType, CRYPT_NEWKEYSET) Then
		      lasterr = Win32.LastError
		      Dim err As New IOException
		      err.ErrorNumber = lasterr
		      err.Message = WinLib.FormatError(lasterr)
		      Raise err
		    End If
		  End If
		  
		  Return cprovider
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function AESProvider() As Integer
		  //Returns 0 on error, positive integer on success
		  
		  If mAESProvider = 0 Then
		    mAESProvider = AcquireProvider(MS_ENH_RSA_AES_PROV, PROV_RSA_AES)
		  end if
		  Return mAESProvider
		End Function
	#tag EndMethod

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
		 Shared Function BaseProvider() As Integer
		  If mBaseProvider = 0 Then
		    mBaseProvider = AcquireProvider(MS_DEF_PROV, PROV_RSA_FULL)
		  end if
		  Return mBaseProvider
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Algorithm As Integer, CryptoProvider As Integer = 0, Key As Integer = 0)
		  If CryptoProvider = 0 Then CryptoProvider = BaseProvider
		  mProvider = CryptoProvider
		  If Not Win32.AdvApi32.CryptCreateHash(mProvider, Algorithm, Key, 0, mHandle) Then
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
		Function LastError() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return mLastError
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


	#tag Property, Flags = &h21
		Private Shared mAESProvider As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mBaseProvider As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mHandle As Integer
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
