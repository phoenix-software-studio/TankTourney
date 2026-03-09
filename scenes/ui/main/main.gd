extends Node

@export var label: Label
@export var button: Button

var server_logic
# The port must be the same on server and client
var port = 60000

func _ready():
    # 1. Instance and add the logic node
    server_logic = load("res://scripts/server/server_main.gd").new()
    server_logic.name = "server_logic"
    add_child(server_logic)
    server_logic.count_changed.connect(_on_count_changed)
    button.pressed.connect(_on_button_pressed)

    # 2. Setup the actual Network Connection
    if OS.has_feature("dedicated_server"):
        _setup_as_server()
    else:
        _setup_as_client()

func _setup_as_server():
    server_logic.start_server(port)

func _setup_as_client():
    var peer = WebSocketMultiplayerPeer.new()
    # Connect to the server's IP (localhost for testing)
    var error = peer.create_client("ws://127.0.0.1:" + str(port))
    if error != OK:
        print("Failed to initialize client!")
        return

    multiplayer.multiplayer_peer = peer
    label.text = "Connecting to Server..."

func _on_count_changed(new_value: int):
    label.text = "Current Count: " + str(new_value)

func _on_button_pressed():
    # Now this has a 'peer' to travel through
    server_logic.request_increment.rpc_id(1)
