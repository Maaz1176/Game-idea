extends Control

const SAVE_PATH := "user://wayfinder_state.cfg"
const SAVE_VERSION := 1
const MAX_STAMINA := 100
const MAX_QUESTS := 5

const ITEMS := [
	{"name": "COMPASS", "kind": "compass"},
	{"name": "LANTERN", "kind": "lantern"},
	{"name": "POTION", "kind": "potion"},
	{"name": "ROPE", "kind": "rope"}
]

const QUESTS := [
	{
		"title": "Locate the old mill",
		"description": "Travel to the river and find the boarded-up watermill. The destination is marked in the adventurer's notebook."
	},
	{
		"title": "Gather three field samples",
		"description": "Collect three samples from the forest. Return them to the camp researcher after the expedition."
	},
	{
		"title": "Speak with the lighthouse keeper",
		"description": "Find the keeper, listen to their directions, then report what you learned to the expedition team."
	},
	{
		"title": "Investigate the extraordinarily mysterious and unexpectedly lengthy list of scattered ancient inscriptions along the northern ridge",
		"description": "LONG STRING TEST: This is intentionally a long quest description. Visit the northern ridge, catalogue every inscription that is visible from the footpath, compare the carvings against the maps supplied by the archivist, and return with clear notes. The quest list must truncate safely, while READ FULL provides all the text."
	},
	{
		"title": "Return to base camp",
		"description": "Finish the expedition by talking with the crew. Completing this quest should not clear your interface or overwrite your save without permission."
	}
]

var stamina: int = 65
var selected_slot: int = 0
var hotbar_items: Array[int] = [0, 1, 2, 3, -1]
var consumables: Dictionary = {"potion": 2}
var quest_entries: Array[Dictionary] = []
var selected_quest: int = -1
var slot_buttons: Array[Button] = []
var quest_buttons: Array[Button] = []


func _ready() -> void:
  
	_ensure_full_screen_layout()
	get_viewport().size_changed.connect(_ensure_full_screen_layout)
	slot_buttons.append_array([%Slot0, %Slot1, %Slot2, %Slot3, %Slot4])
	_set_defaults()
	_connect_buttons()
	if FileAccess.file_exists(SAVE_PATH):
		_load_state(true)
	else:
		_feedback("READY  /  Select 1–5; E uses an item. Tab explores every control.", true)
	_refresh_all()
	call_deferred("_focus_initial_slot")


func _ensure_full_screen_layout() -> void:
 
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x < 1.0 or viewport_size.y < 1.0:
		return
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	size = viewport_size
	$Backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$Frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$Backdrop.size = viewport_size
	$Frame.size = viewport_size


func _focus_initial_slot() -> void:
	slot_buttons[selected_slot].grab_focus()


func _connect_buttons() -> void:
	for i in range(slot_buttons.size()):
		var button: Button = slot_buttons[i]
		button.focus_mode = Control.FOCUS_ALL
		button.pressed.connect(_select_slot.bind(i))
	%UseItem.pressed.connect(_use_hotbar_item)
	%CycleItem.pressed.connect(_cycle_item)
	%ClearItem.pressed.connect(_clear_item)
	%SprintButton.pressed.connect(_sprint)
	%RecoverButton.pressed.connect(_recover)
	%AddQuest.pressed.connect(_add_quest)
	%RemoveQuest.pressed.connect(_remove_quest)
	%FullQuest.pressed.connect(_show_full_quest)
	%SaveButton.pressed.connect(_save_state)
	%LoadButton.pressed.connect(_load_state)
	%QuestDetailsDialog.confirmed.connect(_return_quest_focus)
	%QuestDetailsDialog.close_requested.connect(_return_quest_focus)


func _set_defaults() -> void:
	stamina = 65
	selected_slot = 0
	hotbar_items.assign([0, 1, 2, 3, -1])
	consumables = {"potion": 2}
	quest_entries.clear()
	quest_entries.append({"template": 0, "done": false})
	quest_entries.append({"template": 1, "done": false})
	selected_quest = 0


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo or %QuestDetailsDialog.visible:
		return

	var used := true
	if key_event.keycode >= KEY_1 and key_event.keycode <= KEY_5:
		var index: int = key_event.keycode - KEY_1
		_select_slot(index)
		slot_buttons[index].grab_focus()
	else:
		match key_event.keycode:
			KEY_E:
				if _hotbar_has_focus():
					_use_hotbar_item()
				else:
					used = false
			KEY_C:
				if _hotbar_has_focus():
					_cycle_item()
				else:
					used = false
			KEY_BACKSPACE:
				if _hotbar_has_focus():
					_clear_item()
				else:
					used = false
			KEY_J:
				if not quest_buttons.is_empty():
					quest_buttons[0].grab_focus()
				else:
					%AddQuest.grab_focus()
			KEY_F5:
				_save_state()
			KEY_F9:
				_load_state()
			_:
				used = false
	if used:
		get_viewport().set_input_as_handled()


