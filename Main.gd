extends Node2D

onready var TweenAnim = $Tween
onready var Message = $Menu/Box/Message
var cellScale = .5
var util = preload("Util/Util.gd").new()
var levelLoader = preload("LoadLevels.gd").new()

onready var scoreLabel = get_node("GUI/Container/Scoreboard/Score")
onready var comboLabel = get_node("GUI/Container/Scoreboard/Combo")
onready var turnsLabel = get_node("GUI/Container/Scoreboard/TurnsLeft")

onready var mainGoalLabel = get_node("GUI/Container/Goals/HBoxContainer/MainGoal")
onready var bonusGoalLabel = get_node("GUI/Container/Goals/HBoxContainer/BonusGoal")
onready var levelLabel = get_node("GUI/Container/Goals/HBoxContainer2/Level")

var score = 0
var combo = 0
var level = 1
var type_counter = 0
# TODO How to calculate turns the player has left
var turns_left = 1
var defined_goals = []
const combo_goal = 0
const points_goal = 1
const elimination_goal = 2

var nextLevel = false
const hex_factory = preload("res://HexCell.tscn")
var formatScore = "Score: %s" 
var formatCombo = "Best Combo: %sx" 
var formatTurnsLeft = "Turns Left: %s" 
var formatMainGoal = "Goal: %s"
var formatBonusGoal = "Bonus Goal: %s"
var vectorScale = Vector2(0, 0)
var vectorGridSize = Vector2(13,10)

const hex_grid_factory= preload("res://HexGrid.tscn")
var HexGrid = null
var levelData = {}
var currentLevel = 0

var cells = []
#TODO create a game loop
func _ready():

    CellEventHandler.connect("cell_exploded", self, "camera_shake")
    
    $Menu/Box.hide()
    util.rng.randomize()
    vectorScale = Vector2(cellScale, cellScale)
    reset()    
    levelData = levelLoader.load_file()
    load_level()
#    $Debugger.add_property($HexGrid, "missingCells", "")
#    $Debugger.add_property($HexGrid, "newCells", "")
    ScoreEventHandler.connect("score", self, "update_score")
    ScoreEventHandler.connect("combo", self, "update_combo")
    ScoreEventHandler.connect("type_elimination", self, "check_elimination_goal")
    ScoreEventHandler.connect("turns_left", self, "update_turns_left")
 
func load_level():
    defined_goals.clear()
    levelLabel.text = "Level: %d" %  (currentLevel+1)  
    if currentLevel > levelData.size()-1:
        Message.text = "You Win!"
        stop_game()
        return

    turns_left = levelData[currentLevel].turns
    set_label_text(turnsLabel, formatTurnsLeft, turns_left)
    set_prob_items()
    HexGrid.difficultMode = levelData[currentLevel].difficultMode
    HexGrid.create_grid(vectorScale, vectorGridSize)
    defined_goals.push_back(levelData[currentLevel].main_goal)
    defined_goals.push_back(levelData[currentLevel].bonus_goal)

    for goal in defined_goals:
   
        var goalText = ''    
        if  goal.goal ==  combo_goal:
                goalText = "Get a %dx Combo" %  goal.objective  
        elif  goal.goal ==  points_goal:
                goalText = "Make %d points" %  goal.objective 
        elif goal.goal ==  elimination_goal:
                goalText = "               Eliminate %d cells" %  [(goal.objective - type_counter)]
                var cell = hex_factory.instance()
               
                var position = Vector2.ZERO
                
                if goal.main_goal:     
                    position.x = 120
                    position.y = 80
           
                else:
                    position.x = 180
                    position.y = 130                   
                    
                cell.position = position
                cell.scale = Vector2(0.3, 0.3)
                cell.set_type(goal.cell_type)
                cell.set_button_state('disabled', true)
                cells.append(cell)
                add_child(cell)

        if goal.main_goal:
             set_label_text(mainGoalLabel, formatMainGoal, goalText)
        else:
            set_label_text(bonusGoalLabel, formatBonusGoal, goalText)
            
        for obstacle in levelData[currentLevel].level_obstacles:
            for cords in obstacle.position:
                var position = str2var("Vector2" + cords)
                HexGrid.grid[position.x][position.y].set_type(obstacle.type)
                
                
func stop_game():
        $Menu/Box.show()
        $Menu/Box/NewGame.show()
        HexGrid.queue_free()
        self.set_process(false)
        
       
        
func _process(_delta):
    check_goals_acheived()
    if turns_left <= 0:
        Message.text = "Game Over"
        stop_game()
    elif nextLevel == true:
        currentLevel += 1
        Message.text = "Level Complete!"
        removeCellUI()
        $Menu/Box.show()
        Message.show()
     
        $Menu/Box/NewGame.hide()
        self.set_process(false)
       
        $Timer.start()
             
  
func check_elimination_goal(type:int, amount:int):
    for goal in defined_goals:
        if goal.goal == elimination_goal and goal.cell_type == type:
            type_counter += amount

# todo condition for next level
func check_goals_acheived():
    var objectiveCompleteText = "Complete!"
    var goalText = ''
    for goal in defined_goals:
        var goalComplete = false
        if  combo_goal ==  goal.goal:
            if combo >= goal.objective: 
                goalComplete = true
        elif  points_goal ==    goal.goal:
            if score >= goal.objective: 
                goalComplete = true
        elif  elimination_goal ==   goal.goal:
                goalText = "        Eliminate %d cells" %  [(goal.objective - type_counter)]
                if goal.main_goal:
                    set_label_text(mainGoalLabel, formatMainGoal, goalText)
                else:
                    set_label_text(bonusGoalLabel, formatBonusGoal, goalText)
                if type_counter >= goal.objective: 
                    removeCellUI()
                    goalComplete = true
        if goal.main_goal and goalComplete:
            nextLevel = true
            set_label_text(mainGoalLabel, formatMainGoal, objectiveCompleteText)
        elif goalComplete:
            set_label_text(bonusGoalLabel, formatBonusGoal, objectiveCompleteText)
    

func reset():
    $Menu/Box.hide()
    self.set_process(true)
    nextLevel = false
    score = 0
    combo = 0
    type_counter = 0
    set_label_text(scoreLabel, formatScore, score)
    set_label_text(comboLabel, formatCombo, combo)
    HexGrid = hex_grid_factory.instance()
    add_child(HexGrid)
    


                
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
#    var newLabelText = format %  String(val)
#    $Tween.interpolate_method(label,"set_text",0, 500, 2.0, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
#    $Tween.start()
    label.text = format %  String(val)
    

func _on_NewGame_pressed():
    currentLevel = 0
    nextLevel = false
    reset()
    load_level()

func _on_Timer_timeout():
     if is_instance_valid(HexGrid):
        HexGrid.hide()
        HexGrid.queue_free()
     TweenAnim.interpolate_property(Message, "modulate", 
        Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.8, 
        Tween.TRANS_LINEAR)
     TweenAnim.start()
     reset()
     load_level()
     
func camera_shake():
    $ShakeCamera.add_trauma(.25)
    $ShakeCamera.add_trauma(.3)

func set_prob_items():
    HexGrid.probBomb = levelData[currentLevel].probBomb
    HexGrid.probLineRemover = levelData[currentLevel].probLineRemover
    HexGrid.probHexRemover = levelData[currentLevel].probHexRemover
    HexGrid.difficultMode = levelData[currentLevel].difficultMode


func removeCellUI():
    for cell in cells:
        if is_instance_valid(cell):
                cell.queue_free()
