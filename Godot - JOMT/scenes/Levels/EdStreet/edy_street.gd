extends Node3D

@onready var multiplayer_main_manu: PanelContainer = $CanvasLayer/MultiplayerMainManu
@onready var adress_entry: LineEdit = $CanvasLayer/MultiplayerMainManu/MarginContainer/VBoxContainer/AdressEntry

const Player = preload("res://scenes/player/player_advance_multiplayer.tscn")
const PORT = 9669
var enet_peer = ENetMultiplayerPeer.new()

func _on_host_button_pressed() -> void:
	multiplayer_main_manu.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())
	upnp_setup()

func _on_join_button_pressed() -> void:
	if adress_entry.text != "":
		multiplayer_main_manu.hide()
		enet_peer.create_client(adress_entry.text,PORT)
		multiplayer.multiplayer_peer = enet_peer


func add_player(player_id):
	var player = Player.instantiate()
	player.name = str(player_id)
	add_child(player)

func remove_player(player_id):
	var player = get_node_or_null(str(player_id))
	if player:
		player.queue_free()

func upnp_setup():
	var upnp = UPNP.new()
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discovery Failed! Error %s" % discover_result)
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(),\
		"UPNP Invalid Gateway!")
	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS,\
		"UPNP Port Mapping Failed! Error %s" % map_result)
	print("Succes! Join Address: %s" % upnp.query_external_address())
