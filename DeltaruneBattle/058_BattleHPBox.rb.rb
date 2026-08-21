#===============================================================================
# Deltarune Battle
# 058_BattleHPBox.rb
#===============================================================================

module DeltaruneBattle

  class BattleHPBox

    def initialize(viewport, battler, side)

      @viewport = viewport
      @battler = battler
      @side = side

      @sprite = Sprite.new(@viewport)
      @sprite.z = 10

      @width =
        player? ? 220 : 180

      @height = 55

      @sprite.bitmap =
        Bitmap.new(
          @width,
          @height
        )

      setup_position
      refresh

    end

    #===========================================================================
    # PLAYER?
    #===========================================================================

    def player?

      return true if @side == :player
      return true if @side == :player_1
      return true if @side == "player"
      return true if @side == "player_1"

      false

    end

    #===========================================================================
    # POSIÇÃO
    #===========================================================================

    def setup_position

      if player?

        @sprite.x = 20
        @sprite.y = 235

      else

        @sprite.x =
          Graphics.width - @width - 20

        @sprite.y = 20

      end

    end

    #===========================================================================
    # UPDATE
    #===========================================================================

    def update

      return if !@sprite
      return if @sprite.disposed?

      refresh

    end

    #===========================================================================
    # TROCAR POKÉMON
    #===========================================================================

    def set_battler(battler)

      @battler = battler

      refresh

    end

    #===========================================================================
    # REFRESH
    #===========================================================================

    def refresh

      return if !@sprite
      return if @sprite.disposed?
      return if !@sprite.bitmap

      bitmap = @sprite.bitmap

      bitmap.clear

      return if !@battler

      pokemon = nil

      begin

        if @battler.respond_to?(:pokemon)

          pokemon =
            @battler.pokemon

        end

      rescue

        pokemon = nil

      end

      return if !pokemon

      draw_name(
        bitmap,
        pokemon
      )

      draw_level(
        bitmap,
        pokemon
      )

      draw_hp(
        bitmap,
        pokemon
      )

    end

    #===========================================================================
    # NOME
    #===========================================================================

    def draw_name(bitmap, pokemon)

      bitmap.draw_text(
        8,
        3,
        @width - 70,
        20,
        pokemon.name.to_s
      )

    end

    #===========================================================================
    # LEVEL
    #===========================================================================

    def draw_level(bitmap, pokemon)

      bitmap.draw_text(
        @width - 62,
        3,
        55,
        20,
        "Lv.#{pokemon.level}",
        2
      )

    end

    #===========================================================================
    # HP
    #===========================================================================

    def draw_hp(bitmap, pokemon)

      hp =
        pokemon.hp.to_i

      total =
        pokemon.totalhp.to_i

      return if total <= 0

      ratio =
        hp.to_f / total.to_f

      if ratio < 0.0
        ratio = 0.0
      end

      if ratio > 1.0
        ratio = 1.0
      end

      bar_x = 8
      bar_y = 28
      bar_width = @width - 16
      bar_height = 10

      #-----------------------------------------------------------------------
      # Fundo
      #-----------------------------------------------------------------------

      bitmap.fill_rect(
        bar_x,
        bar_y,
        bar_width,
        bar_height,
        Color.new(
          45,
          45,
          45
        )
      )

      #-----------------------------------------------------------------------
      # HP atual
      #-----------------------------------------------------------------------

      current_width =
        (bar_width * ratio).to_i

      if current_width > 0

        bitmap.fill_rect(
          bar_x,
          bar_y,
          current_width,
          bar_height,
          hp_color(ratio)
        )

      end

      #-----------------------------------------------------------------------
      # Texto HP
      #-----------------------------------------------------------------------

      bitmap.draw_text(
        0,
        39,
        @width,
        16,
        "#{hp}/#{total}",
        1
      )

    end

    #===========================================================================
    # COR DA BARRA
    #===========================================================================

    def hp_color(ratio)

      if ratio <= 0.20

        return Color.new(
          220,
          60,
          60
        )

      end

      if ratio <= 0.50

        return Color.new(
          220,
          180,
          50
        )

      end

      Color.new(
        70,
        210,
        90
      )

    end

    #===========================================================================
    # VISIBILIDADE
    #===========================================================================

    def show

      return if !@sprite

      @sprite.visible = true

    end

    def hide

      return if !@sprite

      @sprite.visible = false

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

      @sprite = nil

    end

  end

end