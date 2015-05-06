#tag Module
Protected Module Libs
	#tag Structure, Name = CURSORINFO, Flags = &h1
		cbSize As Integer
		  Flags As Integer
		  hIcon As Integer
		Hotspot As POINT
	#tag EndStructure

	#tag Structure, Name = DWM_THUMBNAIL_PROPERTIES, Flags = &h1
		flags As Integer
		  Destination As Win32.Libs.RECT
		  Source As Win32.Libs.RECT
		  Opacity As Byte
		  Visible As Boolean
		SourceClientAreaOnly As Boolean
	#tag EndStructure

	#tag Structure, Name = FILETIME, Flags = &h1
		HighDateTime As Integer
		LowDateTime As Integer
	#tag EndStructure

	#tag Structure, Name = FLASHWINFO, Flags = &h1
		cbSize As UInt32
		  HWND As Integer
		  Flags As Integer
		  Count As UInt32
		Timeout As Integer
	#tag EndStructure

	#tag Structure, Name = GUID, Flags = &h1
		data1 As UInt32
		  data2 As Short
		  data3 As Short
		data4 As String*8
	#tag EndStructure

	#tag Structure, Name = IO_STATUS_BLOCK, Flags = &h1
		Status As Int32
		Info As Int32
	#tag EndStructure

	#tag Structure, Name = LUID, Flags = &h1, Attributes = \""
		Lowpart As Integer
		HighPart As Integer
	#tag EndStructure

	#tag Structure, Name = LUID_AND_ATTRIBUTES, Flags = &h1, Attributes = \""
		LUID As LUID
		Attribs As Integer
	#tag EndStructure

	#tag Structure, Name = MARGINS, Flags = &h1
		LeftWidth As Integer
		  RightWidth As Integer
		  TopHeight As Integer
		BottomHeight As Integer
	#tag EndStructure

	#tag Structure, Name = MEMORYSTATUSEX, Flags = &h1
		sSize As Integer
		  MemLoad As Integer
		  TotalPhysicalMemory As UInt64
		  AvailablePhysicalMemory As UInt64
		  TotalPageFile As UInt64
		  AvailablePageFile As UInt64
		  PerProcessAddressSpace As UInt64
		  CurrentProcessAvailableAddressSpace As UInt64
		reserved As UInt64
	#tag EndStructure

	#tag Structure, Name = MEMORY_BASIC_INFORMATION, Flags = &h1
		BaseAddress As Integer
		  AllocationBase As Integer
		  AllocationProtect As Integer
		  RegionSize As Integer
		  State As Integer
		  Protect As Integer
		Type As Integer
	#tag EndStructure

	#tag Structure, Name = MIB_IPSTATS, Flags = &h1
		Forwarding As Integer
		  DefaultTTL As Integer
		  InReceives As Integer
		  InHeaderErrors As Integer
		  InAddressErrors As Integer
		  Forwarded As Integer
		  InUnknownProtos As Integer
		  InDiscards As Integer
		  InDelivered As Integer
		  OutRequests As Integer
		  RoutingDiscards As Integer
		  OutDiscards As Integer
		  OutNoRoutes As Integer
		  ReassemTimeout As Integer
		  ReassemReqds As Integer
		  ReassemOK As Integer
		  ReassemFails As Integer
		  FragOKs As Integer
		  FragFails As Integer
		  FragCreates As Integer
		  NumIf As Integer
		  NumAddresses As Integer
		NumRoutes As Integer
	#tag EndStructure

	#tag Structure, Name = NOTIFYICONDATA, Flags = &h1
		sSize As Integer
		  WindowHandle As Integer
		  uID As UInt32
		  Flags As UInt32
		  CallbackMessage As UInt32
		  IconHandle As Integer
		  ToolTip As String*64
		  State As Integer
		  StateMask As Integer
		  BalloonText As String*256
		  Timeout_Version_Union As UInt32
		  BalloonTitle As String*64
		  InfoFlags As Integer
		  GUIDitem As Win32.Libs.GUID
		BalloonIconHandle As Integer
	#tag EndStructure

	#tag Structure, Name = OVERLAPPED, Flags = &h1
		Internal As Integer
		  InternalHigh As Integer
		  Offset As UInt64
		hEvent As Integer
	#tag EndStructure

	#tag Structure, Name = POINT, Flags = &h1
		X As Integer
		Y As Integer
	#tag EndStructure

	#tag Structure, Name = PROCESSENTRY32, Flags = &h1
		Ssize As Integer
		  cntUsage As Integer
		  ProcessID As Integer
		  DefaultHeapID As Integer
		  ModuleID As Integer
		  ThreadCount As Integer
		  ParentProcessID As Integer
		  BasePriority As Integer
		  Flags As Integer
		EXEPath As WString*520
	#tag EndStructure

	#tag Structure, Name = PROCESS_INFORMATION, Flags = &h1
		Process As Integer
		  Thread As Integer
		  ProcessID As Integer
		ThreadID As Integer
	#tag EndStructure

	#tag Structure, Name = QOCINFO, Flags = &h1
		sSize As Integer
		  flags As Integer
		  inSpeed As Integer
		outSpeed As Integer
	#tag EndStructure

	#tag Structure, Name = RECT, Flags = &h1
		left As Integer
		  top As Integer
		  right As Integer
		bottom As Integer
	#tag EndStructure

	#tag Structure, Name = SERVICE_STATUS, Flags = &h1
		ServiceType As Integer
		  CurrentState As Integer
		  ControlsAccepted As Integer
		  Win32ExitCode As Integer
		  ServiceSpecificExitCode As Integer
		  CheckPoint As Integer
		WaitHint As Integer
	#tag EndStructure

	#tag Structure, Name = SHELLFLAGSTATE, Flags = &h1
		ShowAllObjects As Boolean
		  ShowExtensions As Boolean
		  NoConfirmRecycle As Boolean
		  ShowSystemFiles As Boolean
		  ShowCompColor As Boolean
		  DoubleClickInWebView As Boolean
		  DesktopHTML As Boolean
		  Win95Classic As Boolean
		  DontPrettyPath As Boolean
		  ShowAttribColor As Boolean
		  MapNetDrvBtn As Boolean
		  ShowInfoTip As Boolean
		  HideIcons As Boolean
		  AutoCheckSelect As Boolean
		  IconsOnly As Boolean
		RestFlags As UInt32
	#tag EndStructure

	#tag Structure, Name = SHFILEINFO, Flags = &h1
		hIcon As Integer
		  IconIndex As Int32
		  attribs As Integer
		  displayName As WString*260
		TypeName As WString*80
	#tag EndStructure

	#tag Structure, Name = STARTUPINFO, Flags = &h1
		sSize As Integer
		  Reserved1 As Ptr
		  Desktop As Ptr
		  Title As Ptr
		  WM_X As Integer
		  WM_Y As Integer
		  WM_Width As Integer
		  WM_Height As Integer
		  CON_Buffer_Width As Integer
		  CON_Buffer_Height As Integer
		  CON_FillAttribute As Integer
		  Flags As Integer
		  ShowWindow As UInt16
		  Reserved2 As UInt16
		  Reserved3 As Byte
		  StdInput As Integer
		  StdOutput As Integer
		StdError As Integer
	#tag EndStructure

	#tag Structure, Name = SYSTEMTIME, Flags = &h1
		Year As UInt16
		  Month As UInt16
		  DOW As UInt16
		  Day As UInt16
		  Hour As UInt16
		  Minute As UInt16
		  Second As UInt16
		MS As UInt16
	#tag EndStructure

	#tag Structure, Name = TIME_ZONE_INFORMATION, Flags = &h1
		Bias As Integer
		  StandardName As Wstring*32
		  StandardDate As SYSTEMTIME
		  StandardBias As Integer
		  DaylightName As WString*32
		  DaylightDate As SYSTEMTIME
		DaylightBias As Integer
	#tag EndStructure

	#tag Structure, Name = TOKEN_PRIVILEGES, Flags = &h1, Attributes = \""
		Count As Integer
		LUID_AND_ATTRIBS As LUID_AND_ATTRIBUTES
	#tag EndStructure

	#tag Structure, Name = WIN32_FIND_DATA, Flags = &h1
		Attribs As Integer
		  CreationTime As FILETIME
		  LastAccess As FILETIME
		  LastWrite As FILETIME
		  sizeHigh As Integer
		  sizeLow As Integer
		  Reserved1 As Integer
		  Reserved2 As Integer
		  FileName As WString*260
		AlternateName As String*14
	#tag EndStructure

	#tag Structure, Name = WIN32_FIND_STREAM_DATA, Flags = &h1
		StreamSize As Int64
		StreamName As String*1024
	#tag EndStructure

	#tag Structure, Name = WINDOWINFO, Flags = &h1
		cbSize As Integer
		  WindowArea As Win32.Libs.RECT
		  ClientArea As Win32.Libs.RECT
		  Style As Integer
		  ExStyle As Integer
		  WindowStatus As Integer
		  cxWindowBorders As Integer
		  cyWindowBorders As Integer
		  Atom As UInt16
		CreatorVersion As UInt16
	#tag EndStructure

	#tag Structure, Name = WINDOWPLACEMENT, Flags = &h1
		Length As Integer
		  Flags As Integer
		  ShowCmd As Integer
		  MinPosition As POINT
		  MaxPosition As POINT
		NormalPosition As RECT
	#tag EndStructure

	#tag Structure, Name = WNDCLASS, Flags = &h1
		Style As UInt32
		  WndProc As Ptr
		  ClsExtra As Integer
		  WndExtra As Integer
		  Instance As Integer
		  Icon As Integer
		  Cursor As Integer
		  Brush As Integer
		  MenuName As Ptr
		ClassName As Ptr
	#tag EndStructure

	#tag Structure, Name = WNDCLASSEX, Flags = &h1
		cbSize As Integer
		  Style As UInt32
		  WndProc As Ptr
		  ClsExtra As Integer
		  WndExtra As Integer
		  Instance As Integer
		  Icon As Integer
		  Cursor As Integer
		  Brush As Integer
		  MenuName As Ptr
		  ClassName As Ptr
		IconSm As Integer
	#tag EndStructure


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
