extends Node2D
onready var TweenAnimator = get_node("Tween")
var type = 'default'
var coord = Vector2(0,0)
const animationStateEnum = ['idle','selected','move_to','circular_motion','remove','default']

var animationState = 'default'
var nextPosition = Vector2(0,0)

func _process(_delta):
    match animationState:
        "move_to":
            move_to()
            pass
        _:
            pass
    

#Debug function remove later
func set_text(text):
    $Label.text = text

func get_size():
    return $Button.get_size()

func set_coord(gridPosition: Vector2):    
    coord = gridPosition

func set_button_state(state:String, active: bool):
    $Button.set(state, active) 
    
func set_animation_state(newState:String, position: Vector2 = Vector2(0,0)):
    animationState = newState
    nextPosition = position

func _on_Cell_pressed():
    CellEventHandler.cell_pressed(coord)

func move_to():
    print('mov')
    TweenAnimator.interpolate_property(self, "position",
        self.position, nextPosition, 0.5,
        Tween.TRANS_QUART, Tween.EASE_IN_OUT)
    TweenAnimator.start()
    animationState = ''
    

func circular_motion():
    var radius = $Self.position.distance_to(nextPosition)/2
    pass

func remove():
    pass


