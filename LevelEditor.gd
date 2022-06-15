extends Node2D
const hex_grid_factory= preload("res://HexGrid.tscn")
const button_editor = preload("res://Button.tscn")
var HexGrid = null
export var cellScale = .5
var vectorScale = Vector2(cellScale, cellScale)
export var vectorGridSize = Vector2(13,10)
var util = preload("Util/Util.gd").new()
onready var grid = $Grid 

####UI objetcs
onready var difficult_mode = $TabContainer/items/LevelFeatures/CheckBox
onready var bomb_prob = $TabContainer/items/LevelFeatures/BombContainer/SpinBox
onready var line_prob = $TabContainer/items/LevelFeatures/LineRemover/SpinBox
onready var hex_prob = $TabContainer/items/LevelFeatures/HexRemover/SpinBox

onready var target_goal = $TabContainer/objective/LevelGoals/MainGoal/target
onready var target_bonus = $TabContainer/objective/LevelGoals/BonusGoal/targetBonus
onready var turns = $TabContainer/objective/LevelGoals/TurnsCounter/turns

onready var current_level = $TabContainer/levels/container/Container2/CurrentLevel
onready var current_level_label = $TabContainer/levels/container/Container4/CurrentLevelLabel


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

var levels = []
var current_level_data = {}
var default_level = {
    "difficultMode": false,
    "probBomb": 0,
    "probLineRemover": 0,
    "probHexRemover": 0,
    "turns": 15,
    "main_goal": {
    },
    "bonus_goal": {
    },
    "level_obstacles": []
  }

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
    
var default_level_cells = []

####
# {
#        "type": 3,
#        "position": [
#          {
#            "x": 5,
#            "y": 3
#          },
#          {
#            "x": 6,
#            "y": 3
#          }
#        ]
#      }
####

func _ready():
    button_types += util.SpecialCells
    button_types += util.nonClickable
    
    levels.append(default_level)
    current_level_data = default_level
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


func _on_points_toggled(button_pressed):
    main_goal.goal = 1


func _on_remove_toggled(button_pressed):
    cells_drop.disabled = !button_pressed
    main_goal.goal = 2
##### bonus 

func _on_comboBonus_toggled(button_pressed):
    bonus_goal.goal = 0

func _on_pointsBonus_toggled(button_pressed):
    bonus_goal.goal = 1

func _on_removeBonus_toggled(button_pressed):
   cells_drop_bonus.disabled = !button_pressed
   bonus_goal.goal = 2


####bonus radio buttons


func _on_TotalLevels_value_changed(value):
    current_level.max_value = value


func _on_load_pressed():
    current_level_label.text = str(current_level.value)
    load_level_data_ui(levels[current_level.value])


func load_level_data_ui(level_data):
    current_level_data = level_data
    difficult_mode = current_level_data.difficultMode
    bomb_prob = current_level_data.probBomb
    line_prob = current_level_data.probLineRemover
    hex_prob = current_level_data.probHexRemover
    
    target_goal = current_level_data.main_goal.objective
    target_bonus = current_level_data.bonus_goal.objective
    turns = current_level_data.turns
    
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


func _on_target_value_changed(value):
    main_goal.objective = value

func _on_cellDropdown_item_selected(id):
    main_goal.cell_type = cells_drop.get_item_id(id)
     


func _on_cellDropdownBonus_item_selected(id):
    bonus_goal.cell_type = cells_drop.get_item_id(id)
