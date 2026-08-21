#===============================================================================
# Deltarune Battle - Settings
# Pokémon Essentials v21.1 / RGSS
#===============================================================================
module DeltaruneBattle
  SCREEN_WIDTH  = 640
  SCREEN_HEIGHT = 480

  UI_PATH = "Graphics/DeltaruneBattle/UI/"
  TRAINER_PATH = "Graphics/DeltaruneBattle/Trainers/"
  POKEMON_PATH = "Graphics/DeltaruneBattle/Pokemon/"

  HUD_GRAPHIC         = UI_PATH + "HUD"
  BATTLE_MENU_GRAPHIC = UI_PATH + "BattleMenu"
  TEXTBOX_GRAPHIC     = UI_PATH + "textbox"
  COMMAND_BOX_GRAPHIC = UI_PATH + "command_box"

  PLAYER_TRAINER_GRAPHIC = TRAINER_PATH + "player"
  ENEMY_TRAINER_GRAPHIC  = TRAINER_PATH + "enemy"

  # Optional: set to a Following Partner graphic if you have one.
  PLAYER_PARTNER_GRAPHIC = POKEMON_PATH + "player_partner"
  ENEMY_PARTNER_GRAPHIC  = POKEMON_PATH + "enemy_partner"

  TURN_X = 280
  TURN_Y = 12

  PLAYER_HUD_X = 16
  PLAYER_HUD_Y = 300
  ENEMY_HUD_X  = 384
  ENEMY_HUD_Y  = 32

  MENU_X = 16
  MENU_Y = 394
  TEXTBOX_X = 16
  TEXTBOX_Y = 324

  PLAYER_TRAINER_X = 120
  PLAYER_TRAINER_Y = 205
  ENEMY_TRAINER_X  = 520
  ENEMY_TRAINER_Y  = 85

  PLAYER_POKEMON_X = 190
  PLAYER_POKEMON_Y = 225
  ENEMY_POKEMON_X  = 440
  ENEMY_POKEMON_Y  = 105

  COMMANDS = [:fight, :bag, :pokemon, :run]
  COMMAND_NAMES = {
    :fight   => "FIGHT",
    :bag     => "BAG",
    :pokemon => "POKEMON",
    :run     => "RUN"
  }

  # Demo enemy AI
  ENEMY_AI = :RANDOM

  # Escape: base chance. The engine also considers level difference.
  RUN_BASE_CHANCE = 0.75

  # Simple battle damage settings.
  DAMAGE_MINIMUM = 1
  DAMAGE_VARIANCE = 0.15

  # Animation timing.
  SEND_OUT_FRAMES = 24
  RECALL_FRAMES   = 20
  THROW_FRAMES    = 22
  RUN_FRAMES      = 30
  DEFEAT_FRAMES   = 36
end
