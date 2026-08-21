#==============================================================================
# Game_Map
#------------------------------------------------------------------------------
# Controla os dados básicos do mapa da nossa engine.
#==============================================================================

class Game_Map

  attr_reader :map_id
  attr_reader :width
  attr_reader :height

  def initialize
    @map_id = 0
    @width = 0
    @height = 0
  end

  #--------------------------------------------------------------------------
  # Configura o mapa
  #--------------------------------------------------------------------------
  def setup(map_id)
    @map_id = map_id

    # Temporário.
    # Depois vamos ler os dados reais do RPG Maker XP.
    @width = 20
    @height = 15
  end

  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  def update
  end

end