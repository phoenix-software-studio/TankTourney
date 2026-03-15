extends CenterContainer

@export var start_tournament_button: Button

func _ready() -> void:
    # Connect Signals
    self.start_tournament_button.pressed.connect(self._on_start_tournament_button_pressed)
    GServer.tourney_started.connect(func(): self.visible = false)

func _on_start_tournament_button_pressed():
    # Notify the server to start the tournament (ID 1)
    GServer.request_tournament_start.rpc_id(1)
