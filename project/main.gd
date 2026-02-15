class_name Main
extends Node

#=============================== VARIABLES ===============================

#================ PUBLIC ================

@export_group("Setup")
@export var port : int = 35000
@export_group("Internal")
@export var tcp_server : AstrumTCPServer = null
@export var ai_progress_timer : Timer = null
@export var config_loader_timer : Timer = null

var loaded_config_file : ConfigFile = null
var loaded_planet_ercaris_config_file : ConfigFile = null

#================ PRIVATE ================

#=============================== FUNCTIONS ===============================

#================ PUBLIC ================

func convert_difficulty_to_contribution(p_difficulty : int) -> int:
	match p_difficulty:
		1:
			return loaded_config_file.get_value("contribution", "easy")
		2:
			return loaded_config_file.get_value("contribution", "medium")
		3:
			return loaded_config_file.get_value("contribution", "hard")
		4:
			return loaded_config_file.get_value("contribution", "heroic")
		_:
			return 0


func set_planet_control_value(p_new_value : int) -> void:
	# Load config into memory
	var __config : ConfigFile = ConfigFile.new()
	var __config_path : String
	
	if OS.has_feature("export"):
		__config_path = OS.get_executable_path().get_base_dir() + "/data/planets/ercaris.cfg"
	else:
		__config_path = OS.get_executable_path().get_base_dir().get_base_dir() + "/local_data/planets/ercaris.cfg"
	var __err : Error = __config.load(__config_path)
	if __err != Error.OK:
		push_error("_on_config_loader_timer_timeout(): Failed to load config file at: ", __config_path)
		loaded_planet_ercaris_config_file = null
		return
	
	loaded_planet_ercaris_config_file = __config
	loaded_planet_ercaris_config_file.set_value("hp", "current_hp", p_new_value)
	loaded_planet_ercaris_config_file.save(__config_path)
	
#================ PRIVATE ================

func _enter_tree() -> void:
	# Register at Global
	Global.main = self
	
	
func _ready() -> void:
	assert(tcp_server)
	assert(ai_progress_timer)
	assert(config_loader_timer)
	
	# Signals
	config_loader_timer.timeout.connect( _on_config_loader_timer_timeout)
	
	# Load config files
	_on_config_loader_timer_timeout()
	
	# Start TCP server
	tcp_server.start_server(port)
	
	# Start AI Progress timer
	ai_progress_timer.start(loaded_config_file.get_value("ai", "ai_tick_seconds"))
	
#=============================== CALLBACKS ===============================

func _on_config_loader_timer_timeout() -> void:
	# Normal config
	var __config : ConfigFile = ConfigFile.new()
	var __config_path : String
	if OS.has_feature("export"):
		__config_path = OS.get_executable_path().get_base_dir() + "/data/config/config.cfg"
	else:
		__config_path = OS.get_executable_path().get_base_dir().get_base_dir() + "/local_data/config/config.cfg"
	var __err : Error = __config.load(__config_path)
	if __err != Error.OK:
		push_error("_on_config_loader_timer_timeout(): Failed to load config file at: ", __config_path)
		loaded_config_file = null
		return
	loaded_config_file = __config
	
	# Planet Ercaris config
	var __config__ercaris : ConfigFile = ConfigFile.new()
	var __config_ercaris__path : String
	if OS.has_feature("export"):
		__config_ercaris__path = OS.get_executable_path().get_base_dir() + "/data/planets/ercaris.cfg"
	else:
		__config_ercaris__path = OS.get_executable_path().get_base_dir().get_base_dir() + "/local_data/planets/ercaris.cfg"
	var __err_ercaris : Error = __config__ercaris.load(__config_ercaris__path)
	if __err_ercaris != Error.OK:
		push_error("_on_config_loader_timer_timeout(): Failed to load config file at: ", __config_ercaris__path)
		loaded_planet_ercaris_config_file = null
		return
	loaded_planet_ercaris_config_file = __config__ercaris
		
########################## END OF FILE ##########################
