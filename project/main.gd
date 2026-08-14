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
var loaded_planet_baes_ii__config_file : ConfigFile = null
var loaded_planet_storge_ignatius_config_file : ConfigFile = null
var loaded_planet_xtronia_prime_config_file : ConfigFile = null

enum EPlanets {
	ERCARIS,
	BAES_II,
	STORGE_IGNATIUS,
	XTRONIA_PRIME
}

#================ PRIVATE ================

#=============================== FUNCTIONS ===============================

#================ PUBLIC ================

# DONE
func get_galaxy_status() -> Dictionary:
	var __return_dict : Dictionary
	# Ercaris
	var __ercaris_dict : Dictionary = {}
	__ercaris_dict["value"] = loaded_planet_ercaris_config_file.get_value("hp", "current_hp")
	__ercaris_dict["max_value"] = loaded_planet_ercaris_config_file.get_value("hp", "max_hp")
	__ercaris_dict["defending"] = loaded_planet_ercaris_config_file.get_value("factions", "defending")
	__ercaris_dict["attacking"] = loaded_planet_ercaris_config_file.get_value("factions", "attacking")
	__ercaris_dict["ai_attacker_value"] = loaded_planet_ercaris_config_file.get_value("ai", "ai_attacker_value")
	__ercaris_dict["ai_defender_value"] = loaded_planet_ercaris_config_file.get_value("ai", "ai_defender_value")
	__return_dict["ercaris"] = __ercaris_dict
	
	# Baes II
	var __baes_ii_dict : Dictionary = {}
	__baes_ii_dict["value"] = loaded_planet_baes_ii__config_file.get_value("hp", "current_hp")
	__baes_ii_dict["max_value"] = loaded_planet_baes_ii__config_file.get_value("hp", "max_hp")
	__baes_ii_dict["defending"] = loaded_planet_baes_ii__config_file.get_value("factions", "defending")
	__baes_ii_dict["attacking"] = loaded_planet_baes_ii__config_file.get_value("factions", "attacking")
	__baes_ii_dict["ai_attacker_value"] = loaded_planet_baes_ii__config_file.get_value("ai", "ai_attacker_value")
	__baes_ii_dict["ai_defender_value"] = loaded_planet_baes_ii__config_file.get_value("ai", "ai_defender_value")
	__return_dict["baes_ii"] = __baes_ii_dict
	
	# Storge Ignatius
	var __storge_ignatius_dict : Dictionary = {}
	__storge_ignatius_dict["value"] = loaded_planet_storge_ignatius_config_file.get_value("hp", "current_hp")
	__storge_ignatius_dict["max_value"] = loaded_planet_storge_ignatius_config_file.get_value("hp", "max_hp")
	__storge_ignatius_dict["defending"] = loaded_planet_storge_ignatius_config_file.get_value("factions", "defending")
	__storge_ignatius_dict["attacking"] = loaded_planet_storge_ignatius_config_file.get_value("factions", "attacking")
	__storge_ignatius_dict["ai_attacker_value"] = loaded_planet_storge_ignatius_config_file.get_value("ai", "ai_attacker_value")
	__storge_ignatius_dict["ai_defender_value"] = loaded_planet_storge_ignatius_config_file.get_value("ai", "ai_defender_value")
	__return_dict["storge_ignatius"] = __storge_ignatius_dict
	
	# X'tronia Prime
	var __xtronia_prime_dict : Dictionary = {}
	__xtronia_prime_dict["value"] = loaded_planet_xtronia_prime_config_file.get_value("hp", "current_hp")
	__xtronia_prime_dict["max_value"] = loaded_planet_xtronia_prime_config_file.get_value("hp", "max_hp")
	__xtronia_prime_dict["defending"] = loaded_planet_xtronia_prime_config_file.get_value("factions", "defending")
	__xtronia_prime_dict["attacking"] = loaded_planet_xtronia_prime_config_file.get_value("factions", "attacking")
	__xtronia_prime_dict["ai_attacker_value"] = loaded_planet_xtronia_prime_config_file.get_value("ai", "ai_attacker_value")
	__xtronia_prime_dict["ai_defender_value"] = loaded_planet_xtronia_prime_config_file.get_value("ai", "ai_defender_value")
	__return_dict["xtronia_prime"] = __xtronia_prime_dict
	
	return __return_dict

func get_planet_status(p_planet : EPlanets) -> Dictionary:
	var __return_dict : Dictionary
	
	match p_planet:
		_:
			pass
			
	return __return_dict
			
	

# DONE
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

# TODO
func set_planet_control_value(p_new_value : int, p_config_file : ConfigFile) -> void:
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
	
	# Clamp value range
	var __max_value : int = loaded_planet_ercaris_config_file.get_value("hp", "max_hp")
	p_new_value = clampi(p_new_value, 0, __max_value)
	
	# TODO
	loaded_planet_ercaris_config_file = __config
	loaded_planet_ercaris_config_file.set_value("hp", "current_hp", p_new_value)
	loaded_planet_ercaris_config_file.save(__config_path)
	
#================ PRIVATE ================
# DONE
func _enter_tree() -> void:
	# Register at Global
	Global.main = self
	

# DONE
func _ready() -> void:
	assert(tcp_server)
	assert(ai_progress_timer)
	assert(config_loader_timer)
	
	var _id := OS.get_unique_id()
	
	# Signals
	config_loader_timer.timeout.connect( _on_config_loader_timer_timeout)
	
	# Load config files
	_load_configs()
	
	# Start TCP server
	tcp_server.start_server(port)
	
	# Start AI Progress timer
	ai_progress_timer.start(loaded_config_file.get_value("ai", "ai_tick_seconds"))


# DONE
func _load_planet_config(p_config_filename : String) -> ConfigFile:
	var __config__ercaris : ConfigFile = ConfigFile.new()
	var __config_ercaris__path : String
	if OS.has_feature("export"):
		__config_ercaris__path = OS.get_executable_path().get_base_dir() + "/data/planets/" + p_config_filename
	else:
		__config_ercaris__path = OS.get_executable_path().get_base_dir().get_base_dir() + "/local_data/planets/" + p_config_filename
	var __err_ercaris : Error = __config__ercaris.load(__config_ercaris__path)
	if __err_ercaris != Error.OK:
		push_error("_on_config_loader_timer_timeout(): Failed to load config file at: ", __config_ercaris__path)
		return null
	return __config__ercaris


# DONE
func _load_configs() -> void:
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
	loaded_planet_ercaris_config_file = _load_planet_config("ercaris.cfg")
	
	# Planet Baes II config
	loaded_planet_baes_ii__config_file = _load_planet_config("baes_ii.cfg")
	
	# Planet Storge Ignatius config
	loaded_planet_storge_ignatius_config_file = _load_planet_config("storge_ignatius.cfg")
	
	# Planet X'tronia Prime config
	loaded_planet_xtronia_prime_config_file = _load_planet_config("xtronia_prime.cfg")
	
#=============================== CALLBACKS ===============================

# DONE
func _on_config_loader_timer_timeout() -> void:
	_load_configs()
		
########################## END OF FILE ##########################
