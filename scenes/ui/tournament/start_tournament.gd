extends CenterContainer

@export var start_tournament_button: Button

func _ready() -> void:
    # Connect Signals
    self.start_tournament_button.pressed.connect(self._on_start_tournament_button_pressed)

func _on_start_tournament_button_pressed():
    pass
