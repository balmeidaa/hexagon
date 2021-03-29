extends Node

enum goals {combo, points, type_elimination}
# goal definition
# {
#  main_goal, = main() or bonus
#   goal  = points combo etc   
#  objective
#  cell_type for type_elimination
# }
var defined_goals = []
 
var util = preload("Util/Util.gd").new()     

func set_goals(main_goal: bool, level: int):
     util.rng.randomize()
     var goal = util.rng.randi_range(0, goals.size()-1)
     var objective = 0
     var cell_type = 0
     match goal:
        0: #combo
            objective = util.rng.randi_range(2, 8)
        1:#points
            objective = level * 50
        2:#type
            objective = level * 3
            cell_type = util.rng.randi_range(1, util.Elements.size())
     
     defined_goals.append({
        "main_goal": main_goal,
        "goal": goal,
        "objective": objective,
        "cell_type": cell_type
       })

func check_goals_acheived():
    pass
