extends Node

enum goals {combo, points, type_elimination}
# goal definition
# {
#  type, = main() or bonus
#   goal  = points combo etc   
#  objective
#  cell_type for type_elimination
# }
var defined_goals = []
   

onready var util = preload("Util/Util.gd").new()

func _ready():
    pass
# todo create a better calculation for level diffuclty for the objectuve
func set_goals(rng: RandomNumberGenerator, main_goal: bool, level: int):
     var goal = rng.randi_range(0, goals.size())
     var objective = 0
     var cell_type = 0
     match goal:
        0: #combo
            objective = rng.randi_range(2, 8)
        1:#points
            objective = level * 50
        2:#type
            objective = level * 3
            cell_type = rng.randi_range(1, util.Elements.size())
     
     defined_goals.append({
        "type": "main" if main_goal else "bonus",
        "goal": goal,
        "objective": objective,
        "cell_type": cell_type
       })

func check_goals_acheived():
    pass
