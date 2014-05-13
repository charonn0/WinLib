#tag Class
Protected Class Clip_Board
Implements WinLib.Win32Object
	#tag Method, Flags = &h0
		Sub Close()
		  // Part of the WinLib.Win32Object interface.
		  'System.DebugLog(CurrentMethodName)
		  If Not Win32.User32.CloseClipboard() Then mLastError = Win32.Kernel32.GetLastError()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Handle As Integer)
		  // Part of the WinLib.Win32Object interface.
		  'System.DebugLog(CurrentMethodName)
		  mHandle = Handle
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Data(Format As WinLib.ClipboardFormat) As Variant
		  'System.DebugLog(CurrentMethodName)
		  If Not Me.Open Then Raise New RuntimeException
		  Dim hMem As Integer = Win32.User32.GetClipboardData(Format.Handle)
		  mLastError = Win32.Kernel32.GetLastError()
		  If hMem = 0 Then
		    Me.Close
		    Raise New RuntimeException
		  End If
		  Dim hGlobal As WinMB = WinMB.Acquire(hMem, WinMB.TypeGlobal)
		  If hGlobal.Size > -1 Then
		    Dim data As String 
		    If hGlobal.Value <> Nil Then
		      data = hGlobal.Value.StringValue(0, hGlobal.Size)
		      Me.Close
		      Return data
		    End If
		  Else
		    Return hMem
		    Me.Close
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Data(Format As WinLib.ClipboardFormat, Assigns NewData As MemoryBlock)
		  'System.DebugLog(CurrentMethodName)
		  If Not Me.Open Then Raise New RuntimeException
		  Dim hMem As Integer = Win32.Kernel32.GlobalAlloc(GMEM_MOVEABLE, NewData.Size)
		  If hMem = 0 Then
		    Me.Close
		    Raise New RuntimeException
		  End If
		  Dim hGlobal As WinMB = WinMB.Acquire(hMem, 0)
		  If hGlobal <> Nil And hGlobal.Value <> Nil Then
		    hGlobal.Value.StringValue(0, NewData.Size) = NewData.StringValue(0, NewData.Size)
		    Call Win32.User32.SetClipboardData(Format.Handle, Integer(hMem))
		  End If
		  Me.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Empty() As Boolean
		  Return Win32.User32.EmptyClipboard
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FormatCount() As Integer
		  'System.DebugLog(CurrentMethodName)
		  If Not Me.Open Then Raise New RuntimeException
		  Dim hClip, c As Integer
		  Do
		    hClip = Win32.User32.EnumClipboardFormats(hClip)
		    If hClip = 0 Then Exit Do
		    c = c + 1
		  Loop
		  Me.Close
		  Return c
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetFormat(Index As Integer) As WinLib.ClipboardFormat
		  'System.DebugLog(CurrentMethodName)
		  If Not Me.Open Then Raise New RuntimeException
		  Dim hClip As Integer
		  For i As Integer = 0 To Index
		    hClip = Win32.User32.EnumClipboardFormats(hClip)
		  Next
		  Me.Close
		  If hClip > 0 Then
		    Return New WinLib.ClipboardFormat(hClip)
		  End If
		  Raise New OutOfBoundsException
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return mHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasFormat(Format As WinLib.ClipboardFormat) As Boolean
		  If Not Me.Open Then Raise New RuntimeException
		  Dim hClip As Integer
		  Do
		    hClip = Win32.User32.EnumClipboardFormats(hClip)
		    If hClip = 0 Then Exit Do
		    If hClip = Format.Handle Then Return True
		  Loop
		  Me.Close
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  // Part of the WinLib.Win32Object interface.
		  Return mLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Open() As Boolean
		  'System.DebugLog(CurrentMethodName)
		  Return Win32.User32.OpenClipboard(mHandle)
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
