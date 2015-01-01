#tag Class
Protected Class WinMB
Implements Win32.Win32Object
	#tag Method, Flags = &h0
		 Shared Sub Acquire(ByRef hMem As Win32.Utils.WinMB)
		  hMem.Freeable = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function Acquire(hMem As Integer, Type As Integer, Size As Integer = - 1) As Win32.Utils.WinMB
		  Dim m As New Win32.Utils.WinMB(hMem)
		  m.HeapHandle = Type
		  If Type <> TypeGlobal Then m.mSize = Size
		  m.Freeable = False
		  Return m
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the Win32Object interface.
		  'Call Unlock()
		  If Freeable Then
		    Select Case HeapHandle
		    Case TypeGlobal ' GlobalAllocate
		      If Not Win32.Libs.Kernel32.GlobalFree(Me.Handle) Then mLastError = Win32.LastError()
		    Case TypeVirtual ' VirtualAllocate
		      If Not Win32.Libs.Kernel32.VirtualFree(Me.Handle, 0, MEM_RELEASE) Then mLastError = Win32.LastError()
		    Case Is >0 ' HeapAllocate
		      If Not Win32.Libs.Kernel32.HeapFree(HeapHandle, 0, Me.Handle) Then mLastError = Win32.LastError()
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

	#tag Method, Flags = &h21
		Private Sub Destructor()
		  Me.Close()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function GlobalAllocate(Size As Integer, ZeroMemory As Boolean = True) As Win32.Utils.WinMB
		  #If TargetWin32 Then
		    Dim flags As Integer
		    If ZeroMemory Then
		      flags = GMEM_ZEROINIT
		    End If
		    Dim p As Integer = Win32.Libs.Kernel32.GlobalAlloc(flags, Size)
		    If p <> 0 Then
		      Dim mb As New Win32.Utils.WinMB(p)
		      mb.HeapHandle = TypeGlobal
		      'mb.mSize = Size
		      Return mb
		    Else
		      p = Win32.LastError
		      Dim err As New Win32Exception
		      err.ErrorNumber = p
		      err.Message = Win32.FormatError(p)
		      Raise err
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  // Part of the Win32Object interface.
		  Return mHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function HeapAllocate(Size As Integer, ZeroMemory As Boolean = True, HeapHandle As Integer = - 1, Flags As Integer = 0) As Win32.Utils.WinMB
		  #If TargetWin32 Then
		    If HeapHandle = -1 Then HeapHandle = Win32.Libs.Kernel32.GetProcessHeap
		    If ZeroMemory Then
		      flags = flags Or HEAP_ZERO_MEMORY
		    End If
		    Dim p As Integer = Win32.Libs.Kernel32.HeapAlloc(HeapHandle, flags, Size)
		    If p <> 0 Then
		      Dim mb As New Win32.Utils.WinMB(p)
		      mb.HeapHandle = HeapHandle
		      'mb.mSize = Size
		      Return mb
		    Else
		      p = Win32.LastError
		      Dim err As New Win32Exception
		      err.ErrorNumber = p
		      err.Message = Win32.FormatError(p)
		      Raise err
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  // Part of the Win32Object interface.
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
		    ret = (Win32.Libs.Kernel32.GlobalLock(Me.Handle) <> Nil)
		  Case TypeVirtual ' VirtualAllocate
		    ret = Win32.Libs.Kernel32.VirtualLock(Me.Handle, mSize)
		  Else ' HeapAllocate
		    ret = Win32.Libs.Kernel32.HeapLock(Me.Handle)
		  End Select
		  mLastError = Win32.LastError()
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Operator_Compare(OtherMB As Win32.Utils.WinMB) As Integer
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
		Function ReAlloc(NewSize As Integer, Optional Flags As Integer) As Boolean
		  Dim ret As Boolean
		  Select Case HeapHandle
		  Case TypeGlobal  ' GlobalAllocate
		    If Not Me.Lock Then Return False
		    Dim i As Integer = Win32.Libs.Kernel32.GlobalReAlloc(Me.Handle, NewSize, Flags)
		    mLastError = Win32.LastError()
		    If i <> 0 Then
		      mHandle = i
		      ret = True
		    End If
		    Call Me.Unlock
		  Case TypeVirtual ' VirtualAllocate
		    Return False 'Win32.Libs.Kernel32.VirtualUnlock(Me.Handle, mSize)
		  Else             ' HeapAllocate
		    Dim i As Integer = Win32.Libs.Kernel32.HeapReAlloc(HeapHandle, Flags, Me.Handle, NewSize)
		    mLastError = Win32.LastError()
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
		      mSize = Win32.Libs.Kernel32.GlobalSize(Me.Handle)
		      mLastError = Win32.LastError()
		      Call Me.Unlock
		    Case TypeVirtual ' VirtualAllocate
		      '#pragma Warning "FIXME" ' This doesn't return the size of the block
		      Dim meta As MEMORY_BASIC_INFORMATION
		      If Win32.Libs.Kernel32.VirtualQuery(Me.Handle, meta, meta.Size) = meta.Size Then
		        Do Until meta.AllocationBase <> Me.Handle
		          mSize = mSize + meta.RegionSize
		          Call Win32.Libs.Kernel32.VirtualQuery(Me.Handle + mSize, meta, meta.Size)
		        Loop
		      Else
		        mLastError = Win32.LastError()
		        Return 0
		      End If
		    Else ' HeapAllocate
		      mSize = Win32.Libs.Kernel32.HeapSize(HeapHandle, 0, Me.Handle)
		      mLastError = Win32.LastError()
		    End Select
		  End If
		  Return mSize
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue(OffSet As Integer, Length As Integer) As MemoryBlock
		  Dim p As New MemoryBlock(Length)
		  If HeapHandle = TypeGlobal Then
		    If Not Me.Lock Then Raise New Win32Exception
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
		    If Not Me.Lock Then Raise New Win32Exception
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
		    ret = Win32.Libs.Kernel32.GlobalUnlock(Me.Handle)
		  Case TypeVirtual ' VirtualAllocate
		    ret = Win32.Libs.Kernel32.VirtualUnlock(Me.Handle, mSize)
		  Else             ' HeapAllocate
		    ret = Win32.Libs.Kernel32.HeapUnlock(Me.Handle)
		  End Select
		  mLastError = Win32.LastError()
		  MemLock.Release
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function VirtualAllocate(Size As Integer, StartAddress As Integer = 0, Protection As Integer = PAGE_EXECUTE_READWRITE, AllocType As Integer = MEM_COMMIT) As Win32.Utils.WinMB
		  Dim p As Integer = Win32.Libs.Kernel32.VirtualAlloc(StartAddress, Size, AllocType, Protection)
		  If p <> 0 Then
		    Dim m As New Win32.Utils.WinMB(p)
		    m.HeapHandle = TypeVirtual
		    m.mSize = Size
		    Return m
		  Else
		    p = Win32.LastError
		    Dim err As New Win32Exception
		    err.ErrorNumber = p
		    err.Message = Win32.FormatError(p)
		    Raise err
		  End If
		  
		End Function
	#tag EndMethod


	#tag Note, Name = About this class
		This class manages a block of memory that was not allocated by REALbasic.
		
		Use the shared methods to allocate a block of memory of the desired allocation type.
		See http://msdn.microsoft.com/en-us/library/windows/desktop/aa366533%28v=vs.85%29.aspx for 
		a discussion of the different allocation types.
		
		Once you have allocated the block, use the StringValue methods to COPY string data to and from
		the block. For more direct access, convert the WinMB to a Ptr (e.g. Dim p As Ptr = MyWinMB) and 
		operate on the Ptr. Do not attempt to free the converted Ptr.
		
		You may also use this class to manage blocks of memory allocated elsewhere by using the
		Acquire shared method. An Acquired block will not be freed when the WinMB instance is destroyed
		or when the Close method is called; you must free it yourself (if it is to be freed at all.)
	#tag EndNote


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


	#tag Constant, Name = GMEM_ZEROINIT, Type = Double, Dynamic = False, Default = \"&h0002", Scope = Private
	#tag EndConstant

	#tag Constant, Name = HEAP_ZERO_MEMORY, Type = Double, Dynamic = False, Default = \"&h00000008", Scope = Private
	#tag EndConstant

	#tag Constant, Name = MEM_COMMIT, Type = Double, Dynamic = False, Default = \"&h00001000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = MEM_DECOMMIT, Type = Double, Dynamic = False, Default = \"&h4000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = MEM_LARGE_PAGES, Type = Double, Dynamic = False, Default = \"&h20000000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = MEM_PHYSICAL, Type = Double, Dynamic = False, Default = \"&h00400000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = MEM_RELEASE, Type = Double, Dynamic = False, Default = \"&h8000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = MEM_RESERVE, Type = Double, Dynamic = False, Default = \"&h00002000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = MEM_TOP_DOWN, Type = Double, Dynamic = False, Default = \"&h00100000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = MEM_WRITE_WATCH, Type = Double, Dynamic = False, Default = \"&h00200000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = PAGE_EXECUTE_READWRITE, Type = Double, Dynamic = False, Default = \"&h40", Scope = Private
	#tag EndConstant

	#tag Constant, Name = PAGE_READONLY, Type = Double, Dynamic = False, Default = \"&h02", Scope = Private
	#tag EndConstant

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
