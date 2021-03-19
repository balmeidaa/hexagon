extends Node2D

var cellScale = .5
onready var scoreLabel = get_node("GUI/Container/Score")
onready var comboLabel = get_node("GUI/Container/Combo")
var score = 0
var combo = 0
# TODO How to calculate turns the player has left
var turns_left = 0

var formatScore = "Score: %d" 
var formatCombo = "Best Combo: %dx" 
var formatTurnsLeft = "Turns Left: %d" 

func _ready():

    var vectorScale = Vector2(cellScale, cellScale)
    var vectorGridSize = Vector2(13,10)
    reset()
        
    ScoreEventHandler.connect("score", self, "update_score")
    ScoreEventHandler.connect("combo", self, "update_combo")
    $HexGrid.create_grid(vectorScale, vectorGridSize)

func reset():
    score = 0
    combo = 0
    set_label_text(scoreLabel, formatScore, score)
    set_label_text(comboLabel, formatCombo, combo)
    
func update_score(addScore:int):
    score += addScore
    set_label_text(scoreLabel, formatScore, score)
    
func update_combo(updateCombo:int):
    if combo <=  updateCombo:
        combo = updateCombo    
        set_label_text(comboLabel, formatCombo, combo)
    
func set_label_text(label: Label,format: String, val: int):
    label.text = format %  val
