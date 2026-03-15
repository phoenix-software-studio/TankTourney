extends MarginContainer

@export var player_list_v_box_container: VBoxContainer
@export var player_label: Label
@export var player_label_text = "<online_players_count>"

func _ready() -> void:
    # Connect Signals
    GServer.online_players_updated.connect(self._on_online_players_updated)
    # Set player_label_text
    self.player_label.text = self.player_label_text

func _on_online_players_updated(player_list: Dictionary[int, String]) -> void:
    # Clear existing children
    for child in self.player_list_v_box_container.get_children():
        child.queue_free()

    # Add a label for each online player
    for id in player_list.keys():
        var new_player_label: Label = Label.new()
        new_player_label.text = player_list[id]
        self.player_list_v_box_container.add_child(new_player_label)
