#==============================================================================
# Collision
#------------------------------------------------------------------------------
# Sistema de colisão baseado nos dados de passagem do RPG Maker XP.
#==============================================================================

class Collision

  TILE_SIZE = 32

  DOWN  = 2
  LEFT  = 4
  RIGHT = 6
  UP    = 8

  def initialize(map_id)

    @map = nil
    @tileset = nil
    @passages = nil

    load_map(map_id)
    load_tileset

  end

  #--------------------------------------------------------------------------
  # Carrega mapa
  #--------------------------------------------------------------------------
  def load_map(map_id)

    loader = MapLoader.new

    @map = loader.load(map_id)

  end

  #--------------------------------------------------------------------------
  # Carrega tileset
  #--------------------------------------------------------------------------
  def load_tileset

    file = File.open(
      "Data/Tilesets.rxdata",
      "rb"
    )

    tilesets = Marshal.load(file)

    file.close

    @tileset = tilesets[@map.tileset_id]

    unless @tileset
      raise "Collision: Tileset nao encontrado."
    end

    @passages = @tileset.passages

  end

  #--------------------------------------------------------------------------
  # Verifica se uma posição pode ser atravessada
  #--------------------------------------------------------------------------
  def passable?(x, y, direction)

    tile_x = x / TILE_SIZE
    tile_y = y / TILE_SIZE

    #--------------------------------------------------------------
    # Fora do mapa = bloqueado
    #--------------------------------------------------------------
    return false if tile_x < 0
    return false if tile_y < 0
    return false if tile_x >= @map.width
    return false if tile_y >= @map.height

    bit = direction_bit(direction)

    return false if bit == 0

    #--------------------------------------------------------------
    # Verifica se existe algum tile nessa posição.
    #
    # Se todas as camadas estiverem vazias, consideramos
    # essa posição como espaço inexistente do mapa.
    #--------------------------------------------------------------
    has_tile = false

    layer = 0

    while layer < 3

      tile_id = @map.data[
        tile_x,
        tile_y,
        layer
      ]

      if tile_id && tile_id != 0
        has_tile = true
        break
      end

      layer += 1

    end

    #--------------------------------------------------------------
    # Nenhum tile = bloqueado
    #--------------------------------------------------------------
    return false unless has_tile

    #--------------------------------------------------------------
    # Verifica as camadas de cima para baixo.
    #--------------------------------------------------------------
    layer = 2

    while layer >= 0

      tile_id = @map.data[
        tile_x,
        tile_y,
        layer
      ]

      if tile_id && tile_id != 0

        passage = @passages[tile_id]

        if passage

          #--------------------------------------------------------
          # Bit 0x10 = prioridade "estrela".
          #
          # Esse tile é usado como elemento superior e não deve
          # decidir sozinho a passagem.
          #--------------------------------------------------------
          if (passage & 0x10) != 0

            layer -= 1
            next

          end

          #--------------------------------------------------------
          # Direção bloqueada.
          #--------------------------------------------------------
          if (passage & bit) != 0

            return false

          else

            return true

          end

        end

      end

      layer -= 1

    end

    #--------------------------------------------------------------
    # Existe tile, mas nenhum tile forneceu uma regra explícita.
    # Neste caso permitimos a passagem.
    #--------------------------------------------------------------
    return true

  end

  #--------------------------------------------------------------------------
  # Converte direção para bit de passagem
  #--------------------------------------------------------------------------
  def direction_bit(direction)

    case direction

    when DOWN
      return 0x01

    when LEFT
      return 0x02

    when RIGHT
      return 0x04

    when UP
      return 0x08

    end

    return 0

  end

end