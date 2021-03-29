extends Node
signal score
signal combo
signal type_elimination
signal turns_left

func _ready():
    pass
    
func update_score(score: int):
    emit_signal("score", score)

func update_combo(combo: int):
    emit_signal("combo", combo)
    
func update_type_elimination(type :int, amount:int):
    emit_signal("type_elimination", type, amount)
    
func update_turns_left():
    emit_signal("turns_left")
    
    

