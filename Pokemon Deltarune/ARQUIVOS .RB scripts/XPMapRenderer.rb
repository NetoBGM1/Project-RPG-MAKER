#==============================================================================
# XPMapRenderer
#------------------------------------------------------------------------------
# Renderizador do mapa real do RPG Maker XP.
#==============================================================================

class XPMapRenderer

  TILE_SIZE = 32

  SCREEN_WIDTH  = 640
  SCREEN_HEIGHT = 480

  FIRST_NORMAL_TILE = 384

  def initialize(map_id)

    @map_id = map_id

    @map = nil
    @tileset = nil
    @tileset_bitmap = nil

    @viewport = nil

    @sprites = []
    @world_positions = []

    @camera = nil

  end

  #--------------------------------------------------------------------------
  # Iniciar
  #--------------------------------------------------------------------------
  def start

    load_map
    load_tileset

    create_viewport
    render_map

  end

  #--------------------------------------------------------------------------
  # Carregar mapa
  #--------------------------------------------------------------------------
  def load_map

    loader =
      MapLoader.new

    @map =
      loader.load(
        @map_id
      )

    unless @map

      raise(
        "XPMapRenderer: mapa nao carregado."
      )

    end

  end

  #--------------------------------------------------------------------------
  # Retornar mapa
  #--------------------------------------------------------------------------
  def map

    return @map

  end

  #--------------------------------------------------------------------------
  # Carregar tileset
  #--------------------------------------------------------------------------
  def load_tileset

    file =
      File.open(
        "Data/Tilesets.rxdata",
        "rb"
      )

    tilesets =
      Marshal.load(file)

    file.close

    @tileset =
      tilesets[
        @map.tileset_id
      ]

    unless @tileset

      raise(
        "XPMapRenderer: tileset nao encontrado."
      )

    end

    @tileset_bitmap =
      RPG::Cache.tileset(
        @tileset.tileset_name
      )

  end

  #--------------------------------------------------------------------------
  # Criar viewport
  #--------------------------------------------------------------------------
  def create_viewport

    @viewport =
      Viewport.new(
        0,
        0,
        SCREEN_WIDTH,
        SCREEN_HEIGHT
      )

    @viewport.z = 0

  end

  #--------------------------------------------------------------------------
  # Renderizar mapa
  #--------------------------------------------------------------------------
  def render_map

    for y in 0...@map.height

      for x in 0...@map.width

        for layer in 0...3

          tile_id =
            @map.data[
              x,
              y,
              layer
            ]

          next if tile_id.nil?
          next if tile_id == 0

          #--------------------------------------------------------
          # Autotiles continuam separados por enquanto.
          #--------------------------------------------------------
          next if tile_id < FIRST_NORMAL_TILE

          draw_tile(
            tile_id,
            x,
            y,
            layer
          )

        end

      end

    end

  end

  #--------------------------------------------------------------------------
  # Desenhar tile
  #--------------------------------------------------------------------------
  def draw_tile(
    tile_id,
    map_x,
    map_y,
    layer
  )

    index =
      tile_id -
      FIRST_NORMAL_TILE

    tileset_x =
      index % 8

    tileset_y =
      index / 8

    sprite =
      Sprite.new(
        @viewport
      )

    sprite.bitmap =
      Bitmap.new(
        TILE_SIZE,
        TILE_SIZE
      )

    source_rect =
      Rect.new(
        tileset_x * TILE_SIZE,
        tileset_y * TILE_SIZE,
        TILE_SIZE,
        TILE_SIZE
      )

    sprite.bitmap.blt(
      0,
      0,
      @tileset_bitmap,
      source_rect
    )

    world_x =
      map_x * TILE_SIZE

    world_y =
      map_y * TILE_SIZE

    @world_positions << [
      world_x,
      world_y
    ]

    sprite.x = world_x
    sprite.y = world_y

    #---------------------------------------------------------------------------
    # Layer
    #---------------------------------------------------------------------------
    sprite.z =
      layer * 100

    @sprites << sprite

  end

  #--------------------------------------------------------------------------
  # Atualizar câmera
  #--------------------------------------------------------------------------
  def update_camera(camera)

    @camera = camera

    i = 0

    while i < @sprites.length

      sprite =
        @sprites[i]

      position =
        @world_positions[i]

      world_x =
        position[0]

      world_y =
        position[1]

      sprite.x =
        camera.screen_x(
          world_x
        )

      sprite.y =
        camera.screen_y(
          world_y
        )

      i += 1

    end

  end

  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  def update

    # Atualização futura dos autotiles.

  end

  #--------------------------------------------------------------------------
  # Liberar
  #--------------------------------------------------------------------------
  def dispose

    i = 0

    while i < @sprites.length

      sprite =
        @sprites[i]

      if sprite.bitmap

        sprite.bitmap.dispose

      end

      sprite.dispose

      i += 1

    end

    @sprites.clear
    @world_positions.clear

    if @viewport

      @viewport.dispose
      @viewport = nil

    end

    @map = nil
    @tileset = nil
    @tileset_bitmap = nil
    @camera = nil

  end

end