func _hotbar_has_focus() -> bool:
   
	var focused: Control = get_viewport().gui_get_focus_owner()
	return focused in slot_buttons or focused == %UseItem or focused == %CycleItem or focused == %ClearItem



func _sprint() -> void:
	if stamina < 20:
		_feedback("FAILED  /  Not enough stamina to sprint.", false)
		return
	stamina -= 20
	_refresh_stamina()
	_feedback("SUCCESS  /  Sprint consumed 20 stamina.", true)


func _recover() -> void:
	if stamina >= MAX_STAMINA:
		_feedback("FAILED  /  Stamina is already full.", false)
		return
	var gained: int = mini(25, MAX_STAMINA - stamina)
	stamina += gained
	_refresh_stamina()
	_feedback("SUCCESS  /  Recovered %d stamina." % gained, true)


func _refresh_stamina() -> void:
	stamina = clampi(stamina, 0, MAX_STAMINA)
	%StaminaBar.value = stamina
	%StaminaValue.text = "%d / %d" % [stamina, MAX_STAMINA]
	if stamina == 0:
		%StaminaHelp.text = "EXHAUSTED  /  Recover before sprinting."
	elif stamina == MAX_STAMINA:
		%StaminaHelp.text = "FULL  /  More recovery has no effect."
	elif stamina < 30:
		%StaminaHelp.text = "LOW  /  Save energy for your next action."
	else:
		%StaminaHelp.text = "READY  /  Energy available."
	%SprintButton.disabled = stamina < 20
	%RecoverButton.disabled = stamina == MAX_STAMINA



func _select_slot(index: int) -> void:
	if index < 0 or index >= hotbar_items.size():
		return
	selected_slot = index
	_refresh_hotbar()
	_feedback("SELECTED  /  Hotbar slot %d." % [index + 1], true)


func _cycle_item() -> void:
	
	hotbar_items[selected_slot] += 1
	if hotbar_items[selected_slot] >= ITEMS.size():
		hotbar_items[selected_slot] = -1
	_refresh_hotbar()
	_feedback("UPDATED  /  Changed the item in slot %d." % [selected_slot + 1], true)


func _clear_item() -> void:
	if hotbar_items[selected_slot] == -1:
		_feedback("FAILED  /  Slot %d is already empty." % [selected_slot + 1], false)
		return
	hotbar_items[selected_slot] = -1
	_refresh_hotbar()
	_feedback("UNASSIGNED  /  Slot %d cleared; item stays in backpack." % [selected_slot + 1], true)


func _use_hotbar_item() -> void:
	var item_index: int = hotbar_items[selected_slot]
	if item_index == -1:
		_feedback("FAILED  /  Empty slot. Press C to assign an item.", false)
		return
	var item_kind: String = ITEMS[item_index]["kind"]
	match item_kind:
		"compass":
			_feedback("USED  /  Compass points toward the old mill.", true)
		"lantern":
			if stamina < 12:
				_feedback("FAILED  /  Lantern needs 12 stamina.", false)
				return
			stamina -= 12
			_feedback("USED  /  Lantern lit (-12 stamina).", true)
		"potion":
			var quantity: int = int(consumables.get("potion", 0))
			if quantity <= 0:
				_feedback("FAILED  /  Potion depleted: ghost slot remains.", false)
				return
			if stamina == MAX_STAMINA:
				_feedback("FAILED  /  At maximum stamina. Potion not wasted.", false)
				return
			stamina = mini(MAX_STAMINA, stamina + 35)
			consumables["potion"] = quantity - 1
			_feedback("USED  /  Potion restored stamina. %d left." % consumables["potion"], true)
		"rope":
			if stamina < 20:
				_feedback("FAILED  /  Rope needs 20 stamina.", false)
				return
			stamina -= 20
			_feedback("USED  /  Rope deployed (-20 stamina).", true)
	_refresh_stamina()
	_refresh_hotbar()


