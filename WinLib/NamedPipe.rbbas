#tag Class
Protected Class NamedPipe
Inherits WinLib.IOStream
	#tag Method, Flags = &h0
		Sub Close()
		  PollTimer.Mode = Timer.ModeOff ' Turn off the poll timer
		  mIsConnected = False ' Mark the stream as closed
		  Super.Close
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Connect()
		  If IsConnected Then Me.Close
		  mIsConnected = False
		  If PipeName = "" Then
		    RaiseEvent Error(106) ' Throw an invalid state error
		    Return
		  End If
		  #If TargetWin32 Then
		    Dim hFile As Integer = Win32.Kernel32.CreateFile("\\.\pipe\" + PipeName, GENERIC_READ Or GENERIC_WRITE, 0, 0, OPEN_EXISTING, 0, 0)
		    If hFile > 0 Then
		      Me.mHandle = hFile
		      mIsConnected = True
		      RaiseEvent Connected()
		      PollTimer.Mode = Timer.ModeMultiple
		    Else
		      RaiseEvent Error(103) ' Throw a name resolution error
		    End If
		  #else
		    RaiseEvent Error(100) ' open driver error
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Handle As Integer = 0)
		  PollTimer = New Timer
		  AddHandler PollTimer.Action, WeakAddressOf PollAction
		  PollTimer.Period = 50
		  Super.Constructor(Handle)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Destructor()
		  PollTimer = Nil
		  Super.Destructor
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsConnected() As Boolean
		  Return mIsConnected
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsListening() As Boolean
		  Return mIsListening
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Listen(OpenMode As Integer, MaxInstances As Integer = PIPE_UNLIMITED_INSTANCES, OutBufferSize As Integer = 512, InBufferSize As Integer = 512, DefaultTimeout As Integer = - 1, PipeMode As Integer = 0)
		  ' This method creates a NAMED PIPE SERVER and listens for incoming connections. This is a blocking function;
		  ' Listen will not return until the first client connects, and your app will stop responding until then.
		  ' 
		  
		  Dim err As Integer
		  Dim hFile As Integer = Win32.Kernel32.CreateNamedPipe("\\.\pipe\" + PipeName, OpenMode Or FILE_FLAG_OVERLAPPED, PipeMode, _
		  MaxInstances, OutBufferSize, InBufferSize, DefaultTimeout, Nil)
		  err = GetLastError()
		  If err = 0 Then
		    Dim over As OVERLAPPED
		    over.Internal = 0
		    over.InternalHigh = 0
		    over.Offset = 0
		    over.hEvent = 0
		    If Win32.Kernel32.ConnectNamedPipe(hFile, over) Then
		      Me.mHandle = hFile
		    Else
		      err = GetLastError
		      Dim error As New IOException
		      error.ErrorNumber = err
		      error.Message = FormatError(err)
		      Raise error
		    End If
		  Else
		    Dim error As New IOException
		    error.ErrorNumber = err
		    error.Message = FormatError(err)
		    Raise error
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LookAhead() As String
		  Return mBuffer
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Poll()
		  If Not IsConnected Or PollTimer = Nil Then
		    RaiseEvent Error(106) ' invalid state
		    Return
		  End If
		  PollTimer.Mode = Timer.ModeMultiple
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
		Sub Purge()
		  mBuffer = ""
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
		  Me.Flush
		  RaiseEvent SendComplete()
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

	#tag Hook, Flags = &h0
		Event SendComplete()
	#tag EndHook


	#tag Note, Name = About this class
		Implements a socket-like interface for a Win32 Named Pipe. Based on Wayne Golding's code
		from here: https://forum.xojo.com/4376-pipes/
	#tag EndNote


	#tag Property, Flags = &h21
		Private mBuffer As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mIsConnected As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mIsListening As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPipeName As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mPipeName
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Me.Close
			  mPipeName = value
			End Set
		#tag EndSetter
		PipeName As String
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private PollTimer As Timer
	#tag EndProperty


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
			Name="IsConnected"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Length"
			Group="Behavior"
			Type="Integer"
			InheritedFrom="WinLib.IOStream"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LookAhead"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="PipeName"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Position"
			Group="Behavior"
			Type="Integer"
			InheritedFrom="WinLib.IOStream"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
