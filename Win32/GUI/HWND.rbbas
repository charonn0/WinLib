#tag Class
Protected Class HWND
Implements Win32.Win32Object
	#tag CompatibilityFlags = TargetHasGUI
	#tag Method, Flags = &h0
		Sub Close()
		  If Not Win32.Libs.User32.CloseWindow(mHandle) Then
		    mLastError = Win32.LastError
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(HWND As Integer)
		  Me.mHandle = HWND
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetAncestor(Flags As Integer) As Win32.GUI.HWND
		  Dim h As Integer = Win32.Libs.User32.GetAncestor(Me.Handle, GA_ROOTOWNER)
		  mLastError = Win32.LastError
		  If h <> 0 Then Return New Win32.GUI.HWND(h)
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

	#tag Method, Flags = &h0
		Function Operator_Compare(OtherWindow As Win32.GUI.HWND) As Integer
		  #If TargetWin32 Then
		    Dim selfexists As Boolean = Win32.Libs.User32.IsWindow(Me.Handle)
		    If OtherWindow = Nil Then
		      If selfexists Then
		        Return 1 ' windowref exists and is being compared to Nil
		      Else
		        Return 0 ' windowref does not exist and is being compared to Nil
		      End If
		    ElseIf Win32.Libs.User32.IsWindow(OtherWindow.Handle) And selfexists Then
		      If OtherWindow.Handle <> Me.Handle Then
		        Return 1 ' both windowrefs exist but they do not refer to the same window
		      Else
		        Return 0 ' both windowrefs exist and they refer to the same window
		      End If
		    Else
		      If selfexists Then
		        Return 1 ' windowref exists and is not being compared to Nil, but the OtherWindow doesn't exist
		      Else
		        Return -1' windowref does not exist and is not being compared to Nil, but the OtherWindow doesn't exist either
		      End If
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Owner() As Win32.GUI.HWND
		  #If TargetWin32 Then
		    Dim h As Integer = Win32.Libs.User32.GetWindow(mHandle, GW_OWNER)
		    mLastError = Win32.LastError
		    Return New Win32.GUI.HWND(h)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Attributes( deprecated )  Sub Owner(Assigns NewOwner As Win32.GUI.HWND)
		  ' WARNING: This is not guaranteed to work, and MSDN explicitly warns against doing this.
		  
		  If Win32.Libs.User32.SetWindowLong(mHandle, GWL_HWNDPARENT, NewOwner.Handle) = 0 Then
		    mLastError = Win32.LastError
		  Else
		    mLastError = 0
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Parent() As Win32.GUI.HWND
		  #If TargetWin32 Then
		    Dim h As Integer = Win32.Libs.User32.GetParent(mHandle)
		    mLastError = Win32.LastError
		    Return New Win32.GUI.HWND(h)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Parent(Assigns NewParent As Win32.GUI.HWND)
		  If Win32.Libs.User32.SetParent(mHandle, NewParent.Handle) = 0 Then
		    mLastError = Win32.LastError
		  Else
		    mLastError = 0
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function SetPosition(Left As Integer, Top As Integer, Width As Integer, Height As Integer, Flags As Integer, InsertAfter As Win32.GUI.HWND = Nil) As Boolean
		  Dim hInsertAfter As Integer
		  If InsertAfter <> Nil Then hInsertAfter = InsertAfter.Handle
		  If Not Win32.Libs.User32.SetWindowPos(mHandle, hInsertAfter, Left, Top, Width, Height, Flags) Then
		    mLastError = Win32.LastError
		  Else
		    Return True
		  End If
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mHandle As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastError As Integer
	#tag EndProperty


	#tag Constant, Name = GA_PARENT, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = GA_ROOT, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = GA_ROOTOWNER, Type = Double, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = GWL_HWNDPARENT, Type = Double, Dynamic = False, Default = \"-8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = LWA_ALPHA, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Alpha"
			Group="Behavior"
			Type="Single"
		#tag EndViewProperty
		#tag ViewProperty
			Name="BorderSizeX"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="BorderSizeY"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Maximized"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Minimized"
			Group="Behavior"
			Type="Boolean"
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
			Name="Text"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TrueHeight"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TrueLeft"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TrueRight"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TrueTop"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TrueWidth"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
