#===============================================================================
# Deltarune Battle - Trainer
#
# Independent trainer representation.
#===============================================================================

module DeltaruneBattle

  class Trainer

    attr_reader :party
    attr_reader :name
    attr_reader :graphic

    attr_accessor :active_index

    #===========================================================================
    # Initialize
    #===========================================================================

    def initialize(
      party=[],
      name="Trainer",
      graphic=nil
    )

      @party =
        DeltaruneBattle::PokemonData.copy_party(
          party
        )

      @name =
        name.to_s

      @graphic =
        graphic

      @active_index =
        first_usable_index
    end

    #===========================================================================
    # Player
    #===========================================================================

    def self.player(party)

      return Trainer.new(
        party,
        "Player",
        DeltaruneBattle::PLAYER_TRAINER_GRAPHIC
      )

    end

    #===========================================================================
    # Enemy
    #===========================================================================

    def self.enemy(
      party,
      name="Trainer"
    )

      return Trainer.new(
        party,
        name,
        DeltaruneBattle::ENEMY_TRAINER_GRAPHIC
      )

    end

    #===========================================================================
    # Active Pokémon
    #===========================================================================

    def active_pokemon

      return nil if @active_index.nil?
      return nil if @active_index < 0
      return nil if @active_index >= @party.length

      return @party[@active_index]
    end

    #===========================================================================
    # Party
    #===========================================================================

    def first_usable_index

      i = 0

      while i < @party.length

        pokemon =
          @party[i]

        if pokemon &&
           pokemon.alive?

          return i
        end

        i += 1
      end

      return -1
    end

    def has_usable_pokemon?

      return first_usable_index >= 0
    end

    def defeated?

      return !has_usable_pokemon?
    end

    #===========================================================================
    # Graphic
    #===========================================================================

    def graphic
      return @graphic
    end

  end

end