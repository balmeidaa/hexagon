extends Camera2D
class_name ShakeCamera2D

export var decay = 0.8  # How quickly the shaking stops [0, 1].
export var max_offset = Vector2(100, 50)  # Maximum hor/ver shake in pixels.
export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).
export (NodePath) var target  # Assign the node this camera will follow.

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].
onready var noise = OpenSimplexNoise.new()
var noise_y = 0
const origin = Vector2(500,400)
onready var TweenAnimator = $Tween

func _ready():
    randomize()
    noise.seed = randi()
    noise.period = 4
    noise.octaves = 2
    print(offset)

func _process(delta):
    if trauma:
        trauma = max(trauma - decay * delta, 0)
        shake()
    else:
        TweenAnimator.interpolate_property(self, "offset",
        offset, origin, 0.5,
        Tween.TRANS_QUART, Tween.EASE_IN_OUT)
        TweenAnimator.start()
      
    
func shake():
    var amount = pow(trauma, trauma_power)
    noise_y += 1
    rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
    offset.x =  offset.x + max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
    offset.y =  offset.y + max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)

    
func add_trauma(amount):
    trauma = min(trauma + amount, 1.0)
    
