extends Node


func _ready():
    pass
    
func load_file() -> Dictionary:
    var file := File.new()
    file.open("res://levels.json", File.READ)
    var result := JSON.parse(file.get_as_text())
    file.close()

    if result.error:
        printerr("Failed to parse level data: ", file.error_string)
    return result.result
