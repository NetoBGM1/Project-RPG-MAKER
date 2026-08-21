#==============================================================================
# AutotileRenderer
#------------------------------------------------------------------------------
# Renderizador de Autotiles do RPG Maker XP.
#==============================================================================

class AutotileRenderer

  TILE_SIZE = 32

  def initialize
    @cache = {}
  end

  #--------------------------------------------------------------------------
  # Cria um bitmap de autotile
  #--------------------------------------------------------------------------
  def render(name, tile_id)

    return nil if name.nil?
    return nil if name == ""

    key = [name, tile_id]

    if @cache[key]
      return @cache[key]
    end

    source = RPG::Cache.autotile(name)

    bitmap =
      Bitmap.new(
        TILE_SIZE,
        TILE_SIZE
      )

    #--------------------------------------------------------------
    # O XP usa uma imagem de autotile de 128x96.
    #
    # Cada tile final de 32x32 é composto por 4 partes.
    #--------------------------------------------------------------

    pattern =
      tile_id % 48

    pattern_x =
      (pattern % 6) * 16

    pattern_y =
      (pattern / 6) * 16

    #--------------------------------------------------------------
    # Quadrante superior esquerdo
    #--------------------------------------------------------------
    bitmap.blt(
      0,
      0,
      source,
      Rect.new(
        pattern_x,
        pattern_y,
        16,
        16
      )
    )

    #--------------------------------------------------------------
    # Quadrante superior direito
    #--------------------------------------------------------------
    bitmap.blt(
      16,
      0,
      source,
      Rect.new(
        pattern_x + 16,
        pattern_y,
        16,
        16
      )
    )

    #--------------------------------------------------------------
    # Quadrante inferior esquerdo
    #--------------------------------------------------------------
    bitmap.blt(
      0,
      16,
      source,
      Rect.new(
        pattern_x,
        pattern_y + 16,
        16,
        16
      )
    )

    #--------------------------------------------------------------
    # Quadrante inferior direito
    #--------------------------------------------------------------
    bitmap.blt(
      16,
      16,
      source,
      Rect.new(
        pattern_x + 16,
        pattern_y + 16,
        16,
        16
      )
    )

    @cache[key] = bitmap

    return bitmap

  end

  #--------------------------------------------------------------------------
  # Libera cache
  #--------------------------------------------------------------------------
  def dispose

    @cache.each_value do |bitmap|

      bitmap.dispose if bitmap

    end

    @cache.clear

  end

end