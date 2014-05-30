#tag Class
Protected Class App
Inherits WinLib.ConsoleApp
	#tag Event
		Function CancelClose(CloseType As Integer) As Boolean
		  _Print("Quit? (y/N)")
		  If _Input() = "Y" Then
		    Return False
		  Else
		    Return True
		  End If
		End Function
	#tag EndEvent

	#tag Event
		Function EventLoop() As Integer
		  Print("Loop")
		End Function
	#tag EndEvent

	#tag Event
		Sub Startup(args() As String)
		  Print("Starting up")
		End Sub
	#tag EndEvent


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