func _refresh_hotbar() -> void:
	for i in range(slot_buttons.size()):
		var button: Button = slot_buttons[i]
		var item_index: int = hotbar_items[i]
		button.button_pressed = i == selected_slot
		if item_index == -1:
			button.text = "%d  /  EMPTY" % (i + 1)
			button.tooltip_text = "Empty slot. Focus and press C to assign."
			continue
		var item_name: String = ITEMS[item_index]["name"]
		if item_index == 2:
			var remaining: int = int(consumables.get("potion", 0))
			if remaining == 0:
				button.text = "%d  /  POTION x0 [SPENT]" % (i + 1)
			else:
				button.text = "%d  /  POTION x%d" % [i + 1, remaining]
		else:
			button.text = "%d  /  %s" % [i + 1, item_name]
		button.tooltip_text = "Press E to use %s. C cycles items; Backspace unassigns." % item_name



func _add_quest() -> void:
	if quest_entries.size() >= MAX_QUESTS:
		_feedback("FAILED  /  Quest log is at its five-quest maximum.", false)
		return
	var next_template: int = quest_entries.size()
	quest_entries.append({"template": next_template, "done": false})
	selected_quest = quest_entries.size() - 1
	_render_quests()
	_feedback("SUCCESS  /  Quest added (%d of %d)." % [quest_entries.size(), MAX_QUESTS], true)


func _remove_quest() -> void:
	if quest_entries.is_empty():
		_feedback("FAILED  /  No quest can be removed.", false)
		return
   
	quest_entries.pop_back()
	selected_quest = mini(selected_quest, quest_entries.size() - 1)
	_render_quests()
	%RemoveQuest.grab_focus.call_deferred()
	_feedback("REMOVED  /  Latest quest removed. %d remain." % quest_entries.size(), true)


func _toggle_quest(index: int) -> void:
	if index < 0 or index >= quest_entries.size():
		return
	selected_quest = index
	quest_entries[index]["done"] = not bool(quest_entries[index]["done"])
	var done: bool = bool(quest_entries[index]["done"])
	_render_quests()
	if index < quest_buttons.size():
		quest_buttons[index].grab_focus.call_deferred()
	if done:
		_feedback("COMPLETED  /  Quest %d marked complete." % [index + 1], true)
	else:
		_feedback("REOPENED  /  Quest %d is active again." % [index + 1], true)


func _preview_quest(index: int) -> void:
	if index < 0 or index >= quest_entries.size():
		return
	selected_quest = index
	_refresh_quest_preview()


func _refresh_quest_preview() -> void:
	if selected_quest < 0 or selected_quest >= quest_entries.size():
		%QuestDetail.text = "No quest selected. Add one to begin."
		%FullQuest.disabled = true
		return
	var template: int = int(quest_entries[selected_quest]["template"])
	var state: String = "COMPLETE" if quest_entries[selected_quest]["done"] else "ACTIVE"
	%QuestDetail.text = "%s  /  %s" % [state, QUESTS[template]["description"]]
	%FullQuest.disabled = false


func _show_full_quest() -> void:
	if selected_quest < 0 or selected_quest >= quest_entries.size():
		_feedback("FAILED  /  No quest selected for details.", false)
		return
	var quest: Dictionary = quest_entries[selected_quest]
	var template: int = int(quest["template"])
	var state: String = "COMPLETED" if quest["done"] else "ACTIVE"
	%QuestDetailsDialog.dialog_text = "%s\n\n%s\n\nSTATUS: %s" % [
		QUESTS[template]["title"], QUESTS[template]["description"], state
	]
	%QuestDetailsDialog.popup_centered(Vector2i(650, 270))


func _return_quest_focus() -> void:
	%FullQuest.grab_focus.call_deferred()


func _render_quests() -> void:
	for child in %QuestList.get_children():
		%QuestList.remove_child(child)
		child.queue_free()
	quest_buttons.clear()
	%QuestCount.text = "%d / %d" % [quest_entries.size(), MAX_QUESTS]
	%AddQuest.disabled = quest_entries.size() >= MAX_QUESTS
	%RemoveQuest.disabled = quest_entries.is_empty()

	if quest_entries.is_empty():
		var empty_note := Label.new()
		empty_note.text = "NO QUESTS  /  Press ADD QUEST to start."
		empty_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		%QuestList.add_child(empty_note)
	else:
		for i in range(quest_entries.size()):
			var quest: Dictionary = quest_entries[i]
			var template: int = int(quest["template"])
			var completed: bool = bool(quest["done"])
			var button := Button.new()
			button.text = "%s  %s" % ["[x]" if completed else "[ ]", QUESTS[template]["title"]]
			button.tooltip_text = QUESTS[template]["title"]
			button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			button.clip_text = true
			button.custom_minimum_size = Vector2(0, 34)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.focus_mode = Control.FOCUS_ALL
			button.pressed.connect(_toggle_quest.bind(i))
			button.focus_entered.connect(_preview_quest.bind(i))
			%QuestList.add_child(button)
			quest_buttons.append(button)
	_refresh_quest_preview()



