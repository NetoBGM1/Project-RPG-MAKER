#==============================================================================
# Camera
#------------------------------------------------------------------------------
# Camera estilo Pokemon Essentials.
#
# O jogador se movimenta livremente pelo mapa.
# A camera acompanha o jogador enquanto houver mapa para mostrar.
# Nas bordas, a camera simplesmente para.
#==============================================================================

class Camera

  TILE_SIZE = 32

  SCREEN_WIDTH  = 640
  SCREEN_HEIGHT = 480

  def initialize(map)

    @map = map

    @x = 0
    @y = 0

  end

  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  def update(player)

    #---------------------------------------------------------------------------
    # Calcula a posição que colocaria o jogador no centro da tela.
    #---------------------------------------------------------------------------
    target_x =
      player.x -
      (SCREEN_WIDTH / 2) +
      (TILE_SIZE / 2)

    target_y =
      player.y -
      (SCREEN_HEIGHT / 2) +
      (TILE_SIZE / 2)

    #---------------------------------------------------------------------------
    # Tamanho real do mapa.
    #---------------------------------------------------------------------------
    map_width =
      @map.width *
      TILE_SIZE

    map_height =
      @map.height *
      TILE_SIZE

    #---------------------------------------------------------------------------
    # Quanto a camera pode andar.
    #---------------------------------------------------------------------------
    max_x =
      map_width -
      SCREEN_WIDTH

    max_y =
      map_height -
      SCREEN_HEIGHT

    #---------------------------------------------------------------------------
    # Mapas menores que a tela.
    #---------------------------------------------------------------------------
    if max_x < 0
      max_x = 0
    end

    if max_y < 0
      max_y = 0
    end

    #---------------------------------------------------------------------------
    # Limite esquerdo/superior.
    #---------------------------------------------------------------------------
    if target_x < 0
      target_x = 0
    end

    if target_y < 0
      target_y = 0
    end

    #---------------------------------------------------------------------------
    # Limite direito/inferior.
    #---------------------------------------------------------------------------
    if target_x > max_x
      target_x = max_x
    end

    if target_y > max_y
      target_y = max_y
    end

    #---------------------------------------------------------------------------
    # Camera instantânea.
    #
    # Isso deixa o comportamento previsível enquanto desenvolvemos.
    #---------------------------------------------------------------------------
    @x = target_x
    @y = target_y

  end

  #--------------------------------------------------------------------------
  # Posiciona imediatamente no jogador
  #--------------------------------------------------------------------------
  def snap(player)

    update(player)

  end

  #--------------------------------------------------------------------------
  # Converte mundo → tela
  #--------------------------------------------------------------------------
  def screen_x(world_x)

    return world_x - @x

  end

  #--------------------------------------------------------------------------
  # Converte mundo → tela
  #--------------------------------------------------------------------------
  def screen_y(world_y)

    return world_y - @y

  end

  #--------------------------------------------------------------------------
  # Posição da câmera
  #--------------------------------------------------------------------------
  def x

    return @x

  end

  def y

    return @y

  end

end