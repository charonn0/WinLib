#tag Class
Protected Class UUID
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
		 Shared Function FromString(UUIDString As String) As Win32.Utils.UUID
		  #If TargetWin32 Then
		    Dim mb As New MemoryBlock(16)
		    Dim id As MemoryBlock = UUIDString
		    Call Win32.Libs.Rpcrt4.UuidFromString(id, mb)
		    Dim mUUID As New UUID(mb)
		    Return mUUID
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function NewUUID(Sequential As Boolean = False) As Win32.Utils.UUID
		  #If TargetWin32 Then
		    ' When Sequential=False, UUIDs returned from this method are guaranteed to be globally unique and cannot be traced to the
		    ' generating computer (i.e. version 4 UUIDs.)
		    ' When Sequential=True, the returned UUID was generated using the computer's MAC address and is traceable to that computer;
		    ' if the computer lacks an ethernet port then the returned UUID is guaranteed unique ONLY on that computer.
		    
		    Dim mb As New MemoryBlock(16)
		    If Not Sequential Then
		      Call Win32.Libs.Rpcrt4.UuidCreate(mb)
		    Else
		      Call Win32.Libs.Rpcrt4.UuidCreateSequential(mb)
		    End If
		    Dim mUUID As New UUID(mb)
		    Return mUUID
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Operator_Compare(OtherUUID As UUID) As Integer
		  #If TargetWin32 Then
		    If OtherUUID Is Nil Then Return 1 ' comparing Self to Nil
		    If mUUID <> Nil And OtherUUID.mUUID <> Nil Then
		      Dim status As New MemoryBlock(16)
		      Dim i As Integer = Win32.Libs.Rpcrt4.UuidCompare(mUUID, OtherUUID.mUUID, status)
		      Return i
		    ElseIf OtherUUID.mUUID <> Nil Then
		      Return -1
		    Else
		      Return 0
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Operator_Convert() As String
		  #If TargetWin32 Then
		    Dim pBuffer As Ptr
		    Call Win32.Libs.Rpcrt4.UuidToString(mUUID, pBuffer)
		    Dim mb As MemoryBlock = pBuffer
		    Dim data As String = mb.CString(0)
		    Call Win32.Libs.Rpcrt4.RpcStringFree(pBuffer)
		    Return data
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
