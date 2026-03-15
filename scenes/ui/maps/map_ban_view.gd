extends MarginContainer

@export var map_1: Node
@export var map_2: Node

func _ready():
    # Connect Signals
    self.map_1.map_banned.connect(self._on_map_banned.bind(self.map_2))
    self.map_2.map_banned.connect(self._on_map_banned.bind(self.map_1))

func setup_maps(map_1_texture: Texture, map_1_name: String, map_2_texture: Texture, map_2_name: String) -> void:
    self.map_1.set_map_info(map_1_texture, map_1_name)
    self.map_2.set_map_info(map_2_texture, map_2_name)

func _on_map_banned(map_name: String, disable_map_ban: Node):
    print("Map banned: ", map_name)
    disable_map_ban.disable_ban_button()
