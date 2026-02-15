extends Timer

#=============================== VARIABLES ===============================

#================ PUBLIC ================

#================ PRIVATE ================

#=============================== FUNCTIONS ===============================

#================ PUBLIC ================

#================ PRIVATE ================

func _ready() -> void:
	timeout.connect(_on_timeout)
	
#=============================== CALLBACKS ===============================

func _on_timeout() -> void:
	assert(Global.main.loaded_config_file)
	
	var __attacker_value : int = Global.main.loaded_planet_ercaris_config_file.get_value("ai", "ai_attacker_value")
	var __defender_value : int = Global.main.loaded_planet_ercaris_config_file.get_value("ai", "ai_defender_value")
	var __tick_time : float = Global.main.loaded_config_file.get_value("ai", "ai_tick_seconds")
	
	# Change planet control value
	Global.main.set_planet_control_value(Global.main.loaded_planet_ercaris_config_file.get_value("hp", "current_hp") - (__attacker_value - __defender_value))
	
	# Start new tick delay
	start(__tick_time)
		
########################## END OF FILE ##########################
