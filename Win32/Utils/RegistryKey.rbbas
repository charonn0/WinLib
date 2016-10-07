#tag Class
Protected Class RegistryKey
	#tag Method, Flags = &h0
		Function Child(SubKeyName As String, AccessMask As Integer = 0) As Win32.Utils.RegistryKey
		  If AccessMask = 0 Then AccessMask = mAccessMask
		  Return New Win32.Utils.RegistryKey(mHandle, SubKeyName, AccessMask)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function ClassesRoot(SubKeyPath As String = "", AccessRights As Integer = KEY_ALL_ACCESS) As Win32.Utils.RegistryKey
		  Return New Win32.Utils.RegistryKey(HKEY_CLASSES_ROOT, SubkeyPath, AccessRights)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Close()
		  If Not Win32.Libs.Kernel32.CloseHandle(mHandle) Then
		    mLastError = Win32.LastError
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(KeyHandle As Integer, SubKeyName As String, AccessRights As Integer, Options As Integer = 0)
		  mLastError =  Win32.Libs.AdvApi32.RegOpenKeyEx(KeyHandle, SubKeyName, Options, AccessRights, mHandle)
		  If mLastError <> 0 Then
		    Dim err As New RegistryAccessErrorException
		    err.ErrorNumber = mLastError
		    err.Message = FormatError(mLastError)
		    Raise err
		  End If
		  mOptions = Options
		  mLastError = 0
		  mAccessMask = AccessRights
		  mSubkey = SubKeyName
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(RootKey As Win32.Utils.RegistryKey, SubKeyName As String)
		  Dim wascreated As Integer
		  mAccessMask = KEY_CREATE_SUB_KEY Or KEY_READ Or KEY_WRITE
		  mLastError = Win32.Libs.AdvApi32.RegCreateKeyEx(RootKey.Key, SubKeyName, 0, Nil, 0, mAccessMask, Nil, mHandle, wascreated)
		  If mLastError <> 0 Then
		    Dim err As New RegistryAccessErrorException
		    err.ErrorNumber = mLastError
		    err.Message = FormatError(mLastError)
		    Raise err
		  End If
		  mLastError = 0
		  mSubkey = SubKeyName
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function CurrentConfig(SubKeyPath As String = "", AccessRights As Integer = KEY_ALL_ACCESS) As Win32.Utils.RegistryKey
		  Return New Win32.Utils.RegistryKey(HKEY_CURRENT_CONFIG, SubKeyPath, AccessRights)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function CurrentUser(SubKeyPath As String = "", AccessRights As Integer = KEY_ALL_ACCESS) As Win32.Utils.RegistryKey
		  Return New Win32.Utils.RegistryKey(HKEY_CURRENT_USER, SubkeyPath, AccessRights)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function CurrentUserLocalSettings(SubKeyPath As String = "", AccessRights As Integer = KEY_ALL_ACCESS) As Win32.Utils.RegistryKey
		  Return New Win32.Utils.RegistryKey(HKEY_CURRENT_USER_LOCAL_SETTINGS, SubKeyPath, AccessRights)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DeleteKey(SubKeyName As String) As Boolean
		  mLastError = Win32.Libs.AdvApi32.RegDeleteTree(mHandle, SubKeyName)
		  Return mLastError = 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DeleteValue(ValueName As String) As Boolean
		  mLastError = Win32.Libs.AdvApi32.RegDeleteValue(mHandle, ValueName)
		  Return mLastError = 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Destructor()
		  Me.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function DynData(SubKeyPath As String = "", AccessRights As Integer = KEY_ALL_ACCESS) As Win32.Utils.RegistryKey
		  Return New Win32.Utils.RegistryKey(HKEY_DYN_DATA, SubkeyPath, AccessRights)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function FromPath(RegPath As String, AccessRights As Integer = KEY_ALL_ACCESS) As Win32.Utils.RegistryKey
		  'HKEY_CLASSES_ROOT\*\shell\vthash
		  
		  Dim parts() As String = Split(RegPath, "\")
		  Dim root As String = parts(0)
		  parts.Remove(0)
		  Dim rootkey As Integer
		  Select Case root
		  Case "HKEY_CLASSES_ROOT"
		    rootkey = HKEY_CLASSES_ROOT
		  Case "HKEY_CURRENT_CONFIG"
		    rootkey = HKEY_CURRENT_CONFIG
		  Case "HKEY_CURRENT_USER"
		    rootkey = HKEY_CURRENT_USER
		  Case "HKEY_CURRENT_USER_LOCAL_SETTINGS"
		    rootkey = HKEY_CURRENT_USER_LOCAL_SETTINGS
		  Case "HKEY_DYN_DATA"
		    rootkey = HKEY_DYN_DATA
		  Case "HKEY_LOCAL_MACHINE"
		    rootkey = HKEY_LOCAL_MACHINE
		  Case "HKEY_PERFORMANCE_DATA"
		    rootkey = HKEY_PERFORMANCE_DATA
		  Case "HKEY_PERFORMANCE_NLSTEXT"
		    rootkey = HKEY_PERFORMANCE_NLSTEXT
		  Case "HKEY_PERFORMANCE_TEXT"
		    rootkey = HKEY_PERFORMANCE_TEXT
		  Case "HKEY_USERS"
		    rootkey = HKEY_USERS
		  Else
		    Return Nil
		  End Select
		  
		  Dim r As New Win32.Utils.RegistryKey(rootkey, "", AccessRights)
		  For i As Integer = 0 To UBound(parts)
		    r = r.Child(parts(i))
		  Next
		  Return r
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasChild(SubKeyName As String) As Boolean
		  Try
		    #pragma BreakOnExceptions Off
		    Return Me.Child(SubKeyName) <> Nil
		  Catch Err As RegistryAccessErrorException
		    Return False
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsReadable() As Boolean
		  Return BitXor(mAccessMask, KEY_WRITE) = KEY_WRITE
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsWriteable() As Boolean
		  Return BitXor(mAccessMask, KEY_READ) = KEY_READ
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Key() As Integer
		  Return mHandle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function LocalMachine(SubKeyPath As String = "", AccessRights As Integer = KEY_ALL_ACCESS) As Win32.Utils.RegistryKey
		  Return New Win32.Utils.RegistryKey(HKEY_LOCAL_MACHINE, SubkeyPath, AccessRights)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Path() As String
		  Dim nameinfo As New MemoryBlock(256)
		  Dim outsz As UInt32
		  mLastError = Win32.Libs.NTDLL.NtQueryKey(mHandle, 3, nameinfo, nameinfo.Size, outsz)
		  Return DefineEncoding(nameinfo.StringValue(4, outsz - 4), Encodings.UTF16)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function PerformanceData(SubKeyPath As String = "", AccessRights As Integer = KEY_ALL_ACCESS) As Win32.Utils.RegistryKey
		  Return New Win32.Utils.RegistryKey(HKEY_PERFORMANCE_DATA, SubKeyPath, AccessRights)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function PerformanceDataNLSText(SubKeyPath As String = "", AccessRights As Integer = KEY_ALL_ACCESS) As Win32.Utils.RegistryKey
		  Return New Win32.Utils.RegistryKey(HKEY_PERFORMANCE_NLSTEXT, SubKeyPath, AccessRights)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function PerformanceDataText(SubKeyPath As String = "", AccessRights As Integer = KEY_ALL_ACCESS) As Win32.Utils.RegistryKey
		  Return New Win32.Utils.RegistryKey(HKEY_PERFORMANCE_TEXT, SubkeyPath, AccessRights)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Subkey() As String
		  Return mSubkey
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Type(ValueName As String) As Integer
		  Dim tp, sz As Integer
		  mLastError = Win32.Libs.AdvApi32.RegGetValue(mHandle, mSubkey, ValueName, RRF_RT_ANY, tp, Nil, sz)
		  If mLastError <> 0 Then
		    Dim err As New RegistryAccessErrorException
		    err.ErrorNumber = mLastError
		    err.Message = FormatError(mLastError)
		    Raise err
		  End If
		  Return tp
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function Users(SubKeyPath As String = "", AccessRights As Integer = KEY_ALL_ACCESS) As Win32.Utils.RegistryKey
		  Return New Win32.Utils.RegistryKey(HKEY_USERS, SubKeyPath, AccessRights)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value(ValueName As String, RegType As Integer = REG_NONE) As Variant
		  Dim flags As Integer
		  Select Case RegType
		  Case REG_NONE
		    flags = RRF_RT_ANY
		  Case REG_DWORD, REG_DWORD_BIG_ENDIAN, REG_DWORD_LITTLE_ENDIAN
		    flags = RRF_RT_DWORD
		  Case REG_BINARY
		    flags = RRF_RT_REG_BINARY
		  Case REG_SZ
		    flags = RRF_RT_REG_SZ
		  Case REG_EXPAND_SZ
		    flags = RRF_RT_REG_EXPAND_SZ
		    
		  End Select
		  
		  Const ERROR_MORE_DATA = &hEA
		  Dim buffer As MemoryBlock
		  Dim sz As Integer
		  Do
		    buffer = New MemoryBlock(sz)
		    mLastError = Win32.Libs.AdvApi32.RegGetValue(mHandle, "", ValueName, flags, RegType, buffer, sz)
		  Loop Until mLastError <> ERROR_MORE_DATA
		  If mLastError <> 0 Then
		    Dim err As New RegistryAccessErrorException
		    err.ErrorNumber = mLastError
		    err.Message = FormatError(mLastError)
		    Raise err
		  End If
		  Select Case RegType
		  Case REG_DWORD
		    Return buffer.Int32Value(0)
		    
		  Case REG_BINARY, REG_EXPAND_SZ, REG_MULTI_SZ, REG_SZ
		    Dim out As New MemoryBlock(sz)
		    out.StringValue(0, sz) = buffer.StringValue(0, sz)
		    If RegType = REG_BINARY Then Return out
		    Return DefineEncoding(out, Encodings.UTF16)
		    
		  Else
		    Raise New TypeMismatchException
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Value(SubKeyName As String, RegType As Integer = REG_NONE, Assigns NewValue As Variant)
		  Dim data As MemoryBlock
		  If RegType = REG_NONE Then
		    Select Case VarType(NewValue)
		    Case Variant.TypeBoolean
		      If NewValue.BooleanValue Then
		        Me.Value(SubKeyName, REG_DWORD) = 1
		      Else
		        Me.Value(SubKeyName, REG_DWORD) = 0
		      End If
		      Return
		    Case Variant.TypeColor
		      Dim mb As New MemoryBlock(4)
		      mb.Byte(0) = NewValue.ColorValue.Red
		      mb.Byte(1) = NewValue.ColorValue.Green
		      mb.Byte(2) = NewValue.ColorValue.Blue
		      mb.Byte(3) = NewValue.ColorValue.Alpha
		      Me.Value(SubKeyName, REG_DWORD) = mb.Int32Value(0)
		      Return
		    Case Variant.TypeCString, Variant.TypeString, Variant.TypeWString
		      data = NewValue.StringValue
		      Me.Value(SubKeyName, REG_SZ) = NewValue
		      Return
		    Case Variant.TypeInteger
		      Me.Value(SubKeyName, REG_DWORD) = NewValue.Int32Value
		      Return
		    Case Variant.TypeObject
		      If NewValue IsA MemoryBlock Then
		        data = NewValue
		        RegType = REG_BINARY
		      Else
		        Raise New IllegalCastException
		      End If
		    Else
		      Raise New TypeMismatchException
		    End Select
		  Else
		    Select Case RegType
		    Case REG_BINARY, REG_SZ, REG_MULTI_SZ
		      data = NewValue.WStringValue
		      
		    Case REG_DWORD, REG_DWORD_BIG_ENDIAN, REG_DWORD_LITTLE_ENDIAN
		      data = New MemoryBlock(4)
		      If RegType = REG_DWORD_BIG_ENDIAN Then
		        data.LittleEndian = False
		      ElseIf RegType = REG_DWORD_LITTLE_ENDIAN Then
		        data.LittleEndian = True
		      End If
		      data.Int32Value(0) = NewValue.Int32Value
		    Else
		      Raise New UnsupportedFormatException
		    End Select
		  End If
		  
		  mLastError = Win32.Libs.AdvApi32.RegSetValueEx(mHandle, SubKeyName, 0, RegType, data, data.Size)
		  If mLastError <> 0 Then
		    Dim err As New RegistryAccessErrorException
		    err.ErrorNumber = mLastError
		    err.Message = FormatError(mLastError)
		    Raise err
		  End If
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		ExpandStrings As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mAccessMask As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHandle As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mLastError As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOptions As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSubkey As String
	#tag EndProperty


	#tag Constant, Name = HKEY_CLASSES_ROOT, Type = Double, Dynamic = False, Default = \"&h80000000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = HKEY_CURRENT_CONFIG, Type = Double, Dynamic = False, Default = \"&h80000005", Scope = Private
	#tag EndConstant

	#tag Constant, Name = HKEY_CURRENT_USER, Type = Double, Dynamic = False, Default = \"&h80000001", Scope = Private
	#tag EndConstant

	#tag Constant, Name = HKEY_CURRENT_USER_LOCAL_SETTINGS, Type = Double, Dynamic = False, Default = \"&h80000007", Scope = Private
	#tag EndConstant

	#tag Constant, Name = HKEY_DYN_DATA, Type = Double, Dynamic = False, Default = \"&h80000006", Scope = Private
	#tag EndConstant

	#tag Constant, Name = HKEY_LOCAL_MACHINE, Type = Double, Dynamic = False, Default = \"&h80000002", Scope = Private
	#tag EndConstant

	#tag Constant, Name = HKEY_PERFORMANCE_DATA, Type = Double, Dynamic = False, Default = \"&h80000004", Scope = Private
	#tag EndConstant

	#tag Constant, Name = HKEY_PERFORMANCE_NLSTEXT, Type = Double, Dynamic = False, Default = \"&h80000060", Scope = Private
	#tag EndConstant

	#tag Constant, Name = HKEY_PERFORMANCE_TEXT, Type = Double, Dynamic = False, Default = \"&h80000050", Scope = Private
	#tag EndConstant

	#tag Constant, Name = HKEY_USERS, Type = Double, Dynamic = False, Default = \"&h80000003", Scope = Private
	#tag EndConstant

	#tag Constant, Name = KEY_ALL_ACCESS, Type = Double, Dynamic = False, Default = \"&h0000003F", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_CREATE_LINK, Type = Double, Dynamic = False, Default = \"&h0020", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_CREATE_SUB_KEY, Type = Double, Dynamic = False, Default = \"&h0004", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_ENUMERATE_SUB_KEYS, Type = Double, Dynamic = False, Default = \"&h0008", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_NOTIFY, Type = Double, Dynamic = False, Default = \"&h0010", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_QUERY_VALUE, Type = Double, Dynamic = False, Default = \"&h0001", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_READ, Type = Double, Dynamic = False, Default = \"&h20019", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_SET_VALUE, Type = Double, Dynamic = False, Default = \"&h0002", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_WOW64_32KEY, Type = Double, Dynamic = False, Default = \"&h0200", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_WOW64_64KEY, Type = Double, Dynamic = False, Default = \"&h0100", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_WOW64_RES, Type = Double, Dynamic = False, Default = \"&h0300", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_WRITE, Type = Double, Dynamic = False, Default = \"&h20006", Scope = Public
	#tag EndConstant

	#tag Constant, Name = REG_BINARY, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = REG_DWORD, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = REG_DWORD_BIG_ENDIAN, Type = Double, Dynamic = False, Default = \"5", Scope = Public
	#tag EndConstant

	#tag Constant, Name = REG_DWORD_LITTLE_ENDIAN, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = REG_EXPAND_SZ, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = REG_FULL_RESOURCE_DESCRIPTOR, Type = Double, Dynamic = False, Default = \"9", Scope = Public
	#tag EndConstant

	#tag Constant, Name = REG_LINK, Type = Double, Dynamic = False, Default = \"6", Scope = Public
	#tag EndConstant

	#tag Constant, Name = REG_MULTI_SZ, Type = Double, Dynamic = False, Default = \"7", Scope = Public
	#tag EndConstant

	#tag Constant, Name = REG_NONE, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = REG_RESOURCE_LIST, Type = Double, Dynamic = False, Default = \"8", Scope = Public
	#tag EndConstant

	#tag Constant, Name = REG_RESOURCE_REQUIREMENTS_LIST, Type = Double, Dynamic = False, Default = \"10", Scope = Public
	#tag EndConstant

	#tag Constant, Name = REG_SZ, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = RRF_NOEXPAND, Type = Double, Dynamic = False, Default = \"&h10000000", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = RRF_RT_ANY, Type = Double, Dynamic = False, Default = \"&h0000ffff", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = RRF_RT_DWORD, Type = Double, Dynamic = False, Default = \"&h00000018", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = RRF_RT_QWORD, Type = Double, Dynamic = False, Default = \"&h00000048", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = RRF_RT_REG_BINARY, Type = Double, Dynamic = False, Default = \"&h00000008", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = RRF_RT_REG_DWORD, Type = Double, Dynamic = False, Default = \"&h00000010", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = RRF_RT_REG_EXPAND_SZ, Type = Double, Dynamic = False, Default = \"&h00000004", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = RRF_RT_REG_MULTI_SZ, Type = Double, Dynamic = False, Default = \"&h00000020", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = RRF_RT_REG_NONE, Type = Double, Dynamic = False, Default = \"&h00000001", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = RRF_RT_REG_QWORD, Type = Double, Dynamic = False, Default = \"&h00000040", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = RRF_RT_REG_SZ, Type = Double, Dynamic = False, Default = \"&h00000002", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = RRF_ZEROONFAILURE, Type = Double, Dynamic = False, Default = \"&h20000000", Scope = Protected
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="ExpandStrings"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
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
End Class
#tag EndClass
