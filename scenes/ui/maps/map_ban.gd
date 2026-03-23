extends MarginContainer

@export var map_ban_view: Node

var _team_id: int
var _ban_round: int = 0

func _ready() -> void:
    # Connect Signals
    self.map_ban_view.map_banned.connect(self._on_map_banned)

func start(team_id: int) -> void:
    print("Starting Map Ban Phase")
    self._team_id = team_id

    self._get_current_map_ban_view()
    self.visible = true

func _get_current_map_ban_view() -> void:
    var map_index: int
    if self._team_id == 1:
        map_index = self._ban_round * 2
    else:
        map_index = (self._ban_round * 2) + 1
    if map_index >= len(GServer.map_ban_list):
        GPlayerInfo.set_player_info("Map Ban Phase Completed")
        self.visible = false
        return
    self.map_ban_view.setup_maps(self._load_map_texture(GServer.map_ban_list[map_index][0]), GServer.map_ban_list[map_index][0], self._load_map_texture(GServer.map_ban_list[map_index][1]), GServer.map_ban_list[map_index][1])
    self._ban_round += 1

func _load_map_texture(map_name: String) -> Texture:
    # Loading map textures based on the map name
    return load("res://assets/wot/maps/" + map_name + "/mmap.dds")

func _on_map_banned():
        self._get_current_map_ban_view()
