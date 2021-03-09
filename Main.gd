extends Node2D

var cellScale = .5

func _ready():
    var vectorScale = Vector2(cellScale, cellScale)
    var vectorGridSize = Vector2(13,10)
    $HexGrid.create_grid(vectorScale, vectorGridSize)
#    $Debugger.add_property($HexGrid, "droppedCells", "")
#    $Debugger.add_property($HexGrid, "newCells", "")
#   $Debugger.add_property($HexGrid, "missingCells", "")
#   # $Debugger.add_property($HexGrid, "eliminationQueue", "")