func _save_state() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "version", SAVE_VERSION)
	cfg.set_value("ui", "stamina", stamina)
	cfg.set_value("ui", "selected_slot", selected_slot)
	cfg.set_value("ui", "hotbar_items", hotbar_items.duplicate())
	cfg.set_value("ui", "consumables", consumables.duplicate())
	cfg.set_value("ui", "quests", quest_entries.duplicate(true))
	cfg.set_value("ui", "selected_quest", selected_quest)
	var err: Error = cfg.save(SAVE_PATH)
	if err == OK:
		_feedback("SAVED  /  Stamina, slots, stock, and quests written to user://.", true)
	else:
		_feedback("SAVE FAILED  /  Could not write data (error %d)." % err, false)


func _load_state(automatic: bool = false) -> void:
	var cfg := ConfigFile.new()
	var err: Error = cfg.load(SAVE_PATH)
	if err != OK:
		_feedback("LOAD FAILED  /  No readable saved state (error %d)." % err, false)
		return
	if cfg.get_value("meta", "version", -1) != SAVE_VERSION:
		_feedback("LOAD FAILED  /  Save version is not supported.", false)
		return

	var next_stamina = cfg.get_value("ui", "stamina", null)
	var next_selected = cfg.get_value("ui", "selected_slot", null)
	var next_slots = cfg.get_value("ui", "hotbar_items", null)
	var next_stock = cfg.get_value("ui", "consumables", null)
	var next_quests = cfg.get_value("ui", "quests", null)
	var next_quest_sel = cfg.get_value("ui", "selected_quest", null)
	var valid: bool = (typeof(next_stamina) == TYPE_INT
		and typeof(next_selected) == TYPE_INT
		and typeof(next_slots) == TYPE_ARRAY
		and typeof(next_stock) == TYPE_DICTIONARY
		and typeof(next_quests) == TYPE_ARRAY
		and typeof(next_quest_sel) == TYPE_INT)
	if not valid:
		_feedback("LOAD FAILED  /  Save has invalid value types.", false)
		return
	if next_stamina < 0 or next_stamina > MAX_STAMINA or next_selected < 0 or next_selected >= 5:
		_feedback("LOAD FAILED  /  Stamina or slot out of bounds.", false)
		return
	if next_slots.size() != 5 or next_quests.size() > MAX_QUESTS:
		_feedback("LOAD FAILED  /  Incorrect slot/quest count.", false)
		return
	for slot in next_slots:
		if typeof(slot) != TYPE_INT or slot < -1 or slot >= ITEMS.size():
			_feedback("LOAD FAILED  /  Invalid hotbar item.", false)
			return
	if not next_stock.has("potion") or typeof(next_stock["potion"]) != TYPE_INT:
		_feedback("LOAD FAILED  /  Invalid potion count.", false)
		return
	if next_stock["potion"] < 0 or next_stock["potion"] > 2:
		_feedback("LOAD FAILED  /  Potion stock out of bounds.", false)
		return
	if next_quest_sel < -1 or next_quest_sel >= next_quests.size():
		_feedback("LOAD FAILED  /  Invalid quest selection.", false)
		return
	for i in range(next_quests.size()):
		var entry = next_quests[i]
		if typeof(entry) != TYPE_DICTIONARY:
			_feedback("LOAD FAILED  /  Invalid quest entry.", false)
			return
		if not entry.has("template") or not entry.has("done"):
			_feedback("LOAD FAILED  /  Incomplete quest entry.", false)
			return
		if typeof(entry["template"]) != TYPE_INT or entry["template"] != i or typeof(entry["done"]) != TYPE_BOOL:
			_feedback("LOAD FAILED  /  Invalid quest order or state.", false)
			return

	
	stamina = next_stamina
	selected_slot = next_selected
	hotbar_items.assign(next_slots)
	consumables = next_stock.duplicate()
	quest_entries.clear()
	for entry in next_quests:
		quest_entries.append(entry.duplicate())
	selected_quest = next_quest_sel
	_refresh_all()
	slot_buttons[selected_slot].grab_focus.call_deferred()
	if automatic:
		_feedback("AUTO-LOADED  /  Existing local save restored.", true)
	else:
		_feedback("LOADED  /  All three UI systems restored.", true)


func _refresh_all() -> void:
	_refresh_stamina()
	_refresh_hotbar()
	_render_quests()


func _feedback(message: String, success: bool) -> void:
	%Feedback.text = message
	if success:
		%Feedback.add_theme_color_override("font_color", Color(0.65, 0.94, 0.82))
	else:
		%Feedback.add_theme_color_override("font_color", Color(1.0, 0.67, 0.58))
