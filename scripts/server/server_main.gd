extends Node

# Signal emitted when the state changes
signal count_changed(new_value: int)

# The authoritative variable managed by the server
var current_count: int = 0

func start_server(port: int) -> void:
    var net_peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()

    # Server listens on all interfaces at the given port
    var error = net_peer.create_server(port)
    if error != OK:
        print("Failed to start server!")
        return

    multiplayer.multiplayer_peer = net_peer
    print("Server started on port " + str(port))

    # Give every new client the current state immediately upon connection
    multiplayer.peer_connected.connect(func(id):
        self.update_client_ui.rpc_id(id, current_count))

# RPC called by clients to request a change
@rpc("any_peer", "reliable")
func request_increment():
    # Security check: only the server processes the logic
    if multiplayer.is_server():
        current_count += 1
        # Synchronize new value to all connected peers
        update_client_ui.rpc(current_count)

# RPC called by the server to update all clients
@rpc("authority", "call_local", "reliable")
func update_client_ui(new_value: int):
    # Emit signal so the local UI can react
    count_changed.emit(new_value)
