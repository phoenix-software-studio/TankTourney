extends Control

signal team_selected()

@export var select_team: Control

func _ready():
    self.select_team.team_selected.connect(self._on_child_team_selected)

func _on_child_team_selected():
    team_selected.emit()
