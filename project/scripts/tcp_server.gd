class_name AstrumTCPServer
extends Node

#=============================== VARIABLES ===============================

#================ PUBLIC ================
 
#================ PRIVATE ================

var _tcp_server : TCPServer = null
var _connected_peers : Array[StreamPeerTCP]

enum EOpCode {STATUS_CHECK = 0, GALAXY_STATUS = 1, PLANET_STATUS = 2, SUBMIT_OPERATION_RESULT = 3}

#=============================== FUNCTIONS ===============================

#================ PUBLIC ================

# DONE
func start_server(p_port : int) -> void:
	if _tcp_server:
		push_error("start_server(): Server already running")
		return
		
	_tcp_server = TCPServer.new()
	_tcp_server.listen(p_port)
	print("TCP Server started at port ", p_port)


# DONE
func stop_server() -> void:
	if not _tcp_server:
		return
		
	_tcp_server.stop()
	_tcp_server = null
	print("TCP Server stopped")
	
#================ PRIVATE ================

# TODO
func _process(delta: float) -> void:
	if not _tcp_server:
		return
	
	# Take available connections
	while _tcp_server.is_connection_available():
		var _peer : StreamPeerTCP = _tcp_server.take_connection()
		_connected_peers.push_back(_peer)
		print("Client connected, current clients: ", _connected_peers.size())
	
	var __peers_to_delete : Array[StreamPeerTCP]
	for __peer in _connected_peers:
		if __peer:
			__peer.poll()
			if __peer.get_status() == StreamPeerSocket.Status.STATUS_CONNECTED:
				var __bytes_available : int = __peer.get_available_bytes()
				if __bytes_available > 0:
					var __request_arr : Array = __peer.get_data(__bytes_available)
					var __bytes : PackedByteArray = __request_arr[1]
					if __bytes.size() > 0:
						# Process request
						var __op_code : int = __bytes.decode_u8(0)
						var __version : int = __bytes.decode_u16(1)
						match __op_code:
							EOpCode.STATUS_CHECK:
								var __response : PackedByteArray		# OpCode | Result
								__response.resize(2)
								__response.encode_u8(0, EOpCode.STATUS_CHECK)
								__response.encode_u8(1, 0)
								__peer.put_data(__response)
								__peer.disconnect_from_host()
								__peers_to_delete.push_back(__peer)
							
							EOpCode.GALAXY_STATUS:
								# OpCode | Version
								var __response : PackedByteArray		# OpCode | Result | Galaxy Data
								__response.resize(2)
								__response.encode_u8(0, EOpCode.GALAXY_STATUS)
								__response.encode_u8(1, 0)
								__response.append_array(var_to_bytes(Global.main.get_galaxy_status()))
								__peer.put_data(__response)
								__peer.disconnect_from_host()
								__peers_to_delete.push_back(__peer)
							
							EOpCode.PLANET_STATUS:							# TODO
								# OpCode | Version | Planet Name
								var __response : PackedByteArray		# OpCode | Result | Planet Data
								__response.resize(2)
								__response.encode_u8(0, EOpCode.GALAXY_STATUS)
								__response.encode_u8(1, 0)
								__response.append_array(var_to_bytes(Global.main.get_galaxy_status()))
								__peer.put_data(__response)
								__peer.disconnect_from_host()
								__peers_to_delete.push_back(__peer)
							
							EOpCode.SUBMIT_OPERATION_RESULT:
								# OpCode | Version | Difficulty | HWID | Planet
								var __difficulty : int = __bytes.decode_u8(3)
								var __contribution_points : int = Global.main.convert_difficulty_to_contribution(__difficulty)
								
								# Add player progress
#								Global.main.set_planet_control_value(Global.main.loaded_planet_ercaris_config_file.get_value("hp", "current_hp") + __contribution_points)
								
								var __response : PackedByteArray		# OpCode | Result | Contribution Points | Galaxy Data
								__response.resize(10)
								__response.encode_u8(0, EOpCode.SUBMIT_OPERATION_RESULT)
								__response.encode_u8(1, 0)
								__response.encode_u64(2, __contribution_points)
								__response.append_array(var_to_bytes(Global.main.get_galaxy_status()))
								__peer.put_data(__response)
								__peer.disconnect_from_host()
								__peers_to_delete.push_back(__peer)
								
							_:
								__peer.disconnect_from_host()
								__peers_to_delete.push_back(__peer)
			elif __peer.get_status() == StreamPeerSocket.Status.STATUS_NONE or __peer.get_status() == StreamPeerSocket.Status.STATUS_ERROR:
				__peer.disconnect_from_host()
				__peers_to_delete.push_back(__peer)
		else:
			__peers_to_delete.push_back(__peer)
	
	# Remove disconnected peers
	for __peer in __peers_to_delete:
		_connected_peers.erase(__peer)
	
#=============================== CALLBACKS ===============================

########################## END OF FILE ##########################
