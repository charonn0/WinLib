#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Open()
		  'Dim g As FolderItem = GetSaveFolderItem("", "")
		  'Dim f As New WinLib.IOStream(BinaryStream.Create(g))
		  ''WinLib.IOStream.Open(g, False)'.AbsolutePath, GENERIC_WRITE, 0, OPEN_ALWAYS, 0)
		  'f.Write("Hello, world!")
		  'f.Close
		  Dim io As WinLib.FileObject = WinLib.IOStream.Create(SpecialFolder.Desktop.Child("fd_test"), True)
		  Dim i As Integer = io.Descriptor
		  Break
		End Sub
	#tag EndEvent


	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
