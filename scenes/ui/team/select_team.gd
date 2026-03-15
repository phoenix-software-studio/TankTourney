extends Control

signal team_selected()

@export var team_1_button: Button
@export var team_2_button: Button

func _ready() -> void:
    # Connect Signals
    team_1_button.pressed.connect(self._on_team_button_pressed.bind(self.team_1_button))
    team_2_button.pressed.connect(self._on_team_button_pressed.bind(self.team_2_button))
    GServer.tourney_started.connect(func(): self.visible = true)

func _on_team_button_pressed(button: Button):
    # Check if the metadata exists
    if button.has_meta("team_number"):
        var team_id = button.get_meta("team_number")
        
        # Now send the actual team_id to the server (ID 1)
        GServer.add_player_to_team.rpc_id(1, team_id)
    
    else:
        print_debug("Button does not have team_number metadata!")
        
    # Close the team selection UI after a choice is made
    self.visible = false

    self.team_selected.emit()
