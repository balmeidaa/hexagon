extends Node

const hexCell = preload("res://HexCell.gd")
var queue = []

# Q elements {
#    node:
#    animationType:
#    nextPosition:
#}

# TODO function to process Q for Swap an elimination
    
func _process(delta):
    print('f')
    for obj in queue:
       
        match obj.animationType:
            "move_to":
                print(queue)
                swapAll()

func swapAll():
    for obj in queue:
        obj.node.set_animation_state(obj.animationType, obj.nextPosition)
        queue.pop_front()
        if queue.size() == 1:
            break

func setQueueAnimation(newQ:Array):
    queue += newQ
    
