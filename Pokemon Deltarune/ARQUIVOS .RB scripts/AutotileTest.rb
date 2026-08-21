#==============================================================================
# AutotileTest
#------------------------------------------------------------------------------
# Diagnóstico dos autotiles usados pelo Map001.
#==============================================================================

class AutotileTest

  def self.run

    loader = MapLoader.new
    map = loader.load(1)

    tilesets = load_tilesets

    tileset = tilesets[map.tileset_id]

    p "========================================"
    p "AUTOTILE TEST"
    p "========================================"

    p "Map ID: #{map.id}"
    p "Map Width: #{map.width}"
    p "Map Height: #{map.height}"
    p "Tileset ID: #{map.tileset_id}"

    p "----------------------------------------"
    p "Autotiles do Tileset:"
    p "----------------------------------------"

    for i in 0...7

      name = tileset.autotile_names[i]

      p "Autotile #{i}: #{name}"

    end

    p "----------------------------------------"
    p "Autotiles encontrados no mapa:"
    p "----------------------------------------"

    found = {}

    for y in 0...map.height

      for x in 0...map.width

        for z in 0...3

          tile_id = map.data[x, y, z]

          next if tile_id.nil?
          next if tile_id == 0

          # IDs abaixo de 384 são autotiles.
          if tile_id < 384

            found[tile_id] = true

          end

        end

      end

    end

    found.each_key do |tile_id|

      p "Autotile Tile ID: #{tile_id}"

    end

    p "========================================"

  end

  #--------------------------------------------------------------------------
  # Carrega Tilesets.rxdata
  #--------------------------------------------------------------------------
  def self.load_tilesets

    filename = "Data/Tilesets.rxdata"

    file = File.open(filename, "rb")

    tilesets = Marshal.load(file)

    file.close

    return tilesets

  end

end