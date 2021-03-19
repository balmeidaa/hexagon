extends Node2D
onready var TweenAnimator = $Tween
var type = 0
var coord = Vector2(0,0)

var animationState = []
var nextPosition = []
var animation = ""
onready var util = preload("Util/Util.gd").new()
    
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
            _:
                pass

#Debug function remove later
func set_text(text):
    $Label.text = text

func set_type(newType : int):
    type = newType
    load_texture()

func load_texture():
    var formatFileString = "res://Assets/Img/%s.png"
#    print(util.Elements.keys())
    var file_name = formatFileString % String(type)
    if type == 0:
        $Button.disabled = true
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
    CellEventHandler.cell_pressed(coord)

func move_to():
    TweenAnimator.interpolate_property(self, "position",
        self.position, nextPosition.pop_front(), 0.5,
        Tween.TRANS_QUART, Tween.EASE_IN_OUT)
    TweenAnimator.start()


# rework this tween
func appear():    
    TweenAnimator.interpolate_property(self, "modulate", 
    Color(1, 1, 1, 0.3), Color(1, 1, 1, 1), 0.5, 
    Tween.TRANS_LINEAR)
    TweenAnimator.start() 

func remove():
    TweenAnimator.interpolate_property(self, "scale", 
    self.scale, (self.scale*1.2), 0.8, 
    Tween.TRANS_QUINT, Tween.EASE_IN)
    
    TweenAnimator.interpolate_property(self, "modulate", 
    Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.8, 
    Tween.TRANS_QUINT, Tween.EASE_IN)
    TweenAnimator.start()


func init(coordinates: Vector2, Type: int):
    coord = coordinates
    type = Type
    load_texture()
    

func _on_Tween_tween_all_completed():
    
    if animation == 'remove':
         TweenAnimator.stop_all()
         CellEventHandler.cell_removed(coord)
         

