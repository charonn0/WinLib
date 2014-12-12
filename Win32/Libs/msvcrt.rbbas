#tag Module
Protected Module msvcrt
	#tag Method, Flags = &h1
		Protected Function IsAvailable() As Boolean
		  Return System.IsFunctionAvailable("__argc", "msvcrt")
		End Function
	#tag EndMethod

	#tag ExternalMethod, Flags = &h1
		Protected Soft Declare Function _open_osfhandle Lib "msvcrt" (osfhandle As Integer, Flags As Integer) As Integer
	#tag EndExternalMethod


End Module
#tag EndModule
