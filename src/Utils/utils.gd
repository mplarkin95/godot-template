class_name Utils extends RefCounted


static func get_time_string(time: float):
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)
	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
