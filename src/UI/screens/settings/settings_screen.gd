extends Control

signal close_requested

var _master_slider: HSlider
var _music_slider: HSlider
var _sfx_slider: HSlider
var _fullscreen_check: CheckButton


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.7)
	bg.mouse_filter = MOUSE_FILTER_STOP
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(360, 0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Settings"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	_master_slider = _add_volume_row(vbox, "Master", "Master")
	_music_slider = _add_volume_row(vbox, "Music", "Music")
	_sfx_slider = _add_volume_row(vbox, "SFX", "SFX")

	var fs_row := HBoxContainer.new()
	vbox.add_child(fs_row)
	var fs_label := Label.new()
	fs_label.text = "Fullscreen"
	fs_label.size_flags_horizontal = SIZE_EXPAND_FILL
	fs_row.add_child(fs_label)
	_fullscreen_check = CheckButton.new()
	_fullscreen_check.button_pressed = (
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	)
	fs_row.add_child(_fullscreen_check)

	var spacer := Control.new()
	spacer.size_flags_vertical = SIZE_EXPAND_FILL
	spacer.custom_minimum_size.y = 8
	vbox.add_child(spacer)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)
	vbox.add_child(btn_row)

	var apply_btn := Button.new()
	apply_btn.text = "Apply"
	apply_btn.custom_minimum_size.x = 100
	apply_btn.pressed.connect(_on_apply_pressed)
	btn_row.add_child(apply_btn)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size.x = 100
	close_btn.pressed.connect(func(): close_requested.emit())
	btn_row.add_child(close_btn)


func _add_volume_row(parent: VBoxContainer, label_text: String, bus_name: String) -> HSlider:
	var row := HBoxContainer.new()
	parent.add_child(row)

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 70
	row.add_child(label)

	var slider := HSlider.new()
	slider.min_value = -40.0
	slider.max_value = 0.0
	slider.step = 1.0
	slider.size_flags_horizontal = SIZE_EXPAND_FILL
	var idx := AudioServer.get_bus_index(bus_name)
	if idx != -1:
		slider.value = AudioServer.get_bus_volume_db(idx)
	row.add_child(slider)

	return slider


func _on_apply_pressed() -> void:
	var master_db := _master_slider.value
	var music_db := _music_slider.value
	var sfx_db := _sfx_slider.value
	var fullscreen := _fullscreen_check.button_pressed

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_db)
	var music_idx := AudioServer.get_bus_index("Music")
	if music_idx != -1:
		AudioServer.set_bus_volume_db(music_idx, music_db)
	var sfx_idx := AudioServer.get_bus_index("SFX")
	if sfx_idx != -1:
		AudioServer.set_bus_volume_db(sfx_idx, sfx_db)

	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	Settings.save(master_db, music_db, sfx_db, fullscreen)
