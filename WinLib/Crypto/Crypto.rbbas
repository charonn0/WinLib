#tag Module
Protected Module Crypto
	#tag Method, Flags = &h1
		Protected Function BinaryToString(Data As MemoryBlock, Flags As Integer) As String
		  Dim sz As Integer
		  Call Win32.Crypt32.CryptBinaryToString(Data, Data.Size, Flags, Nil, sz)
		  Dim output As New MemoryBlock(sz * 2)
		  If Not Win32.Crypt32.CryptBinaryToString(Data, Data.Size, Flags, output, sz) Then
		    sz = Win32.LastError
		    Dim err As New IOException
		    err.ErrorNumber = sz
		    err.Message = WinLib.FormatError(sz)
		    Raise err
		  End If
		  Return output.WString(0)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function EncodeBase64(Data As MemoryBlock) As String
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
		  Dim r As New WinLib.Crypto.Random
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
