#tag Class
Class FolderWatcher
Inherits WinLib.Waiter
	#tag Property, Flags = &h1
		Protected ChangeHandle As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTargetFolder As FolderItem
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mTargetFolder
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mTargetFolder = value
			  If mTargetFolder <> Nil Then
			    Dim filters As Integer = FILE_NOTIFY_CHANGE_FILE_NAME Or FILE_NOTIFY_CHANGE_DIR_NAME
			    ChangeHandle = Win32.Kernel32.FindFirstChangeNotification(mTargetFolder.AbsolutePath, False, filters)
			    Super.Close
			    Call Me.WaitOnce(ChangeHandle)
			  End If
			End Set
		#tag EndSetter
		TargetFolder As FolderItem
	#tag EndComputedProperty


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
			Name="Timeout"
			Group="Behavior"
			InitialValue="INFINITE"
			Type="Integer"
			InheritedFrom="WinLib.Waiter"
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
