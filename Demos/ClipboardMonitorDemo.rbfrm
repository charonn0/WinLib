#tag Window
Begin Window ClipboardMonitorDemo
   BackColor       =   &hFFFFFF
   Backdrop        =   ""
   CloseButton     =   True
   Composite       =   False
   Frame           =   3
   FullScreen      =   False
   HasBackColor    =   False
   Height          =   2.56e+2
   ImplicitInstance=   True
   LiveResize      =   True
   MacProcID       =   0
   MaxHeight       =   32000
   MaximizeButton  =   False
   MaxWidth        =   32000
   MenuBar         =   ""
   MenuBarVisible  =   True
   MinHeight       =   64
   MinimizeButton  =   True
   MinWidth        =   64
   Placement       =   0
   Resizeable      =   True
   Title           =   "Clipboard Monitor"
   Visible         =   True
   Width           =   5.17e+2
   Begin Canvas Canvas1
      AcceptFocus     =   ""
      AcceptTabs      =   ""
      AutoDeactivate  =   True
      Backdrop        =   ""
      DoubleBuffer    =   False
      Enabled         =   True
      EraseBackground =   True
      Height          =   256
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Left            =   0
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Scope           =   0
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Top             =   0
      UseFocusRing    =   True
      Visible         =   True
      Width           =   256
   End
   Begin TextArea TextArea1
      AcceptTabs      =   ""
      Alignment       =   0
      AutoDeactivate  =   True
      AutomaticallyCheckSpelling=   True
      BackColor       =   &hFFFFFF
      Bold            =   ""
      Border          =   True
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Format          =   ""
      Height          =   256
      HelpTag         =   ""
      HideSelection   =   True
      Index           =   -2147483648
      Italic          =   ""
      Left            =   261
      LimitText       =   0
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Mask            =   ""
      Multiline       =   True
      ReadOnly        =   ""
      Scope           =   0
      ScrollbarHorizontal=   ""
      ScrollbarVertical=   True
      Styled          =   True
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextColor       =   &h000000
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   0
      Underline       =   ""
      UseFocusRing    =   True
      Visible         =   True
      Width           =   256
   End
   Begin ClipboardMonitor ClipboardMonitor1
      Height          =   32
      Index           =   -2147483648
      Left            =   563
      LockedInPosition=   False
      Scope           =   0
      TabPanelIndex   =   0
      Top             =   0
      Width           =   32
   End
End
#tag EndWindow

#tag WindowCode
	#tag Event
		Function CancelClose(appQuitting as Boolean) As Boolean
		  #pragma Unused appQuitting
		  ClipboardMonitor1.Close
		End Function
	#tag EndEvent

	#tag Event
		Sub Open()
		  CheckClipboard()
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub CheckClipboard()
		  ClipPic = Nil
		  TextArea1.Text = ""
		  Dim cp As New WinLib.Clip_Board(Self.Handle)
		  If cp.HasFormat(CF_BITMAP) Then
		    Dim hMem As Ptr = cp.Data(CF_BITMAP)
		    ClipPic = Win32.HBITMAP(Integer(hMem))
		  End If
		  If cp.HasFormat(CF_TEXT) Then
		    TextArea1.Text = cp.Data(CF_TEXT)
		  End If
		  Canvas1.Invalidate(True)
		  
		Exception
		  Return
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private ClipPic As Picture
	#tag EndProperty


#tag EndWindowCode

#tag Events Canvas1
	#tag Event
		Sub Paint(g As Graphics)
		  If ClipPic <> Nil Then
		    g.DrawPicture(ClipPic, 0, 0)
		  End If
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events ClipboardMonitor1
	#tag Event
		Sub ClipboardChanged()
		  CheckClipboard()
		End Sub
	#tag EndEvent
#tag EndEvents
