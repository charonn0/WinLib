#tag Class
Protected Class App
Inherits WinLib.ConsoleApp
	#tag Event
		Function CancelClose(CloseType As Integer) As Boolean
		  Select Case CloseType
		  Case CTRL_C_EVENT, CTRL_BREAK_EVENT
		    _Print("Quit? (y/N)")
		    If _Input() = "Y" Then
		      Return False
		    Else
		      Return True
		    End If
		  End Select
		  
		End Function
	#tag EndEvent

	#tag Event
		Function EventLoop() As Integer
		  'Dim b As New WinLib.ScreenBuffer
		  'Static j As Integer
		  'b.SetChar(0, 5, Format(j, "0"))
		  'ActiveScreenBuffer = b
		End Function
	#tag EndEvent

	#tag Event
		Sub Startup(args() As String)
		  Print("Starting up")
		  
		  WinLib.ScreenBuffer.CurrentBuffer.StdOutput.Write("Hello, world!")
		End Sub
	#tag EndEvent


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
