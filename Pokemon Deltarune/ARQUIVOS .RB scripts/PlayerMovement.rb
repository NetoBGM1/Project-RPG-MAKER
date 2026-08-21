#==============================================================================
# PlayerMovement
#------------------------------------------------------------------------------
# Controle de movimento do jogador.
#==============================================================================

class PlayerMovement

  def initialize(player)
    @player = player
  end

  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  def update
    return if @player.moving?

    if Input.press?(Input::DOWN)
      move_down
    elsif Input.press?(Input::LEFT)
      move_left
    elsif Input.press?(Input::RIGHT)
      move_right
    elsif Input.press?(Input::UP)
      move_up
    end
  end

  #--------------------------------------------------------------------------
  # Baixo
  #--------------------------------------------------------------------------
  def move_down
    @player.set_direction(Game_Player::DOWN)
    @player.move(0, Game_Player::MOVE_DISTANCE)
  end

  #--------------------------------------------------------------------------
  # Esquerda
  #--------------------------------------------------------------------------
  def move_left
    @player.set_direction(Game_Player::LEFT)
    @player.move(-Game_Player::MOVE_DISTANCE, 0)
  end

  #--------------------------------------------------------------------------
  # Direita
  #--------------------------------------------------------------------------
  def move_right
    @player.set_direction(Game_Player::RIGHT)
    @player.move(Game_Player::MOVE_DISTANCE, 0)
  end

  #--------------------------------------------------------------------------
  # Cima
  #--------------------------------------------------------------------------
  def move_up
    @player.set_direction(Game_Player::UP)
    @player.move(0, -Game_Player::MOVE_DISTANCE)
  end

end