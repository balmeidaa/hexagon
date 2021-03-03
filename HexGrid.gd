extends Node2D

onready var animationHandler = preload("Util/AnimationHandler.gd").new()
onready var util = preload("Util/Util.gd").new()

var screenHOffset = 80
var screenWoffset = 60

var offset = Vector2(0,0)

const origin = Vector2(0,0)

const axial_directions = [
    [ 
    Vector2(-1, -1), Vector2(0, -1), Vector2(1, 0), #Pares
    Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0)],
    [
    Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), #Impares
    Vector2(1, 1), Vector2(0, 1), Vector2(-1, 0)
    ]
]

const axis_direction = [
      { # Ejes pares
       "L-R": [Vector2(-1, 0), Vector2(1, 0)],
        "UpL-LoR":[Vector2(-1, -1), Vector2(0, 1)],
        "LoL-UpR": [Vector2(-1, 1), Vector2(0, -1)]
       },
       { # Ejes impares
       "L-R": [Vector2(-1, 0), Vector2(1, 0)],
        "UpL-LoR":[Vector2(0, -1), Vector2(1, 1)],
        "LoL-UpR": [Vector2(0, 1), Vector2(1, -1)]
       },
    
]
var gridSize = Vector2(0,0)
var col = 0
var row = 0
var grid = []

var selectionStack = []
var eliminationQueue = []
var availableNeighbors = []
var gridArea = Rect2(origin, origin)

const hex_factory = preload("res://HexCell.tscn")


func _ready():
    CellEventHandler.connect("cell_pressed", self, "cell_handler")
    CellEventHandler.connect("cell_removed", self, "cell_remover")

func cell_remover(coordinates: Vector2):
    var node = get_cell(coordinates)
    grid[int(coordinates.x)][int(coordinates.y)] = null
    node.call_deferred("free")


#TODO Rename this function
# We check the selected cell  neighbors, for second selection we check if selected cell is a neighbor
# else the cell should un select
func cell_handler(coordinates: Vector2):

    match selectionStack.size():
        0:
            availableNeighbors = get_neighbors(coordinates)
            selectionStack.push_back(coordinates)
        1:
            # Deselected the same cell click twice
             if coordinates == selectionStack[0]:
                selectionStack.clear()
                availableNeighbors.clear()
             elif availableNeighbors.has(coordinates): 
                selectionStack.push_back(coordinates)
                set_cells_state(selectionStack, 'pressed', false)
                swap_cells()
                check_cells_type()
                selectionStack.clear()
                availableNeighbors.clear()
             else:
                set_cells_state([coordinates], 'pressed', false)
                
func check_cells_type():
   
    for hexCell in selectionStack:
        eliminationQueue += get_neighbors_w_direction(hexCell, get_cell_type(hexCell))


func get_neighbors_w_direction(coord : Vector2, type :int)-> Array:

    var cells = []
    var parity = int(coord.y) & 1

    for axis in axis_direction[parity].values():
        var axisNeigbors = []
        for direction in axis:
            axisNeigbors += get_line_cells(coord, direction, type)

        if axisNeigbors.size() >= 2:
            cells += axisNeigbors
    if cells.size() > 1:  
        cells.push_front({
            "coord":coord,
            "type":type
            })
    return cells

func get_line_cells(coord:Vector2, direction:Vector2, type:int):
    var next = true
    var result = []
    var nextCell = coord + direction
    while next:
     
        if gridArea.has_point(nextCell):
            var nextType = get_cell_type(nextCell)
            if nextType == type:
                result.append({
                    "coord":nextCell,
                    "type":type
                   })
                nextCell = nextCell + direction
            else:
                next = false
        else:
            next = false
    return result
        

func get_neighbors(coord : Vector2) -> Array:
    var hex_neighbor = []
    # We check for valid neighbors
    var parity = int(coord.y) & 1
    for direction in axial_directions[parity]:
        var hex_coord = coord + direction
        if gridArea.has_point(hex_coord):
            hex_neighbor.append(hex_coord)       
    return hex_neighbor
    
func set_cells_state(cells : Array, state : String, active: bool) -> void:
    for cell in cells:
        var hex_cell = grid[int(cell.x)][int(cell.y)]
        hex_cell.set_button_state(state, active)

func get_cell_type(coord : Vector2):
    return grid[int(coord.x)][int(coord.y)].type
  
func get_cell(coord : Vector2):
    return grid[int(coord.x)][int(coord.y)] 
    
func set_offset() -> void:
    var cell = hex_factory.instance()
    offset = cell.get_size()

func swap_cells():
    
    var temp = grid[int(selectionStack[0].x)][int(selectionStack[0].y)]
    
    var cellAPos = grid[int(selectionStack[0].x)][int(selectionStack[0].y)].position
    var cellBPos = grid[int(selectionStack[1].x)][int(selectionStack[1].y)].position
    # Swap object positions in the grid
    grid[int(selectionStack[0].x)][int(selectionStack[0].y)] = grid[int(selectionStack[1].x)][int(selectionStack[1].y)]
    grid[int(selectionStack[1].x)][int(selectionStack[1].y)] = temp
    
    # We swap internal grid coord in the cell // For debug purposes only
    grid[int(selectionStack[0].x)][int(selectionStack[0].y)].set_coord(selectionStack[0])
    grid[int(selectionStack[1].x)][int(selectionStack[1].y)].set_coord(selectionStack[1])
    
    # We swap screen positions too
    # TODO use animation handler send { node , vector2d"}
    
#    var swapQueue = []
#    var animation = 'move_to'
#    for stack in selectionStack:
#        var node = grid[int(stack.x)][int(stack.y)]
#        var nextPosition = node.position
#        node.set_animation_state("move_to", nextPosition)
#        var dict = {
#            "node": node,
#            "animationType": animation,
#            "nextPosition": nextPosition
#           }
#        swapQueue.append(dict)
#    animationHandler.setQueueAnimation(swapQueue)
    grid[int(selectionStack[0].x)][int(selectionStack[0].y)].set_animation_state("move_to", cellAPos)
    grid[int(selectionStack[1].x)][int(selectionStack[1].y)].set_animation_state("move_to", cellBPos)

    
func create_hex(x : int, y : int, scale : Vector2):
    var cell = hex_factory.instance()
    var offsetX = 0
    if (y%2)==1:
        offsetX = offset.x/4

    else:
        offsetX = 0
   
    var posx = screenWoffset + (offset.x/2 * x) + offsetX 
    var posy = screenHOffset + (offset.y/3 * y)  
    var position = Vector2(posx,posy) 
    cell.position = position
    cell.scale = scale
    cell.init(Vector2(x, y),  util.random())
    
    # remove debug code
    var format_string = "%d-(%d,%d)"
    var string = format_string % [cell.type,x,y]
    cell.set_text(string)
    ##
    add_child(cell)
    return cell

func create_grid(vectorScale : Vector2, vectorGridSize : Vector2):
    set_offset()
    gridSize = vectorGridSize
    gridArea = Rect2(origin, gridSize)
    col = vectorGridSize.x
    row = vectorGridSize.y
    
    for x in range(col):
        grid.append([])
        grid[x]=[]        
        for y in range(row):
            grid[x].append([])
            grid[x][y]=create_hex(x, y, vectorScale)

####
func _process(_delta):
    if eliminationQueue.size() > 0:
        for dict in eliminationQueue:
            var cell = get_cell(dict["coord"])
            cell.set_animation_state("remove")
        eliminationQueue.clear()
           
           
            
