#tag Module
Protected Module Crypto
	#tag Method, Flags = &h1
		Protected Function BinaryToString(Data As MemoryBlock, Flags As Integer) As String
		  Dim sz As Integer
		  Call Win32.Libs.Crypt32.CryptBinaryToString(Data, Data.Size, Flags, Nil, sz)
		  Dim output As New MemoryBlock(sz * 2)
		  If Not Win32.Libs.Crypt32.CryptBinaryToString(Data, Data.Size, Flags, output, sz) Then
		    sz = Win32.LastError
		    Dim err As New IOException
		    err.ErrorNumber = sz
		    err.Message = Win32.FormatError(sz)
		    Raise err
		  End If
		  Return output.WString(0)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function EncodeBase64(Data As MemoryBlock) As String
		  Return BinaryToString(Data, CRYPT_STRING_BASE64)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function EncodeHex(Data As MemoryBlock) As String
		  Return BinaryToString(Data, CRYPT_STRING_HEX)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetRandomData(ByteCount As Integer) As MemoryBlock
		  ' The data produced by this funtion is cryptographically random.
		  ' See: http://msdn.microsoft.com/en-us/library/windows/desktop/aa379942%28v=vs.85%29.aspx
		  Dim r As New Win32.Crypto.Random
		  Return r.Generate(ByteCount)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function MD2(Data As MemoryBlock) As String
		  Return ProcessHash(Data, CALG_MD2)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function MD4(Data As MemoryBlock) As String
		  Return ProcessHash(Data, CALG_MD4)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function MD5(Data As MemoryBlock) As String
		  Return ProcessHash(Data, CALG_MD5)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ProcessHash(Data As MemoryBlock, Algorithm As Integer) As String
		  Dim h As New HashProcessor(Algorithm)
		  Dim bs As New BinaryStream(Data)
		  While Not bs.EOF
		    h.Process(bs.Read(1024 *4))
		  Wend
		  bs.Close
		  Return h.Value
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function RandDouble() As Double
		  Return GetRandomData(8).DoubleValue(0)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function RandInt32() As Integer
		  Return GetRandomData(4).Int32Value(0)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function RandInt64() As Int64
		  Return GetRandomData(8).Int64Value(0)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function RandUInt32() As UInt32
		  Return GetRandomData(4).UInt32Value(0)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function RandUInt64() As Int64
		  Return GetRandomData(8).UInt64Value(0)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function SHA1(Data As MemoryBlock) As String
		  Return ProcessHash(Data, CALG_SHA1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function SHA256(Data As MemoryBlock) As String
		  Return ProcessHash(Data, CALG_SHA256)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function SHA384(Data As MemoryBlock) As String
		  Return ProcessHash(Data, CALG_SHA384)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function SHA512(Data As MemoryBlock) As String
		  Return ProcessHash(Data, CALG_SHA512)
		End Function
	#tag EndMethod


	#tag Constant, Name = CALG_3DES, Type = Double, Dynamic = False, Default = \"&h00006603", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_3DES_112, Type = Double, Dynamic = False, Default = \"&h00006609", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_AES, Type = Double, Dynamic = False, Default = \"&h00006611", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_AES128, Type = Double, Dynamic = False, Default = \"&h0000660e", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_AES192, Type = Double, Dynamic = False, Default = \"&h0000660f", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_AES256, Type = Double, Dynamic = False, Default = \"&h00006610", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_DES, Type = Double, Dynamic = False, Default = \"&h00006601", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_HMAC, Type = Double, Dynamic = False, Default = \"&h00008009", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_MAC, Type = Double, Dynamic = False, Default = \"&h00008005", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_MD2, Type = Double, Dynamic = False, Default = \"&h00008001", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_MD4, Type = Double, Dynamic = False, Default = \"&h00008002", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_MD5, Type = Double, Dynamic = False, Default = \"&h00008003", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_RC2, Type = Double, Dynamic = False, Default = \"&h000065FF", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_RC4, Type = Double, Dynamic = False, Default = \"&h00006801", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_SHA1, Type = Double, Dynamic = False, Default = \"&h00008004", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_SHA256, Type = Double, Dynamic = False, Default = \"&h0000800c", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_SHA384, Type = Double, Dynamic = False, Default = \"&h0000800d", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CALG_SHA512, Type = Double, Dynamic = False, Default = \"&h0000800e", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_CREATE_SALT, Type = Double, Dynamic = False, Default = \"4", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_EXPORTABLE, Type = Double, Dynamic = False, Default = \"1", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_NEWKEYSET, Type = Double, Dynamic = False, Default = \"&h00000008\r", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_NO_SALT, Type = Double, Dynamic = False, Default = \"&h10", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_SERVER, Type = Double, Dynamic = False, Default = \"1024", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_STRING_BASE64, Type = Double, Dynamic = False, Default = \"1", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_STRING_BASE64HEADER, Type = Double, Dynamic = False, Default = \"0", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_STRING_BASE64REQUESTHEADER, Type = Double, Dynamic = False, Default = \"3", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_STRING_BASE64X509CRLHEADER, Type = Double, Dynamic = False, Default = \"9", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_STRING_BINARY, Type = Double, Dynamic = False, Default = \"2", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_STRING_HEX, Type = Double, Dynamic = False, Default = \"4", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_STRING_HEXADDR, Type = Double, Dynamic = False, Default = \"&h0a", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_STRING_HEXASCII, Type = Double, Dynamic = False, Default = \"5", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_STRING_HEXASCIIADDR, Type = Double, Dynamic = False, Default = \"&h0B", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_STRING_HEXRAW, Type = Double, Dynamic = False, Default = \"&h0C", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_STRING_STRICT, Type = Double, Dynamic = False, Default = \"&h20000000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = CRYPT_UPDATE_KEY, Type = Double, Dynamic = False, Default = \"&h00000008", Scope = Protected
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
End Module
#tag EndModule
