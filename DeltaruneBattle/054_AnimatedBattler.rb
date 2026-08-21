#===============================================================================
# Deltarune Battle
# 054_AnimatedBattler.rb
#
# Pokémon Battle Character
#
# PLAYER:
#   Linha 3
#   Anima horizontalmente
#
# ENEMY:
#   Linha 2
#   Anima horizontalmente
#
# Nunca muda de linha.
# Nunca gira.
#===============================================================================

module DeltaruneBattle

  class AnimatedBattler

    FRAME_COLUMNS = 4
    FRAME_ROWS    = 4

    #---------------------------------------------------------------------------
    # PLAYER
    #---------------------------------------------------------------------------

    PLAYER_ROW = 2

    #---------------------------------------------------------------------------
    # ENEMY
    #---------------------------------------------------------------------------

    ENEMY_ROW = 1

    #---------------------------------------------------------------------------
    # Inicialização
    #---------------------------------------------------------------------------

    def initialize(viewport, filename)

      @viewport = viewport
      @filename = filename

      @column = 0
      @row = PLAYER_ROW

      @counter = 0

      # Velocidade da animação.
      #
      # Quanto maior:
      #   mais lento
      #
      # Quanto menor:
      #   mais rápido
      #
      @speed = 8

      @sprite =
        Sprite.new(@viewport)

      @sprite.visible = false

      @sprite.z = 30

      # Nunca usar rotação.
      @sprite.angle = 0

      load_bitmap

    end

    #---------------------------------------------------------------------------
    # Carregar
    #---------------------------------------------------------------------------

    def load_bitmap

      begin

        @sheet =
          Bitmap.new(@filename)

        @frame_width =
          @sheet.width / FRAME_COLUMNS

        @frame_height =
          @sheet.height / FRAME_ROWS

        @sprite.bitmap =
          Bitmap.new(
            @frame_width,
            @frame_height
          )

        refresh

      rescue Exception => e

        puts "[Deltarune Battle] Erro ao carregar sprite:"
        puts "  #{@filename}"
        puts "  #{e.class}: #{e.message}"

      end

    end

    #---------------------------------------------------------------------------
    # Update
    #---------------------------------------------------------------------------

    def update

      return if !@sheet
      return if !@sprite
      return if @sprite.disposed?

      @counter += 1

      return if @counter < @speed

      @counter = 0

      next_frame

    end

    #---------------------------------------------------------------------------
    # Próximo frame
    #
    # SOMENTE a coluna muda.
    # A linha permanece fixa.
    #---------------------------------------------------------------------------

    def next_frame

      @column += 1

      if @column >= FRAME_COLUMNS

        @column = 0

      end

      refresh

    end

    #---------------------------------------------------------------------------
    # Reset
    #---------------------------------------------------------------------------

    def reset_animation

      @column = 0
      @counter = 0

      refresh

    end

    #---------------------------------------------------------------------------
    # Atualizar imagem
    #---------------------------------------------------------------------------

    def refresh

      return if !@sheet
      return if !@sprite
      return if !@sprite.bitmap

      source =
        Rect.new(
          @column * @frame_width,
          @row * @frame_height,
          @frame_width,
          @frame_height
        )

      @sprite.bitmap.clear

      @sprite.bitmap.blt(
        0,
        0,
        @sheet,
        source
      )

      @sprite.ox =
        @frame_width / 2

      @sprite.oy =
        @frame_height

      # Garantia contra qualquer rotação.
      @sprite.angle = 0

    end

    #---------------------------------------------------------------------------
    # PLAYER
    #
    # Sempre linha 3.
    #---------------------------------------------------------------------------

    def face_right

      @row = PLAYER_ROW

      @sprite.mirror = false
      @sprite.angle = 0

      refresh

    end

    #---------------------------------------------------------------------------
    # ENEMY
    #
    # Sempre linha 2.
    #---------------------------------------------------------------------------

    def face_left

      @row = ENEMY_ROW

      @sprite.mirror = false
      @sprite.angle = 0

      refresh

    end

    #---------------------------------------------------------------------------
    # Velocidade
    #---------------------------------------------------------------------------

    def speed=(value)

      @speed =
        [value, 1].max

    end

    #---------------------------------------------------------------------------
    # Tone
    #---------------------------------------------------------------------------

    def tone=(tone)

      @sprite.tone = tone

    end

    #---------------------------------------------------------------------------
    # Limpar Tone
    #---------------------------------------------------------------------------

    def clear_tone

      @sprite.tone =
        Tone.new(
          0,
          0,
          0,
          0
        )

    end

    #---------------------------------------------------------------------------
    # Mostrar
    #---------------------------------------------------------------------------

    def show

      @sprite.visible = true

    end

    #---------------------------------------------------------------------------
    # Esconder
    #---------------------------------------------------------------------------

    def hide

      @sprite.visible = false

    end

    #---------------------------------------------------------------------------
    # Visibilidade
    #---------------------------------------------------------------------------

    def visible?

      return false if !@sprite
      return false if @sprite.disposed?

      @sprite.visible

    end

    #---------------------------------------------------------------------------
    # Posição
    #---------------------------------------------------------------------------

    def set_position(x, y)

      @sprite.x = x
      @sprite.y = y

    end

    #---------------------------------------------------------------------------
    # Dispose
    #---------------------------------------------------------------------------

    def dispose

      if @sprite

        if @sprite.bitmap
          @sprite.bitmap.dispose
        end

        @sprite.dispose

      end

      if @sheet
        @sheet.dispose
      end

      @sprite = nil
      @sheet = nil

    end

  end

end