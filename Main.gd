extends Node2D

var cellScale = .5
var goalGenerator = preload("ProceduralGoal.gd").new()
var util = preload("Util/Util.gd").new()

onready var scoreLabel = get_node("GUI/Container/Scoreboard/Score")
onready var comboLabel = get_node("GUI/Container/Scoreboard/Combo")
onready var turnsLabel = get_node("GUI/Container/Scoreboard/TurnsLeft")

onready var mainGoalLabel = get_node("GUI/Container/Goals/MainGoal")
onready var bonusGoalLabel = get_node("GUI/Container/Goals/BonusGoal")

var score = 0
var combo = 0
var level = 1
var type_counter = 0
# TODO How to calculate turns the player has left
var turns_left = 20

const combo_goal = 0
const points_goal = 1
const elimination_goal = 2

var formatScore = "Score: %d" 
var formatCombo = "Best Combo: %sx" 
var formatTurnsLeft = "Turns Left: %d" 
var formatMainGoal = "Goal: %s"
var formatBonusGoal = "Bonus Goal: %s"

#TODO create a game loop
func _ready():

    var vectorScale = Vector2(cellScale, cellScale)
    var vectorGridSize = Vector2(13,10)
    reset()
        
    ScoreEventHandler.connect("score", self, "update_score")
    ScoreEventHandler.connect("combo", self, "update_combo")
    ScoreEventHandler.connect("type_elimination", self, "check_type_goal")
    ScoreEventHandler.connect("turns_left", self, "update_turns_left")
        
    $HexGrid.create_grid(vectorScale, vectorGridSize)
  

func _process(_delta):
    check_goals_acheived()
  
func check_type_goal(type:int, amount:int):
    for goal in goalGenerator.defined_goals:
        if goal["objective"] == elimination_goal and goal["cell_type"] == type:
            type_counter += amount
# todo condition for next level
func check_goals_acheived():
    var objectiveCompleteText = "Complete!"
    if is_instance_valid(goalGenerator):
        for goal in goalGenerator.defined_goals:
            var goalComplete = false
            match goal["goal"]:
                combo_goal:
                    if combo >= goal['objective']: 
                        goalComplete = true
                points_goal:
                    if score >= goal['objective']: 
                        goalComplete = true
                elimination_goal:
                    if type_counter >= goal['objective']: 
                        goalComplete = true
            if goal["main_goal"] and goalComplete:
                set_label_text_combo(mainGoalLabel, formatMainGoal, objectiveCompleteText)
            elif goalComplete:
                set_label_text_combo(bonusGoalLabel, formatBonusGoal, objectiveCompleteText)
        


func reset():
    score = 0
    combo = 0
    turns_left = 20
    type_counter = 0
    set_label_text(scoreLabel, formatScore, score)
    set_label_text(comboLabel, formatCombo, combo)
    set_label_text(turnsLabel, formatTurnsLeft, turns_left)
    goalGenerator.set_goals(true, level)
    goalGenerator.set_goals(false, level)
    for goal in goalGenerator.defined_goals:
        var goalText = ''
        
        match goal["goal"]:
             combo_goal:
               goalText = "Get a %dx Combo" %  goal["objective"]   
             points_goal:
                goalText = "Make %d points" %  goal["objective"]  
             elimination_goal:
                var type_cell = util.Elements.keys()[goal["cell_type"]].to_lower()
                goalText = "Eliminate %d %s cells" %  [goal["objective"], type_cell]
        
        if goal["main_goal"]:
             set_label_text_combo(mainGoalLabel, formatMainGoal, goalText)
        else:
            set_label_text_combo(bonusGoalLabel, formatBonusGoal, goalText)
                
func update_turns_left():
    turns_left -= 1
    set_label_text(turnsLabel, formatTurnsLeft, turns_left)
    
func update_score(addScore:int):
    score += addScore
    set_label_text(scoreLabel, formatScore, score)
    
func update_combo(updateCombo:int):
    if combo <=  updateCombo:
        combo = updateCombo    
        set_label_text(comboLabel, formatCombo, combo)
    
func set_label_text(label: Label,format: String, val: int):
    label.text = format %  val
    
func set_label_text_combo(label: Label,format: String, val: String):
    label.text = format %  val
