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
var turns_left = 1

const combo_goal = 0
const points_goal = 1
const elimination_goal = 2

var formatScore = "Score: %s" 
var formatCombo = "Best Combo: %sx" 
var formatTurnsLeft = "Turns Left: %s" 
var formatMainGoal = "Goal: %s"
var formatBonusGoal = "Bonus Goal: %s"
var vectorScale = Vector2(0, 0)
var vectorGridSize = Vector2(13,10)

const hex_grid_factory= preload("res://HexGrid.tscn")
var HexGrid = null
#TODO create a game loop
func _ready():
    util.rng.randomize()
    vectorScale = Vector2(cellScale, cellScale)
    reset()
        
    ScoreEventHandler.connect("score", self, "update_score")
    ScoreEventHandler.connect("combo", self, "update_combo")
    ScoreEventHandler.connect("type_elimination", self, "check_elimination_goal")
    ScoreEventHandler.connect("turns_left", self, "update_turns_left")
        

  

func _process(_delta):
    check_goals_acheived()
    if turns_left <= 0:
        $Menu/Box.show()
        HexGrid.queue_free()
        self.set_process(false)
  
func check_elimination_goal(type:int, amount:int):
    for goal in goalGenerator.defined_goals:
        if goal["goal"] == elimination_goal and goal["cell_type"] == type:
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
                set_label_text(mainGoalLabel, formatMainGoal, objectiveCompleteText)
            elif goalComplete:
                set_label_text(bonusGoalLabel, formatBonusGoal, objectiveCompleteText)
        


func reset():
    self.set_process(true)
    score = 0
    combo = 0
    turns_left = 3
    type_counter = 0
    var cell_type_goal = util.rng.randi_range(2, util.Elements.size()-1)
    set_label_text(scoreLabel, formatScore, score)
    set_label_text(comboLabel, formatCombo, combo)
    set_label_text(turnsLabel, formatTurnsLeft, turns_left)
    goalGenerator.set_goals(true,1, level)
    goalGenerator.set_goals(false,2, level, cell_type_goal)
    $Menu/Box.hide()
    HexGrid = hex_grid_factory.instance()
    add_child(HexGrid)
    HexGrid.create_grid(vectorScale, vectorGridSize)
    
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
             set_label_text(mainGoalLabel, formatMainGoal, goalText)
        else:
            set_label_text(bonusGoalLabel, formatBonusGoal, goalText)
                
func update_turns_left():
    turns_left -= 1
    set_label_text(turnsLabel, formatTurnsLeft, turns_left)
    
func update_score(addScore:int):
    score += addScore
    set_label_text(scoreLabel, formatScore, score)
    
func update_combo(updateCombo:int):
    if combo <  updateCombo:
        combo = updateCombo  
        $ComboAudio.play()  
        set_label_text(comboLabel, formatCombo, combo)
    
func set_label_text(label: Label,format: String, val):
    label.text = format %  String(val)
    



func _on_NewGame_pressed():
    reset()
