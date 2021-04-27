# Hex Runes
## _Additional docs_

Made with Godot 3.2

Credits:

- Programing: BJAA
- Art/Design: Game_emaG
- Audio/SFX: Tim Carroll

### Adding levels

- Hex runes has a levels.json file in which has the level for each level in json format, each json object is a level, this is the basic structure:
```json
  {
    "probBomb": 10,
    "probLineRemover": 5,
    "probHexRemover": 0.5,
    "main_goal": {
      "main_goal": true,
      "goal": 0,
      "objective": 4,
      "cell_type": 0
    },
    "bonus_goal": {
      "main_goal": false,
      "goal": 0,
      "objective": 4,
      "cell_type": 0
    },
    "level_obstacles": [
      {
        "type": 0,
        "position": [
          {
            "x": 0,
            "y": 0
          }
        ]
      },
      {
        "type": 1,
        "position": [
          {
            "x": 0,
            "y": 0
          }
        ]
      }
    ]
  }
```

| Property | What they do |
| ------ | ------ |
| probBomb | probability of spawning a bomb cell |
| probLineRemover | probability of spawning a line remover cell |
| probHexRemover | probability of spawning a hexagonal remover cell |
| turns | total turns for this level |
| main_goal | if it's the main goal for this level |
| goal | type of goal, 0 is for combo, 1 for points, 2 is for X removal of certain type of cells| 
| objective | the amount of combo, points or cells to remove |
| level_obstacles | the obstacles for the level |
| type | is the type of cell, 0 is for cells that can't be moved or removed, 1 is for cells that can be removed but not be moved by the player, you can place special cells too, bomb is the 2, line remover 3, nad hexagonal removel 4  |
| position | array of objects  in which has the position for the type of cells|

Here is an image of the positions of the cells:
![image info](https://raw.githubusercontent.com/balmeidaa/hexagon/main/board.png)

