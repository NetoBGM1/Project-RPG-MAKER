#==============================================================================
# Engine
#==============================================================================

class Engine

  def initialize

    @running = false

    @player = nil
    @player_sprite = nil

    @character_bitmap = nil

    @frame_width = 0
    @frame_height = 0

    @walk_frame = 0
    @walk_timer = 0
    @walk_speed = 6

    @map_renderer = nil
    @camera = nil

  end

  #--------------------------------------------------------------------------
  # Iniciar
  #--------------------------------------------------------------------------
  def start

    @running = true

    #---------------------------------------------------------------------------
    # MAPA REAL
    #---------------------------------------------------------------------------
    @map_renderer =
      XPMapRenderer.new(
        1
      )

    @map_renderer.start

    #---------------------------------------------------------------------------
    # CÂMERA
    #---------------------------------------------------------------------------
    @camera =
      Camera.new(
        @map_renderer.map
      )

    #---------------------------------------------------------------------------
    # PLAYER
    #---------------------------------------------------------------------------
    create_player

    #---------------------------------------------------------------------------
    # Posicionamento inicial
    #---------------------------------------------------------------------------
    @camera.snap(
      @player
    )

    update_camera

  end

  #--------------------------------------------------------------------------
  # Update
  #--------------------------------------------------------------------------
  def update

    return unless @running

    #---------------------------------------------------------------------------
    # 1. Jogador
    #---------------------------------------------------------------------------
    @player.update

    #---------------------------------------------------------------------------
    # 2. Câmera acompanha jogador
    #---------------------------------------------------------------------------
    @camera.update(
      @player
    )

    #---------------------------------------------------------------------------
    # 3. Mapa acompanha câmera
    #---------------------------------------------------------------------------
    @map_renderer.update_camera(
      @camera
    )

    #---------------------------------------------------------------------------
    # 4. Animação
    #---------------------------------------------------------------------------
    update_walk_animation

    #---------------------------------------------------------------------------
    # 5. Player acompanha câmera
    #---------------------------------------------------------------------------
    update_player_sprite

    @map_renderer.update

  end

  #--------------------------------------------------------------------------
  # Criar jogador
  #--------------------------------------------------------------------------
  def create_player

    @player =
      Game_Player.new

    @player_sprite =
      Sprite.new

    @character_bitmap =
      RPG::Cache.character(
        "trainer_POKEMONTRAINER_Neto",
        0
      )

    @frame_width =
      @character_bitmap.width / 4

    @frame_height =
      @character_bitmap.height / 4

    @player_sprite.bitmap =
      Bitmap.new(
        @frame_width,
        @frame_height
      )

    @player_sprite.z = 1000

  end

  #--------------------------------------------------------------------------
  # Atualizar câmera
  #--------------------------------------------------------------------------
  def update_camera

    @camera.update(
      @player
    )

    @map_renderer.update_camera(
      @camera
    )

  end

  #--------------------------------------------------------------------------
  # Animação
  #--------------------------------------------------------------------------
  def update_walk_animation

    if @player.moving?

      @walk_timer += 1

      if @walk_timer >= @walk_speed

        @walk_timer = 0

        @walk_frame += 1

        @walk_frame %= 4

      end

    else

      @walk_frame = 0
      @walk_timer = 0

    end

  end

  #--------------------------------------------------------------------------
  # Sprite do jogador
  #--------------------------------------------------------------------------
  def update_player_sprite

    update_player_frame
    update_player_position

  end

  #--------------------------------------------------------------------------
  # Frame
  #--------------------------------------------------------------------------
  def update_player_frame

    row =
      case @player.direction

      when Game_Player::DOWN
        0

      when Game_Player::LEFT
        1

      when Game_Player::RIGHT
        2

      when Game_Player::UP
        3

      else
        0

      end

    frame_x =
      @walk_frame *
      @frame_width

    frame_y =
      row *
      @frame_height

    @player_sprite.bitmap.clear

    @player_sprite.bitmap.blt(

      0,
      0,

      @character_bitmap,

      Rect.new(
        frame_x,
        frame_y,
        @frame_width,
        @frame_height
      )

    )

  end

  #--------------------------------------------------------------------------
  # Posição do jogador
  #--------------------------------------------------------------------------
  def update_player_position

    @player_sprite.x =
      @camera.screen_x(
        @player.x
      )

    @player_sprite.y =
      @camera.screen_y(
        @player.y
      )

  end

  #--------------------------------------------------------------------------
  # Encerrar
  #--------------------------------------------------------------------------
  def shutdown

    @running = false

    if @map_renderer

      @map_renderer.dispose

      @map_renderer = nil

    end

    if @player_sprite

      if @player_sprite.bitmap

        @player_sprite.bitmap.dispose

      end

      @player_sprite.dispose

      @player_sprite = nil

    end

    @player = nil
    @camera = nil
    @character_bitmap = nil

  end

  #--------------------------------------------------------------------------
  # Rodando?
  #--------------------------------------------------------------------------
  def running?

    return @running

  end

end