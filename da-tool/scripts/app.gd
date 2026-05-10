extends ColorRect


func _ready() -> void:
	var v:Viewport = get_viewport()
	v.files_dropped.connect(on_files_dropped)
func on_files_dropped(files:PackedStringArray):
	for f:String in files:
		var allow:bool = false
		var s:String = "*." + f.get_extension()
		for i:Array in DAT.supported_file_types:
			if i[0] == s:
				allow = true
				break
		if allow:
			DAT.load_data_package(f) #this should ouput the DAT assets.
		if s == "*.dbp":
			var F:FileAccess = FileAccess.open(f,FileAccess.READ)
			if !F:
				return
			#reassemble dbp back into a encrypted DAT file.
			DAT.FLAG_INFO.resize(5)
			
			DAT.MANAGER.clear()
			#print(f.get_base_dir())
			var all_files:PackedStringArray = get_all_files(f.get_base_dir())
			var sort_array:Array = []
			sort_array.resize(all_files.size())
			for i:int in range(0, all_files.size()):
				var number:int = int(all_files[i].get_file().split('_')[1].split('.')[0])
				sort_array[i] = [all_files[i],number]
			sort_array.sort_custom(func(a,b) -> bool:
				return a[1] < b[1])
			
			var ALL_PATHS:PackedStringArray = []
			for i:int in range(0, sort_array.size()):
				if FileAccess.file_exists(sort_array[i][0]) && FileAccess.file_exists(sort_array[i][0] + ".i"):
					ALL_PATHS.append(sort_array[i][0])
					ALL_PATHS.append(sort_array[i][0] + ".i")
				
			DAT.dat_data_array.clear()
			DAT.dat_data_array.resize(roundi(ALL_PATHS.size()/2))
			for i:int in range(0, ALL_PATHS.size(),2):
				var index:int = roundi(i / 2)
				#print(ALL_PATHS[i])
				DAT.dat_data_array[index] = [ALL_PATHS[i].get_file().split('_')[0], FileAccess.get_file_as_bytes(ALL_PATHS[i+1]), FileAccess.get_file_as_bytes(ALL_PATHS[i])]
			F.seek(F.get_8() + 1)
			DAT.FLAG_INFO[0] = F.get_32()
			DAT.FLAG_INFO[1] = F.get_32()
			DAT.FLAG_INFO[2] = F.get_32()
			DAT.FLAG_INFO[3] = F.get_32()
			DAT.FLAG_INFO[4] = F.get_32()
			DAT.MANAGER.refresh()
			
#chatgpt helped me on this one lmao 🥀
func get_all_files(path:String, files:Array = []) -> PackedStringArray:
	var dir := DirAccess.open(path)
	
	if dir == null:
		push_error("Cannot open directory: " + path)
		return files
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name == "":
			break
		# Skip hidden/system entries
		if file_name.begins_with("."):
			continue
		var full_path := path.path_join(file_name)
		if dir.current_is_dir():
			get_all_files(full_path, files)
		else:
			if "#IGNORE" not in full_path && full_path.get_extension() != "i":
				var vt:PackedStringArray = full_path.get_file().split('_') #check if the file type is correct
				if vt.size() == 2:
					var vt2:PackedStringArray = vt[1].split('.')
					if vt2.size() == 2:
						if vt2[0].is_valid_int():
							
							files.append(full_path)
	dir.list_dir_end()
	return files
