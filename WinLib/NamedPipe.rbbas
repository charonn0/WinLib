#tag Class
Protected Class NamedPipe
Inherits WinLib.IOStream
	#tag Method, Flags = &h0
		Sub Close()
		  PollTimer.Mode = Timer.ModeOff ' Turn off the poll timer
		  IsConnected = False ' Mark the stream as closed
		  Super.Close
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Connect()
		  If IsConnected Then Me.Close
		  IsConnected = False
		  If PipeName = "" Then
		    RaiseEvent Error(106) ' Throw an invalid state error
		  End If
		  
		  Dim hFile As Integer = Win32.Kernel32.CreateFile("\\.\pipe\" + PipeName, GENERIC_READ Or GENERIC_WRITE, 0, 0, OPEN_EXISTING, 0, 0)
		  If hFile > 0 Then
		    Me.mHandle = hFile
		    IsConnected = True
		    RaiseEvent Connected()
		    PollTimer.Mode = Timer.ModeMultiple
		  Else
		    RaiseEvent Error(103) ' Throw a name resolution error
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Attributes( Hidden )  Sub Constructor()
		  PollTimer = New Timer
		  AddHandler PollTimer.Action, AddressOf PollAction
		  PollTimer.Period = 50
		  Super.Constructor(0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Destructor()
		  If IsConnected Then
		    Me.Close
		  End If
		  RemoveHandler PollTimer.Action, AddressOf PollAction
		  PollTimer = Nil
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Listen(OpenMode As Integer, MaxInstances As Integer = PIPE_UNLIMITED_INSTANCES, OutBufferSize As Integer = 512, InBufferSize As Integer = 512, DefaultTimeout As Integer = - 1, PipeMode As Integer = 0)
		  Dim err As Integer
		  Dim hFile As Integer = Win32.Kernel32.CreateNamedPipe("\\.\pipe\" + PipeName, OpenMode Or FILE_FLAG_OVERLAPPED, PipeMode, _
		  MaxInstances, OutBufferSize, InBufferSize, DefaultTimeout, Nil)
		  err = WinLib.GetLastError()
		  If err = 0 Then
		    Dim over As OVERLAPPED
		    over.Internal = 0
		    over.InternalHigh = 0
		    over.Offset = 0
		    over.hEvent = 0
		    If Win32.Kernel32.ConnectNamedPipe(hFile, over) Then
		      Me.mHandle = hFile
		    Else
		      err = WinLib.GetLastError
		      Dim error As New IOException
		      error.ErrorNumber = err
		      error.Message = WinLib.FormatError(err)
		      Raise error
		    End If
		  Else
		    Dim error As New IOException
		    error.ErrorNumber = err
		    error.Message = WinLib.FormatError(err)
		    Raise error
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PollAction(Sender As Timer)
		  #pragma Unused Sender
		  Dim s As String
		  
		  If Me.Length > 0 Then
		    s = Super.Read(Me.Length)
		    If s.LenB > 0 Then
		      mBuffer = mBuffer + s
		      RaiseEvent DataAvailable()
		    End If
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Read(Bytes As Integer) As String
		  If Not IsConnected Then
		    RaiseEvent Error(106)
		    Return ""
		  End If
		  
		  PollTimer.Mode = Timer.ModeOff
		  Dim s As String = ""
		  If mBuffer.LenB > 0 Then
		    If Bytes < mBuffer.LenB Then
		      s = LeftB(mBuffer, Bytes)
		      mBuffer = MidB(mBuffer, Bytes + 1)
		    Else
		      s = mBuffer
		      mBuffer = ""
		    End If
		  End If
		  PollTimer.Mode = Timer.ModeMultiple
		  
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReadAll() As String
		  If Not IsConnected Then
		    RaiseEvent Error(106)
		    Return ""
		  End If
		  
		  PollTimer.Mode = Timer.ModeOff
		  Dim s As String = mBuffer
		  mBuffer = ""
		  PollTimer.Mode = Timer.ModeMultiple
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Write(Data As String)
		  If Not IsConnected Then
		    RaiseEvent Error(106)
		  End If
		  
		  Super.Write(Data)
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Connected()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event DataAvailable()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Error(ErrorNo As Integer)
	#tag EndHook


	#tag Note, Name = About this class
		Implements a socket-like interface for a Win32 Named Pipe. Based on Wayne Golding's code
		from here: https://forum.xojo.com/4376-pipes/
		
	#tag EndNote


	#tag Property, Flags = &h0
		IsConnected As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mBuffer
			  
			  
			End Get
		#tag EndGetter
		LookAhead As String
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mBuffer As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PipeName As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private PollTimer As Timer
	#tag EndProperty


End Class
#tag EndClass
