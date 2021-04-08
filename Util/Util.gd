extends Node

enum Elements {STATIC,STATIC_2, BOMB, LINE_REMOVER, FIRE, ICE, WATER, EARTH, WIND, METAL, ENERGY}
const SpecialCells = [ Elements.BOMB, Elements.LINE_REMOVER ]

var rng = RandomNumberGenerator.new()

    
func random() -> int:
   return rng.randi_range(0, Elements.size())
    
func remove_dupes(array:Array) -> Array:
    var result = []

    for element in array:
       if not result.has(element):
        result.append(element)

    return result
        
