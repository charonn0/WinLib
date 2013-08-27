#tag Class
Protected Class Hardware
	#tag Method, Flags = &h1
		Protected Sub Constructor()
		  ' empty
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CPUArch() As Integer
		  //Returns the CPU architecture of the installed operating system. See the PROCESSOR_ARCHITECTURE_* constants for possible return values
		  //This may differ from the information provided by OSArchitecture since a 32 bit OS can run on a 64 bit capable processor (see below)
		  
		  #If TargetWin32 Then
		    Dim info As SYSTEM_INFO
		    
		    If X64 Then
		      //The RB compiler, as of the time this function is being written, is incapable of creating 64 bit Windows executables.
		      //As a result, all RB applications under 64 bit Windows are executed within the Win32 subsystem of Win64 (WoW64)
		      //WoW64 accomplishes its task by, primarily, lying to the application about its environment. We have to
		      //specifically ask not to be lied to in these cases. Hence, this function call:
		      WinLib.Kernel32.GetNativeSystemInfo(info)
		    Else
		      WinLib.Kernel32.GetSystemInfo(info)
		    End If
		    
		    Return info.OEMID
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CPUCount() As Integer
		  //Returns the number of LOGICAL processor cores. e.g. a quad core processor with hyperthreading will have 8 logical cores.
		  
		  #If TargetWin32 Then
		    Dim info As SYSTEM_INFO
		    WinLib.Kernel32.GetSystemInfo(info)
		    Return info.numberOfProcessors
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CPUID() As String
		  //Returns the description for the installed processor as stored in the registry.
		  //e.g. "Intel64 Family 6 Model 42 Stepping 7"
		  
		  #If TargetWin32 Then
		    Dim reg As New RegistryItem("HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor\0", False)
		    Return reg.Value("Identifier")
		  #endif
		  
		Exception RegistryAccessErrorException
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CPUMHz() As Integer
		  //Returns the default speed in MHz of the processor. (this will not reflect overclocking)
		  #If TargetWin32 Then
		    Dim reg As New RegistryItem("HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor\0", False)
		    Return Val(reg.Value("~MHZ"))
		  #endif
		  
		Exception RegistryAccessErrorException
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CPUName() As String
		  //Returns the name of the processor recorded in the registry. e.g. "Intel(R) Core(TM) i7-2600K CPU @ 3.40GHz"
		  
		  #If TargetWin32 Then
		    Dim reg As New RegistryItem("HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\", False)
		    Return reg.Child("CentralProcessor").Child("0").Value("ProcessorNameString")
		  #endif
		  
		Exception RegistryAccessErrorException
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GlobalMemoryStatus() As MEMORYSTATUSEX
		  //Returns a MEMEORYSTATUSEX structure.
		  
		  #If TargetWin32 Then
		    Dim info As MEMORYSTATUSEX
		    info.sSize = info.Size
		    If WinLib.Kernel32.GlobalMemoryStatusEx(info) Then Return info
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MemoryLoad() As Integer
		  //Returns an Integer representing the percent of system memory currently in use.
		  
		  #If TargetWin32 Then Return GlobalMemoryStatus.MemLoad
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OEM() As String
		  //Returns the OEM manufacturer's name as recorded in the OEMINFO.INI file, if any.
		  
		  Dim f As FolderItem = SpecialFolder.System.Child("OEMINFO.INI")
		  If f <> Nil Then
		    If f.Exists Then
		      Dim tis As TextInputStream
		      tis = tis.Open(f)
		      While Not tis.EOF
		        Dim line As String = tis.ReadLine
		        If NthField(line, "=", 1) = "Manufacturer" Then
		          Return NthField(line, "=", 2)
		        End If
		      Wend
		    End If
		  End If
		  
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PageFileAvailable() As UInt64
		  //Returns an Unsigned 64 bit Integer representing the number of bytes of page file currently available.
		  
		  #If TargetWin32 Then Return GlobalMemoryStatus.AvailablePageFile
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PageFileTotal() As UInt64
		  //Returns an Unsigned 64 bit Integer representing the number of bytes allocated for all pagefiles.
		  
		  #If TargetWin32 Then Return GlobalMemoryStatus.TotalPageFile
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RAMAvailable() As UInt64
		  //Returns an Unsigned 64 bit Integer representing the number of bytes of physical RAM which are free.
		  
		  #If TargetWin32 Then Return GlobalMemoryStatus.AvailablePhysicalMemory
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RAMTotal() As UInt64
		  //Returns an Unsigned 64 bit Integer representing the number of bytes of physical RAM installed.
		  
		  #If TargetWin32 Then Return GlobalMemoryStatus.TotalPhysicalMemory
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function x64() As Boolean
		  //Returns 64 if the current operating system is a 64 bit build, 32 for 32 bit build, -1 on error or unknown architecture.
		  //This function assumes that the application itself is a 32 bit executable. Therefore, if REALSoftware one day releases a 64 bit
		  //capable compiler then the results of this function will become unreliable and I will be immensely pleased.
		  
		  #If TargetWin32 Then
		    Dim pHandle As Integer = WinLib.Kernel32.OpenProcess(PROCESS_QUERY_INFORMATION, False, WinLib.CurrentProcessID)
		    
		    Dim is64 As Boolean
		    If WinLib.Kernel32.IsWow64Process(pHandle, is64) Then
		      Return is64
		    End If
		  #endif
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If mInstance = Nil Then mInstance = New WinLib.Classes.Hardware
			  Return mInstance
			End Get
		#tag EndGetter
		Shared Instance As WinLib.Classes.Hardware
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private Shared mInstance As WinLib.Classes.Hardware
	#tag EndProperty


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
End Class
#tag EndClass
