extends VBoxContainer

func _ready() -> void:
    # Connect Signals
    GServer.online_users_updated.connect(self._on_online_users_updated)

func _on_online_users_updated(user_list: Dictionary[int, String]) -> void:
    # Clear existing children
    for child in get_children():
        child.queue_free()
    # Add Headerplayer Label
    var header: Label = Label.new()
    header.text = "Online Players:"
    self.add_child(header)

    # Add a label for each online user
    for id in user_list.keys():
        var user_label: Label = Label.new()
        user_label.text = user_list[id]
        self.add_child(user_label)
