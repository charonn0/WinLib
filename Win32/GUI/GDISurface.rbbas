#tag Class
Protected Class GDISurface
Implements Win32.Win32Object
	#tag CompatibilityFlags = TargetHasGUI
	#tag Method, Flags = &h0
		Sub Close()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(HDC As Integer)
		  Me.mHandle = HDC
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function CreateBitmap(Width As Integer, Height As Integer, Depth As Integer) As Win32.GUI.GDISurface
		  Dim hBitmap As Integer = Win32.Libs.GDI32.CreateBitmap(Width, Height, 1, Depth, Nil)
		  If hBitmap <> 0 Then
		    Return New Win32.GUI.GDISurface(hBitmap)
		  Else
		    Raise Win32Exception(Win32.LastError)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Handle() As Integer
		  return mHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastError() As Integer
		  Return mLastError
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mHandle As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastError As Integer
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
