@tool
extends Node
class_name BoardGenerator

@export var width: int = 10
@export var depth: int = 10
@export var board: Board

var savePath = "res://Data/Levels/"
@export var fileName = "defaultMap.txt"
@export var fileNameJSON = "saveGame.json"

@export_tool_button("Clear") var clear_action = Clear
@export_tool_button("Grow") var grow_action = Grow
@export_tool_button("Shrink") var shrink_action = Shrink
@export_tool_button("Grow Area") var growArea_action = GrowArea
@export_tool_button("Shrink Area") var shrinkArea_action = ShrinkArea
@export_tool_button("Save") var save_action = Save
@export_tool_button("Load") var load_action = Load
@export_tool_button("Save JSON") var saveJSON_action = SaveJSON
@export_tool_button("Load JSON") var loadJSON_action = LoadJSON

var _random = RandomNumberGenerator.new()

func _ready():
	_random.randomize()

func _RandomRect():
	var x = _random.randi_range(0, width - 1)
	var y = _random.randi_range(0, depth - 1)
	var w = _random.randi_range(1, width - x)
	var h = _random.randi_range(1, depth - y)
	return Rect2i(x, y, w, h)

func _GrowRect(rect: Rect2i):
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var p = Vector2i(x,y)
			board.GrowSingle(p)

func _ShrinkRect(rect: Rect2i):
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var p = Vector2i(x,y)
			board.ShrinkSingle(p)

func Clear():
	board.Clear()

func Grow():
	board.GrowSingle(board.pos)

func Shrink():
	board.ShrinkSingle(board.pos)

func GrowArea():
	var r: Rect2i = _RandomRect()
	_GrowRect(r)

func ShrinkArea():
	var r: Rect2i = _RandomRect()
	_ShrinkRect(r)

func Save():
	var saveFile = savePath + fileName
	board.SaveMap(saveFile)

func Load():
	var saveFile = savePath + fileName
	board.LoadMap(saveFile)

func SaveJSON():
	var saveFile = savePath + fileNameJSON
	board.SaveMapJSON(saveFile)

func LoadJSON():
	var saveFile = savePath + fileNameJSON
	board.LoadMapJSON(saveFile)
