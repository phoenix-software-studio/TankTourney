extends AspectRatioContainer

signal map_banned(map_name: String)

@export var map_texture_rect: TextureRect
@export var map_name_label: Label
@export var transparency_color_rect: ColorRect
@export var cross_texture_rect: TextureRect
@export var ban_button: Button

var _map_name: String = ""

func _ready():
    # Connect Signals
    self.ban_button.pressed.connect(self._on_ban_button_pressed)

func set_map_info(map_texture: Texture, map_name: String) -> void:
    self.map_texture_rect.texture = map_texture
    self.map_name_label.text = map_name
    self._map_name = map_name

func disable_ban_button():
    self.ban_button.visible = false

func _on_ban_button_pressed():
    self._ban_selected_map()

func _ban_selected_map():
    self.transparency_color_rect.visible = true
    self.ban_button.visible = false
    self.cross_texture_rect.visible = true
    self.map_banned.emit(self._map_name)

func set_round_ban_view(map_texture: Texture, map_name: String, banned: bool):
    self.set_map_info(map_texture, map_name)
    if banned:
        self.transparency_color_rect.visible = true
        self.ban_button.visible = false
        self.cross_texture_rect.visible = true
