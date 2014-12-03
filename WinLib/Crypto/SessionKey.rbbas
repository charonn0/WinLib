#tag Class
Protected Class SessionKey
Inherits WinLib.Crypto.KeyContainer
	#tag Method, Flags = &h1000
		Sub Constructor(BaseData As WinLib.Crypto.HashProcessor)
		  // Calling the overridden superclass constructor.
		  // Constructor(DuplicateContext As WinLib.Crypto.Context) -- From Context
		  Super.Constructor(BaseData)
		  mBaseData = BaseData
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Generate(Algorithm As Integer, KeySize As Integer) As Boolean
		  Dim Flags As Integer = BitOr(ShiftLeft(KeySize, 16), (CRYPT_CREATE_SALT Or CRYPT_EXPORTABLE))
		  If Win32.AdvApi32.CryptDeriveKey(Me.Provider, Algorithm, mBaseData.Handle, Flags, mHandle) Then
		    Return True
		  End If
		  mLastError = Win32.LastError
		End Function
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected mBaseData As WinLib.Crypto.HashProcessor
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
