# MIT License
# Copyright (c) 2022 BIFRACTAL - Florian Roth

tool
extends EditorPlugin

const SCENE_HISTORY_FILE : String = "user://default-scene-history.save"

var DefaultSceneSelector = preload("ui/DefaultSceneSelector.tscn")

var default_scene_selector	: HBoxContainer = null
var scene_selector			: OptionButton	= null
var scene_selector_popup	: PopupMenu		= null
var open_browser_button		: ToolButton	= null
var file_dialog				: FileDialog	= null

var settings : Dictionary = {
	"scenes"			: [],
	"selected_index"	: 0
}

# Enter Tree
func _enter_tree():
	var editor_interface = get_editor_interface()
	var editor_theme = editor_interface.get_base_control().theme
	
	# Initialize UI
	default_scene_selector = DefaultSceneSelector.instance()
	scene_selector = default_scene_selector.get_node("SceneSelector")
	scene_selector_popup = scene_selector.get_node("SceneSelectorPopupMenu")
	open_browser_button = default_scene_selector.get_node("OpenBrowserButton")
	
	# File Dialog
	file_dialog = FileDialog.new()
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.filters = ["*.tscn ; Scene Files"]
	add_child(file_dialog)
	
	file_dialog.owner = self
	file_dialog.theme = editor_theme
	file_dialog.rect_size.x = 1280.0
	file_dialog.rect_size.y = 720.0
	
	# Signals
	file_dialog.connect("file_selected", self, "_on_file_selected")
	open_browser_button.connect("pressed", self, "_on_open_browser_button_pressed")
	scene_selector.connect("item_selected", self, "_on_scene_selected")
	scene_selector.connect("gui_input", self, "_on_scene_selector_gui_input")
	scene_selector_popup.connect("index_pressed", self, "_on_scene_selector_popup_index_pressed")
	
	_load_initial_scenes()
	
	add_control_to_container(CONTAINER_TOOLBAR, default_scene_selector)
	
# Exit Tree
func _exit_tree():
	remove_control_from_container(CONTAINER_TOOLBAR, default_scene_selector)

# Load Initial Scenes
func _load_initial_scenes():
	scene_selector.add_item("None", 0)
	
	_load_settings()
	
	for i in settings.scenes.size():
		scene_selector.add_item(settings.scenes[i], i + 1)
	
	scene_selector.select(settings.selected_index)
	ProjectSettings.save()

# On Open Browser Button Pressed
func _on_open_browser_button_pressed():
	file_dialog.popup_centered()

# On File Selected
func _on_file_selected(path):
	if (settings.scenes.empty()):
		_add_scene(path)
		return
	
	for scene in settings.scenes:
		if (scene == path):
			return
	
	_add_scene(path)

# On Scene Selected
func _on_scene_selected(index):
	settings.selected_index = index
	_save_settings()
	
	if (index == 0):
		ProjectSettings.set_setting("application/run/main_scene", "")
		ProjectSettings.save()
		return
		
	var scene_path = scene_selector.get_item_text(index)
	ProjectSettings.set_setting("application/run/main_scene", scene_path)
	ProjectSettings.save()

# On Scene Selector GUI Input
func _on_scene_selector_gui_input(event: InputEvent):
	if (event is InputEventMouseButton):
		var mouse_button_event = event as InputEventMouseButton
		
		if (mouse_button_event.is_pressed() && mouse_button_event.button_index == BUTTON_RIGHT):
			scene_selector_popup.set_global_position(mouse_button_event.global_position)
			scene_selector_popup.popup()

# On Scene Selector Popup Index Pressed
func _on_scene_selector_popup_index_pressed(index):
	
	# Clear List
	if (index == 0):
		_clear_scenes()

# Add Scene To History
func _add_scene(scene_path : String):
	settings.scenes.append(scene_path)
	scene_selector.add_item(scene_path)
	_save_settings()

# Clear Scenes
func _clear_scenes():
	_on_scene_selected(0)
	
	settings.scenes.clear()
	settings.selected_index = 0
	
	scene_selector.clear()
	scene_selector.add_item("None", 0)
	
	_save_settings()

# Save Settings
func _save_settings():
	var file = File.new()
	
	if (file.open(SCENE_HISTORY_FILE, File.WRITE) != OK):
		push_warning("Could not save settings for default scene selector plugin.")
		return
	
	file.store_string(to_json(settings))
	file.close()

# Load Settings
func _load_settings():
	var file = File.new()
	
	if (file.open(SCENE_HISTORY_FILE, File.READ) != OK):
		#push_warning("Could not load settings for default scene selector plugin.")
		return
	
	# TODO Check ...
	while (file.get_position() < file.get_len()):
		var line = file.get_line()
		settings = parse_json(line)
		
		if (typeof(settings) != TYPE_DICTIONARY):
			push_warning("Could not save settings for default scene selector plugin. Invalid data type.")
	
	file.close()
