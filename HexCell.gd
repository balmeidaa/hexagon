extends Node2D
onready var TweenAnimator = $Tween
var type = 0
var coord = Vector2(0,0)
const animationStateEnum = ['idle','selected','move_to','circular_motion','remove','default']

var animationState = []
var nextPosition = []
var playNextAnimation = true
var animation = ""

func _ready():
    TweenAnimator.connect("tween_completed", self, "continue_animation")
    
func _process(_delta):
    if animationState.size() > 0 and playNextAnimation:
        playNextAnimation = false
        animation = animationState.pop_front()
        match animation:
            "move_to":
                move_to()
            "remove":
                remove()
            _:
                pass

#Debug function remove later
func set_text(text):
    $Label.text = text

func set_type(newType : int):
    type = newType

func get_size():
    return $Button.get_size()

func set_coord(gridPosition: Vector2):    
    coord = gridPosition

func set_button_state(state:String, active: bool):
    $Button.set(state, active) 
    
func set_animation_state(newState:String, position: Vector2 = Vector2(0,0)):
    animationState.append(newState)
    nextPosition.append(position)

func _on_Cell_pressed():
    CellEventHandler.cell_pressed(coord)

func move_to():
    TweenAnimator.interpolate_property(self, "position",
        self.position, nextPosition.pop_front(), 0.5,
        Tween.TRANS_QUART, Tween.EASE_IN_OUT)
    TweenAnimator.start()
    
    

func circular_motion():
    var radius = $Self.position.distance_to(nextPosition)/2
    pass

func remove():
    TweenAnimator.interpolate_property(self, "scale", 
    self.scale, (self.scale*1.2), 0.4, 
    Tween.TRANS_QUINT, Tween.EASE_IN)
    
    TweenAnimator.interpolate_property(self, "modulate", 
    Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.4, 
    Tween.TRANS_QUINT, Tween.EASE_IN)
    TweenAnimator.start()
    
func init(coordinates: Vector2, Type: int):
    coord = coordinates
    type = Type


func _on_Tween_tween_completed(object, key):
    playNextAnimation = true
    

func _on_Tween_tween_all_completed():
    if animation == 'remove':
         CellEventHandler.cell_removed(coord)
