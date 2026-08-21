Deltarune Battle - Pokémon Essentials v21.1

INSTALL
1. Put the DeltaruneBattle folder into Plugins.
2. Put UI graphics in:
   Graphics/DeltaruneBattle/UI/
3. Optional trainer graphics:
   Graphics/DeltaruneBattle/Trainers/player.png
   Graphics/DeltaruneBattle/Trainers/enemy.png

The engine is independent of Essentials' Battle::Battle and Battle::Scene.
It only uses Essentials Pokémon/GameData/Bag objects as data sources.

TEST EVENT SCRIPT:
  pbDeltaruneBattle(:PIKACHU, 10)

CONTROLS:
Left/Right = command
Enter/Z = confirm
Esc/X = back

IMPORTANT:
This is a first complete independent engine pass. It deliberately uses its
own battle state and turn loop. Damage is a simple Pokémon-like formula, not
Essentials' full battle mechanics yet. The UI assets can be replaced without
changing the battle controller.
