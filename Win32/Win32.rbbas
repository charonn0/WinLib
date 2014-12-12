#tag Module
Protected Module Win32
	#tag Method, Flags = &h1
		Protected Function CurrentProcessID() As Integer
		  #If TargetWin32 Then
		    Return Win32.Libs.Kernel32.GetCurrentProcess()
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function CurrentThreadID() As Integer
		  #If TargetWin32 Then
		    Return Win32.Libs.Kernel32.GetCurrentThreadId()
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FILE_ALL_ACCESS() As Integer
		  Return STANDARD_RIGHTS_REQUIRED Or SYNCHRONIZE Or &h1FF
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FILE_GENERIC_READ() As Integer
		  Return STANDARD_RIGHTS_READ Or FILE_READ_DATA Or FILE_READ_ATTRIBUTES Or FILE_READ_EA Or SYNCHRONIZE
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function FormatError(WinErrorNumber As Integer) As String
		  //Returns the error message corresponding to a given windows error number.
		  
		  #If TargetWin32 Then
		    Dim buffer As New MemoryBlock(2048)
		    If Win32.Libs.Kernel32.FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, 0, WinErrorNumber, 0 , Buffer, Buffer.Size, 0) <> 0 Then
		      Return Buffer.WString(0)
		    Else
		      Return "Unknown error number: " + Str(WinErrorNumber)
		    End If
		  #Else
		    Return "Not a Windows system. Error number: " + Str(WinErrorNumber)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetSystemInfo() As SYSTEM_INFO
		  Dim info As SYSTEM_INFO
		  Win32.Libs.Kernel32.GetSystemInfo(info)
		  Return info
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetSystemMetric(Index As Integer) As Integer
		  #If TargetWin32 Then
		    Return Win32.Libs.User32.GetSystemMetrics(Index)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HBITMAP(hMap As Integer) As Picture
		  Dim szm As New MemoryBlock(28)
		  If Win32.Libs.GDI32.GetObject(hMap, 28, szm) > 0 Then
		    Dim p As New Picture(szm.Int32Value(4), szm.Int32Value(8), 32)
		    Dim dsthDC, srcDC As Integer
		    dsthDC = p.Graphics.Handle(1)
		    srcDC = Win32.Libs.GDI32.CreateCompatibleDC(dsthDC)
		    Call Win32.Libs.GDI32.SelectObject(srcDC, hMap)
		    Call Win32.Libs.GDI32.BitBlt(dsthDC, 0, 0, p.Width, p.Height, srcDC, 0, 0, SRCCOPY)
		    Return p
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HBITMAP(p As Picture) As Integer
		  Dim pp As New Picture(p.Width, p.Height, 32)
		  Dim srcDC As Integer = pp.Graphics.Handle(1)
		  Dim bmp As Integer = Win32.Libs.GDI32.CreateCompatibleBitmap(srcDC, p.Width, p.Height)
		  Dim dstDC As Integer = Win32.Libs.GDI32.CreateCompatibleDC(srcDC)
		  Call Win32.Libs.GDI32.SelectObject(dstDC, bmp)
		  Call Win32.Libs.GDI32.BitBlt(dstDC, 0, 0, p.Width, p.Height, srcDC, 0, 0, SRCCOPY)
		  Return bmp
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HighBits(Extends BigInt As Int64) As Integer
		  'Gets the high-order bits of the passed Int64
		  Return ShiftRight(BigInt, 32)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HighBits(Extends ByRef BigInt As Int64, Assigns HighOrder As Integer)
		  'Sets the high-order bits of the passed Int64
		  BigInt = BitOr(ShiftLeft(HighOrder, 32), BigInt.LowBits)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function KernelVersion() As Double
		  //Returns the Kernel version of Windows as a Double (MajorVersion.MinorVersion)
		  //For example, Windows 2000 returns 5.0, XP Returns 5.1, Vista Returns 6.0 and Windows 7 returns 6.1
		  //On error, returns 0.0
		  
		  #If TargetWin32 Then
		    Return Win32.OSVersion.MajorVersion + (Win32.OSVersion.MinorVersion / 10)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function LastError() As Integer
		  Return Win32.Libs.Kernel32.GetLastError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub LastError(Assigns NewErrorNumber As Integer)
		  Win32.Libs.Kernel32.SetLastError(NewErrorNumber)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LowBits(Extends BigInt As Int64) As Integer
		  'Gets the low-order bits of the passed Int64
		  Return BitAnd(BigInt, &hFFFFFFFF)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LowBits(Extends ByRef BigInt As Int64, Assigns LowOrder As Integer)
		  'Sets the low-order bits of the passed Int64
		  BigInt = BitOr(ShiftLeft(BigInt.HighBits, 32), LowOrder)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MS_ENH_RSA_AES_PROV() As String
		  If KernelVersion < 6.0 Then ' XP used a different name
		    Return "Microsoft Enhanced RSA and AES Cryptographic Provider (Prototype)"
		  Else
		    Return "Microsoft Enhanced RSA and AES Cryptographic Provider"
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function OSVersion() As OSVERSIONINFOEX
		  Dim info As OSVERSIONINFOEX
		  info.StructSize = Info.Size
		  #If TargetWin32 Then
		    If Win32.Libs.Kernel32.GetVersionEx(info) Then
		      Return info
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ScreenToClient(ScreenPoint As Realbasic.Point, HWND As Integer) As REALbasic.Point
		  Dim p As Win32.POINT
		  p.X = ScreenPoint.X
		  p.Y = ScreenPoint.Y
		  If Not Win32.Libs.User32.ScreenToClient(HWND, p) Then
		    p.X = -1
		    p.Y = -1
		  End If
		  Return New REALbasic.Point(p.X, p.Y)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function UserName() As String
		  //Returns the username of the account under which the application is running.
		  //On Error, returns an empty string
		  
		  #If TargetWin32 Then
		    Dim mb As New MemoryBlock(0)
		    Dim nmLen As Integer = mb.Size
		    If Not Win32.Libs.AdvApi32.GetUserName(mb, nmLen) Then Return ""
		    mb = New MemoryBlock(nmLen * 2)
		    nmLen = mb.Size
		    If Win32.Libs.AdvApi32.GetUserName(mb, nmLen) Then
		      Return mb.WString(0)
		    Else
		      Return ""
		    End If
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Win32Exception(ErrorNumber As Integer) As RuntimeException
		  Dim err As New RuntimeException
		  err.ErrorNumber = ErrorNumber
		  err.Message = "Win32 error: " + FormatError(ErrorNumber)
		  Return err
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  #If TargetWin32 Then
			    Dim mb As New MemoryBlock(1024)
			    Dim i As Integer
			    Do
			      i = Win32.Libs.Kernel32.GetCurrentDirectory(mb.Size, mb)
			    Loop Until i <= mb.Size And i > 0
			    
			    Return GetFolderItem(mb.WString(0), FolderItem.PathTypeAbsolute)
			  #endif
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #If TargetWin32 Then
			    Dim path As String = value.AbsolutePath
			    If Not Win32.Libs.Kernel32.SetCurrentDirectory(path) Then
			      Dim e As Integer = Win32.LastError
			      Dim err As New IOException
			      err.Message = CurrentMethodName + ": " + FormatError(e)
			      err.ErrorNumber = e
			      Raise err
			    End If
			  #endif
			End Set
		#tag EndSetter
		Protected CurrentDirectory As FolderItem
	#tag EndComputedProperty


	#tag Constant, Name = FILE_READ_ATTRIBUTES, Type = Double, Dynamic = False, Default = \"&h0080", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_READ_DATA, Type = Double, Dynamic = False, Default = \"&h0001", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FILE_READ_EA, Type = Double, Dynamic = False, Default = \"&h0008", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = FORMAT_MESSAGE_FROM_SYSTEM, Type = Double, Dynamic = False, Default = \"&H1000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = INVALID_HANDLE_VALUE, Type = Double, Dynamic = False, Default = \"-1", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = READ_CONTROL, Type = Double, Dynamic = False, Default = \"&h00020000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = SE_SHUTDOWN_NAME, Type = String, Dynamic = False, Default = \"SeShutdownPrivilege", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = SRCCOPY, Type = Double, Dynamic = False, Default = \"&h00CC0020", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = STANDARD_RIGHTS_ALL, Type = Double, Dynamic = False, Default = \"&h001F0000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = STANDARD_RIGHTS_EXECUTE, Type = Double, Dynamic = False, Default = \"READ_CONTROL", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = STANDARD_RIGHTS_READ, Type = Double, Dynamic = False, Default = \"READ_CONTROL", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = STANDARD_RIGHTS_REQUIRED, Type = Double, Dynamic = False, Default = \"&h000F0000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = STANDARD_RIGHTS_WRITE, Type = Double, Dynamic = False, Default = \"READ_CONTROL", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = SYNCHRONIZE, Type = Double, Dynamic = False, Default = \"&h00100000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = S_OK, Type = Double, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant


	#tag Structure, Name = AT_INFO, Flags = &h0
		JobTime As Ptr
		  DaysOfMonth As Integer
		  DaysOfWeek As Byte
		  Flags As Byte
		Command As Ptr
	#tag EndStructure

	#tag Structure, Name = BITMAPINFO, Flags = &h0
		Header As BITMAPINFOHEADER
		RGBQUAD As Ptr
	#tag EndStructure

	#tag Structure, Name = BITMAPINFOHEADER, Flags = &h0
		sSize As Integer
		  Width As Integer
		  Height As Integer
		  Planes As Int16
		  BitCount As Int16
		  Compression As Integer
		  SizeImage As Integer
		  XPelsPerMeter As Integer
		  YPelsPerMeter As Integer
		  ClrUsed As Integer
		ClrImportant As Integer
	#tag EndStructure

	#tag Structure, Name = CAPDRIVERCAPS, Flags = &h0
		DeviceIndex As Integer
		  HasOverlay As Boolean
		  HasSourceSelectDialog As Boolean
		  HasFormatSelectDialog As Boolean
		  HasDisplayDialog As Boolean
		  CaptureInitialized As Boolean
		  DriverSuppliesPalettes As Boolean
		  VideoIn As Integer
		  VideoOut As Integer
		  VideoExtIn As Integer
		VideoExtOut As Integer
	#tag EndStructure

	#tag Structure, Name = CAPTUREPARMS, Flags = &h0
		RequestMicroSecPerFrame As Integer
		  MakeUserHitOKToCapure As Boolean
		  PercentDropForError As UInt32
		  Yield As Boolean
		  IndexSize As Integer
		  ChunkGranularity As UInt32
		  UsingDOSMemory As Boolean
		  NumVideoRequested As UInt32
		  CaptureAudio As Boolean
		  NumAudioRequested As UInt32
		  KeyAbort As UInt32
		  AbortLeftMouse As Boolean
		  AbortRightMouse As Boolean
		  LimitEnabled As Boolean
		  TimeLimit As UInt32
		  MCIControl As Boolean
		  StepMCIDevice As Boolean
		  MCIStartTime As Integer
		  MCIStopTime As Integer
		  StepCaptureAt2x As Boolean
		  StepCaptureAverageFrames As UInt32
		  AudioBufferSize As Integer
		  DisableWriteCache As Boolean
		AVStreamMaster As UInt32
	#tag EndStructure

	#tag Structure, Name = CHAR_INFO, Flags = &h0
		char As UInt16
		attribs As UInt16
	#tag EndStructure

	#tag Structure, Name = CONSOLE_CURSOR_INFO, Flags = &h0
		height As Integer
		visible As Boolean
	#tag EndStructure

	#tag Structure, Name = CONSOLE_SCREEN_BUFFER_INFO, Flags = &h0
		dwSize As COORD
		  CursorPosition As COORD
		  Attribute As UInt16
		  sdWindow As SMALL_RECT
		MaxWindowSize As COORD
	#tag EndStructure

	#tag Structure, Name = CONSOLE_SCREEN_BUFFER_INFOEX, Flags = &h0, Attributes = \"StructureAlignment \x3D 8"
		sSize As Integer
		  dwSize As COORD
		  CursorPosition As COORD
		  Attribute As UInt16
		  sdWindow As SMALL_RECT
		  MaxWindowSize As COORD
		  PopupAttributes As UInt16
		  FullscreenSupported As Boolean
		ColorTable(15) As UInt32
	#tag EndStructure

	#tag Structure, Name = COORD, Flags = &h0
		X As UInt16
		Y As UInt16
	#tag EndStructure

	#tag Structure, Name = CURSORINFO, Flags = &h0
		cbSize As Integer
		  Flags As Integer
		  hIcon As Integer
		Hotspot As POINT
	#tag EndStructure

	#tag Structure, Name = DRAWTEXTPARAMS, Flags = &h0
		sSize As UInt32
		  TabLen As Int32
		  LeftMargin As Int32
		  RightMargin As Int32
		UILengthDrawn As UInt32
	#tag EndStructure

	#tag Structure, Name = DWM_THUMBNAIL_PROPERTIES, Flags = &h0
		flags As Integer
		  Destination As RECT
		  Source As RECT
		  Opacity As Byte
		  Visible As Boolean
		SourceClientAreaOnly As Boolean
	#tag EndStructure

	#tag Structure, Name = FILETIME, Flags = &h0
		HighDateTime As Integer
		LowDateTime As Integer
	#tag EndStructure

	#tag Structure, Name = FILE_STREAM_INFO, Flags = &h0
		NextEntryOffset As Integer
		  SteamNameLength As Integer
		  StreamSize As UInt64
		  StreamAllocationSize As Uint64
		streamName As string*255
	#tag EndStructure

	#tag Structure, Name = FLASHWINFO, Flags = &h0
		cbSize As UInt32
		  HWND As Integer
		  Flags As Integer
		  Count As UInt32
		Timeout As Integer
	#tag EndStructure

	#tag Structure, Name = GUID, Flags = &h0
		data1 As UInt32
		  data2 As Short
		  data3 As Short
		data4 As String*8
	#tag EndStructure

	#tag Structure, Name = IO_STATUS_BLOCK, Flags = &h0
		Status As Int32
		Info As Int32
	#tag EndStructure

	#tag Structure, Name = IP_ADAPTER_INFO, Flags = &h0
		ComboIndex As Integer
		  AdapterName As CString*264
		  Description As CString*132
		  AddressLength As UInt32
		  Address As Byte
		  Index As Integer
		  Type As UInt32
		  DHCPEnabled As UInt32
		  CurrentIPAddress As IP_ADDR_STRING
		  GatewayList As IP_ADDR_STRING
		  DHCPServer As IP_ADDR_STRING
		  HaveWins As Boolean
		  PrimaryWinsServer As IP_ADDR_STRING
		  SecondaryWinsServer As IP_ADDR_STRING
		  LeaseObtained As UInt64
		LeaseExpires As UInt64
	#tag EndStructure

	#tag Structure, Name = IP_ADDR_STRING, Flags = &h0
		NextStruct As Ptr
		  IPAddress As CString*16
		  IPMask As CString*16
		Context As Integer
	#tag EndStructure

	#tag Structure, Name = LOGFONT, Flags = &h0
		Height As Integer
		  Width As Integer
		  Escapement As Integer
		  Orientation As Integer
		  Weight As Integer
		  Italic As Byte
		  Underline As Byte
		  StrikeOut As Byte
		  CharSet As Byte
		  OutPrecision As Byte
		  ClipPrecision As Byte
		  Quality As Byte
		  PitchAndFamily As Byte
		faceName As String*255
	#tag EndStructure

	#tag Structure, Name = LUID, Flags = &h0, Attributes = \""
		Lowpart As Integer
		HighPart As Integer
	#tag EndStructure

	#tag Structure, Name = LUID_AND_ATTRIBUTES, Flags = &h0, Attributes = \""
		LUID As LUID
		Attribs As Integer
	#tag EndStructure

	#tag Structure, Name = MARGINS, Flags = &h0
		LeftWidth As Integer
		  RightWidth As Integer
		  TopHeight As Integer
		BottomHeight As Integer
	#tag EndStructure

	#tag Structure, Name = MEMORYSTATUSEX, Flags = &h0
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

	#tag Structure, Name = MEMORY_BASIC_INFORMATION, Flags = &h0
		BaseAddress As Integer
		  AllocationBase As Integer
		  AllocationProtect As Integer
		  RegionSize As Integer
		  State As Integer
		  Protect As Integer
		Type As Integer
	#tag EndStructure

	#tag Structure, Name = MIB_IPSTATS, Flags = &h0
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

	#tag Structure, Name = MODULEENTRY32, Flags = &h0
		sSize As Integer
		  ModuleID As Integer
		  ProcessID As Integer
		  LoadCount As Integer
		  GLoadCount As Integer
		  BaseAddress As Byte
		  BaseSize As Integer
		  Handle As Integer
		  Name As WString*256
		Path As WString*260
	#tag EndStructure

	#tag Structure, Name = NOTIFYICONDATA, Flags = &h0
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
		  GUIDitem As GUID
		BalloonIconHandle As Integer
	#tag EndStructure

	#tag Structure, Name = OFSTRUCT, Flags = &h0
		cbytes As Byte
		  fFixedSize As Byte
		  nErrCode As Integer
		  res1 As Integer
		  res2 As Integer
		szPathName(128) As Byte
	#tag EndStructure

	#tag Structure, Name = OSVERSIONINFOEX, Flags = &h0
		StructSize As UInt32
		  MajorVersion As Integer
		  MinorVersion As Integer
		  BuildNumber As Integer
		  PlatformID As Integer
		  ServicePackName As String*128
		  ServicePackMajor As UInt16
		  ServicePackMinor As UInt16
		  SuiteMask As UInt16
		  ProductType As Byte
		Reserved As Byte
	#tag EndStructure

	#tag Structure, Name = OVERLAPPED, Flags = &h0
		Internal As Integer
		  InternalHigh As Integer
		  Offset As UInt64
		hEvent As Integer
	#tag EndStructure

	#tag Structure, Name = POINT, Flags = &h0
		X As Integer
		Y As Integer
	#tag EndStructure

	#tag Structure, Name = PROCESSENTRY32, Flags = &h0
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

	#tag Structure, Name = PROCESSOR_POWER_INFORMATION, Flags = &h0
		ProcessorNumber As UInt32
		  MaxMhz As UInt32
		  CurrentMhz As UInt32
		  MhzLimit As UInt32
		  MaxIdleState As UInt32
		CurrentIdleState As UInt32
	#tag EndStructure

	#tag Structure, Name = PROCESS_INFORMATION, Flags = &h0
		Process As Integer
		  Thread As Integer
		  ProcessID As Integer
		ThreadID As Integer
	#tag EndStructure

	#tag Structure, Name = QOCINFO, Flags = &h0
		sSize As Integer
		  flags As Integer
		  inSpeed As Integer
		outSpeed As Integer
	#tag EndStructure

	#tag Structure, Name = QUERY_SERVICE_CONFIG, Flags = &h0
		ServiceType As Integer
		  StartType As Integer
		  ErrorControl As Integer
		  BinPathName As Ptr
		  LoadOrderGroup As Ptr
		  TagID As Integer
		  Dependencies As Ptr
		  ServiceStartName As Ptr
		DisplayName As Ptr
	#tag EndStructure

	#tag Structure, Name = RECT, Flags = &h0
		left As Integer
		  top As Integer
		  right As Integer
		bottom As Integer
	#tag EndStructure

	#tag Structure, Name = SECURITY_ATTRIBUTES, Flags = &h0
		Length As Integer
		  secDescriptor As Ptr
		InheritHandle As Boolean
	#tag EndStructure

	#tag Structure, Name = SERVICE_STATUS, Flags = &h0
		ServiceType As Integer
		  CurrentState As Integer
		  ControlsAccepted As Integer
		  Win32ExitCode As Integer
		  ServiceSpecificExitCode As Integer
		  CheckPoint As Integer
		WaitHint As Integer
	#tag EndStructure

	#tag Structure, Name = SHELLFLAGSTATE, Flags = &h0
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

	#tag Structure, Name = SHFILEINFO, Flags = &h0
		hIcon As Integer
		  IconIndex As Int32
		  attribs As Integer
		  displayName As WString*260
		TypeName As WString*80
	#tag EndStructure

	#tag Structure, Name = SMALL_RECT, Flags = &h0
		Left As UInt16
		  Top As UInt16
		  Right As UInt16
		Bottom As UInt16
	#tag EndStructure

	#tag Structure, Name = SP_DEVINFO_DATA, Flags = &h0
		cbSize As Integer
		  UUID As String*16
		  DevList As Integer
		reserved As Integer
	#tag EndStructure

	#tag Structure, Name = STARTUPINFO, Flags = &h0
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

	#tag Structure, Name = SYSTEMTIME, Flags = &h0
		Year As UInt16
		  Month As UInt16
		  DOW As UInt16
		  Day As UInt16
		  Hour As UInt16
		  Minute As UInt16
		  Second As UInt16
		MS As UInt16
	#tag EndStructure

	#tag Structure, Name = SYSTEM_BATTERY_STATE, Flags = &h0
		ACOnline As Boolean
		  BatteryPresent As Boolean
		  Charging As Boolean
		  Discharging As Boolean
		  spare(3) As Byte
		  MaxCapacity As Integer
		  RemainingCapacity As Integer
		  Rate As Integer
		  EstimatedTimer As Integer
		  DefaultAlert1 As Integer
		DefaultAlert2 As Integer
	#tag EndStructure

	#tag Structure, Name = SYSTEM_HANDLE_TABLE_ENTRY_INFO, Flags = &h0
		ProcessID As Integer
		  ObjectType As Byte
		  Flags As Byte
		  Value As Int16
		  Address As Ptr
		GrantedAccess As Integer
	#tag EndStructure

	#tag Structure, Name = SYSTEM_INFO, Flags = &h0
		OEMID As Integer
		  pageSize As Integer
		  minApplicationAddress As Ptr
		  maxApplicationAddress As Ptr
		  activeProcessorMask As Integer
		  numberOfProcessors As Integer
		  processorType As Integer
		  allocationGranularity As Integer
		  processorLevel As Int16
		processorRevision As Int16
	#tag EndStructure

	#tag Structure, Name = SYSTEM_INFO_EX, Flags = &h0
		StructSize As Integer
		  MajorVersion As Integer
		  MinorVersion As Integer
		  buildNumber As Integer
		  platformID As Integer
		  serivePackString As String*256
		  servicePackMajor As Int16
		  servicePackMinor As Int16
		  suiteMask As Int16
		  productType As Byte
		reserved As Byte
	#tag EndStructure

	#tag Structure, Name = TIME_ZONE_INFORMATION, Flags = &h0
		Bias As Integer
		  StandardName As Wstring*32
		  StandardDate As SYSTEMTIME
		  StandardBias As Integer
		  DaylightName As WString*32
		  DaylightDate As SYSTEMTIME
		DaylightBias As Integer
	#tag EndStructure

	#tag Structure, Name = TOKEN_PRIVILEGES, Flags = &h0, Attributes = \""
		Count As Integer
		LUID_AND_ATTRIBS As LUID_AND_ATTRIBUTES
	#tag EndStructure

	#tag Structure, Name = VS_FIXEDFILEINFO, Flags = &h0
		Signature As Integer
		  StrucVersion As Integer
		  FileVersionMS As Integer
		  FileVersionLS As Integer
		  FileFlagMasks As Integer
		  FileFlags As Integer
		  FileOS As Integer
		  FileType As Integer
		  FileSubType As Integer
		  FileDateMS As Integer
		FileDateLS As Integer
	#tag EndStructure

	#tag Structure, Name = WIN32_FIND_DATA, Flags = &h0
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

	#tag Structure, Name = WIN32_FIND_STREAM_DATA, Flags = &h0
		StreamSize As Int64
		StreamName As String*1024
	#tag EndStructure

	#tag Structure, Name = WINDOWINFO, Flags = &h0
		cbSize As Integer
		  WindowArea As RECT
		  ClientArea As RECT
		  Style As Integer
		  ExStyle As Integer
		  WindowStatus As Integer
		  cxWindowBorders As Integer
		  cyWindowBorders As Integer
		  Atom As UInt16
		CreatorVersion As UInt16
	#tag EndStructure

	#tag Structure, Name = WINDOWPLACEMENT, Flags = &h0
		Length As Integer
		  Flags As Integer
		  ShowCmd As Integer
		  MinPosition As POINT
		  MaxPosition As POINT
		NormalPosition As RECT
	#tag EndStructure

	#tag Structure, Name = WINTRUST_DATA, Flags = &h0
		cbStruct As Integer
		  PolicyCallbackData As Ptr
		  SIPClientData As Ptr
		  UIChoice As Integer
		  fwdRevocationChecks As Integer
		  UnionChoice As Integer
		  Union As Ptr
		  StateAction As Integer
		  WVTStateData As Integer
		  URLContext_reserved As Ptr
		  ProvFlags As Integer
		UIContext As Integer
	#tag EndStructure

	#tag Structure, Name = WINTRUST_FILE_INFO, Flags = &h0
		cbStruct As Integer
		  FilePath As String*260
		  fHandle As Integer
		KnownSubjet As GUID
	#tag EndStructure

	#tag Structure, Name = WNDCLASS, Flags = &h0
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

	#tag Structure, Name = WNDCLASSEX, Flags = &h0
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


	#tag Enum, Name = TOKEN_INFORMATION_CLASS, Flags = &h0
		TokenUser
		  TokenGroups
		  TokenPrivileges
		  TokenOwner
		  TokenPrimaryGroup
		  TokenDefaultDacl
		  TokenSource
		  TokenType
		  TokenImpersonationLevel
		  TokenStatistics
		  TokenRestrictedSids
		  TokenSessionId
		  TokenGroupsAndPrivileges
		  TokenSessionReference
		  TokenSandboxInert
		  TokenAuditPolicy
		  TokenOrigin
		  TokenElevationType
		  TokenLinkedToken
		  TokenElevation
		  TokenHasRestrictions
		  TokenAccessInformation
		  TokenVirtualizationAllowed
		  TokenVirtualizationEnabled
		  TokenIntegrityLevel
		  TokenUIAccess
		  TokenMandatoryPolicy
		  TokenLogonSid
		  TokenIsAppContainer
		  TokenCapabilities
		  TokenAppContainerSid
		  TokenAppContainerNumber
		  TokenUserClaimAttributes
		  TokenDeviceClaimAttributes
		  TokenRestrictedUserClaimAttributes
		  TokenRestrictedDeviceClaimAttributes
		  TokenDeviceGroups
		  TokenRestrictedDeviceGroups
		  TokenSecurityAttributes
		  TokenIsRestricted
		MaxTokenInfoClass
	#tag EndEnum


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
