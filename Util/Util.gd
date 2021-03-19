extends Node

enum Elements {STATIC,FIRE, ICE, WATER, EARTH}#, WIND, METAL, ENERGY}
var rng = RandomNumberGenerator.new()

    
func random() -> int:
   return rng.randi_range(0, Elements.size())
    
func remove_dupes(array:Array) -> Array:
    var result = []

    for element in array:
       if not result.has(element):
        result.append(element)

    return result
        
