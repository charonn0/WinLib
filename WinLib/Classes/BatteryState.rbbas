#tag Class
Protected Class BatteryState
	#tag Method, Flags = &h0
		Function BatteryPresent() As Boolean
		  //Returns True if the computer has at least one battery.
		  
		  Dim procs() As SYSTEM_BATTERY_STATE = GetBatteryState()
		  Return procs(0).BatteryPresent
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Charging() As Boolean
		  //Returns True if a battery is charging.
		  
		  
		  Dim procs() As SYSTEM_BATTERY_STATE = GetBatteryState()
		  Return procs(0).Charging
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Constructor()
		  'empty
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CriticalAlarmLevel() As Integer
		  //Returns the recommended remaining battery capacity at which a critical battery alert should be given.
		  
		  
		  Dim procs() As SYSTEM_BATTERY_STATE = GetBatteryState()
		  Return procs(0).DefaultAlert2
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DischargeRate() As Integer
		  //Returns the current battery (dis)charge rate in milliwatt hours. Negative values
		  //indicate that the battery is discharging whereas positive values indicate that the
		  //battery is charging. Not all batteries report charging rates.
		  
		  
		  Dim procs() As SYSTEM_BATTERY_STATE = GetBatteryState()
		  Return procs(0).Rate
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Discharging() As Boolean
		  //Returns True if the computer is running on batteries.
		  
		  
		  Dim procs() As SYSTEM_BATTERY_STATE = GetBatteryState()
		  Return procs(0).Discharging
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function GetBatteryState() As SYSTEM_BATTERY_STATE()
		  #If TargetWin32 Then
		    
		    Const Battery = 5
		    
		    Dim info As New MemoryBlock(32 * WinLib.Devices.CPUCount)
		    Call WinLib.PowrProf.CallNtPowerInformation(Battery, Nil, 0, info, info.Size)
		    
		    Dim ret() As SYSTEM_BATTERY_STATE
		    For i As Integer = 0 To info.Size - 24 Step 24
		      Dim ppi As SYSTEM_BATTERY_STATE
		      ppi.ACOnline = info.BooleanValue(i)
		      ppi.BatteryPresent = info.BooleanValue(i + 1)
		      ppi.Charging = info.BooleanValue(i + 2)
		      ppi.Discharging = info.BooleanValue(i + 3)
		      ppi.MaxCapacity = info.Int32Value(i + 7)
		      ppi.RemainingCapacity = info.Int32Value(i + 11)
		      ppi.Rate = info.Int32Value(i + 15)
		      ppi.EstimatedTimer = info.Int32Value(i + 19)
		      ppi.DefaultAlert1 = info.Int32Value(i + 23)
		      ppi.DefaultAlert2 = info.Int32Value(i + 27)
		      
		      ret.Append(ppi)
		    Next
		    Return ret
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LowAlarmLevel() As Integer
		  //Returns the recommended remaining battery capacity at which a low-battery notice should be given.
		  
		  
		  Dim procs() As SYSTEM_BATTERY_STATE = GetBatteryState()
		  Return procs(0).DefaultAlert1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Maximum() As Integer
		  //Returns the maximum capacity of the battery in milliwatt hours.
		  
		  
		  Dim procs() As SYSTEM_BATTERY_STATE = GetBatteryState()
		  Return procs(0).MaxCapacity
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PluggedIn() As Boolean
		  //Returns True if the computer is plugged into the mains rather than running on batteries.
		  
		  
		  Dim procs() As SYSTEM_BATTERY_STATE = GetBatteryState()
		  Return procs(0).ACOnline
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RemainingCharge() As Integer
		  //Returns the remaining capacity of the battery in milliwatt hours.
		  
		  
		  Dim procs() As SYSTEM_BATTERY_STATE = GetBatteryState()
		  Return procs(0).RemainingCapacity
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RemainingTime() As Integer
		  //Returns the remaining capacity of the battery or batteries in milliwatt hours.
		  
		  
		  Dim procs() As SYSTEM_BATTERY_STATE = GetBatteryState()
		  Return procs(0).EstimatedTimer
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If mInstance = Nil Then mInstance = New WinLib.Classes.BatteryState
			  Return mInstance
			End Get
		#tag EndGetter
		Shared Instance As WinLib.Classes.BatteryState
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private Shared mInstance As WinLib.Classes.BatteryState
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
