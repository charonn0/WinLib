#tag Class
Protected Class ConsoleApp
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  Interrrupt = New Semaphore
		  mApp = New WeakRef(Me)
		  Call Win32.Kernel32.SetConsoleCtrlHandler(AddressOf CancelQuit, True)
		  RaiseEvent Startup(args)
		  
		  Do Until RaiseEvent EventLoop() <> 0
		    While Not Interrrupt.TrySignal
		      App.YieldToNextThread
		    Wend
		    DoEvents
		    Interrrupt.Release
		  Loop
		End Function
	#tag EndEvent

	#tag Event
		Function UnhandledException(error As RuntimeException) As Boolean
		  Dim s() As String = CleanStack(error)
		  Return RaiseEvent UnhandledException(error, s)
		End Function
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Function CancelClose(CloseType As Integer) As Boolean
		  Return RaiseEvent CancelClose(CloseType)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function CancelQuit(ControlType As Integer) As Boolean
		  #pragma X86CallingConvention StdCall
		  While Not Interrrupt.TrySignal
		    Continue
		  Wend
		  Dim ret As Boolean
		  Try
		    If mApp.Value <> Nil And mApp.Value Is App Then 
		      ret = ConsoleApp(mApp.Value).CancelClose(ControlType)
		    End If
		  Finally
		    Interrrupt.Release
		  End Try
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function CleanMangledFunction(item as string) As string
		  'This method was originally written by SirG3 <TheSirG3@gmail.com>; http://fireyesoftware.com/developer/stackcleaner/
		  #If rbVersion >= 2005.5
		    Static blacklist() As String
		    If UBound(blacklist) <= -1 Then
		      blacklist = Array("REALbasic._RuntimeRegisterAppObject%%o<Application>", _
		      "_NewAppInstance", "_Main", _
		      "% main", _
		      "REALbasic._RuntimeRun" _
		      )
		    End If
		    
		    If blacklist.indexOf(item) >= 0 Then Return ""
		    
		    Dim parts() As String = item.Split("%")
		    If ubound(parts) < 2 Then Return ""
		    
		    Dim func As String = parts(0)
		    Dim returnType As String
		    If parts(1) <> "" Then returnType = parseParams(parts(1)).pop
		    Dim args() As String = parseParams(parts(2))
		    
		    If func.InStr("$") > 0 Then
		      args(0) = "Extends " + args(0)
		      func = func.ReplaceAll("$", "")
		      
		    Elseif ubound(args) >= 0 And func.NthField(".", 1) = args(0) Then
		      args.remove(0)
		      
		    End If
		    
		    If func.InStr("=") > 0 Then
		      Dim index As Integer = ubound(args)
		      
		      args(index) = "Assigns " + args(index)
		      func = func.ReplaceAll("=", "")
		    End If
		    
		    If func.InStr("*") > 0 Then
		      Dim index As Integer = ubound(args)
		      
		      args(index) = "ParamArray " + args(index)
		      func = func.ReplaceAll("*", "")
		    End If
		    
		    Dim sig As String
		    If func.InStr("#") > 0 Then
		      If returnType = "" Then
		        sig = "Event Sub"
		      Else
		        sig = "Event Function"
		      End If
		      func = func.ReplaceAll("#", "")
		      
		    Elseif func.InStr("!") > 0 Then
		      If returnType = "" Then
		        sig = "Shared Sub"
		      Else
		        sig = "Shared Function"
		      End If
		      func = func.ReplaceAll("!", "")
		      
		    Elseif returnType = "" Then
		      sig = "Sub"
		      
		    Else
		      sig = "Function"
		      
		    End If
		    
		    If ubound(args) >= 0 Then
		      sig = sig + " " + func + "(" + Join(args, ", ") + ")"
		      
		    Else
		      sig = sig + " " + func + "()"
		      
		    End If
		    
		    
		    If returnType <> "" Then
		      sig = sig + " As " + returnType
		    End If
		    
		    Return sig
		    
		  #Else
		    Return ""
		    
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function CleanStack(error as RuntimeException) As string()
		  'This method was written by SirG3 <TheSirG3@gmail.com>; http://fireyesoftware.com/developer/stackcleaner/
		  Dim result() As String
		  
		  #If rbVersion >= 2005.5
		    For Each s As String In error.stack
		      Dim tmp As String = cleanMangledFunction(s)
		      If tmp <> "" Then result.append(tmp)
		      
		    Next
		    
		  #Else
		    // leave result empty
		    
		  #EndIf
		  
		  // we must return some sort of array (even if empty), otherwise REALbasic will return a "nil" array, causing a crash when trying to use the array.
		  // see http://realsoftware.com/feedback/viewreport.php?reportid=urvbevct
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Clear() As Boolean
		  //Clears the screen and moves the cursor to the top left corner (0,0)
		  Return WinLib.Console.GetCurrentBuffer.Clear
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetChar(x As Integer, y As Integer) As String
		  //Returns the character from the specified character cell in the screen buffer.
		  Return WinLib.Console.GetCurrentBuffer.GetChar(x, y)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Input() As String
		  If Instream <> Nil Then
		    Dim tis As TextInputStream = TextInputStream(Instream)
		    Return tis.ReadLine
		  Else
		    Return REALbasic.Input()
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function ParseParams(input as string) As string()
		  'This method was written by SirG3 <TheSirG3@gmail.com>; http://fireyesoftware.com/developer/stackcleaner/
		  
		  Const kParamMode = 0
		  Const kObjectMode = 1
		  Const kIntMode = 2
		  Const kUIntMode = 3
		  Const kFloatingMode = 4
		  Const kArrayMode = 5
		  
		  Dim chars() As String = Input.Split("")
		  Dim funcTypes(), buffer As String
		  Dim arrays(), arrayDims(), byrefs(), mode As Integer
		  
		  For Each char As String In chars
		    Select Case mode
		    Case kParamMode
		      Select Case char
		      Case "v"
		        funcTypes.append( "Variant" )
		        
		      Case "i"
		        mode = kIntMode
		        
		      Case "u"
		        mode = kUIntMode
		        
		      Case "o"
		        mode = kObjectMode
		        
		      Case "b"
		        funcTypes.append("Boolean")
		        
		      Case "s"
		        funcTypes.append("String")
		        
		      Case "f"
		        mode = kFloatingMode
		        
		      Case "c"
		        funcTypes.append("Color")
		        
		      Case "A"
		        mode = kArrayMode
		        
		      Case "&"
		        byrefs.append(ubound(funcTypes) + 1)
		        
		      End Select
		      
		      
		    Case kObjectMode
		      If char = "<" Then Continue
		      
		      If char = ">" Then
		        funcTypes.append(buffer)
		        buffer = ""
		        mode = kParamMode
		        
		        Continue
		      End If
		      
		      buffer = buffer + char
		      
		      
		    Case kIntMode, kUIntMode
		      Dim intType As String = "Int"
		      
		      If mode = kUIntMode Then intType = "UInt"
		      
		      funcTypes.append(intType + Str(Val(char) * 8))
		      mode = kParamMode
		      
		      
		    Case kFloatingMode
		      If char = "4" Then
		        funcTypes.append("Single")
		        
		      Elseif char = "8" Then
		        funcTypes.append("Double")
		        
		      End If
		      
		      mode = kParamMode
		      
		    Case kArrayMode
		      arrays.append(ubound(funcTypes) + 1)
		      arrayDims.append(Val(char))
		      mode = kParamMode
		      
		    End Select
		  Next
		  
		  For i As Integer = 0 To ubound(arrays)
		    Dim arr As Integer = arrays(i)
		    Dim s As String = funcTypes(arr) + "("
		    
		    For i2 As Integer = 2 To arrayDims(i)
		      s = s + ","
		    Next
		    
		    funcTypes(arr) = s + ")"
		  Next
		  
		  For Each b As Integer In byrefs
		    funcTypes(b) = "ByRef " + funcTypes(b)
		  Next
		  
		  Return funcTypes
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Print(Line As String)
		  StdOut.Write(Line + EndOfLine)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PrintError(Line As String)
		  StdErr.Write(Line + EndOfLine)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetChar(x As Integer, y As Integer, char As String)
		  //Writes the character specified to the character cell specified in the screen buffer
		  
		  WinLib.Console.GetCurrentBuffer.SetChar(x, y, char)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StdErr() As Writeable
		  If ErrStream <> Nil Then Return ErrStream Else Return REALbasic.stderr
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StdErr(Assigns Err As Writeable)
		  Select Case StdErr
		  Case IsA StandardOutputStream
		    ' meh
		  Case IsA TCPSocket
		    TCPSocket(StdErr).Close
		  Case IsA SSLSocket
		    SSLSocket(StdErr).Close
		  Case IsA BinaryStream
		    BinaryStream(StdErr).Close
		  Case IsA TextOutputStream
		    TextOutputStream(StdErr).Close
		  Else
		    Raise New TypeMismatchException
		  End Select
		  ErrStream = Err
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StdIn() As Readable
		  If Instream <> Nil Then Return Instream Else Return REALbasic.stdin
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StdIn(Assigns NewIn As Readable)
		  Select Case StdIn
		  Case IsA StandardInputStream
		    ' meh
		  Case IsA TCPSocket
		    TCPSocket(StdIn).Close
		  Case IsA SSLSocket
		    SSLSocket(StdIn).Close
		  Case IsA BinaryStream
		    BinaryStream(StdIn).Close
		  Case IsA TextInputStream
		    TextInputStream(StdIn).Close
		  Else
		    Raise New TypeMismatchException
		  End Select
		  Instream = NewIn
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StdOut() As Writeable
		  If OutStream <> Nil Then Return OutStream Else Return REALbasic.stdout
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StdOut(Assigns Out As Writeable)
		  Select Case StdOut
		  Case IsA StandardOutputStream
		    ' meh
		  Case IsA TCPSocket
		    TCPSocket(StdOut).Close
		  Case IsA SSLSocket
		    SSLSocket(StdOut).Close
		  Case IsA BinaryStream
		    BinaryStream(StdOut).Close
		  Case IsA TextOutputStream
		    TextOutputStream(StdOut).Close
		  Else
		    Raise New TypeMismatchException
		  End Select
		  OutStream = Out
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function WorkingDirectory() As FolderItem
		  Return SpecialFolder.CurrentWorkingDirectory
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WorkingDirectory(Assigns NewCWD As FolderItem)
		  #If TargetWin32 Then
		    Declare Function SetCurrentDirectoryW Lib "Kernel32" (Buffer As WString) As Boolean
		    Declare Function GetLastError Lib "Kernel32" () As Integer
		    Dim path As String = NewCWD.AbsolutePath
		    If Not SetCurrentDirectoryW(path) Then
		      Dim e As Integer = GetLastError
		      Dim err As New IOException
		      'err.Message = CurrentMethodName + ": " + FormatError(e)
		      err.ErrorNumber = e
		      Raise err
		    End If
		    
		  #ElseIf DebugBuild Then
		    Raise New PlatformNotSupportedException
		    
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function _Input() As String
		  Return REALbasic.Input()
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub _Print(Line As String)
		  REALbasic.Print(Line)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub _PrintError(Line As String)
		  REALbasic.StdErr.Write(Line + EndOfLine)
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event CancelClose(CloseType As Integer) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event EventLoop() As Integer
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Startup(args() As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event UnhandledException(Err As RuntimeException, CleanedStackTrace() As String) As Boolean
	#tag EndHook


	#tag Property, Flags = &h21
		Private ErrStream As Writeable
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Instream As Readable
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared Interrrupt As Semaphore
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mApp As WeakRef
	#tag EndProperty

	#tag Property, Flags = &h21
		Private OutStream As Writeable
	#tag EndProperty


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
