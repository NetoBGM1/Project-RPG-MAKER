#==============================================================================
# RenderSystem
#------------------------------------------------------------------------------
# Sistema responsável pela renderização da nossa engine.
#==============================================================================

class RenderSystem

  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @sprites = []
  end

  #--------------------------------------------------------------------------
  # Inicia a renderização
  #--------------------------------------------------------------------------
  def start
    create_background
    create_player
  end

  #--------------------------------------------------------------------------
  # Cria o fundo temporário
  #--------------------------------------------------------------------------
  def create_background
    @background = Sprite.new(@viewport)
    @background.bitmap = Bitmap.new(Graphics.width, Graphics.height)

    # Fundo temporário
    @background.bitmap.fill_rect(
      0,
      0,
      Graphics.width,
      Graphics.height,
      Color.new(40, 40, 40)
    )

    @sprites << @background
  end

  #--------------------------------------------------------------------------
  # Cria o jogador temporário
  #--------------------------------------------------------------------------
  def create_player
    @player_sprite = Sprite.new(@viewport)

    bitmap = Bitmap.new(32, 32)

    bitmap.fill_rect(
      0,
      0,
      32,
      32,
      Color.new(255, 255, 255)
    )

    @player_sprite.bitmap = bitmap

    @sprites << @player_sprite
  end

  #--------------------------------------------------------------------------
  # Atualização
  #--------------------------------------------------------------------------
  def update
    return unless $game_player

    update_player
  end

  #--------------------------------------------------------------------------
  # Atualiza posição do jogador
  #--------------------------------------------------------------------------
  def update_player
    @player_sprite.x = ($game_player.x * 32)
    @player_sprite.y = ($game_player.y * 32)
  end

  #--------------------------------------------------------------------------
  # Libera recursos
  #--------------------------------------------------------------------------
  def dispose
    @sprites.each do |sprite|
      sprite.bitmap.dispose if sprite.bitmap
      sprite.dispose
    end

    @sprites.clear

    @viewport.dispose
  end

end