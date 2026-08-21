#===============================================================================
# Deltarune Battle
# 001_Config.rb
#===============================================================================

module DeltaruneBattle
  #---------------------------------------------------------------------------
  # Configuração geral
  #---------------------------------------------------------------------------

  VERSION = "0.1.0"

  # Ativa/desativa o sistema.
  ENABLED = true

  #---------------------------------------------------------------------------
  # Battle Background
  #---------------------------------------------------------------------------

  BACKGROUND_PATH = "Graphics/DeltaruneBattle/Battle Background/"

  BACKGROUND_FRAME_PREFIX = "BBS_"

  BACKGROUND_FRAME_COUNT = 100

  # Quantidade de frames do jogo entre cada frame do background.
  #
  # 1 = mais rápido
  # 2 = mais lento
  # 3 = ainda mais lento
  #
  # Vamos ajustar isso depois de vermos a velocidade real do BBS.
  BACKGROUND_FRAME_DELAY = 2

  # O background volta para BBS_1 depois de BBS_100.
  BACKGROUND_LOOP = true

  #---------------------------------------------------------------------------
  # Battle
  #---------------------------------------------------------------------------

  # Primeira versão do plugin.
  # Por enquanto trabalharemos apenas com batalhas 1 contra 1.
  SINGLE_BATTLE_ONLY = true

  #---------------------------------------------------------------------------
  # Debug
  #---------------------------------------------------------------------------

  DEBUG = true
end