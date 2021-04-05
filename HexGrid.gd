extends Node2D

onready var util = preload("Util/Util.gd").new()

var screenHOffset = 200
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
       }
]
var gridSize = Vector2(0,0)
var col = 0
var row = 0
var grid = []
var vectorScale = Vector2(0,0)
var selectionStack = []
var eliminationQueue = []
var availableNeighbors = []
var missingCells = []
var nextToDrop = []
var newCells = []
var droppedCells = []
var gridArea = Rect2(origin, origin)

var ready_for_drop = false
const hex_factory = preload("res://HexCell.tscn")


func _ready():
    util.rng.randomize()
    CellEventHandler.connect("cell_pressed", self, "cell_handler")
    CellEventHandler.connect("cell_removed", self, "cell_remover")

func _process(_delta):
    
    self.set_process(false)
    # remove cells
    if eliminationQueue.size() > 0:
        
        for coord in eliminationQueue:
            var cell = get_cell(coord)
            cell.set_animation_state("remove")

        eliminationQueue.clear()
        
   # drop cells below
    if missingCells.size() > 0 and check_non_null_cells(missingCells):
        drop_cells()

        missingCells += nextToDrop
        nextToDrop.clear()
    if newCells.size() > 0:
        drop_new() 
     # check for dropped cells for 3 of more in lines
    if droppedCells.size() > 0 and not check_non_null_cells(droppedCells):
        check_cells_type(droppedCells)
        droppedCells.clear()
     
    self.set_process(true)
    

# Hay celdas no nulas en la lista? 
func check_non_null_cells(cells: Array)->bool:
    for cell in cells:
        if is_instance_valid(grid[int(cell.x)][int(cell.y)]):
            return false
    return true
        
       
func cell_remover(coordinates: Vector2):
    var node = get_cell(coordinates)
    grid[int(coordinates.x)][int(coordinates.y)] = null
    node.queue_free()
    

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
                set_cells_state([coordinates], 'pressed', false)
             elif availableNeighbors.has(coordinates):
                selectionStack.push_back(coordinates)
                swap_cells()
                set_cells_state(selectionStack, 'pressed', false)
                check_cells_type(selectionStack)
                selectionStack.clear()
                availableNeighbors.clear()
                ScoreEventHandler.update_turns_left()
             
                
func check_cells_type(stack: Array):
   
    var scoreCells = 0
    var comboCounter = 0
    var cellsRemoved = []
    for hexCell in stack:
        var cell_type = get_cell_type(hexCell)
        # Check for static cells to avoid removing them
        if cell_type == util.Elements.STATIC:
            continue
        cellsRemoved = get_neighbors_w_direction(hexCell, cell_type)
        scoreCells += cellsRemoved.size()
        
        ScoreEventHandler.update_score(scoreCells)
        if cellsRemoved.size() > 0:
            comboCounter += 1
            ScoreEventHandler.update_combo(comboCounter)
            ScoreEventHandler.update_type_elimination(cell_type, cellsRemoved.size())
        eliminationQueue += cellsRemoved
        
    missingCells += eliminationQueue
    
    if comboCounter > 0:
        scoreCells = scoreCells * comboCounter
    
    ScoreEventHandler.update_score(scoreCells)
    ScoreEventHandler.update_combo(comboCounter)

func get_neighbors_w_direction(coord : Vector2, type :int)-> Array:
    var cells = []
    var parity = int(coord.y) & 1
    for axis in axis_direction[parity].keys():
        var axisNeigbors = []
        axisNeigbors += get_line_cells(coord, axis, type)
        if axisNeigbors.size() >= 2:
            cells += axisNeigbors
    if cells.size() > 1:  
        cells.push_front(coord)
    return cells

func get_line_cells(coord:Vector2, axis:String, type:int):
    var next = true
    var result = []
    var parity = int(coord.y) & 1
    var nextCell = origin 
    var axis_dir_list = axis_direction[parity][axis]
    
    for index in range(axis_dir_list.size()):     
        nextCell = coord + axis_dir_list[index]
        while next:
            if grid_has_cell(nextCell):
                var nextType = get_cell_type(nextCell)
                if nextType == type:
                    result.append(nextCell)
                    parity = int(nextCell.y) & 1
                    var direction =  axis_direction[parity][axis][index]
                    nextCell = nextCell + direction
                else:
                    next = false
            else:
                next = false
        next = true
    return result
        

