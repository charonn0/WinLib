#tag Class
Class WinMB
Implements WinLib.Win32Object
	#tag Method, Flags = &h0
		 Shared Function Acquire(hMem As Integer, Type As Integer, Size As Integer = -1) As WinMB
		  Dim m As New WinMB(hMem)
		  m.HeapHandle = Type
		  If Type <> TypeGlobal Then m.mSize = Size
		  m.Freeable = False
		  Return m
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the WinLib.Win32Object interface.
		  Call Unlock()
		  If Freeable Then
		    Select Case HeapHandle
		    Case TypeGlobal ' GlobalAllocate
		      If Not Win32.Kernel32.GlobalFree(Me.Handle) Then mLastError = Win32.Kernel32.GetLastError()
		    Case TypeVirtual ' VirtualAllocate
		      If Not Win32.Kernel32.VirtualFree(Me.Handle, 0, MEM_RELEASE) Then mLastError = Win32.Kernel32.GetLastError()
		    Case Is >0 ' HeapAllocate
		      If Not Win32.Kernel32.HeapFree(HeapHandle, 0, Me.Handle) Then mLastError = Win32.Kernel32.GetLastError()
		    End Select
		  Else
		    ' Memory not allocated by us, so not freed by us.
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1001
		Protected Sub Constructor(hMem As Integer)
		  mHandle = hMem
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Destructor()
		  Me.Close()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function GlobalAllocate(Size As Integer, ZeroMemory As Boolean = True) As WinMB
		  #If TargetWin32 Then
		    Dim flags As Integer
		    If ZeroMemory Then
		      flags = HEAP_ZERO_MEMORY
		    End If
		    Dim p As Integer = Win32.Kernel32.GlobalAlloc(flags, Size)
		    Dim mb As New WinMB(p)
		    mb.HeapHandle = TypeGlobal
		    mb.mSize = Size
		    Return mb
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return mHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function HeapAllocate(Size As Integer, ZeroMemory As Boolean = True, HeapHandle As Integer = - 1) As WinMB
		  #If TargetWin32 Then
		    If HeapHandle = -1 Then HeapHandle = Win32.Kernel32.GetProcessHeap
		    Dim flags As Integer
		    If ZeroMemory Then
		      flags = HEAP_ZERO_MEMORY
		    End If
		    Dim p As Integer = Win32.Kernel32.HeapAlloc(HeapHandle, flags, Size)
		    Dim mb As New WinMB(p)
		    mb.HeapHandle = HeapHandle
		    mb.mSize = Size
		    Return mb
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Lock() As Boolean
		  Select Case HeapHandle
		  Case TypeGlobal ' GlobalAllocate
		    Return Win32.Kernel32.GlobalLock(Me.Handle) <> Nil
		  Case TypeVirtual ' VirtualAllocate
		    Return Win32.Kernel32.VirtualLock(Me.Handle, mSize)
		  Else ' HeapAllocate
		    Return Win32.Kernel32.HeapLock(Me.Handle)
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Size() As Integer
		  If mSize = -1 And HeapHandle = TypeGlobal And Me.Lock Then
		    mSize = Win32.Kernel32.GlobalSize(Me.Handle)
		    Call Me.Unlock
		    mLastError = Win32.Kernel32.GetLastError()
		  End If
		  Return mSize
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Unlock() As Boolean
		  Select Case HeapHandle
		  Case TypeGlobal ' GlobalAllocate
		    Return Win32.Kernel32.GlobalUnlock(Me.Handle)
		  Case TypeVirtual ' VirtualAllocate
		    Return Win32.Kernel32.VirtualUnlock(Me.Handle, mSize)
		  Else ' HeapAllocate
		    Return Win32.Kernel32.HeapUnlock(Me.Handle)
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value(OffSet As Integer = 0) As MemoryBlock
		  If HeapHandle = TypeGlobal Then
		    Dim p As New MemoryBlock(Me.Size)
		    If Me.Lock Then
		      Dim m As MemoryBlock = Ptr(mHandle)
		      p.StringValue(0, p.Size) = m.StringValue(Offset, Offset + p.Size)
		      Call Me.Unlock
		      Return p
		    End If
		  End If
		  
		  Return Ptr(mHandle)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Value(OffSet As Integer = 0, Assigns NewData As MemoryBlock)
		  If HeapHandle = TypeGlobal Then 
		    If Not Me.Lock Then Raise New RuntimeException
		  End If
		  Dim m As MemoryBlock = Ptr(mHandle)
		  m.StringValue(OffSet, OffSet + NewData.Size) = NewData.StringValue(0, NewData.Size)
		  If HeapHandle = TypeGlobal Then Call Me.Unlock
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function VirtualAllocate(Size As Integer, StartAddress As Integer = 0, Protection As Integer = PAGE_EXECUTE_READWRITE, AllocType As Integer = MEM_COMMIT) As WinLib.WinMB
		  Dim p As Integer = Win32.Kernel32.VirtualAlloc(StartAddress, Size, AllocType, Protection)
		  If p <> 0 Then 
		    Dim m As New WinMB(p)
		    m.HeapHandle = TypeVirtual
		    m.mSize = Size
		    Return m
		  End If
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Freeable As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected HeapHandle As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mHandle As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mSize As Integer = -1
	#tag EndProperty


	#tag Constant, Name = TypeGlobal, Type = Double, Dynamic = False, Default = \"-1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TypeVirtual, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant


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
