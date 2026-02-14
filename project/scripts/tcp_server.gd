class_name AstrumTCPServer
extends Node

#=============================== VARIABLES ===============================

#================ PUBLIC ================


 
#================ PRIVATE ================

var _tcp_server : TCPServer = null
var _connected_peers : Array[StreamPeerTCP]

#=============================== FUNCTIONS ===============================

#================ PUBLIC ================

func start_server(p_port : int) -> void:
	if _tcp_server:
		push_error("start_server(): Server already running")
		return
		
	_tcp_server = TCPServer.new()
	_tcp_server.listen(p_port)
	print("TCP Server started at port ", p_port)


func stop_server() -> void:
	if not _tcp_server:
		return
		
	_tcp_server.stop()
	_tcp_server = null
	print("TCP Server stopped")
	
#================ PRIVATE ================

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
							1:		# Get planet status
								# OpCode | Version
								var __response : PackedByteArray		# OpCode | Result | Planet Data
								__response.resize(2)
								__response.encode_u8(0, 1)
								__response.encode_u8(1, 0)
								__response.append_array(var_to_bytes({"value": randi_range(1,80), "max_value": 30000}))
								__peer.put_data(__response)
								__peer.disconnect_from_host()
								__peers_to_delete.push_back(__peer)
								
							2:		# Submit operation result
								# OpCode | Version | Difficulty
								var __difficulty : int = __bytes.decode_u8(3)
								var __response : PackedByteArray		# OpCode | Result | Contribution Points | Planet Data
								__response.resize(10)
								__response.encode_u8(0, 2)
								__response.encode_u8(1, 0)
								__response.encode_u64(2, __difficulty)
								__response.append_array(var_to_bytes({"value": 70, "max_value": 30000}))
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
