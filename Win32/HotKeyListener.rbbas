#tag Class
Class HotKeyListener
Inherits WMListener
	#tag Event
		Function WindowMessage(HWND As Integer, Message As Integer, WParam As Ptr, LParam As Ptr) As Boolean
		  #If DebugBuild Then
		    ' We should not be getting messages addressed to other windows.
		    If HWND <> Me.ParentWindow Then Break
		  #Else
		    #pragma Unused HWND
		  #endif
		  If Message = WM_HOTKEY Then
		    Dim keystring As String = ConstructKeyString(Integer(LParam))
		    Return HotKeyPressed(Integer(WParam), keystring)
		  End If
		End Function
	#tag EndEvent


	#tag Method, Flags = &h1
		Protected Shared Function ConstructKeyString(lParam as Integer) As String
		  #If TargetWin32 Then
		    Dim lo, high As Integer
		    lo = Bitwise.BitAnd(lParam, &hFFFF)
		    high = Bitwise.ShiftRight(lParam, 16)
		    
		    Dim ret As String
		    If Bitwise.BitAnd(lo, MOD_CONTROL) <> 0 Then
		      ret = ret + "Ctrl "
		    End
		    If Bitwise.BitAnd(lo, MOD_ALT) <> 0 Then
		      ret = ret + "Alt "
		    End
		    If Bitwise.BitAnd(lo, MOD_SHIFT) <> 0 Then
		      ret = ret + "Shift "
		    End
		    If Bitwise.BitAnd(lo, MOD_WIN) <> 0 Then
		      ret = ret + "Meta "
		    End
		    ret = ReplaceAll(ret, " ", "+")
		    
		    Dim scanCode As Integer = WinLib.User32.MapVirtualKey(high, 0)
		    scanCode = Bitwise.ShiftLeft(scanCode, 16)
		    Dim keyText As New MemoryBlock(32)
		    Dim keyTextLen As Integer
		    keyTextLen = WinLib.User32.GetKeyNameText(scanCode, keyText, keyText.Size)
		    Return ret + keyText.WString(0)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor()
		  // Calling the overridden superclass constructor.
		  // Constructor() -- From WMListener
		  Super.Constructor()
		  Me.AddMessageFilter(WM_HOTKEY)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Destructor()
		  For Each key As Integer In KeyIDs
		    Me.UnregisterKey(key)
		  Next
		  Super.Destructor
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RegisterKey(modifiers as Integer, virtualKey as Integer) As Integer
		  #If TargetWin32 Then
		    Dim id As Integer
		    id = WinLib.Kernel32.GlobalAddAtom("WinLibAtom" + Str(NextNum))
		    KeyIDs.Append(id)
		    
		    If WinLib.User32.RegisterHotKey(Me.ParentWindow, id, modifiers, virtualKey) Then
		      Return id
		    Else
		      Return -1
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UnregisterKey(id as Integer)
		  #If TargetWin32 Then
		    Call WinLib.User32.UnregisterHotkey(Me.ParentWindow, id)
		    Call WinLib.User32.GlobalDeleteAtom(id)
		    For i As Integer = UBound(KeyIDs) DownTo 0
		      If KeyIDs(i) = id Then
		        KeyIDs.Remove(i)
		      End If
		    Next
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function VirtualKey(Key As String) As Integer
		  #If TargetWin32 Then Return WinLib.User32.VkKeyScan(Asc(Key))
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event HotKeyPressed(Identifier As Integer, KeyString As String) As Boolean
	#tag EndHook


	#tag Property, Flags = &h1
		Protected KeyIDs() As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  Static i As Integer
			  i = i + 1
			  Return i
			End Get
		#tag EndGetter
		Private Shared NextNum As Integer
	#tag EndComputedProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
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
