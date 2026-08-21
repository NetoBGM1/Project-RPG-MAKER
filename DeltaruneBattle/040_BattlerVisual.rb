#===============================================================================
# Deltarune Battle
# 040_BattlerVisual.rb
#===============================================================================

module DeltaruneBattle

  class BattlerVisual

    attr_reader :battler
    attr_reader :side
    attr_reader :animated
    attr_reader :state

    def initialize(viewport, battler, side)

      @viewport = viewport
      @battler = battler
      @side = side

      @animated = nil
      @state = :hidden

      setup

    end

    def setup

      create_animation
      setup_position
      setup_direction
      update_status_tone

      @animated.hide if @animated

    end

    def create_animation

      return if !@battler
      return if !@battler.pokemon

      pokemon = @battler.pokemon

      filename =
        pokemon_character_filename(pokemon)

      puts "[Deltarune Battle] Carregando Character:"
      puts "  Pokémon: #{pokemon.name}"
      puts "  File: #{filename}"

      @animated =
        DeltaruneBattle::AnimatedBattler.new(
          @viewport,
          filename
        )

      @animated.speed = 6

    rescue Exception => e

      puts "[Deltarune Battle] Falha no BattlerVisual."
      puts "  #{e.class}: #{e.message}"

    end

    def pokemon_character_filename(pokemon)

      species_name =
        pokemon.species.to_s

      return "Graphics/Characters/#{species_name}"

    end

    def setup_position

      return if !@animated

      if player_side?

        x =
          Graphics.width *
          DeltaruneBattle::Positions::PLAYER_POKEMON_X

        y =
          Graphics.height *
          DeltaruneBattle::Positions::PLAYER_POKEMON_Y

      else

        x =
          Graphics.width *
          DeltaruneBattle::Positions::ENEMY_POKEMON_X

        y =
          Graphics.height *
          DeltaruneBattle::Positions::ENEMY_POKEMON_Y

      end

      @animated.set_position(x, y)

    end

    def setup_direction

      return if !@animated

      if player_side?
        @animated.face_right
      else
        @animated.face_left
      end

    end

    def player_side?

      return true if @side == :player
      return true if @side == :player_1

      false

    end

    def update_status_tone

      return if !@animated
      return if !@battler
      return if !@battler.pokemon

      pokemon = @battler.pokemon

      @animated.tone =
        status_tone(pokemon)

    end

    def status_tone(pokemon)

      status = pokemon.status

      case status

      when :PARALYSIS
        return Tone.new(50, 50, -20, 0)

      when :BURN
        return Tone.new(60, -20, -20, 0)

      when :POISON
        return Tone.new(40, -40, 40, 0)

      when :TOXIC
        return Tone.new(60, -50, 60, 0)

      when :FROZEN
        return Tone.new(-20, 30, 70, 0)

      when :SLEEP
        return Tone.new(-30, -30, -30, 0)

      else
        return Tone.new(0, 0, 0, 0)

      end

    end

    def play(state)

      return if !@animated

      @state = state

      case state

      when :hidden
        @animated.hide

      when :neutral
        @animated.show

      when :send_out
        @animated.reset_animation
        @animated.show

      when :idle
        @animated.show

      when :attack
        @animated.show

      when :hit
        @animated.show

      when :faint
        @animated.show

      when :recall
        @animated.hide

      end

    end

    def update

      return if !@animated

      @animated.update
      update_status_tone

    end

    def set_battler(battler)

      dispose

      @battler = battler
      @state = :hidden

      setup

    end

    def show
      play(:neutral)
    end

    def hide
      play(:hidden)
    end

    def dispose

      return if !@animated

      @animated.dispose
      @animated = nil

    end

  end

end