extends Control

signal close_requested

## Assign your main menu scene in the inspector for "Quit to Menu".
@export var main_menu_scene: PackedScene

## Override to replace the built-in settings screen.
@export var settings_scene: PackedScene = preload("res://src/UI/screens/settings/settings_screen.tscn")


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	_build_ui()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_requested.emit()
		get_viewport().set_input_as_handled()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.6)
	bg.mouse_filter = MOUSE_FILTER_STOP
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(240, 0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Paused"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 16
	vbox.add_child(spacer)

	var resume_btn := Button.new()
	resume_btn.text = "Resume"
	resume_btn.custom_minimum_size.x = 160
	resume_btn.pressed.connect(func(): close_requested.emit())
	vbox.add_child(resume_btn)

	var settings_btn := Button.new()
	settings_btn.text = "Settings"
	settings_btn.custom_minimum_size.x = 160
	settings_btn.pressed.connect(_on_settings_pressed)
	vbox.add_child(settings_btn)

	var quit_btn := Button.new()
	quit_btn.text = "Quit to Menu"
	quit_btn.custom_minimum_size.x = 160
	quit_btn.pressed.connect(_on_quit_to_menu_pressed)
	vbox.add_child(quit_btn)


func _on_settings_pressed() -> void:
	if settings_scene:
		UIManager.push_screen(settings_scene, false)


func _on_quit_to_menu_pressed() -> void:
	UIManager.clear()
	if main_menu_scene:
		SceneTransitionManager.transition_to_scene(main_menu_scene)
	else:
		push_warning("PauseMenu: main_menu_scene not set — assign it in the inspector")
