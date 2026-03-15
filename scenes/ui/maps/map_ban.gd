extends MarginContainer

@export var map_ban_view: Node

func _ready() -> void:
    pass

func start() -> void:
    print("Starting Map Ban Phase")
    self._get_current_map_ban_view(0)
    self.visible = true

func _get_current_map_ban_view(ban_round: int) -> void:
    self.map_ban_view.setup_maps(self._load_map_texture(GServer.map_ban_list[ban_round][0]), GServer.map_ban_list[ban_round][0], self._load_map_texture(GServer.map_ban_list[ban_round][1]), GServer.map_ban_list[ban_round][1])

func _load_map_texture(map_name: String) -> Texture:
    # Loading map textures based on the map name
    return load("res://assets/wot/maps/" + map_name + "/mmap.dds")
