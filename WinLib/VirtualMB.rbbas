#tag Class
Class VirtualMB
	#tag Method, Flags = &h0
		 Shared Function Allocate(Size As Integer, StartAddress As Integer = 0, Protection As Integer = PAGE_EXECUTE_READWRITE, AllocType As Integer = MEM_COMMIT) As VirtualMB
		  Dim p As Ptr = Win32.Kernel32.VirtualAlloc(StartAddress, Size, AllocType, Protection)
		  If p <> Nil Then Return New VirtualMB(p, Size)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the WinLib.Win32Object interface.
		  Call VirtualMB.Free(Me)
		  OSPtr = Nil
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1001
		Protected Sub Constructor(hmb As Ptr, Size As Integer)
		  OSPtr = hmb
		  mSize = Size
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Destructor()
		  Me.Close()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function Free(MB As VirtualMB) As Boolean
		  If Not Win32.Kernel32.VirtualFree(MB.Value, 0, MEM_RELEASE) Then
		    MB.mLastError = Win32.Kernel32.GetLastError()
		  Else
		    MB.mLastError = 0
		  End If
		  
		  Return MB.LastError = 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Lock() As Boolean
		  Return Win32.Kernel32.VirtualLock(Me.Value, mSize)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Operator_Compare(OtherMB As VirtualMB) As Integer
		  If OtherMB Is Nil Or OtherMB.Value = Nil Then Return -1 ' comparing Self to Nil
		  
		  If Me.Value <> Nil Then 
		    If Integer(OtherMB.Value) > Integer(Me.Value) Then Return -1
		    If Integer(OtherMB.Value) < Integer(Me.Value) Then Return 1
		    Return 0
		  ElseIf OtherMB.Value <> Nil Then
		    Return 1
		  Else
		    Return 0
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Protect(Size As Integer, NewProtect As Integer) As Integer
		  Dim oldprot As Integer
		  If Win32.Kernel32.VirtualProtect(Me.Value, size, Newprotect, oldprot) Then
		    mLastError = 0
		    Return oldprot
		  Else
		    mLastError = Win32.Kernel32.GetLastError()
		    Return 0
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Query() As MEMORY_BASIC_INFORMATION
		  Dim info As MEMORY_BASIC_INFORMATION
		  Call Win32.Kernel32.VirtualQuery(Me.Value, info, info.Size)
		  Return info
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Size() As Integer
		  Return mSize
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue(Start As Integer, Length As Integer) As String
		  If Start + Length > mSize Then Raise New OutOfBoundsException
		  Dim mb As MemoryBlock = Me.Value
		  Return mb.StringValue(Start, Length)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StringValue(Start As Integer, Length As Integer, Assigns NewData As String)
		  If Start + Length > mSize Then Raise New OutOfBoundsException
		  Dim mb As MemoryBlock = Me.Value
		  mb.StringValue(Start, Length) = NewData
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Unlock() As Boolean
		  Return Win32.Kernel32.VirtualUnlock(Me.Value, mSize)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value() As Ptr
		  Return OSPtr
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Me.Query.AllocationBase
			End Get
		#tag EndGetter
		AllocationBase As Ptr
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Me.Query.AllocationProtect
			End Get
		#tag EndGetter
		AllocationProtect As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Me.Query.BaseAddress
			End Get
		#tag EndGetter
		BaseAddress As Ptr
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mSize As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected OSPtr As Ptr
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Me.Query.Protect
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Call Me.Protect(mSize, value)
			End Set
		#tag EndSetter
		Protect As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Me.Query.RegionSize
			End Get
		#tag EndGetter
		RegionSize As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Me.Query.State
			End Get
		#tag EndGetter
		State As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return Me.Query.Type
			End Get
		#tag EndGetter
		Type As Integer
	#tag EndComputedProperty


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
