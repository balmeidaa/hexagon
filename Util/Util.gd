extends Node

enum Elements {FIRE, ICE, WATER, EARTH}
var rng = RandomNumberGenerator.new()

    

    
func random() -> int:
   return rng.randi_range(0, Elements.size())
    
