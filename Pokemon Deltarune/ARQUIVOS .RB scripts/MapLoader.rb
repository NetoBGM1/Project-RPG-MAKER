#==============================================================================
# MapLoader
#------------------------------------------------------------------------------
# Carrega mapas reais do RPG Maker XP.
#==============================================================================

class MapLoader

  def initialize
    @cache = {}
  end

  #--------------------------------------------------------------------------
  # Carrega um mapa pelo ID
  #--------------------------------------------------------------------------
  def load(map_id)

    #--------------------------------------------------------------
    # Usa o mapa já carregado se estiver no cache.
    #--------------------------------------------------------------
    if @cache[map_id]
      return @cache[map_id]
    end

    filename =
      sprintf(
        "Data/Map%03d.rxdata",
        map_id
      )

    unless FileTest.exist?(filename)

      raise(
        "MapLoader: mapa nao encontrado: #{filename}"
      )

    end

    file =
      File.open(
        filename,
        "rb"
      )

    map =
      Marshal.load(file)

    file.close

    @cache[map_id] = map

    return map

  end

end