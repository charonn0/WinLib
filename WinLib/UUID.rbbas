#tag Class
Class UUID
	#tag Method, Flags = &h1
		Protected Sub Constructor(UUIDPtr As MemoryBlock)
		  Me.mUUID = UUIDPtr
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Copy() As UUID
		  Return New UUID(mUUID)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function FromString(UUIDString As String) As WinLib.UUID
		  #If TargetWin32 Then
		    Dim mb As New MemoryBlock(16)
		    Dim id As MemoryBlock = UUIDString
		    Call Win32.Rpcrt4.UuidFromString(id, mb)
		    Dim mUUID As New UUID(mb)
		    Return mUUID
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function NewUUID() As WinLib.UUID
		  #If TargetWin32 Then
		    ' UUIDs returned from this method are guaranteed to be globally unique
		    ' and cannot be traced to the generating computer
		    Dim mb As New MemoryBlock(16)
		    Call Win32.Rpcrt4.UuidCreate(mb)
		    Dim mUUID As New UUID(mb)
		    Return mUUID
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Operator_Compare(OtherUUID As UUID) As Integer
		  #If TargetWin32 Then
		    Dim status As New MemoryBlock(16)
		    Dim i As Integer = Win32.Rpcrt4.UuidCompare(mUUID, OtherUUID.mUUID, status)
		    Return i
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Operator_Convert() As String
		  #If TargetWin32 Then
		    Dim ptrUUID As New MemoryBlock(16)
		    Dim ppAddr As ptr
		    Call Win32.Rpcrt4.UuidToString(mUUID, ppAddr)
		    Dim mb2 As MemoryBlock = ppAddr
		    Call Win32.Rpcrt4.RpcStringFree(ptrUUID)
		    Return mb2.CString(0)
		  #endif
		End Function
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected mUUID As MemoryBlock
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
