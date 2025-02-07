extends Control

signal memo_toggled(is_memo_visible: bool)

@export var button_scale = 1.0
@export var vertical_spacing = 100
@export_range(0.0, 1.0) var max_horizontal_ratio = 0.2  # Maximum ratio of screen width to offset (0-1)
@export var buttons_per_tier = 2  # Maximum buttons that can fit in one tier
@export var tier_height = 150  # Height of each tier
@export var tier_1_vertical_offset = -1350: set = update_vertical_offset  # Vertical offset for tier 1 group
@export var tier_2_vertical_offset = -550: set = update_tier_2_vertical_offset  # Vertical offset for tier 2 group
@export var tier_3_vertical_offset = 2800: set = update_tier_3_vertical_offset  # Vertical offset for tier 3 group
@export var tier_4_vertical_offset = 4050: set = update_tier_4_vertical_offset  # Vertical offset for tier 4 group
@export var tier_5_vertical_offset = 6525: set = update_tier_5_vertical_offset  # Vertical offset for tier 5 group
@export var tier_6_vertical_offset = 8385: set = update_tier_6_vertical_offset  # Vertical offset for tier 6 group
@export var tier_7_vertical_offset = 9555: set = update_tier_7_vertical_offset  # Vertical offset for tier 7 group
@export var tier_8_vertical_offset = 10550: set = update_tier_8_vertical_offset  # Vertical offset for tier 8 group
@export var tier_9_vertical_offset = 11065: set = update_tier_9_vertical_offset  # Vertical offset for tier 9 group
@export var tier_10_vertical_offset = 11550: set = update_tier_10_vertical_offset  # Vertical offset for tier 10 group

@onready var conspiracy_menu_button = preload("res://scenes/conspiracy_theory_button.tscn")
@onready var custom_font = preload("res://assets/ui/GelatinTTFCAPS.ttf")

var button_container: Control
var memo_panel: Panel
var memo_image: TextureRect
var memo_text: RichTextLabel
var memo_title: Label
var back_button: Button
var current_ui_offset = 0.0

var _base_positions = {}  # Store base positions of buttons

const SPACING_SEED = 12345
const SCREEN_MARGIN_RATIO = 0.05  # 5% of screen width
const MIN_BUTTON_SPACING = 50  # Minimum horizontal space between buttons
const MEMO_PANEL_SIZE = Vector2(800, 600)

var tier_1_keys = TowerAndBoonData.tier_1_keys
var tier_2_keys = TowerAndBoonData.tier_2_keys
var tier_3_keys = TowerAndBoonData.tier_3_keys
var tier_4_keys = TowerAndBoonData.tier_4_keys
var tier_5_keys = TowerAndBoonData.tier_5_keys
var tier_6_keys = TowerAndBoonData.tier_6_keys
var tier_7_keys = TowerAndBoonData.tier_7_keys
var tier_8_keys = TowerAndBoonData.tier_8_keys
var tier_9_keys = TowerAndBoonData.tier_9_keys
var tier_10_keys = TowerAndBoonData.tier_10_keys


# Dictionary to store memo content for each conspiracy
var memo_content = {}

func _ready():
	TowerAndBoonData.memo_content_loaded.connect(_on_memo_content_loaded)
	if TowerAndBoonData.memo_content.size() > 0:
		_on_memo_content_loaded()
	else:
		setup_ui()

func _process(_delta):
	if memo_panel and memo_panel.visible:
		# Keep the memo panel centered in the viewport
		var viewport_size = get_viewport_rect().size
		memo_panel.global_position = (viewport_size - MEMO_PANEL_SIZE) / 2

func setup_ui():
	button_container = Control.new()
	button_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(button_container)
	
	memo_panel = Panel.new()
	memo_panel.visible = false
	memo_panel.custom_minimum_size = MEMO_PANEL_SIZE
	memo_panel.size = MEMO_PANEL_SIZE
	
	memo_panel.set_anchors_preset(Control.PRESET_CENTER)
	memo_panel.position = -MEMO_PANEL_SIZE / 2
	add_child(memo_panel)
	
	var margin_container = MarginContainer.new()
	margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", 20)
	margin_container.add_theme_constant_override("margin_right", 20)
	margin_container.add_theme_constant_override("margin_top", 20)
	margin_container.add_theme_constant_override("margin_bottom", 20)
	memo_panel.add_child(margin_container)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin_container.add_child(vbox)
	
	memo_title = Label.new()
	memo_title.name = "MemoTitle"
	memo_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	memo_title.add_theme_font_override("font", custom_font)
	memo_title.add_theme_font_size_override("font_size", 36)
	memo_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	memo_title.custom_minimum_size = Vector2(0, 50)
	memo_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vbox.add_child(memo_title)
	
	memo_image = TextureRect.new()
	memo_image.custom_minimum_size = Vector2(0, 200)
	memo_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	memo_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(memo_image)
	
	var scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.custom_minimum_size = Vector2(0, 200)
	vbox.add_child(scroll_container)
	
	var text_container = VBoxContainer.new()
	text_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(text_container)
	
	memo_text = RichTextLabel.new()
	memo_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	memo_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	memo_text.add_theme_font_override("normal_font", custom_font)
	memo_text.add_theme_font_size_override("normal_font_size", 24)
	memo_text.bbcode_enabled = true
	memo_text.text = "Memo text goes here..."
	memo_text.fit_content = true
	memo_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_container.add_child(memo_text)
	
	back_button = Button.new()
	back_button.custom_minimum_size = Vector2(200, 50)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.add_theme_font_override("font", custom_font)
	back_button.add_theme_font_size_override("font_size", 30)
	back_button.text = "BACK"
	back_button.pressed.connect(_on_back_button_pressed)
	vbox.add_child(back_button)

