#tag Module
Protected Module Compression
	#tag Method, Flags = &h1
		Protected Function Compress(Data As MemoryBlock, MaximumCompression As Boolean = False, ChunkLen As Integer = 512) As MemoryBlock
		  Dim engine As Integer = COMPRESSION_FORMAT_LZNT1
		  If MaximumCompression Then
		    engine = engine Or COMPRESSION_ENGINE_MAXIMUM
		  End If
		  Dim sz, fragsize  As Integer
		  If Win32.NTDLL.RtlGetCompressionWorkSpaceSize(engine, sz, fragsize) = 0 Then
		    Dim workspace As New MemoryBlock(sz)
		    Dim output As New MemoryBlock(sz)
		    If Win32.NTDLL.RtlCompressBuffer(engine, data, data.Size, output, output.Size, ChunkLen, fragsize, workspace) <> 0 Then
		      Break
		    Else
		      Return output
		    End If
		  End If
		End Function
	#tag EndMethod


End Module
#tag EndModule
