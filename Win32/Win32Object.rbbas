#tag Interface
Interface Win32Object
	#tag Method, Flags = &h0
		Sub Close()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Handle As Integer)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  
		End Function
	#tag EndMethod


	#tag Note, Name = About this interface
		
		
		A Win32Object.Constructor accepts a Win32 handle (or equivalent) as an Integer. Once the Object is constructed, implementors 
		guarentee that the value passed to the constructor will be returned from the Win32Object.Handle method. Implementors do
		not necessarily guarantee that the handle is (or ever was) valid.
		
		Implementors MUST store the value of Win32.LastError after every Win32 call, and return the stored error number from
		Win32Object.LastError.
		
		If the object represented by the handle is not a an object which can be "opened", then the Win32Object.Close method is superfluous.
		Implementors should consider Win32Object.Close to invalidate all internal references of the object. Implementors need not guarantee
		that all references will be CLEARED, only that all references are invalid as far as Windows is concerned. Win32Object.Close MUST NOT
		raise exceptions; it may set the object's last error (0=success/superfluous, or a Win32 error number).
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
End Interface
#tag EndInterface
