extends Node

enum Elements {BOMB, LINE_REMOVER, HEXAGONAL_REMOVER, STATIC,STATIC_2,FIRE, ICE, WATER, EARTH, WIND, METAL, ENERGY, PLANT, LIFE}
const SpecialCells = [ Elements.BOMB, Elements.LINE_REMOVER, Elements.HEXAGONAL_REMOVER ]
const normalCells = [Elements.FIRE, Elements.ICE, Elements.WATER, Elements.EARTH, Elements.WIND, Elements.METAL, Elements.ENERGY]
const directionAxis = ["L-R", "UpL-LoR", "LoL-UpR"]
const nonClickable = [Elements.STATIC,Elements.STATIC_2]

var rng = RandomNumberGenerator.new()

    
func random_cell(difficultMode: bool) -> int:

    if difficultMode:
        return rng.randi_range(3, Elements.size()-1)
    return rng.randi_range(5, Elements.size()-1)

    
func remove_dupes(array:Array) -> Array:
    var result = []

    for element in array:
       if not result.has(element):
        result.append(element)

    return result
        
