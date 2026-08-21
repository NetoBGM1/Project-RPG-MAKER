#==============================================================================
# Game_Player
#==============================================================================

class Game_Player

  attr_reader :x
  attr_reader :y
  attr_reader :direction

  DOWN  = 2
  LEFT  = 4
  RIGHT = 6
  UP    = 8

  TILE_SIZE = 32
  MOVE_DISTANCE = 32
  MOVE_SPEED = 3

  def initialize

    #---------------------------------------------------------------------------
    # Posição inicial
    #---------------------------------------------------------------------------
    @tile_x = 6
    @tile_y = 4

    @x = @tile_x * TILE_SIZE
    @y = @tile_y * TILE_SIZE

    @target_x = @x
    @target_y = @y

    @direction = DOWN

    @moving = false

    #---------------------------------------------------------------------------
    # Sistemas
    #---------------------------------------------------------------------------
    @collision = Collision.new(1)

    @movement = PlayerMovement.new(self)

  end

  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  def update

    update_movement

    @movement.update

  end

  #--------------------------------------------------------------------------
  # Movimento físico
  #--------------------------------------------------------------------------
  def update_movement

    return unless @moving

    #---------------------------------------------------------------------------
    # Movimento horizontal
    #---------------------------------------------------------------------------
    if @x != @target_x

      if @x < @target_x

        @x += MOVE_SPEED

        if @x > @target_x
          @x = @target_x
        end

      else

        @x -= MOVE_SPEED

        if @x < @target_x
          @x = @target_x
        end

      end

    end

    #---------------------------------------------------------------------------
    # Movimento vertical
    #---------------------------------------------------------------------------
    if @y != @target_y

      if @y < @target_y

        @y += MOVE_SPEED

        if @y > @target_y
          @y = @target_y
        end

      else

        @y -= MOVE_SPEED

        if @y < @target_y
          @y = @target_y
        end

      end

    end

    #---------------------------------------------------------------------------
    # Chegou ao destino
    #---------------------------------------------------------------------------
    if @x == @target_x &&
       @y == @target_y

      @moving = false

    end

  end

  #--------------------------------------------------------------------------
  # Solicita movimento
  #--------------------------------------------------------------------------
  def move(dx, dy)

    return if @moving

    direction =
      direction_from_movement(dx, dy)

    #---------------------------------------------------------------------------
    # Calcula o tile de destino
    #---------------------------------------------------------------------------
    new_tile_x = @tile_x
    new_tile_y = @tile_y

    if dx > 0

      new_tile_x += 1

    elsif dx < 0

      new_tile_x -= 1

    elsif dy > 0

      new_tile_y += 1

    elsif dy < 0

      new_tile_y -= 1

    end

    #---------------------------------------------------------------------------
    # Converte tile para posição em pixels
    #---------------------------------------------------------------------------
    new_x =
      new_tile_x * TILE_SIZE

    new_y =
      new_tile_y * TILE_SIZE

    #---------------------------------------------------------------------------
    # Verifica colisão ANTES de começar o movimento
    #---------------------------------------------------------------------------
    unless @collision.passable?(
      new_x,
      new_y,
      direction
    )

      @direction = direction

      return

    end

    #---------------------------------------------------------------------------
    # Atualiza posição lógica
    #---------------------------------------------------------------------------
    @tile_x = new_tile_x
    @tile_y = new_tile_y

    @target_x = new_x
    @target_y = new_y

    @direction = direction

    @moving = true

  end

  #--------------------------------------------------------------------------
  # Determina direção
  #--------------------------------------------------------------------------
  def direction_from_movement(dx, dy)

    if dx > 0

      return RIGHT

    elsif dx < 0

      return LEFT

    elsif dy > 0

      return DOWN

    elsif dy < 0

      return UP

    end

    return DOWN

  end

  #--------------------------------------------------------------------------
  # Define direção
  #--------------------------------------------------------------------------
  def set_direction(direction)

    @direction = direction

  end

  #--------------------------------------------------------------------------
  # Verifica se está andando
  #--------------------------------------------------------------------------
  def moving?

    return @moving

  end

end