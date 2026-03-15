extends Node

@export var player_info: Node
@export var start_view: MarginContainer
@export var player_input_scene: Control
@export var tournament_start_scene: Control
@export var team_tornament_view_scene: Control
@export var map_ban_scene: Control

# TODO: Will be removed in the future; only test porpose
@export var label: Label
@export var button: Button

# The port must be the same on server and client
var port: int = 60000
var host: String = "ws://127.0.0.1:"

func _ready() -> void:
    # Connect Signals
    # TODO: Will be removed in the future; only test porpose
    GServer.count_changed.connect(self._on_count_changed)
    self.button.pressed.connect(self._on_button_pressed)

    multiplayer.connected_to_server.connect(_on_connection_success)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.server_disconnected.connect(_on_server_lost)

    self.player_input_scene.user_submitted.connect(self._on_player_input_visibility_changed)
    GServer.admin_changed.connect(self._on_admin_changed)
    GServer.tourney_started.connect(func(): self.team_tornament_view_scene.visible = true)

    self.team_tornament_view_scene.team_selected.connect(func(): self.map_ban_scene.start())

    # Setup the actual Network Connection
    if OS.has_feature("dedicated_server"):
        self._setup_as_server()
    else:
        self._setup_as_client()

func _setup_as_server():
    GServer.start_server(self.port)

func _setup_as_client():
    var peer = WebSocketMultiplayerPeer.new()
    # Connect to the server's IP and port
    var error = peer.create_client(self.host + str(self.port))
    if error != OK:
        print("Failed to initialize client!")
        return

    multiplayer.multiplayer_peer = peer
    self.label.text = "Connecting to Server..."

    # TODO: Change to room owner if rooms will be avaible

func _on_player_input_visibility_changed():
    self.start_view.visible = true

# TODO: Will be removed in the future; only test porpose
func _on_count_changed(new_value: int):
    self.label.text = "Current Count: " + str(new_value)

func _on_button_pressed():
    # Now this has a 'peer' to travel through
    GServer.request_increment.rpc_id(1)

func _on_admin_changed():
    self.tournament_start_scene.visible = true
    self.player_info.set_player_info("You are the new admin! You can start the tournament now.")

func _on_connection_success():
    self.player_info.set_player_info("Connection successful! Welcome.")

func _on_connection_failed():
    self.player_info.set_player_info("Connection failed. Server unreachable.")

func _on_server_lost():
    self.player_info.set_player_info("Lost connection to server.")
