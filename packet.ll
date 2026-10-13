; Define a network packet header structure: { i32 source_ip, i32 telemetry_tag }
%struct.PacketHeader = type { i32, i32 }

define void @process_packet(%struct.PacketHeader* %pkt) {
entry:
  ; Extract a pointer to the source_ip (Index 0)
  %ip_ptr = getelementptr %struct.PacketHeader, %struct.PacketHeader* %pkt, i32 0, i32 0
  
  ; Simulate reading the IP address
  %ip_val = load i32, i32* %ip_ptr
  
  ; NOTE: We never generate any instructions to read or write the telemetry_tag (Index 1)
  
  ret void
}
