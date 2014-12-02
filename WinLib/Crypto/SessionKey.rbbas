#tag Class
Protected Class SessionKey
Inherits WinLib.Crypto.KeyContainer
	#tag Method, Flags = &h0
		Function Generate(Algorithm As Integer, Flags As Integer, BaseData As WinLib.Crypto.HashProcessor) As Boolean
		  If Win32.AdvApi32.CryptDeriveKey(Me.Provider, Algorithm, BaseData.Handle, Flags, mHandle) Then
		    Return True
		  End If
		  mLastError = Win32.LastError
		End Function
	#tag EndMethod


End Class
#tag EndClass
