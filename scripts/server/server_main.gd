extends Node

# Signal emitted when the state changes
signal count_changed(new_value: int)
signal online_users_updated(user_list: Dictionary[int, String])
signal admin_changed()
signal tourney_started()

# The authoritative variable managed by the server
var _current_count: int = 0

var _admin_peer_id: int = -1
var _online_users: Dictionary[int, String] = {}

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
    multiplayer.peer_connected.connect(self._on_peer_connected)

    # Handle user disconnection to keep the list clean
    multiplayer.peer_disconnected.connect(func(id):
        if self._online_users.has(id):
            self._online_users.erase(id)
            # Sync the cleaned list to everyone
            self.update_online_users.rpc(self._online_users)
    )

# RPC called by clients to request a change
@rpc("any_peer", "reliable")
func request_increment() -> void:
    # Security check: only the server processes the logic
    if multiplayer.is_server():
        self._current_count += 1
        # Synchronize new value to all connected peers
        self.update_client_ui.rpc(self._current_count)

# RPC called by the server to update all clients
@rpc("authority", "call_local", "reliable")
func update_client_ui(new_value: int) -> void:
    # Emit signal so the local UI can react
    self.count_changed.emit(new_value)

# RPC called by clients to update their username
@rpc("any_peer", "reliable")
func update_username(new_username: String) -> void:
    var peer_id = multiplayer.get_remote_sender_id()
    # Update the online users list
    self._online_users[peer_id] = new_username
    # Broadcast the updated list to all clients
    self.update_online_users.rpc(self._online_users)

    self._set_admin_user(peer_id)

# RPC called to update online users list
@rpc("authority", "call_local", "reliable")
func update_online_users(user_list: Dictionary[int, String]) -> void:
    # Emit signal so the local UI can react
    self.online_users_updated.emit(user_list)

func _on_peer_connected(id: int) -> void:
    print("Peer connected with ID: " + str(id))
    self.update_client_ui.rpc_id(id, _current_count)

func _set_admin_user(peer_id: int) -> void:
    # For simplicity, the first connected peer becomes the admin
    if self._admin_peer_id == -1:
        self._admin_peer_id = peer_id
        self._notify_admin_player.rpc_id(peer_id)

@rpc("authority", "call_local", "reliable")
func _notify_admin_player() -> void:
    self.admin_changed.emit()
