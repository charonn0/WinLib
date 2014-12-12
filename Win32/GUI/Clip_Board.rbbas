#tag Class
Protected Class Clip_Board
Implements Win32.Win32Object
	#tag CompatibilityFlags = TargetHasGUI
	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the Win32Object interface.
		  'System.DebugLog(CurrentMethodName)
		  If Not Win32.Libs.User32.CloseClipboard() Then mLastError = Win32.LastError()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Handle As Integer)
		  // Part of the Win32Object interface.
		  'System.DebugLog(CurrentMethodName)
		  mHandle = Handle
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Data(Format As Win32.GUI.ClipboardFormat) As MemoryBlock
		  'System.DebugLog(CurrentMethodName)
		  If Not Me.Open Then Raise New RuntimeException
		  Dim hMem As Integer = Win32.Libs.User32.GetClipboardData(Format.Handle)
		  mLastError = Win32.LastError()
		  If hMem = 0 Then
		    Me.Close
		    Raise New RuntimeException
		  End If
		  Dim hGlobal As Win32.Utils.WinMB = Win32.Utils.WinMB.Acquire(hMem, Win32.Utils.WinMB.TypeGlobal)
		  If hGlobal.Size > -1 Then
		    Dim data As String
		    If hGlobal <> Nil Then
		      data = hGlobal.StringValue(0, hGlobal.Size)
		      Me.Close
		      Return data
		    End If
		  Else
		    Return Ptr(hMem)
		    Me.Close
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Data(Format As Win32.GUI.ClipboardFormat, Assigns NewData As MemoryBlock)
		  'System.DebugLog(CurrentMethodName)
		  If Not Me.Open Or Not Me.Empty Then Raise New RuntimeException
		  Dim hGlobal As Win32.Utils.WinMB = Win32.Utils.WinMB.HeapAllocate(NewData.Size, True, -1, GMEM_MOVEABLE)
		  If hGlobal <> Nil Then
		    Win32.Utils.WinMB.Acquire(hGlobal) ' mark as not freeable.
		    hGlobal.StringValue(0, NewData.Size) = NewData.StringValue(0, NewData.Size)
		    Call Win32.Libs.User32.SetClipboardData(Format.Handle, hGlobal)
		    mLastError = Win32.LastError()
		    Break
		  End If
		  Me.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Empty() As Boolean
		  If Win32.Libs.User32.EmptyClipboard Then Return True
		  mLastError = Win32.LastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FormatCount() As Integer
		  'System.DebugLog(CurrentMethodName)
		  If Not Me.Open Then Raise New RuntimeException
		  Dim hClip, c As Integer
		  Do
		    hClip = Win32.Libs.User32.EnumClipboardFormats(hClip)
		    If hClip = 0 Then Exit Do
		    c = c + 1
		  Loop
		  mLastError = Win32.LastError
		  Me.Close
		  Return c
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetFormat(Index As Integer) As Win32.GUI.ClipboardFormat
		  'System.DebugLog(CurrentMethodName)
		  If Not Me.Open Then Raise New RuntimeException
		  Dim hClip As Integer
		  For i As Integer = 0 To Index
		    hClip = Win32.Libs.User32.EnumClipboardFormats(hClip)
		  Next
		  mLastError = Win32.LastError
		  Me.Close
		  If hClip > 0 Then
		    Return New Win32.GUI.ClipboardFormat(hClip)
		  End If
		  Raise New OutOfBoundsException
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  // Part of the Win32Object interface.
		  Return mHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasFormat(Format As Win32.GUI.ClipboardFormat) As Boolean
		  If Not Me.Open Then Raise New RuntimeException
		  Dim hClip As Integer
		  Dim ret As Boolean
		  Do
		    hClip = Win32.Libs.User32.EnumClipboardFormats(hClip)
		    mLastError = Win32.LastError
		    If hClip = 0 Then Exit Do
		    If hClip = Format.Handle Then ret = True
		  Loop
		  Me.Close
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  // Part of the Win32Object interface.
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Open() As Boolean
		  'System.DebugLog(CurrentMethodName)
		  If Win32.Libs.User32.OpenClipboard(mHandle) Then Return True
		  mLastError = Win32.LastError
		End Function
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected mHandle As Integer
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
