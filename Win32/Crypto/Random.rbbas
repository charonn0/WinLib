#tag Class
Protected Class Random
Inherits Win32.Crypto.Context
	#tag Method, Flags = &h1000
		Sub Constructor(Optional RandomProvider As Win32.Crypto.Context)
		  If RandomProvider = Nil Then RandomProvider = BaseProvider
		  // Calling the overridden superclass constructor.
		  // Constructor(DuplicateContext As Win32.Crypto.Context) -- From Context
		  Super.Constructor(RandomProvider)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Generate(ByteCount As Integer) As MemoryBlock
		  Dim mb As New MemoryBlock(ByteCount)
		  If Not Win32.Libs.AdvApi32.CryptGenRandom(Me.Provider, mb.Size, mb) Then
		    mLastError = Win32.LastError
		  Else
		    Return mb
		  End If
		  
		End Function
	#tag EndMethod


	#tag Note, Name = About this class
		Data produced by this class are cryptographically random, and suitable for secure systems.
		See: http://msdn.microsoft.com/en-us/library/windows/desktop/aa379942%28v=vs.85%29.aspx
		
	#tag EndNote


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
