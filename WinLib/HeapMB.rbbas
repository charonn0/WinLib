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
		    Dim mb As New HeapMB(Integer(p))
		    mb.HeapHandle = HeapHandle
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

	#tag Method, Flags = &h0
		Sub Constructor(Handle As Integer) Implements Win32Object.Constructor
		  // Part of the WinLib.Win32Object interface.
		  mHandle = Ptr(Handle)
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
		Function Handle() As Integer
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


	#tag Property, Flags = &h1
		Protected HeapHandle As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mHandle As Ptr
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty


End Class
#tag EndClass
