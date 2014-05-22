#tag Class
Class WinMB
Implements WinLib.Win32Object
	#tag Method, Flags = &h0
		 Shared Sub Acquire(ByRef hMem As WinLib.WinMB)
		  hMem.Freeable = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function Acquire(hMem As Integer, Type As Integer, Size As Integer = - 1) As WinMB
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
		  'Call Unlock()
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
		      flags = GMEM_ZEROINIT
		    End If
		    Dim p As Integer = Win32.Kernel32.GlobalAlloc(flags, Size)
		    If p <> 0 Then
		      Dim mb As New WinMB(p)
		      mb.HeapHandle = TypeGlobal
		      'mb.mSize = Size
		      Return mb
		    Else
		      p = Win32.Kernel32.GetLastError
		      Dim err As New RuntimeException
		      err.ErrorNumber = p
		      err.Message = WinLib.FormatError(p)
		      Raise err
		    End If
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
		 Shared Function HeapAllocate(Size As Integer, ZeroMemory As Boolean = True, HeapHandle As Integer = - 1, Flags As Integer = 0) As WinMB
		  #If TargetWin32 Then
		    If HeapHandle = -1 Then HeapHandle = Win32.Kernel32.GetProcessHeap
		    If ZeroMemory Then
		      flags = flags Or HEAP_ZERO_MEMORY
		    End If
		    Dim p As Integer = Win32.Kernel32.HeapAlloc(HeapHandle, flags, Size)
		    If p <> 0 Then
		      Dim mb As New WinMB(p)
		      mb.HeapHandle = HeapHandle
		      'mb.mSize = Size
		      Return mb
		    Else
		      p = Win32.Kernel32.GetLastError
		      Dim err As New RuntimeException
		      err.ErrorNumber = p
		      err.Message = WinLib.FormatError(p)
		      Raise err
		    End If
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
		  If MemLock = Nil Then MemLock = New Semaphore
		  MemLock.Signal
		  Dim ret As Boolean
		  Select Case HeapHandle
		  Case TypeGlobal ' GlobalAllocate
		    ret = (Win32.Kernel32.GlobalLock(Me.Handle) <> Nil)
		  Case TypeVirtual ' VirtualAllocate
		    ret = Win32.Kernel32.VirtualLock(Me.Handle, mSize)
		  Else ' HeapAllocate
		    ret = Win32.Kernel32.HeapLock(Me.Handle)
		  End Select
		  mLastError = Win32.Kernel32.GetLastError()
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Operator_Compare(OtherMB As WinLib.WinMB) As Integer
		  If OtherMB Is Nil Then Return 1
		  If OtherMB.Handle = Me.Handle Then Return 0
		  If OtherMB.Handle > Me.Handle Then Return -1
		  If OtherMB.Handle < Me.Handle Then Return 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Operator_Convert() As Ptr
		  Return Ptr(Me.Handle)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReAlloc(NewSize As Integer) As Boolean
		  Dim ret As Boolean
		  Select Case HeapHandle
		  Case TypeGlobal  ' GlobalAllocate
		    If Not Me.Lock Then Return False
		    Dim i As Integer = Win32.Kernel32.GlobalReAlloc(Me.Handle, NewSize, 0)
		    mLastError = Win32.Kernel32.GetLastError()
		    If i <> 0 Then
		      mHandle = i
		      ret = True
		    End If
		    Call Me.Unlock
		  Case TypeVirtual ' VirtualAllocate
		    Return False 'Win32.Kernel32.VirtualUnlock(Me.Handle, mSize)
		  Else             ' HeapAllocate
		    Dim i As Integer = Win32.Kernel32.HeapReAlloc(HeapHandle, 0, Me.Handle, NewSize)
		    mLastError = Win32.Kernel32.GetLastError()
		    If i <> 0 Then
		      mHandle = i
		      ret = True
		    End If
		  End Select
		  If ret Then mSize = NewSize
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Size() As Integer
		  If mSize = -1 Then
		    Select Case HeapHandle
		    Case TypeGlobal ' GlobalAllocate
		      If Not Me.Lock Then Return -1
		      mSize = Win32.Kernel32.GlobalSize(Me.Handle)
		      mLastError = Win32.Kernel32.GetLastError()
		      Call Me.Unlock
		    Case TypeVirtual ' VirtualAllocate
		      '#pragma Warning "FIXME" ' This doesn't return the size of the block
		      Dim meta As MEMORY_BASIC_INFORMATION
		      If Win32.Kernel32.VirtualQuery(Me.Handle, meta, meta.Size) = meta.Size Then
		        Do Until meta.AllocationBase <> Me.Handle
		          mSize = mSize + meta.RegionSize
		          Call Win32.Kernel32.VirtualQuery(Me.Handle + mSize, meta, meta.Size)
		        Loop
		      Else
		        mLastError = Win32.Kernel32.GetLastError()
		        Return 0
		      End If
		    Else ' HeapAllocate
		      mSize = Win32.Kernel32.HeapSize(HeapHandle, 0, Me.Handle)
		      mLastError = Win32.Kernel32.GetLastError()
		    End Select
		  End If
		  Return mSize
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue(OffSet As Integer, Length As Integer) As MemoryBlock
		  Dim p As New MemoryBlock(Length)
		  If HeapHandle = TypeGlobal Then
		    If Not Me.Lock Then Raise New RuntimeException
		  End If
		  Dim m As MemoryBlock = Ptr(mHandle)
		  p.StringValue(0, Length) = m.StringValue(Offset, Length)
		  If HeapHandle = TypeGlobal Then Call Me.Unlock
		  Return p
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StringValue(OffSet As Integer, Length As Integer, Assigns NewData As MemoryBlock)
		  If HeapHandle = TypeGlobal Then
		    If Not Me.Lock Then Raise New RuntimeException
		  End If
		  Dim m As MemoryBlock = Ptr(mHandle)
		  m.StringValue(OffSet, Length) = NewData.StringValue(0, Length)
		  If HeapHandle = TypeGlobal Then Call Me.Unlock
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Unlock() As Boolean
		  Dim ret As Boolean
		  Select Case HeapHandle
		  Case TypeGlobal  ' GlobalAllocate
		    ret = Win32.Kernel32.GlobalUnlock(Me.Handle)
		  Case TypeVirtual ' VirtualAllocate
		    ret = Win32.Kernel32.VirtualUnlock(Me.Handle, mSize)
		  Else             ' HeapAllocate
		    ret = Win32.Kernel32.HeapUnlock(Me.Handle)
		  End Select
		  mLastError = Win32.Kernel32.GetLastError()
		  MemLock.Release
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function VirtualAllocate(Size As Integer, StartAddress As Integer = 0, Protection As Integer = PAGE_EXECUTE_READWRITE, AllocType As Integer = MEM_COMMIT) As WinLib.WinMB
		  Dim p As Integer = Win32.Kernel32.VirtualAlloc(StartAddress, Size, AllocType, Protection)
		  If p <> 0 Then
		    Dim m As New WinMB(p)
		    m.HeapHandle = TypeVirtual
		    m.mSize = Size
		    Return m
		  Else
		    p = Win32.Kernel32.GetLastError
		    Dim err As New RuntimeException
		    err.ErrorNumber = p
		    err.Message = WinLib.FormatError(p)
		    Raise err
		  End If
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Freeable As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected HeapHandle As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h21
		Private MemLock As Semaphore
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
