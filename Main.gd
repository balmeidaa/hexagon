extends Node2D

var cellScale = .5
var util = preload("Util/Util.gd").new()
var levelLoader = preload("LoadLevels.gd").new()

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
var defined_goals = []
const combo_goal = 0
const points_goal = 1
const elimination_goal = 2

var nextLevel = false

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

#TODO create a game loop
func _ready():
    util.rng.randomize()
    vectorScale = Vector2(cellScale, cellScale)
    reset()    
    levelData = levelLoader.load_file()
    load_level()
    ScoreEventHandler.connect("score", self, "update_score")
    ScoreEventHandler.connect("combo", self, "update_combo")
    ScoreEventHandler.connect("type_elimination", self, "check_elimination_goal")
    ScoreEventHandler.connect("turns_left", self, "update_turns_left")
   
func load_level():
    if currentLevel >= levelData.size():
        return
    HexGrid.probBomb = levelData[currentLevel].probBomb
    HexGrid.probLineRemover = levelData[currentLevel].probLineRemover
    HexGrid.probHexRemover = levelData[currentLevel].probHexRemover
    
    turns_left = levelData[currentLevel].turns
    set_label_text(turnsLabel, formatTurnsLeft, turns_left)
    
    defined_goals.push_back(levelData[currentLevel].main_goal)
    defined_goals.push_back(levelData[currentLevel].bonus_goal)
    
    for goal in defined_goals:

        var goalText = ''    
        if  goal.goal ==  combo_goal:
                goalText = "Get a %dx Combo" %  goal.objective  
        elif  goal.goal ==  points_goal:
                goalText = "Make %d points" %  goal.objective 
        elif goal.goal ==  elimination_goal:
                var type_cell = util.Elements.keys()[goal.cell_type].to_lower()
                goalText = "Eliminate %d %s cells" %  [goal.objective, type_cell]

        if goal.main_goal:
             set_label_text(mainGoalLabel, formatMainGoal, goalText)
        else:
            set_label_text(bonusGoalLabel, formatBonusGoal, goalText)
            
        for obstacle in levelData[currentLevel].level_obstacles:
            for position in obstacle.position:
                HexGrid.grid[position.x][position.y].set_type(obstacle.type)
        

func _process(_delta):
    check_goals_acheived()
    if turns_left <= 0:
        $Menu/Box.show()
        HexGrid.queue_free()
        self.set_process(false)
    elif nextLevel == true:
        HexGrid.queue_free()
        self.set_process(false)
        currentLevel += 1
        reset()
        load_level()
  
func check_elimination_goal(type:int, amount:int):
    for goal in defined_goals:
        if goal.goal == elimination_goal and goal.cell_type == type:
            type_counter += amount

# todo condition for next level
func check_goals_acheived():
    var objectiveCompleteText = "Complete!"

    for goal in defined_goals:
        var goalComplete = false
        if  combo_goal ==  goal.goal:
            if combo >= goal.objective: 
                goalComplete = true
        elif  points_goal ==    goal.goal:
            if score >= goal.objective: 
                goalComplete = true
        elif  elimination_goal ==   goal.goal:
                if type_counter >= goal.objective: 
                    goalComplete = true
        if goal.main_goal and goalComplete:
            nextLevel = true
            set_label_text(mainGoalLabel, formatMainGoal, objectiveCompleteText)
        elif goalComplete:
            update_score(score * .5)
            set_label_text(bonusGoalLabel, formatBonusGoal, objectiveCompleteText)
        


func reset():
    self.set_process(true)
    nextLevel = false
    score = 0
    combo = 0
    type_counter = 0
    var cell_type_goal = util.rng.randi_range(2, util.Elements.size()-1)
    set_label_text(scoreLabel, formatScore, score)
    set_label_text(comboLabel, formatCombo, combo)
    $Menu/Box.hide()
    HexGrid = hex_grid_factory.instance()
    add_child(HexGrid)
    HexGrid.create_grid(vectorScale, vectorGridSize)


                
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
    currentLevel = 0
    reset()
