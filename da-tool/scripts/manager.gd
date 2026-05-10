extends VBoxContainer
@onready var tip:Label = $"../../../tip"
var default_press_look:StyleBoxFlat
@onready var context_menu:VBoxContainer = $"../../../context_menu"
@onready var file:FileDialog = $"../../../FileDialog"


@onready var OPT:MenuButton = $"../../../options"
func _ready() -> void:
	default_press_look = StyleBoxFlat.new()
	default_press_look.bg_color = Color(1,1,1,0.5)
	default_press_look.corner_radius_bottom_left = 4
	default_press_look.corner_radius_bottom_right = 4
	default_press_look.corner_radius_top_left = 4
	default_press_look.corner_radius_top_right = 4
	context_menu.visible = false
	OPT.get_popup().id_pressed.connect(FILE_)
	#file.show()
	
	
func clear() -> void:
	tip.visible = true
	for i:Node in get_children(true):
		i.free()
		
			
func refresh() -> void:
	if DAT.dat_data_array.size() > 0:
		tip.visible = false
	for i:int in range(0,DAT.dat_data_array.size()):
		var b:Button = Button.new()
		add_child(b)
		
		#print(i, "   ", DAT.dat_data_array.size(), "     ",DAT.dat_data_array[i][0])
		
		var size_count:float = DAT.dat_data_array[i][2].size()
		var sulfix:String = "Byte(s)"
		if size_count >= 1024.0:
			size_count /= 1024.0
			sulfix = "Kilobyte(s)"
		if size_count >= 1024.0:
			size_count /= 1024.0
			sulfix = "Megabyte(s)" #ok?
		if size_count >= 1024.0:
			size_count /= 1024.0
			sulfix = "Gigabyte(s)" #what the fuck are you trying to put in the game
		if size_count >= 1024.0:
			size_count /= 1024.0
			sulfix = "Terabyte(s)" #holy shit bruh
			
		
		b.text = " " + str(i) + " |     " + DAT.dat_data_array[i][0] + "     |     " + type(DAT.dat_data_array[i][0])  + "     |     " +  "%.2f" % size_count + " " + sulfix
		
		#b.set_meta("ID",i)
		b.name = str(i)
		b.clip_text = true
		#b.button_mask = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT
		b.button_mask = 0
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.toggle_mode = true
		b.add_theme_stylebox_override("pressed",default_press_look)
		b.gui_input.connect(func(event:InputEvent):
			if event is InputEventMouseButton && !event.pressed:
				if event.button_index == 1:
					context_menu.visible = false
					
					get_node(str(i)).button_pressed = true
					if !Input.is_action_pressed("CTRL") && !Input.is_action_pressed("SHIFT"):
						deselect_all(i)
					if !Input.is_action_pressed("CTRL") && Input.is_action_pressed("SHIFT"):
						var selected_nodes:PackedInt32Array = selected_children()
						selected_nodes.append(i)
						selected_nodes.sort()
						for a:int in range(selected_nodes[0], selected_nodes[selected_nodes.size()-1]):
							if a == i:
								continue
							var t:Node = get_node_or_null(str(a))
							t.button_pressed = true
				if event.button_index == 2:
					var selected_nodes:PackedInt32Array = selected_children()
					if i in selected_nodes:
						context_menu.visible = true
						context_menu.global_position = get_viewport().get_mouse_position()
					else:
						deselect_all(i)
						get_node(str(i)).button_pressed = true
						context_menu.visible = true
						context_menu.global_position = get_viewport().get_mouse_position()
					
			)
func type(t:String) -> String:
	match(t):
		"MOT":
			return "Animation file"
		"SEQ":
			return "Animation config file"
		"DDP":
			return "Texture container file"
		"MD":
			return "Model file"
		"DDS":
			return "Texture file"
			
	return "Unknown"
func deselect_all(remaining:int) -> void:
	for i:Node in get_children(true):
		if i is Button:
			if int(i.name) != remaining:
				i.button_pressed = false
func selected_children() -> PackedInt32Array:
	var ret:PackedInt32Array = []
	for i:Node in get_children(true):
		if i is Button:
			if i.button_pressed:
				ret.append(int(i.name))
	
	return ret


var MENU_SELECTOR:int = 0
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("LOAD"):
		FILE_(0)
	if Input.is_action_just_pressed("SAVE"):
		FILE_(1)
	if Input.is_action_just_pressed("SAVE_UNENC"):
		FILE_(2)
		
func FILE_(id:int) -> void:
	context_menu.visible = false
	MENU_SELECTOR = id
	match id:
		0:
			file.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			file.clear_filename_filter()
			file.clear_filters()
			for i:Array in DAT.supported_file_types:
				file.add_filter(i[0],i[1])
			file.show()
		1:
			file.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			file.clear_filename_filter()
			file.clear_filters()
			for i:Array in DAT.supported_file_types:
				file.add_filter(i[0],i[1])
			file.show()
		2:
			file.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			file.clear_filename_filter()
			file.clear_filters()
			for i:Array in DAT.supported_file_types:
				file.add_filter(i[0],i[1])
			file.show()
			
			
		9999:
			file.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			file.clear_filename_filter()
			file.clear_filters()
			file.show()
		
func file_selected(path: String) -> void:
	match MENU_SELECTOR:
		0:
			DAT.load_data_package(path)
		1:
			DAT.save_file(path,true)
		2:
			DAT.save_file(path,false)
			
			
			
		9999:
			var index:int = selected_children()[0]
			DAT.replace_content(index,path)
			DAT.LOG.ADD_LOG("Item index " + str(index) + " data was replaced by " + path)
			var UPDATE:Node = get_node(str(index))
			
			
			var size_count:float = DAT.dat_data_array[index][2].size()
			var sulfix:String = "Byte(s)"
			if size_count >= 1024.0:
				size_count /= 1024.0
				sulfix = "Kilobyte(s)"
			if size_count >= 1024.0:
				size_count /= 1024.0
				sulfix = "Megabyte(s)" #ok?
			if size_count >= 1024.0:
				size_count /= 1024.0
				sulfix = "Gigabyte(s)" #what the fuck are you trying to put in the game
			if size_count >= 1024.0:
				size_count /= 1024.0
				sulfix = "Terabyte(s)" #holy shit bruh
			UPDATE.text = " " + str(index) + " |     " + DAT.dat_data_array[index][0] + "     |     " + type(DAT.dat_data_array[index][0])  + "     |     " +  "%.2f" % size_count + " " + sulfix
func export_partial() -> void:
	context_menu.visible = false
	DAT.LOG.ADD_LOG("Exporting selected contents.")
	var sel:PackedInt32Array = selected_children()
	DAT.export(sel)
	DAT.LOG.ADD_LOG("Selected contents were exported to path " + DAT.TEMP_PATH)
	
func export_all() -> void:
	context_menu.visible = false
	DAT.LOG.ADD_LOG("Exporting all contents.")
	DAT.export_all()
	DAT.LOG.ADD_LOG("All contents were exported to path " + DAT.TEMP_PATH)
	
	


		
