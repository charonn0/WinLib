#tag Window
Begin Window WebCamDemo
   BackColor       =   16777215
   Backdrop        =   ""
   CloseButton     =   True
   Composite       =   False
   Frame           =   0
   FullScreen      =   False
   HasBackColor    =   False
   Height          =   521
   ImplicitInstance=   False
   LiveResize      =   True
   MacProcID       =   0
   MaxHeight       =   32000
   MaximizeButton  =   False
   MaxWidth        =   32000
   MenuBar         =   2105012223
   MenuBarVisible  =   True
   MinHeight       =   64
   MinimizeButton  =   True
   MinWidth        =   64
   Placement       =   0
   Resizeable      =   True
   Title           =   "WebCam Demo"
   Visible         =   True
   Width           =   744
   Begin BevelButton PushButton3
      AcceptFocus     =   ""
      AutoDeactivate  =   True
      BackColor       =   0
      Bevel           =   1
      Bold            =   ""
      ButtonType      =   1
      Caption         =   "Preview"
      CaptionAlign    =   3
      CaptionDelta    =   0
      CaptionPlacement=   0
      Enabled         =   False
      HasBackColor    =   ""
      HasMenu         =   0
      Height          =   22
      HelpTag         =   ""
      Icon            =   ""
      IconAlign       =   0
      IconDX          =   0
      IconDY          =   0
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   7
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   False
      MenuValue       =   0
      Scope           =   0
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      TextColor       =   0
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   498
      Underline       =   ""
      Value           =   ""
      Visible         =   True
      Width           =   80
   End
   Begin Canvas Canvas1
      AcceptFocus     =   ""
      AcceptTabs      =   ""
      AutoDeactivate  =   True
      Backdrop        =   ""
      DoubleBuffer    =   True
      Enabled         =   True
      EraseBackground =   True
      Height          =   487
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Left            =   0
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Scope           =   0
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Top             =   0
      UseFocusRing    =   True
      Visible         =   True
      Width           =   744
   End
   Begin CheckBox CheckBox1
      AutoDeactivate  =   True
      Bold            =   ""
      Caption         =   "Scale"
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   False
      Height          =   20
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   638
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      Scope           =   0
      State           =   1
      TabIndex        =   3
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   498
      Underline       =   ""
      Value           =   True
      Visible         =   True
      Width           =   100
   End
   Begin ComboBox ComboBox1
      AutoComplete    =   False
      AutoDeactivate  =   True
      Bold            =   ""
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   ""
      Index           =   -2147483648
      InitialValue    =   ""
      Italic          =   ""
      Left            =   99
      ListIndex       =   0
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   False
      Scope           =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   498
      Underline       =   ""
      UseFocusRing    =   True
      Visible         =   True
      Width           =   361
   End
End
#tag EndWindow

#tag WindowCode
	#tag Event
		Sub Open()
		  Device = WinLib.ImageDevice.GetDeviceByIndex(0)
		End Sub
	#tag EndEvent

	#tag Event
		Sub Resizing()
		  Call Win32.User32.MoveWindow(Device.Handle, Canvas1.Left, Canvas1.Top, Canvas1.Width, Canvas1.Height, False)
		  
		End Sub
	#tag EndEvent


	#tag Property, Flags = &h1
		Protected Device As WinLib.ImageDevice
	#tag EndProperty


#tag EndWindowCode

#tag Events PushButton3
	#tag Event
		Sub Action()
		  ComboBox1.Enabled = Not Me.Value
		  CheckBox1.Enabled = Me.Value
		  If Me.Value Then
		    Device.EmbedPreviewWithin(Canvas1)
		    Device.ScalePreview = True
		    Device.PreviewRate = 10
		    Device.StartPreview
		  Else
		    Device.StopPreview
		    Device.Close
		  End If
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events Canvas1
	#tag Event
		Sub Paint(g As Graphics)
		  Dim d As WinLib.ImageDevice = ComboBox1.RowTag(ComboBox1.ListIndex)
		  Dim s As String
		  If d <> Nil And Device.Handle <= 0 Then
		    ' dev selected but not connected
		    s = "Click 'Preview' to activate " + d.Name
		  ElseIf Device.Handle > 0 Then
		    ' selected and connected
		    s = ""
		  Else
		    s = "No imaging device selected."
		  End If
		  
		  g.ForeColor = &cC0C0C000
		  g.FillRect(0, 0, g.Width, g.Height)
		  g.ForeColor = &c00000000
		  g.TextSize = 15
		  Dim w, h As Integer
		  w = g.StringWidth(s)
		  h = g.StringHeight(s, w)
		  w = (g.Width - w) / 2
		  h = (g.Height - h) / 2
		  g.DrawString(s, w, h)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events CheckBox1
	#tag Event
		Sub Action()
		  Device.ScalePreview = Me.Value
		  Canvas1.Invalidate(True)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events ComboBox1
	#tag Event
		Sub Open()
		  Me.AddRow("Select image capture device")
		  Me.ListIndex = 0
		  Dim c As Integer = WinLib.ImageDevice.DeviceCount
		  If c <= 0 Then Return
		  For i As Integer = 0 To c -1
		    Dim d As WinLib.ImageDevice = WinLib.ImageDevice.GetDeviceByIndex(i)
		    Me.AddRow(d.Name)
		    Me.RowTag(i + 1) = d
		  Next
		  
		End Sub
	#tag EndEvent
	#tag Event
		Sub Change()
		  PushButton3.Enabled = Me.RowTag(Me.ListIndex) <> Nil And Me.RowTag(Me.ListIndex) IsA WinLib.ImageDevice
		  Canvas1.Invalidate(False)
		End Sub
	#tag EndEvent
#tag EndEvents
