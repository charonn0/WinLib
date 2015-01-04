#tag Class
Protected Class FolderWatcher
Inherits Win32.Utils.Waiter
	#tag Method, Flags = &h0
		Function Wait() As Boolean
		  Return Super.WaitOnce(ChangeHandle)
		End Function
	#tag EndMethod


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
			    ChangeHandle = Win32.Libs.Kernel32.FindFirstChangeNotification(mTargetFolder.AbsolutePath, False, filters)
			  End If
			End Set
		#tag EndSetter
		TargetFolder As FolderItem
	#tag EndComputedProperty


	#tag Constant, Name = FILE_NOTIFY_CHANGE_ATTRIBUTES, Type = Double, Dynamic = False, Default = \"&h00000004", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FILE_NOTIFY_CHANGE_DIR_NAME, Type = Double, Dynamic = False, Default = \"&h00000002\r", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FILE_NOTIFY_CHANGE_FILE_NAME, Type = Double, Dynamic = False, Default = \"&h00000001\r", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FILE_NOTIFY_CHANGE_LAST_WRITE, Type = Double, Dynamic = False, Default = \"&h00000010", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FILE_NOTIFY_CHANGE_SECURITY, Type = Double, Dynamic = False, Default = \"&h00000100\r", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FILE_NOTIFY_CHANGE_SIZE, Type = Double, Dynamic = False, Default = \"&h00000008\r", Scope = Public
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
			Name="Timeout"
			Group="Behavior"
			InitialValue="INFINITE"
			Type="Integer"
			InheritedFrom="Win32.Utils.Waiter"
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
