#tag Class
Class HeapMB
Inherits MemoryBlock
Implements WinLib.Win32Object
	#tag Method, Flags = &h0
		 Shared Function Allocate(Size As Integer, ZeroMemory As Boolean = True, HeapHandle As Integer = - 1) As HeapMB
		  #If TargetWin32 Then
		    If HeapHandle = -1 Then HeapHandle = DefaultHeap
		    Dim flags As Integer
		    If ZeroMemory Then
		      flags = HEAP_ZERO_MEMORY
		    End If
		    Dim p As Ptr = Win32.Kernel32.HeapAlloc(HeapHandle, flags, Size)
		    Dim mb As New HeapMB(p, HeapHandle)
		    'mb.HeapHandle = HeapHandle
		    Return mb
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the WinLib.Win32Object interface.
		  Call HeapMB.Free(Me)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Attributes( deprecated = "WinLib.HeapMB.Allocate" ) Private Sub Constructor(Handle As Integer) Implements Win32Object.Constructor
		  // Part of the WinLib.Win32Object interface.
		  Break ' Do not use this Constructor. Use HeapMB.Allocate
		  mHandle = Ptr(Handle)
		  HeapHandle = DefaultHeap
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1001
		Protected Sub Constructor(hmb As Ptr, Heap As Integer) Implements Win32Object.Constructor
		  mHandle = hmb
		  HeapHandle = Heap
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function DefaultHeap() As Integer
		  Return Win32.Kernel32.GetProcessHeap
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Destructor()
		  Me.Close()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function Free(HMB As HeapMB) As Boolean
		  #If TargetWin32 Then
		    Dim HeapHandle As Integer = HMB.HeapHandle
		    Return Win32.Kernel32.HeapFree(HeapHandle, 0, HMB)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Attributes( deprecated = "WinLib.HeapMB.Value" )  Function Handle() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return Integer(mHandle)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value() As Ptr
		  Return mHandle
		End Function
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected HeapHandle As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mHandle As Ptr
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
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
			Name="LittleEndian"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
			InheritedFrom="MemoryBlock"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Size"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="MemoryBlock"
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
