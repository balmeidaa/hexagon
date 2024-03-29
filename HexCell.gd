extends Node2D
onready var TweenAnimator = $Tween
var type = 0
var coord = Vector2(0,0)

const formatFileString = "res://Assets/Img/%s.png"
const formatFileStringPressed = "res://Assets/Img/%s_pressed.png"
var animationState = []
var nextPosition = []
var animation = ""
onready var label_button = $Button/Label  
var util = preload("Util/Util.gd").new()
    
func _ready():
    if CellEventHandler.level_editor:
        label_button.show()
        $Button.toggle_mode = false
    
func _process(_delta):
        
    if animationState.size() > 0 :
        animation = animationState.pop_front()
        match animation:
            "move_to":
                move_to()
            "remove":
                remove()
            "appear":
                appear()
            "explode":
                explode()
            _:
                pass


func set_type(newType : int):
    type = newType
    load_texture()

func load_texture():
    if util.nonClickable.has(type):
        $Button.disabled = true

    var file_name = formatFileString % util.Elements.keys()[type].to_lower()
    $Button.set_normal_texture(load(file_name))
        

func get_size():
    return $Button.get_size()

func set_coord(gridPosition: Vector2):    
    coord = gridPosition

func set_button_state(state:String, active: bool):
    $Button.set(state, active) 
    
func set_animation_state(newState:String, position: Vector2 = Vector2(0,0)):
    animationState.append(newState)
    if position !=  Vector2(0,0):
        nextPosition.append(position)

func _on_Cell_pressed():
    if not CellEventHandler.level_editor:
        get_hover_pressed_texture()
        CellEventHandler.cell_pressed(coord)
    else:
        set_type(CellEventHandler.cell_type)
        CellEventHandler.cell_pressed(coord)


func move_to():
    TweenAnimator.interpolate_property(self, "position",
        self.position, nextPosition.pop_front(), 0.3,
        Tween.TRANS_QUART, Tween.EASE_IN_OUT)
    TweenAnimator.start()
    $SwapAudio.play()

# rework this tween
func appear():    
    TweenAnimator.interpolate_property(self, "modulate", 
    Color(1, 1, 1, 0.3), Color(1, 1, 1, 1), 0.5, 
    Tween.TRANS_LINEAR)
    TweenAnimator.start() 

func remove():
    TweenAnimator.interpolate_property(self, "scale", 
    self.scale, (self.scale*1.2), 0.5, 
    Tween.TRANS_QUINT, Tween.EASE_IN)
    
    TweenAnimator.interpolate_property(self, "modulate", 
    Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5, 
    Tween.TRANS_QUINT, Tween.EASE_IN)
    TweenAnimator.start()   
    $RemoveAudio.play()

func explode():
    
    TweenAnimator.interpolate_property(self, "scale", 
    self.scale, (self.scale*1.8), 0.3, 
    Tween.TRANS_QUINT, Tween.EASE_OUT)
    
    TweenAnimator.interpolate_property(self, "modulate", 
    Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.3, 
    Tween.TRANS_QUINT, Tween.EASE_OUT)
    TweenAnimator.start()
    CellEventHandler.cell_exploded()  
    $ExplosionAudio.play()

func init(coordinates: Vector2, Type: int):
    coord = coordinates
    if not CellEventHandler.level_editor:
        type = Type
        load_texture()
    else:
        $Button/Label.text = String(coordinates)


func _on_Tween_tween_all_completed():
    if animation == 'remove' or animation == 'explode':
         TweenAnimator.stop_all()
         CellEventHandler.cell_removed(coord)
         

func _on_Button_mouse_entered():
    if not CellEventHandler.level_editor:
        get_hover_pressed_texture()

func get_hover_pressed_texture():
    var file_name = formatFileStringPressed % util.Elements.keys()[type].to_lower()
    $Button.set_pressed_texture(load(file_name))
    $Button.set_hover_texture(load(file_name))
