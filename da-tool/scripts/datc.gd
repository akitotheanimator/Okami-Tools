extends CheckBox

func _ready() -> void:
	set_pressed_no_signal(DAT.save_dat_cont)
func _toggled(toggled_on: bool) -> void:
	DAT.save_dat_cont = toggled_on
	DAT.save_config()
