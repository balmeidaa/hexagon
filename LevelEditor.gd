extends Node2D
const hex_grid_factory= preload("res://HexGrid.tscn")
const button_editor = preload("res://Button.tscn")
var HexGrid = null
export var cellScale = .5
var vectorScale = Vector2(cellScale, cellScale)
export var vectorGridSize = Vector2(13,10)
var util = preload("Util/Util.gd").new()
var levelLoader = preload("LoadLevels.gd").new()
onready var grid = $Grid 

####UI objetcs
onready var difficult_mode = $TabContainer/items/LevelFeatures/difficiltMode
onready var bomb_prob = $TabContainer/items/LevelFeatures/BombContainer/bombPercent
onready var line_prob = $TabContainer/items/LevelFeatures/LineRemover/linePercent
onready var hex_prob = $TabContainer/items/LevelFeatures/HexRemover/hexPercent

onready var target_goal = $TabContainer/objective/LevelGoals/MainGoal/target
onready var target_bonus = $TabContainer/objective/LevelGoals/BonusGoal/targetBonus
onready var turns = $TabContainer/objective/LevelGoals/TurnsCounter/turns

onready var current_level = $TabContainer/levels/container/Container2/CurrentLevel
onready var current_level_label = $TabContainer/levels/container/Container4/CurrentLevelLabel

onready var total_levels = $TabContainer/levels/container/Container/TotalLevels
onready var combo = $TabContainer/objective/LevelGoals/MainGoal/TypeGoal/combo
onready var points = $TabContainer/objective/LevelGoals/MainGoal/TypeGoal/points
onready var remove = $TabContainer/objective/LevelGoals/MainGoal/TypeGoal/remove
onready var cells_drop = $TabContainer/objective/LevelGoals/MainGoal/TypeGoal/cellDropdown

onready var bonus_goal_active = $TabContainer/objective/LevelGoals/BonusGoal/Labelcontainer/BonusGoalActive

onready var combo_bonus = $TabContainer/objective/LevelGoals/BonusGoal/TypeGoal/comboBonus
onready var points_bonus = $TabContainer/objective/LevelGoals/BonusGoal/TypeGoal/pointsBonus
onready var remove_bonus = $TabContainer/objective/LevelGoals/BonusGoal/TypeGoal/removeBonus
onready var cells_drop_bonus = $TabContainer/objective/LevelGoals/BonusGoal/TypeGoal/cellDropdownBonus
####

var button_types = []
var buttons = []
var level_edited = 0
var levels = []
var current_level_data = {}


var main_goal =  {
      "main_goal": true,
      "goal": 0,
      "objective": 0,
      "cell_type": 0
    }
    
var bonus_goal =  {
      "main_goal": false,
      "goal": 0,
      "objective": 0,
      "cell_type": 0
    }

var default_level = {
    "difficultMode": false,
    "probBomb": 0,
    "probLineRemover": 0,
    "probHexRemover": 0,
    "turns": 15,
    "main_goal": main_goal,
    "bonus_goal": bonus_goal,
    "level_obstacles": []
  }


    
var level_cells = []
var cell_default = {
    "type":0, 
    "position":[] 
}
var cell_data = cell_default.duplicate(true)

func _ready():
    CellEventHandler.connect("cell_type_signal", self, "change_cell_type")
    CellEventHandler.connect("cell_pressed", self, "save_cell_coord")
    button_types += util.SpecialCells
    button_types += util.nonClickable
    
    current_level_data = default_level.duplicate(true) 
    levels.append(current_level_data)
    
    for type in button_types:
        var button = button_editor.instance()
        grid.add_child(button)
        buttons.append(button)
        button.set_type(type)
    
    var elements = util.Elements.keys()
    var types = util.normalCells
    
    for index in types.size():
        cells_drop.add_item(elements[types[index]], types[index])
        cells_drop_bonus.add_item(elements[types[index]], types[index])

    
       
    util.rng.randomize()
    CellEventHandler.level_editor = true
    HexGrid = hex_grid_factory.instance()   
    add_child(HexGrid)
    HexGrid.create_grid(vectorScale, vectorGridSize)



func _on_combo_toggled(button_pressed):
    main_goal.goal = 0
    save_goals()

func _on_points_toggled(button_pressed):
    main_goal.goal = 1
    save_goals()

func _on_remove_toggled(button_pressed):
    cells_drop.disabled = !button_pressed
    main_goal.goal = 2
    save_goals()
##### bonus 

func _on_comboBonus_toggled(button_pressed):
    bonus_goal.goal = 0
    save_goals()

func _on_pointsBonus_toggled(button_pressed):
    bonus_goal.goal = 1
    save_goals()