func update_tier_2_vertical_offset(new_offset):
	tier_2_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 2:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_2_vertical_offset

func update_vertical_offset(new_offset):
	tier_1_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 1:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_1_vertical_offset

func update_tier_3_vertical_offset(new_offset):
	tier_3_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 3:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_3_vertical_offset

func update_tier_4_vertical_offset(new_offset):
	tier_4_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 4:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_4_vertical_offset

func update_tier_5_vertical_offset(new_offset):
	tier_5_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 5:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_5_vertical_offset

func update_tier_6_vertical_offset(new_offset):
	tier_6_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 6:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_6_vertical_offset

func update_tier_7_vertical_offset(new_offset):
	tier_7_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 7:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_7_vertical_offset

func update_tier_8_vertical_offset(new_offset):
	tier_8_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 8:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_8_vertical_offset

func update_tier_9_vertical_offset(new_offset):
	tier_9_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 9:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_9_vertical_offset

func update_tier_10_vertical_offset(new_offset):
	tier_10_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 10:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_10_vertical_offset

func create_button(key: String, tier_number: int, viewport_size: Vector2, screen_margin: float, start_y: float, tiers: Dictionary, current_tier: int, rng: RandomNumberGenerator) -> void:
	var button_instance = conspiracy_menu_button.instantiate()
	button_container.add_child(button_instance)
	button_instance.show_memo.connect(_on_button_show_memo)
	
	# Update the button with its key
	if button_instance.has_method("update_button_by_key"):
		button_instance.update_button_by_key(key)
		button_instance.override_name(memo_content[key].name_override)
		button_instance.set_description(memo_content[key].text)
		button_instance.override_image(memo_content[key].image)
	
	# Scale the button
	button_instance.scale = Vector2(button_scale, button_scale)
	var button_width = button_instance.size.x * button_scale
	
	# Initialize tier if not exists
	if not tiers.has(current_tier):
		tiers[current_tier] = []
	
	# Try to find a valid position in current tier
	var position_found = false
	var max_attempts = 10  # Prevent infinite loops
	var attempts = 0
	
	while not position_found and attempts < max_attempts:
		# Generate a potential x position
		var center_x = (viewport_size.x - button_width) / 2
		var max_offset = viewport_size.x * max_horizontal_ratio
		var h_offset = rng.randf_range(-max_offset, max_offset)
		var x_pos = clamp(center_x + h_offset, screen_margin, viewport_size.x - button_width - screen_margin)
		
		# Check if this position overlaps with any existing buttons in this tier
		var overlaps = false
		for existing_button in tiers[current_tier]:
			if abs(existing_button.x - x_pos) < (button_width + MIN_BUTTON_SPACING):
				overlaps = true
				break
		
		if not overlaps:
			position_found = true
			var y_pos = start_y + (current_tier * tier_height)
			var base_position = Vector2(x_pos, y_pos)
			button_instance.set_meta("base_position", base_position)
			button_instance.set_meta("tier", tier_number)
			
			# Apply the appropriate vertical offset based on the tier
			var vertical_offset: float
			if tier_number == 1:
				vertical_offset = tier_1_vertical_offset
			elif tier_number == 2:
				vertical_offset = tier_2_vertical_offset
			elif tier_number == 3:
				vertical_offset = tier_3_vertical_offset
			elif tier_number == 4:
				vertical_offset = tier_4_vertical_offset
			elif tier_number == 5:
				vertical_offset = tier_5_vertical_offset
			elif tier_number == 6:
				vertical_offset = tier_6_vertical_offset
			elif tier_number == 7:
				vertical_offset = tier_7_vertical_offset
			elif tier_number == 8:
				vertical_offset = tier_8_vertical_offset
			elif tier_number == 9:
				vertical_offset = tier_9_vertical_offset
			else:
				vertical_offset = tier_10_vertical_offset
			button_instance.position = Vector2(x_pos, y_pos + vertical_offset)
			tiers[current_tier].append(Vector2(x_pos, y_pos))
		
		attempts += 1
		
		# If we couldn't find a spot after several attempts, move to next tier
		if attempts >= max_attempts:
			current_tier += 1
			if not tiers.has(current_tier):
				tiers[current_tier] = []
			attempts = 0  # Reset attempts for new tier
	
	# If current tier is full, move to next tier
	if tiers[current_tier].size() >= buttons_per_tier:
		current_tier += 1

