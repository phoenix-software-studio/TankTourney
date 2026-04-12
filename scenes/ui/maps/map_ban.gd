extends MarginContainer

signal map_ban_finished()

@export var maps: HBoxContainer
@export var map_timer: Timer
@export var map_template: PackedScene

var map_1: Node
var map_2: Node
var _ban_round: int = 0
var _team_id: int

func _ready():
    # Connect Signals
    self.map_timer.timeout.connect(self._on_map_timer_timeout)

func start(team_id: int) -> void:
    print("Starting Map Ban Phase")
    self._team_id = team_id

    self._get_current_map_ban_view()
    self.visible = true

func _setup_maps(map_1_texture: Texture, map_1_name: String, map_2_texture: Texture, map_2_name: String, ban_round: int) -> void:
    self._ban_round = ban_round
    for child in self.maps.get_children():
        child.queue_free()
    self.map_1 = self.map_template.instantiate()
    self.map_2 = self.map_template.instantiate()
    self.map_1.map_banned.connect(self._on_map_banned.bind(self.map_2))
    self.map_2.map_banned.connect(self._on_map_banned.bind(self.map_1))
    self.map_1.set_map_info(map_1_texture, map_1_name)
    self.map_2.set_map_info(map_2_texture, map_2_name)
    self.maps.add_child(self.map_1)
    self.maps.add_child(self.map_2)

func _on_map_banned(map_name: String, disable_map_ban: Node):
    print("Map banned: ", map_name)
    GServer.request_map_ban.rpc_id(1, self._ban_round, map_name)
    disable_map_ban.disable_ban_button()
    self.map_timer.start()

func _on_map_timer_timeout():
    self.map_1.hide()
    self.map_2.hide()
    self._get_current_map_ban_view()

func _get_current_map_ban_view() -> void:
    var map_index: int
    if self._team_id == 1:
        map_index = self._ban_round * 2
    else:
        map_index = (self._ban_round * 2) + 1
    if map_index >= len(GServer.map_ban_list):
        GPlayerInfo.set_player_info("Map Ban Phase Completed")
        self.visible = false
        self.map_ban_finished.emit()
        return
    self._setup_maps(self._load_map_texture(GServer.map_ban_list[map_index][0]), GServer.map_ban_list[map_index][0], self._load_map_texture(GServer.map_ban_list[map_index][1]), GServer.map_ban_list[map_index][1], map_index)
    self._ban_round += 1

func _load_map_texture(map_name: String) -> Texture:
    # Loading map textures based on the map name
    return load("res://assets/wot/maps/" + map_name + "/mmap.dds")