func _on_removeBonus_toggled(button_pressed):
   cells_drop_bonus.disabled = !button_pressed
   bonus_goal.goal = 2
   save_goals()


####bonus radio buttons



func load_level_data_ui(level_data):
    current_level_data = level_data.duplicate(true)
    difficult_mode.toggle_mode = current_level_data.difficultMode
    bomb_prob.value = current_level_data.probBomb
    line_prob.value = current_level_data.probLineRemover
    hex_prob.value = current_level_data.probHexRemover
    
    target_goal.value = current_level_data.main_goal.objective
    target_bonus.value = current_level_data.bonus_goal.objective
    turns.value = current_level_data.turns
    #revisar aqui los combos
    match (current_level_data.main_goal.goal):
        0:
            combo.pressed = true
        1:
            points.pressed = true
        2:
            remove.pressed = true
          
    match (current_level_data.bonus_goal.goal):
        0:
            combo_bonus.pressed = true
        1:
            points_bonus.pressed = true
        2:
            remove_bonus.pressed = true
    HexGrid.queue_free()
    HexGrid = hex_grid_factory.instance()
    add_child(HexGrid)  
    HexGrid.create_grid(vectorScale, vectorGridSize)
    
    for obstacle in current_level_data.level_obstacles:
        for position in obstacle.position:           
            HexGrid.grid[position.x][position.y].set_type(obstacle.type)


### Don't touch!
func _on_difficiltMode_toggled(button_pressed):
    current_level_data.difficultMode = button_pressed


func _on_bombPercent_value_changed(value):
    current_level_data.probBomb = value  


func _on_linePercent_value_changed(value):
    current_level_data.probLineRemover = value  


func _on_hexPercent_value_changed(value):
    current_level_data.probHexRemover = value


func _on_turns_value_changed(value):
    current_level_data.turns = value


func _on_targetBonus_value_changed(value):
    bonus_goal.objective = value
    save_goals()


func _on_target_value_changed(value):
    main_goal.objective = value
    save_goals()

func _on_cellDropdown_item_selected(id):
    main_goal.cell_type = cells_drop.get_item_id(id)
     

func _on_cellDropdownBonus_item_selected(id):
    bonus_goal.cell_type = cells_drop.get_item_id(id)

###level load


func _on_TotalLevels_value_changed(value):
    
    var old_val = current_level.max_value
    current_level.max_value = value - 1

    var difference = (value-1) - old_val

    if difference > 0:
        for i in difference:
            levels.append(default_level.duplicate(true))
    else:
        for i in (abs(difference)):
            levels.pop_back()

        

func _on_CurrentLevel_value_changed(value):
    save_current()

    levels[level_edited] = current_level_data.duplicate(true)
    current_level_label.text = str(current_level.value)
    current_level_data = levels[value].duplicate(true)
    level_edited = value
    load_level_data_ui(levels[value])
 


func _on_save_pressed():
    save_current()
    var file = File.new()
    file.open("res://levels.json", File.WRITE)
    file.store_string(JSON.print(levels,'\t'))
    file.close()



func _on_reset_pressed():
    current_level_data = default_level.duplicate(true)
    load_level_data_ui(current_level_data)

func change_cell_type(type):
    cell_data.type = type 
    #sin datos en celdas
    if cell_data.position.size() == 0:
       return
    #si el tipo de celda ya existia pero se agregan mas
    for index in level_cells.size():
        if level_cells[index].type == type:
            cell_data = level_cells[index].duplicate(true)
            level_cells.remove(index)
            return    
    #tipos nuevos de celdas
    level_cells.append(cell_data.duplicate(true))
    cell_data = cell_default.duplicate(true)
      



func save_cell_coord(coord:Vector2): 
    var index = cell_data.position.find(coord)
    if index == -1:
        cell_data.position.append(coord)
    else:
       cell_data.position.remove(index) 

  
func save_current():
    if cell_data.position.size() > 0:
        level_cells.append(cell_data)
        cell_data = cell_default.duplicate(true)

    if level_cells.size() > 0:
        current_level_data.level_obstacles = level_cells
    level_cells = []



func _on_load_pressed():
    load_from_file()

func save_goals():
    current_level_data.main_goal = main_goal
    current_level_data.bonus_goal = bonus_goal
    
func load_from_file():
    levels = levelLoader.load_file() 
    total_levels.value = levels.size()
    for level in levels.size():
        for obstacle in levels[level].level_obstacles.size():
            for index in levels[level].level_obstacles[obstacle].position.size():
                levels[level].level_obstacles[obstacle].position[index] = str2var("Vector2" + levels[level].level_obstacles[obstacle].position[index])
    load_level_data_ui(levels[0])
                 
