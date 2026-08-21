#===============================================================================
# Deltarune Battle
# 055_TrainerAnimation.rb
#
# Controlador de animações dos treinadores.
#
# Sheet 4x4:
#
# Linha 1 = Idle
# Linha 2 = Send Out
# Linha 3 = Troca de Pokémon
# Linha 4 = Run / Bag / Item / End
#===============================================================================

module DeltaruneBattle

  class TrainerAnimation

    FRAME_COLUMNS = 4
    FRAME_ROWS    = 4

    #---------------------------------------------------------------------------
    # Linhas
    #---------------------------------------------------------------------------

    IDLE_ROW     = 0
    SEND_OUT_ROW = 1
    SWITCH_ROW   = 2
    ACTION_ROW   = 3

    #---------------------------------------------------------------------------
    # Velocidade
    #
    # Treinador propositalmente mais lento que o Pokémon.
    #---------------------------------------------------------------------------

    IDLE_SPEED     = 12
    SEND_OUT_SPEED = 10
    SWITCH_SPEED   = 10
    ACTION_SPEED   = 10

    #---------------------------------------------------------------------------
    # Pausa especial da troca.
    #---------------------------------------------------------------------------

    SWITCH_PAUSE = 7

    #===========================================================================

    def initialize(viewport, filename)

      @viewport = viewport
      @filename = filename

      @column = 0
      @row = IDLE_ROW

      @counter = 0

      @speed = IDLE_SPEED

      @state = :idle

      @visible = false

      @switch_sequence = []
      @switch_index = 0
      @switch_pause = 0

      @sprite =
        Sprite.new(@viewport)

      @sprite.visible = false

      @sprite.z = 30

      @sprite.angle = 0

      load_bitmap

    end

    #===========================================================================

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

        puts "[Deltarune Battle] Erro no TrainerAnimation."
        puts "  #{@filename}"
        puts "  #{e.class}: #{e.message}"

      end

    end

    #===========================================================================

    # UPDATE
    #===========================================================================

    def update

      return if !@sheet
      return if !@sprite
      return if @sprite.disposed?

      case @state

      when :idle
        update_idle

      when :send_out
        update_send_out

      when :switch
        update_switch

      when :bag
        update_bag

      when :item
        update_item

      when :run
        update_run

      when :end
        update_end

      end

    end

    #===========================================================================

    # IDLE
    #
    # 1 → 2 → 3 → 4
    #===========================================================================

    def update_idle

      @counter += 1

      return if @counter < IDLE_SPEED

      @counter = 0

      @column += 1

      if @column >= FRAME_COLUMNS
        @column = 0
      end

      refresh

    end

    #===========================================================================

    # SEND OUT
    #
    # 1 → 2 → 3 → 4
    #===========================================================================

    def update_send_out

      @counter += 1

      return if @counter < SEND_OUT_SPEED

      @counter = 0

      @column += 1

      if @column >= FRAME_COLUMNS

        @column = 0

        @row = IDLE_ROW
        @state = :idle

      end

      refresh

    end

    #===========================================================================

    # SWITCH
    #
    # Sequência:
    #
    # 1 2 3 4
    # 4 3 2 1
    # 1 2 3 4
    # 4 3 2 1
    #
    # Depois:
    #
    # IDLE
    #===========================================================================

    def start_switch

      @state = :switch

      @row = SWITCH_ROW

      @counter = 0

      @switch_pause = 0

      @switch_sequence = [

        0, 1, 2, 3,

        3, 2, 1, 0,

        0, 1, 2, 3,

        3, 2, 1, 0

      ]

      @switch_index = 0

      @column =
        @switch_sequence[@switch_index]

      refresh

    end

    #===========================================================================

    def update_switch

      #-----------------------------------------------------------------------
      # Pausa
      #-----------------------------------------------------------------------

      if @switch_pause > 0

        @switch_pause -= 1

        return

      end

      #-----------------------------------------------------------------------
      # Avançar frame
      #-----------------------------------------------------------------------

      @counter += 1

      return if @counter < SWITCH_SPEED

      @counter = 0

      @switch_index += 1

      #-----------------------------------------------------------------------
      # Terminou
      #-----------------------------------------------------------------------

      if @switch_index >= @switch_sequence.length

        @column = 0

        @row = IDLE_ROW

        @state = :idle

        refresh

        return

      end

      @column =
        @switch_sequence[@switch_index]

      #-----------------------------------------------------------------------
      # Pausa de 7 frames ao trocar de direção/fase.
      #-----------------------------------------------------------------------

      if @column == 0 || @column == 3

        @switch_pause = SWITCH_PAUSE

      end

      refresh

    end

    #===========================================================================

    # BAG
    #
    # Frame 2 da linha 4.
    #
    # Fica repetindo enquanto estiver nesse estado.
    #===========================================================================

    def start_bag

      @state = :bag

      @row = ACTION_ROW

      @column = 1

      @counter = 0

      refresh

    end

    #===========================================================================

    def update_bag

      # Por enquanto o frame 2 permanece parado.
      #
      # Isso permite que a Bag fique aberta sem consumir
      # a animação do treinador.

      return

    end

    #===========================================================================

    # ITEM
    #
    # Frame 3.
    #===========================================================================

    def start_item

      @state = :item

      @row = ACTION_ROW

      @column = 2

      @counter = 0

      refresh

    end

    #===========================================================================

    def update_item

      @counter += 1

      return if @counter < ACTION_SPEED

      @counter = 0

      @column = 3

      @state = :end

      refresh

    end

    #===========================================================================

    # RUN
    #
    # Frame 1.
    #===========================================================================

    def start_run

      @state = :run

      @row = ACTION_ROW

      @column = 0

      @counter = 0

      refresh

    end

    #===========================================================================

    def update_run

      # A animação de fuga será controlada pelo BattleController.
      return

    end

    #===========================================================================

    # END
    #
    # Frame 4.
    #===========================================================================

    def update_end

      # Mantém o último frame.
      return

    end

    #===========================================================================

    # Voltar para Idle
    #===========================================================================

    def idle

      @state = :idle

      @row = IDLE_ROW

      @column = 0

      @counter = 0

      refresh

    end

    #===========================================================================

    # SEND OUT
    #===========================================================================

    def send_out

      @state = :send_out

      @row = SEND_OUT_ROW

      @column = 0

      @counter = 0

      refresh

    end

    #===========================================================================

    # REFRESH
    #===========================================================================

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

      @sprite.angle = 0

    end

    #===========================================================================

    # VISIBILIDADE
    #===========================================================================

    def show

      @sprite.visible = true

      @visible = true

    end

    def hide

      @sprite.visible = false

      @visible = false

    end

    #===========================================================================

    # POSIÇÃO
    #===========================================================================

    def set_position(x, y)

      @sprite.x = x
      @sprite.y = y

    end

    #===========================================================================

    # ESPELHAMENTO
    #===========================================================================

    def face_right

      @sprite.mirror = false
      @sprite.angle = 0

    end

    def face_left

      @sprite.mirror = true
      @sprite.angle = 0

    end

    #===========================================================================

    # TONE
    #===========================================================================

    def tone=(tone)

      @sprite.tone = tone

    end

    def clear_tone

      @sprite.tone =
        Tone.new(0, 0, 0, 0)

    end

    #===========================================================================

    # DISPOSE
    #===========================================================================

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