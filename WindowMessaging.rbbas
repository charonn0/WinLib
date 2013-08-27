#tag Module
Protected Module WindowMessaging
	#tag Method, Flags = &h1
		Protected Sub AddMessageHandler(HWND As Integer, MessageID As Integer, Handler As WindowMessageHandler)
		  Dim msg As New WinLib.Classes.WindowMessenger(HWND, MessageID)
		  AddHandler msg.WindowMessage, AddressOf WMHandler
		  Dim win As New Dictionary
		  win.Value("Message") = MessageID
		  win.Value("HWND") = HWND
		  win.Value("Handler") = Handler
		  HWNDS.Value(HWND:MessageID) = win
		End Sub
	#tag EndMethod

	#tag DelegateDeclaration, Flags = &h0
		Delegate Function WindowMessageHandler(HWND as Integer, msg as Integer, wParam as Ptr, lParam as Ptr) As Boolean
	#tag EndDelegateDeclaration

	#tag Method, Flags = &h21
		Private Function WMHandler(Sender As WinLib.Classes.WindowMessenger, HWND As Integer, Message As Integer, WParam As Ptr, LParam As Ptr) As Boolean
		  #pragma Unused Sender
		  If HWNDS.HasKey(HWND:Message) Then
		    Dim win As Dictionary = HWNDS.Value(HWND:Message)
		    Return WindowMessageHandler(win.Value("Handler")).Invoke(HWND, Message, WParam, LParam)
		  End If
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  If mHWNDS = Nil Then mHWNDS = New Dictionary
			  return mHWNDS
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mHWNDS = value
			End Set
		#tag EndSetter
		Protected HWNDS As Dictionary
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mHWNDS As Dictionary
	#tag EndProperty


End Module
#tag EndModule
