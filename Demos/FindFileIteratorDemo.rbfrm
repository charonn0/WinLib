#tag Window
Begin Window FindFileIteratorDemo
   BackColor       =   &hFFFFFF
   Backdrop        =   ""
   CloseButton     =   True
   Composite       =   False
   Frame           =   3
   FullScreen      =   False
   HasBackColor    =   False
   Height          =   4.0e+2
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
   Title           =   "File finder demo"
   Visible         =   True
   Width           =   2.9e+2
   Begin TextField TextField1
      AcceptTabs      =   ""
      Alignment       =   0
      AutoDeactivate  =   True
      AutomaticallyCheckSpelling=   False
      BackColor       =   &hFFFFFF
      Bold            =   ""
      Border          =   True
      CueText         =   ""
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Format          =   ""
      Height          =   22
      HelpTag         =   ""
      Index           =   -2147483648
      Italic          =   ""
      Left            =   56
      LimitText       =   0
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Mask            =   ""
      Password        =   ""
      ReadOnly        =   ""
      Scope           =   0
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   "*.*"
      TextColor       =   &h000000
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   6
      Underline       =   ""
      UseFocusRing    =   True
      Visible         =   True
      Width           =   123
   End
   Begin Label Label1
      AutoDeactivate  =   True
      Bold            =   ""
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   0
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Multiline       =   ""
      Scope           =   0
      Selectable      =   False
      TabIndex        =   1
      TabPanelIndex   =   0
      Text            =   "Search"
      TextAlign       =   2
      TextColor       =   &h000000
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   6
      Transparent     =   False
      Underline       =   ""
      Visible         =   True
      Width           =   51
   End
   Begin PushButton PushButton1
      AutoDeactivate  =   True
      Bold            =   ""
      ButtonStyle     =   0
      Cancel          =   ""
      Caption         =   "Select Folder"
      Default         =   ""
      Enabled         =   True
      Height          =   22
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   182
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Scope           =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   6
      Underline       =   ""
      Visible         =   True
      Width           =   95
   End
   Begin PushButton PushButton2
      AutoDeactivate  =   True
      Bold            =   ""
      ButtonStyle     =   0
      Cancel          =   ""
      Caption         =   "Go"
      Default         =   ""
      Enabled         =   True
      Height          =   22
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   98
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Scope           =   0
      TabIndex        =   3
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   34
      Underline       =   ""
      Visible         =   True
      Width           =   95
   End
   Begin Listbox Listbox1
      AutoDeactivate  =   True
      AutoHideScrollbars=   True
      Bold            =   ""
      Border          =   True
      ColumnCount     =   1
      ColumnsResizable=   ""
      ColumnWidths    =   ""
      DataField       =   ""
      DataSource      =   ""
      DefaultRowHeight=   -1
      Enabled         =   True
      EnableDrag      =   ""
      EnableDragReorder=   ""
      GridLinesHorizontal=   0
      GridLinesVertical=   0
      HasHeading      =   ""
      HeadingIndex    =   -1
      Height          =   332
      HelpTag         =   ""
      Hierarchical    =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   ""
      Italic          =   ""
      Left            =   0
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      RequiresSelection=   ""
      Scope           =   0
      ScrollbarHorizontal=   ""
      ScrollBarVertical=   True
      SelectionType   =   0
      TabIndex        =   4
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   68
      Underline       =   ""
      UseFocusRing    =   True
      Visible         =   True
      Width           =   290
      _ScrollWidth    =   -1
   End
   Begin Thread Thread1
      Height          =   32
      Index           =   -2147483648
      Left            =   322
      LockedInPosition=   False
      Priority        =   5
      Scope           =   0
      StackSize       =   0
      TabPanelIndex   =   0
      Top             =   34
      Width           =   32
   End
   Begin Timer Timer1
      Height          =   32
      Index           =   -2147483648
      Left            =   360
      LockedInPosition=   False
      Mode            =   2
      Period          =   10
      Scope           =   0
      TabPanelIndex   =   0
      Top             =   34
      Width           =   32
   End
End
#tag EndWindow

#tag WindowCode
	#tag Property, Flags = &h21
		Private Listed() As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private RootFolder As FolderItem
	#tag EndProperty


#tag EndWindowCode

#tag Events PushButton1
	#tag Event
		Sub Action()
		  Dim f As FolderItem = SelectFolder()
		  If f <> Nil Then RootFolder = f
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PushButton2
	#tag Event
		Sub Action()
		  If TextField1.Text.Trim = "" Then
		    MsgBox("You must enter a search pattern (e.g. '*.*')")
		  ElseIf RootFolder = Nil Then
		    MsgBox("You must select a folder to search within")
		  ElseIf Not RootFolder.Exists Then
		    MsgBox("The selected search folder does not exist or is inaccessible")
		  ElseIf Not RootFolder.Directory Then
		    MsgBox("You must select a folder to search within")
		  Else
		    Thread1.Run
		    App.YieldToNextThread
		  End If
		  
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events Thread1
	#tag Event
		Sub Run()
		  Dim fe As New FindFileIterator(RootFolder, TextField1.Text)
		  Do Until Not fe.NextItem
		    If fe.CurrentItem = Nil Then Continue
		    Listed.Insert(0, fe.CurrentItem)
		    App.YieldToNextThread
		  Loop
		  fe.Close
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events Timer1
	#tag Event
		Sub Action()
		  While Listed.Ubound > -1
		    Listbox1.AddRow(Listed.Pop.AbsolutePath)
		    App.YieldToNextThread
		  Wend
		End Sub
	#tag EndEvent
#tag EndEvents
