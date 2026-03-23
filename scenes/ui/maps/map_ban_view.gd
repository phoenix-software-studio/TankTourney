extends MarginContainer

signal map_banned()

@export var maps: HBoxContainer
@export var map_timer: Timer
@export var map_temokate: PackedScene

var map_1: Node
var map_2: Node

func _ready():
    # Connect Signals
    self.map_timer.timeout.connect(self._on_map_timer_timeout)

func setup_maps(map_1_texture: Texture, map_1_name: String, map_2_texture: Texture, map_2_name: String) -> void:
    for child in self.maps.get_children():
        child.queue_free()
    self.map_1 = self.map_temokate.instantiate()
    self.map_2 = self.map_temokate.instantiate()
    self.map_1.map_banned.connect(self._on_map_banned.bind(self.map_2))
    self.map_2.map_banned.connect(self._on_map_banned.bind(self.map_1))
    self.map_1.set_map_info(map_1_texture, map_1_name)
    self.map_2.set_map_info(map_2_texture, map_2_name)
    self.maps.add_child(self.map_1)
    self.maps.add_child(self.map_2)

func _on_map_banned(map_name: String, disable_map_ban: Node):
    print("Map banned: ", map_name)
    disable_map_ban.disable_ban_button()
    self.map_timer.start()

func _on_map_timer_timeout():
    self.map_1.hide()
    self.map_2.hide()
    self.map_banned.emit()