func get_neighbors(coord : Vector2) -> Array:
    var hex_neighbor = []
    # We check for valid neighbors
    var parity = int(coord.y) & 1
    for direction in axial_directions[parity]:
        var hex_coord = coord + direction
        if grid_has_cell(hex_coord):
            hex_neighbor.append(hex_coord)       
    return hex_neighbor
    
func set_cells_state(cells : Array, state : String, active: bool) -> void:
    for cell_coord in cells:
        var hex_cell = get_cell(cell_coord)
        hex_cell.set_button_state(state, active)

func get_cell_type(coord : Vector2):
    return grid[int(coord.x)][int(coord.y)].type
  
func get_cell(coord : Vector2):
    return grid[int(coord.x)][int(coord.y)] 

func grid_has_cell(coord : Vector2)->bool:
    return (gridArea.has_point(coord) and  is_instance_valid(grid[int(coord.x)][int(coord.y)]))
    
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

    grid[int(selectionStack[0].x)][int(selectionStack[0].y)].set_animation_state("move_to", cellAPos)
    grid[int(selectionStack[1].x)][int(selectionStack[1].y)].set_animation_state("move_to", cellBPos)

    
func create_hex(x : int, y : int):
    var cell = hex_factory.instance()
    var position = get_screen_position(x, y)
    cell.position = position
    cell.scale = vectorScale
    cell.init(Vector2(x, y),  util.random())
    cell.set_animation_state("appear")
    
    # remove debug code
    var format_string = "%d" #-(%d,%d)"
    var string = format_string % [cell.type]#,x,y]
    cell.set_text(string)
    ##
    add_child(cell)
    return cell

func get_screen_position(x : int, y : int):
     var offsetX = 0
    
     if (y%2)==1:
        offsetX = offset.x/4
     else:
        offsetX = 0
   
     var posx = screenWoffset + (offset.x/2 * x) + offsetX 
     var posy = screenHOffset + (offset.y/3 * y)  

     return Vector2(posx,posy) 

func create_grid(scale : Vector2, vectorGridSize : Vector2):
    set_offset()
    gridSize = vectorGridSize
    gridArea = Rect2(origin, gridSize)
    col = vectorGridSize.x
    row = vectorGridSize.y
    vectorScale = scale
    
    for x in range(col):
        grid.append([])
        grid[x]=[]        
        for y in range(row):
            grid[x].append([])
            grid[x][y]=create_hex(x, y)


func drop_cells():

    missingCells.sort_custom(self, "sort_cells")
    missingCells = util.remove_dupes(missingCells)

    while missingCells.size() > 0:
      
        var voidCell = missingCells.pop_front()
       
        var parity = int(voidCell.y) & 1
        var UpLeftCell = voidCell + axis_direction[parity]["UpL-LoR"][0]
        var UpRightCell = voidCell + axis_direction[parity]["LoL-UpR"][1]

        var UpLeftCellType =  get_cell_type(UpLeftCell)  if grid_has_cell(UpLeftCell) else 0
        var UpRightCellType =  get_cell_type(UpRightCell)  if grid_has_cell(UpRightCell) else 0
        
        if grid_has_cell(UpLeftCell) and UpLeftCellType > 0:
            move_cell_to(UpLeftCell, voidCell)
            
        elif grid_has_cell(UpRightCell) and UpRightCellType > 0:
             move_cell_to(UpRightCell, voidCell)

        elif voidCell.y == 0:
            newCells.append(voidCell)
        
        elif UpRightCellType == 0 and UpLeftCellType == 0:
            newCells.append(voidCell)
            
        else:
            nextToDrop.append(voidCell)

func drop_new():
    for new in newCells:
        var node = create_hex(int(new.x),int(new.y))
        grid[int(new.x)][int(new.y)] = node
        node.set_animation_state("appear")
    newCells.clear()
    
func move_cell_to(origin:Vector2, destination:Vector2):
    var cell = get_cell(origin)
    grid[int(origin.x)][int(origin.y)] = null
    grid[int(destination.x)][int(destination.y)] = cell
    cell.set_coord(destination)
    cell.set_animation_state("move_to", get_screen_position(int(destination.x), int(destination.y)))
    nextToDrop.append(origin)
    droppedCells.append(destination)
    
func sort_cells(a:Vector2, b:Vector2):
    return a.y > b.y


        
        
     

            
