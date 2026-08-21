#==============================================================================
# MapRenderer
#------------------------------------------------------------------------------
# Renderiza os tiles normais do mapa do RPG Maker XP.
#==============================================================================

class MapRenderer

  SCREEN_WIDTH  = 640
  SCREEN_HEIGHT = 480

  TILE_SIZE = 32
  TILESET_COLUMNS = 8
  FIRST_TILE_ID = 384

  def initialize(map_id)

    @map_id = map_id

    @map = nil
    @tileset = nil
    @tileset_bitmap = nil

    @viewport = nil
    @tile_sprites = []

    @width = 0
    @height = 0

  end

  #--------------------------------------------------------------------------
  # Inicia
  #--------------------------------------------------------------------------
  def start

    load_map
    load_tileset
    create_viewport
    render_map

  end

  #--------------------------------------------------------------------------
  # Carrega o mapa
  #--------------------------------------------------------------------------
  def load_map

    loader = MapLoader.new

    @map = loader.load(@map_id)

    @width = @map.width
    @height = @map.height

  end

  #--------------------------------------------------------------------------
  # Carrega o tileset
  #--------------------------------------------------------------------------
  def load_tileset

    tilesets = load_tilesets_database

    tileset_id = @map.tileset_id

    @tileset = tilesets[tileset_id]

    unless @tileset
      raise "MapRenderer: Tileset #{tileset_id} nao encontrado."
    end

    @tileset_bitmap = RPG::Cache.tileset(
      @tileset.tileset_name
    )

  end

  #--------------------------------------------------------------------------
  # Carrega Tilesets.rxdata
  #--------------------------------------------------------------------------
  def load_tilesets_database

    filename = "Data/Tilesets.rxdata"

    unless FileTest.exist?(filename)
      raise "MapRenderer: arquivo nao encontrado: #{filename}"
    end

    file = File.open(filename, "rb")

    tilesets = Marshal.load(file)

    file.close

    return tilesets

  end

  #--------------------------------------------------------------------------
  # Cria viewport
  #--------------------------------------------------------------------------
  def create_viewport

    @viewport = Viewport.new(
      0,
      0,
      SCREEN_WIDTH,
      SCREEN_HEIGHT
    )

    @viewport.z = 0

  end

  #--------------------------------------------------------------------------
  # Renderiza mapa
  #--------------------------------------------------------------------------
  def render_map

    render_layer(0)
    render_layer(1)
    render_layer(2)

  end

  #--------------------------------------------------------------------------
  # Renderiza camada
  #--------------------------------------------------------------------------
  def render_layer(layer)

    for y in 0...@height

      for x in 0...@width

        tile_id = @map.data[x, y, layer]

        next if tile_id.nil?
        next if tile_id == 0

        # Autotiles ainda não são renderizados.
        next if tile_id < FIRST_TILE_ID

        render_normal_tile(
          tile_id,
          x,
          y,
          layer
        )

      end

    end

  end

  #--------------------------------------------------------------------------
  # Renderiza tile normal
  #--------------------------------------------------------------------------
  def render_normal_tile(
    tile_id,
    x,
    y,
    layer
  )

    sprite = Sprite.new(@viewport)

    sprite.bitmap = Bitmap.new(
      TILE_SIZE,
      TILE_SIZE
    )

    sprite.bitmap.blt(
      0,
      0,
      @tileset_bitmap,
      tile_rect(tile_id)
    )

    sprite.x = x * TILE_SIZE
    sprite.y = y * TILE_SIZE

    sprite.z = layer * 10

    @tile_sprites << sprite

  end

  #--------------------------------------------------------------------------
  # Área do tile dentro do tileset
  #--------------------------------------------------------------------------
  def tile_rect(tile_id)

    index = tile_id - FIRST_TILE_ID

    tile_x = index % TILESET_COLUMNS
    tile_y = index / TILESET_COLUMNS

    Rect.new(
      tile_x * TILE_SIZE,
      tile_y * TILE_SIZE,
      TILE_SIZE,
      TILE_SIZE
    )

  end

  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  def update
  end

  #--------------------------------------------------------------------------
  # Libera recursos
  #--------------------------------------------------------------------------
  def dispose

    @tile_sprites.each do |sprite|

      if sprite.bitmap
        sprite.bitmap.dispose
      end

      sprite.dispose

    end

    @tile_sprites.clear

    if @viewport

      @viewport.dispose
      @viewport = nil

    end

    @tileset_bitmap = nil
    @tileset = nil
    @map = nil

  end

end