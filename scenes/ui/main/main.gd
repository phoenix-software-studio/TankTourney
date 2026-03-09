extends Node

@export var label: Label
@export var button: Button
@export var start_view: MarginContainer
@export var player_input_scene: Control

# The port must be the same on server and client
var port: int = 60000
var host: String = "ws://127.0.0.1:"

func _ready() -> void:
    # 1. Instance and add the logic node
    GServer.count_changed.connect(self._on_count_changed)
    self.button.pressed.connect(self._on_button_pressed)
    self.player_input_scene.user_submitted.connect(self._on_player_input_visibility_changed)

    # 2. Setup the actual Network Connection
    if OS.has_feature("dedicated_server"):
        self._setup_as_server()
    else:
        self._setup_as_client()

func _setup_as_server():
    GServer.start_server(self.port)

func _setup_as_client():
    var peer = WebSocketMultiplayerPeer.new()
    # Connect to the server's IP (localhost for testing)
    var error = peer.create_client(self.host + str(self.port))
    if error != OK:
        print("Failed to initialize client!")
        return

    multiplayer.multiplayer_peer = peer
    self.label.text = "Connecting to Server..."

func _on_count_changed(new_value: int):
    self.label.text = "Current Count: " + str(new_value)

func _on_button_pressed():
    # Now this has a 'peer' to travel through
    GServer.request_increment.rpc_id(1)

func _on_player_input_visibility_changed():
    self.start_view.visible = true
