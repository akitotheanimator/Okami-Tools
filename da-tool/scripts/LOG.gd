extends VBoxContainer


func ADD_LOG(text:String) -> void:
	var T:Button = Button.new()
	T.pressed.connect(func():
		DisplayServer.clipboard_set(T.text))
	T.alignment = HORIZONTAL_ALIGNMENT_CENTER
	T.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(T)
	T.text = text
	await get_tree().create_timer(7).timeout
	var t:Tween = create_tween()
	t.tween_property(T,"self_modulate",Color(1,1,1,0),1)
	await t.finished
	T.queue_free()
