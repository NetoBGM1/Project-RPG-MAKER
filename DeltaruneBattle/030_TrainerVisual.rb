#===============================================================================
# Deltarune Battle
# 030_TrainerVisual.rb
#===============================================================================

module DeltaruneBattle

  class TrainerVisual

    attr_reader :side
    attr_reader :outfit
    attr_reader :trainer_type
    attr_reader :state
    attr_reader :sprite

    #-------------------------------------------------------------------------
    # Inicialização
    #-------------------------------------------------------------------------

    def initialize(viewport, side, trainer_type = nil)

      @viewport = viewport
      @side = side
      @trainer_type = trainer_type
      @state = :hidden

      @sprite = Sprite.new(@viewport)

      determine_trainer
      determine_outfit
      load_graphic
      setup_position

      @sprite.visible = false

    end

    #-------------------------------------------------------------------------
    # Determinar treinador
    #-------------------------------------------------------------------------

    def determine_trainer

      return if @side == :player_1

      # Se o tipo já foi fornecido, usamos ele.
      return if @trainer_type

      battle = DeltaruneBattle::Integration.get_battle

      return if !battle

      #-----------------------------------------------------------------------
      # No Essentials, os treinadores inimigos ficam em trainer arrays.
      #-----------------------------------------------------------------------

      begin

        trainers = battle.opponent

        if trainers && trainers.length > 0

          trainer = trainers[0]

          if trainer
            @trainer_type = trainer.trainer_type
          end

        end

      rescue Exception => e

        puts "[Deltarune Battle] Não foi possível determinar TrainerType."
        puts "  #{e.class}: #{e.message}"

      end

      #-----------------------------------------------------------------------
      # Fallback
      #-----------------------------------------------------------------------

      @trainer_type = :RIVAL if !@trainer_type

    end

    #-------------------------------------------------------------------------
    # Outfit do jogador
    #-------------------------------------------------------------------------

    def determine_outfit

      if @side == :player_1

        @outfit = 0

        if defined?($player) && $player
          @outfit = $player.outfit
        end

      else

        @outfit = 0

      end

    end

    #-------------------------------------------------------------------------
    # Carregar gráfico
    #-------------------------------------------------------------------------

    def load_graphic

      begin

        #---------------------------------------------------------------------
        # PLAYER
        #---------------------------------------------------------------------

        if @side == :player_1

          if @outfit == 0

            path = "Graphics/DeltaruneBattle/Trainers/Player1/Normal"

          else

            path =
              "Graphics/DeltaruneBattle/Trainers/Player1/Outfit#{@outfit}"

          end

        #---------------------------------------------------------------------
        # INIMIGO
        #---------------------------------------------------------------------

        else

          type_name = @trainer_type.to_s.upcase

          path =
            "Graphics/DeltaruneBattle/Trainers/#{type_name}"

        end

        puts "[Deltarune Battle] Carregando treinador:"
        puts "  Side: #{@side}"
        puts "  Class: #{@trainer_type}"
        puts "  Path: #{path}"

        @sprite.bitmap = Bitmap.new(path)

        @sprite.ox = @sprite.bitmap.width / 2
        @sprite.oy = @sprite.bitmap.height

      rescue Exception => e

        puts "[Deltarune Battle] Não foi possível carregar TrainerVisual."
        puts "  Side: #{@side}"
        puts "  Class: #{@trainer_type}"
        puts "  #{e.class}: #{e.message}"

      end

    end

    #-------------------------------------------------------------------------
    # Posição
    #-------------------------------------------------------------------------

    def setup_position

      if @side == :player_1

        x =
          Graphics.width *
          DeltaruneBattle::Positions::PLAYER_TRAINER_X

        y =
          Graphics.height *
          DeltaruneBattle::Positions::PLAYER_TRAINER_Y

      else

        x =
          Graphics.width *
          DeltaruneBattle::Positions::ENEMY_TRAINER_X

        y =
          Graphics.height *
          DeltaruneBattle::Positions::ENEMY_TRAINER_Y

      end

      @sprite.x = x
      @sprite.y = y

    end

    #-------------------------------------------------------------------------
    # Play
    #-------------------------------------------------------------------------

    def play(state)

      @state = state

      case state

      when :hidden

        @sprite.visible = false

      when :neutral

        @sprite.visible = true

      when :send_out

        @sprite.visible = true

      when :idle

        @sprite.visible = true

      when :victory

        @sprite.visible = true

      when :defeat

        @sprite.visible = true

      when :escape

        @sprite.visible = true

      end

    end

    #-------------------------------------------------------------------------
    # Update
    #-------------------------------------------------------------------------

    def update

      return if !@sprite
      return if @sprite.disposed?

    end

    #-------------------------------------------------------------------------
    # Dispose
    #-------------------------------------------------------------------------

    def dispose

      return if !@sprite

      if @sprite.bitmap

        @sprite.bitmap.dispose
        @sprite.bitmap = nil

      end

      @sprite.dispose if !@sprite.disposed?

      @sprite = nil

    end

  end

end