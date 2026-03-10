extends Label

@export var player_info_timer: Timer

func _ready() -> void:
    # Connect Signals
    self.player_info_timer.timeout.connect(self._on_player_info_timer_timeout)

func set_player_info(info: String) -> void:
    self.text = info
    self.player_info_timer.start()

func _on_player_info_timer_timeout():
    self.text = ""
