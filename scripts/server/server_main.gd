extends Node

# Signal emitted when the state changes
signal count_changed(new_value: int)
signal online_players_updated(player_list: Dictionary[int, String])
signal admin_changed()
signal tourney_started()

# The authoritative variable managed by the server
var _current_count: int = 0

var _admin_peer_id: int = -1
var _online_players: Dictionary[int, String] = {}
var team_assignments: Dictionary[int, int] = {} # Maps peer_id to team_id

# final list of maps for the tournament
var _tourney_maps: Array = []

var map_ban_list: Dictionary[int, Array] = {}

class GetMapData:
    var name: String
    var remaining: Array[String] = []

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
        if self._online_players.has(id):
            self._online_players.erase(id)
            # Sync the cleaned list to everyone
            self.update_online_players.rpc(self._online_players)
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
func update_username(new_player_name: String) -> void:
    var peer_id = multiplayer.get_remote_sender_id()
    # Update the online players list
    self._online_players[peer_id] = new_player_name
    # Broadcast the updated list to all clients
    self.update_online_players.rpc(self._online_players)

    self._set_admin_user(peer_id)

# RPC called to update online players list
@rpc("authority", "call_local", "reliable")
func update_online_players(player_list: Dictionary[int, String]) -> void:
    # Emit signal so the local UI can react
    self.online_players_updated.emit(player_list)

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

@rpc("any_peer", "call_local", "reliable")
func add_player_to_team(team_id: int) -> void:
    # This function would contain logic to add a player to a team
    # For now, it's just a placeholder to show where that logic would go
    var peer_id = multiplayer.get_remote_sender_id()
    print("Adding player to team with ID: " + str(team_id) + " from peer ID: " + str(peer_id))
    self.team_assignments[peer_id] = team_id

@rpc("any_peer", "reliable")
func request_tournament_start():
    var sender_id = multiplayer.get_remote_sender_id()
    if sender_id == _admin_peer_id:
        # TODO: Use round int var here
        self.map_ban_list = self._setup_tourney(3)
        print(self.map_ban_list)
        self._get_map_ban_list.rpc(self.map_ban_list)
    else:
        print("Only the admin can start the tournament!")

@rpc("authority", "call_local", "reliable")
func _get_map_ban_list(new_map_ban_list: Dictionary[int, Array]) -> void:
    self.map_ban_list = new_map_ban_list
    self._execute_start.rpc()

@rpc("authority", "call_local", "reliable")
func _execute_start():
    self.tourney_started.emit()

func _setup_tourney(max_rounds: int) -> Dictionary[int, Array]:
    # Placeholder for map selection logic
    var available_maps: Array[String] = ["01_karelia", "02_malinovka", "18_cliff", "31_airfield", "04_himmelsdorf", "35_steppes", "08_ruinberg"]
    var sorted_maps_for_banning: Dictionary[int, Array] = {}
    for tourney_round in range(max_rounds):
        #TODO: Use for loop
        var map_data = self._get_map(available_maps)
        sorted_maps_for_banning[tourney_round] = []
        sorted_maps_for_banning[tourney_round].append(map_data.name)
        available_maps = map_data.remaining
        map_data = self._get_map(available_maps)
        sorted_maps_for_banning[tourney_round].append(map_data.name)
        available_maps = map_data.remaining
    return sorted_maps_for_banning

func _get_map(available_maps: Array[String]) -> GetMapData:
    var map_data = GetMapData.new()
    available_maps.shuffle()
    map_data.name = available_maps.pop_front()
    map_data.remaining = available_maps
    return map_data
