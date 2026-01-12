@tool
extends Node
class_name Board

@export var height: int = 8
@export var pos: Vector2i:
	get:
		return pos
	set(_newPos):
		pos = _newPos
		_UpdateMarker()
	
var tileViewPrefab = preload("res://Prefabs/Tile.tscn")
var tileSelectionIndicatorPrefab = preload("res://Prefabs/Tile Selection Indicator.tscn")

var tiles = {}
var marker

func _init():
	marker = tileSelectionIndicatorPrefab.instantiate()
	add_child(marker)
	pos = Vector2i(0,0)

func Clear():
	for key in tiles:
		tiles[key].free()
	tiles.clear()

func _UpdateMarker():
	if tiles.has(pos):
		var t: Tile = tiles[pos]
		marker.position = t.Center()
	else:
		marker.position = Vector3(pos.x, 0, pos.y)

func GrowSingle(p: Vector2i):
	var t: Tile = _GetOrCreate(p)
	if t.height < height:
		t.Grow()
		_UpdateMarker()

func ShrinkSingle(p: Vector2i):
	if not tiles.has(p):
		return
	
	var t: Tile = tiles[p]
	t.Shrink()
	_UpdateMarker()
	
	if t.height <= 0:
		tiles.erase(p)
		t.free()

func _GetOrCreate(p: Vector2i):
	if tiles.has(p):
		return tiles[p]
	
	var t: Tile = _Create()
	t.Load(p, 0)
	tiles[p] = t
	
	return t

func _Create():
	var instance = tileViewPrefab.instantiate()
	add_child(instance)
	return instance

func SaveMap(saveFile):
	var save_game = FileAccess.open(saveFile, FileAccess.WRITE)
	var version = 1
	var size = tiles.size()
	
	save_game.store_8(version)
	save_game.store_16(size)
	
	for key in tiles:
		save_game.store_8(key.x)
		save_game.store_8(key.y)
		save_game.store_8(tiles[key].height)
	
	save_game.close()

func LoadMap(saveFile):
	Clear()
	
	if not FileAccess.file_exists(saveFile):
		return # Error! We don't have a save to load.
	
	var save_game = FileAccess.open(saveFile, FileAccess.READ)
	var version = save_game.get_8()
	var size = save_game.get_16()
	
	for i in range(size):
		var save_x = save_game.get_8()
		var save_z = save_game.get_8()
		var save_height = save_game.get_8()
		
		var t: Tile = _Create()
		t.Load(Vector2i(save_x, save_z) , save_height)
		tiles[Vector2i(t.pos.x, t.pos.y)] = t
	
	save_game.close()
	_UpdateMarker()

func SaveMapJSON(saveFile):
	var main_dict = {
		"version": "1.0.0",
		"tiles": []
	}
	
	for key in tiles:
		var save_dict = {
			"pos_x" : tiles[key].pos.x,
			"pos_z" : tiles[key].pos.y,
			"height" : tiles[key].height
		}
		main_dict["tiles"].append(save_dict)
	
	var save_game = FileAccess.open(saveFile, FileAccess.WRITE)
	
	var json_string = JSON.stringify(main_dict, "\t", false)
	save_game.store_line(json_string)
	save_game.close()
	
func LoadMapJSON(saveFile):
	Clear()
	
	if not FileAccess.file_exists(saveFile):
		return # Error! We don't have a save to load
	
	var save_game = FileAccess.open(saveFile, FileAccess.READ)
	
	var json_text = save_game.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		print("Error %s reading json file." % parse_result)
		return
	
	var data = {}
	data = json.get_data()
	
	for mtile in data["tiles"]:
		var t: Tile = _Create()
		t.Load(Vector2(mtile["pos_x"],mtile["pos_z"]), mtile["height"])
		tiles[Vector2i(t.pos.x, t.pos.y)] = t
	
	save_game.close()
	_UpdateMarker()
	
