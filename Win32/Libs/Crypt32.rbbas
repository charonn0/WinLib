#tag Module
Protected Module Crypt32
	#tag ExternalMethod, Flags = &h1
		Protected Declare Function CryptBinaryToString Lib "Crypt32" Alias "CryptBinaryToStringW" (Data As Ptr, DataLen As Integer, Flags As Integer, Buffer As Ptr, ByRef BufferLen As Integer) As Boolean
	#tag EndExternalMethod


End Module
#tag EndModule
