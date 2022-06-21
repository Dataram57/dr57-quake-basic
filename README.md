# dr57-quake-basic
Is a mod for Quake 1 which brings new objects that aim to help mappers make the map more interesting, optimized, and visually looking good.

## Installation
Assuming that you know how the simple process of making maps in quake goes, and you know how to use trenchbroom, download this repository (from the `main` branch), and unpack it into a `/YOUR-QUAKE-GAME-PATH/dr57-quake-basic/`.
## Mapping
In order to make a map with use of this mod, you have to:
 - include this mod in your level editor. Example from trenchbroom:
 - load the entity definition file from `/dr57-quake-basic/maps/def.fgd` in your level editor.
## Objects
| classname | short description |
|--|--|
| fx_dustbox | Creates an effect of particles surrounding the player in a specific box area, specified by the brush size. Objects are being grouped by their properties and each object from the same group is using the same pool of particles, in order to make the game work faster. |