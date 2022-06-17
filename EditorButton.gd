extends TextureButton
 

const formatFileString = "res://Assets/Img/%s.png"
const formatFileStringPressed = "res://Assets/Img/%s_pressed.png"
var type = 0
var util = preload("Util/Util.gd").new()

func _ready():
    pass


func set_type(newType : int):
    type = newType
    load_texture()

func load_texture():
    var file_name = formatFileString % util.Elements.keys()[type].to_lower()
    self.set_normal_texture(load(file_name))
        

func _on_Button_mouse_entered():
    self.set_hover_texture(load(get_filename()))


func _on_Button_pressed():
    self.set_pressed_texture(load(get_filename()))
    CellEventHandler.emit_cell_type(type)

func get_filename():
    return formatFileStringPressed % util.Elements.keys()[type].to_lower()
