extends Node

signal player_info_updated(info: String)

func set_player_info(info: String) -> void:
    self.player_info_updated.emit(info)
