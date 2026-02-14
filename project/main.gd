class_name Main
extends Node

#=============================== VARIABLES ===============================

#================ PUBLIC ================

@export_group("Setup")
@export var port : int = 35000
@export_group("Internal")
@export var tcp_server : AstrumTCPServer = null

#================ PRIVATE ================

#=============================== FUNCTIONS ===============================

#================ PUBLIC ================

#================ PRIVATE ================

func _ready() -> void:
	assert(tcp_server)
	
	# Start TCP server
	tcp_server.start_server(port)
	
#=============================== CALLBACKS ===============================

########################## END OF FILE ##########################
