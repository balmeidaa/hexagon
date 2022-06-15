extends Node2D
const hex_grid_factory= preload("res://HexGrid.tscn")
const button_editor = preload("res://Button.tscn")
var HexGrid = null
export var cellScale = .5
var vectorScale = Vector2(cellScale, cellScale)
export var vectorGridSize = Vector2(13,10)
var util = preload("Util/Util.gd").new()
onready var grid = $Grid 

var button_types = []
var buttons = []

func _ready():
    
    button_types += util.SpecialCells
    button_types += util.nonClickable

    for type in button_types:
        var button = button_editor.instance()
        grid.add_child(button)
        buttons.append(button)
        button.set_type(type)
        
    util.rng.randomize()
    CellEventHandler.level_editor = true
    HexGrid = hex_grid_factory.instance()
   
    add_child(HexGrid)
    HexGrid.create_grid(vectorScale, vectorGridSize)
