extends CheckBox

func _ready() -> void:
	set_pressed_no_signal(DAT.save_unic_dat)
func _toggled(toggled_on: bool) -> void:
	DAT.save_unic_dat = toggled_on
	DAT.save_config()
