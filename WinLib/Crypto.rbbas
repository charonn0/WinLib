#tag Module
Protected Module Crypto
	#tag Method, Flags = &h1
		Protected Function CryptoProvider(Provider As String = MS_DEF_PROV) As Integer
		  Dim prov As Integer
		  If Not Win32.AdvApi32.CryptAcquireContext(prov, 0, Provider, PROV_RSA_FULL, 0) Then
		    If Not Win32.AdvApi32.CryptAcquireContext(prov, 0, Provider, PROV_RSA_FULL, CRYPT_NEWKEYSET) Then
		      Raise Win32Exception(Win32.LastError)
		    End If
		  End If
		  
		  Return prov
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HashData(Data As MemoryBlock, Algorithm As Integer, Key As Integer = 0) As String
		  ' processes the whole Data and returns a binary hash string
		  
		  Dim hashhandle As Integer = HashDataProcessStart(Algorithm, Key)
		  Dim bs As New BinaryStream(Data)
		  While Not bs.EOF
		    Dim chunk As MemoryBlock = bs.Read(512)
		    If Not HashDataProcess(chunk, hashhandle) Then
		      Raise Win32Exception(Win32.LastError)
		    End If
		  Wend
		  bs.Close
		  Return HashDataProcessEnd(hashhandle)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HashDataProcess(AdditionalData As MemoryBlock, HashHandle As Integer) As Boolean
		  ' Adds the passed data to the hash object specified by HashHandle
		  
		  Return Win32.AdvApi32.CryptHashData(HashHandle, AdditionalData, AdditionalData.Size, 0)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HashDataProcessEnd(HashHandle As Integer) As String
		  ' Closes the hash object and returns the hash value
		  
		  Dim mb As New MemoryBlock(1024)
		  Dim sz As Integer = mb.Size
		  If Not Win32.AdvApi32.CryptGetHashParam(hashhandle, HP_HASHVAL, mb, sz, 0) Then
		    Raise Win32Exception(Win32.LastError)
		  End If
		  Dim hash As String = mb.StringValue(0, sz)
		  Win32.AdvApi32.CryptDestroyHash(hashhandle)
		  Return hash
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HashDataProcessStart(Algorithm As Integer, Key As Integer = 0) As Integer
		  ' Begins a hashing operation
		  
		  Dim hashhandle As Integer
		  Dim provider As Integer
		  Select Case Algorithm
		  Case CALG_HMAC, CALG_MAC, CALG_MD2, CALG_MD5, CALG_SHA1
		    provider = CryptoProvider(MS_DEF_PROV)
		    
		  Case CALG_SHA256, CALG_SHA384, CALG_SHA512
		    provider = CryptoProvider(MS_ENH_RSA_AES_PROV)
		    
		  Else
		    Dim err As New RuntimeException
		    err.Message = "Illegal hashing algorithm"
		    err.ErrorNumber = -1
		    Raise err
		  End Select
		  
		  If Not Win32.AdvApi32.CryptCreateHash(Provider, Algorithm, key, 0, hashhandle) Then
		    Raise Win32Exception(Win32.LastError)
		  End If
		  
		  Return hashhandle
		End Function
	#tag EndMethod


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
End Module
#tag EndModule