func generate_buttons():
	var viewport_size = get_viewport_rect().size
	var screen_margin = viewport_size.x * SCREEN_MARGIN_RATIO
	var base_start_y = screen_margin
	
	# Create a new random number generator with our seed
	var rng = RandomNumberGenerator.new()
	rng.seed = SPACING_SEED
	
	# Create a structure to track button positions in each tier
	var tiers = {}
	var current_tier = 0
	
	# Generate tier 1 buttons
	var tier1_start_y = base_start_y
	for key in tier_1_keys:
		create_button(key, 1, viewport_size, screen_margin, tier1_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 2 buttons
	current_tier = 0
	tiers.clear()
	
	# Generate tier 2 buttons
	var tier2_start_y = base_start_y + viewport_size.y * 0.10  # 10% down the screen
	for key in tier_2_keys:
		create_button(key, 2, viewport_size, screen_margin, tier2_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 3 buttons
	current_tier = 0
	tiers.clear()
	
	# Generate tier 3 buttons
	var tier3_start_y = base_start_y + viewport_size.y * 0.20  # 20% down the screen
	for key in tier_3_keys:
		create_button(key, 3, viewport_size, screen_margin, tier3_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 4 buttons
	current_tier = 0
	tiers.clear()
	
	# Generate tier 4 buttons
	var tier4_start_y = base_start_y + viewport_size.y * 0.30  # 30% down the screen
	for key in tier_4_keys:
		create_button(key, 4, viewport_size, screen_margin, tier4_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 5 buttons
	current_tier = 0
	tiers.clear()
	
	# Generate tier 5 buttons
	var tier5_start_y = base_start_y + viewport_size.y * 0.40  # 40% down the screen
	for key in tier_5_keys:
		create_button(key, 5, viewport_size, screen_margin, tier5_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 6 buttons
	current_tier = 0
	tiers.clear()
	
	# Generate tier 6 buttons
	var tier6_start_y = base_start_y + viewport_size.y * 0.50  # 50% down the screen
	for key in tier_6_keys:
		create_button(key, 6, viewport_size, screen_margin, tier6_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 7 buttons
	current_tier = 0
	tiers.clear()
	
	# Generate tier 7 buttons
	var tier7_start_y = base_start_y + viewport_size.y * 0.60  # 60% down the screen
	for key in tier_7_keys:
		create_button(key, 7, viewport_size, screen_margin, tier7_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 8 buttons
	current_tier = 0
	tiers.clear()
	
	# Generate tier 8 buttons
	var tier8_start_y = base_start_y + viewport_size.y * 0.70  # 70% down the screen
	for key in tier_8_keys:
		create_button(key, 8, viewport_size, screen_margin, tier8_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 9 buttons
	current_tier = 0
	tiers.clear()
	
	# Generate tier 9 buttons
	var tier9_start_y = base_start_y + viewport_size.y * 0.80  # 80% down the screen
	for key in tier_9_keys:
		create_button(key, 9, viewport_size, screen_margin, tier9_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 10 buttons
	current_tier = 0
	tiers.clear()
	
	# Generate tier 10 buttons
	var tier10_start_y = base_start_y + viewport_size.y * 0.90  # 90% down the screen
	for key in tier_10_keys:
		create_button(key, 10, viewport_size, screen_margin, tier10_start_y, tiers, current_tier, rng)

func _on_button_show_memo(key: String):
	if memo_content.has(key):
		var content = memo_content[key]
		memo_text.text = key.to_upper().replace(' ', '_')
		memo_image.texture = load(content.image)
		memo_title.text = content.name_override
		button_container.hide()
		memo_panel.show()
		emit_signal("memo_toggled", true)

func _on_back_button_pressed():
	memo_panel.hide()
	button_container.show()
	emit_signal("memo_toggled", false)

func set_ui_offset(offset):
	current_ui_offset = offset
	position.y = offset

func _on_memo_content_loaded():
	memo_content = TowerAndBoonData.get_memo_content()
	if not button_container:
		setup_ui()
	seed(SPACING_SEED)
	generate_buttons()
