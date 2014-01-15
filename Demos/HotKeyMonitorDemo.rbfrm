#tag Window
Begin Window HotKeyMonitorDemo
   BackColor       =   &hFFFFFF
   Backdrop        =   ""
   CloseButton     =   True
   Composite       =   False
   Frame           =   3
   FullScreen      =   False
   HasBackColor    =   False
   Height          =   9.0e+1
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
   Resizeable      =   False
   Title           =   "Global Hotkey Demo"
   Visible         =   True
   Width           =   1.82e+2
   Begin Label Label1
      AutoDeactivate  =   True
      Bold            =   False
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   56
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   7
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Multiline       =   True
      Scope           =   0
      Selectable      =   False
      TabIndex        =   1
      TabPanelIndex   =   0
      Text            =   "Press Ctrl+Alt+A\r\nWorks even if this window is minimized/invisible."
      TextAlign       =   0
      TextColor       =   "&c00000000"
      TextFont        =   "System"
      TextSize        =   0.0
      TextUnit        =   0
      Top             =   14
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   175
      Begin HotKeyMonitor HotKeyMonitor1
         Height          =   32
         Index           =   -2147483648
         InitialParent   =   "Label1"
         Left            =   7.8e+1
         LockedInPosition=   False
         Scope           =   0
         TabPanelIndex   =   0
         Top             =   2.6e+1
         Width           =   32
      End
   End
End
#tag EndWindow

#tag WindowCode
	#tag Event
		Function CancelClose(appQuitting as Boolean) As Boolean
		  #pragma Unused appQuitting
		  HotKeyMonitor1.UnregisterKey(kHandle)
		End Function
	#tag EndEvent

	#tag Event
		Sub Open()
		  kHandle = HotKeyMonitor1.RegisterKey("a", MOD_CONTROL, MOD_ALT)
		End Sub
	#tag EndEvent


	#tag Property, Flags = &h21
		Private kHandle As Integer
	#tag EndProperty


#tag EndWindowCode

#tag Events HotKeyMonitor1
	#tag Event
		Function HotKeyPressed(Identifier As Integer, KeyString As String) As Boolean
		  MsgBox("Hotkey detected: " + KeyString + " (" + Str(Identifier) + ")")
		  Return True
		End Function
	#tag EndEvent
#tag EndEvents
