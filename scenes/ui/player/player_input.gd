extends Control

signal user_submitted

@export var input_field: LineEdit
@export var submit_button: Button

func _ready() -> void:
    # Connect Signals
    self.submit_button.pressed.connect(_on_user_submit_pressed)
    self.input_field.text_submitted.connect(_on_user_text_submit_pressed)

func _on_user_text_submit_pressed(user_name: String) -> void:
    GServer.update_username.rpc_id(1, user_name)
    self.visible = false
    self.user_submitted.emit()

func _on_user_submit_pressed() -> void:
    GServer.update_username.rpc_id(1, self.input_field.text)
    self.visible = false
    self.user_submitted.emit()
