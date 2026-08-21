#===============================================================================
# Deltarune Battle - Trainer
#
# Independent trainer representation.
#
# Pokémon Essentials is used only as a source of trainer/party data.
# The Deltarune Battle system owns the battle-side Trainer object.
#===============================================================================

module DeltaruneBattle

  class Trainer

    attr_reader :source
    attr_reader :name
    attr_reader :party
    attr_reader :active_index
    attr_reader :side

    def initialize(source=nil, party=nil, name=nil, side=:player)
      @source = source
      @side = side

      @active_index = 0

      #---------------------------------------------------------------------------
      # Determine trainer name.
      #---------------------------------------------------------------------------

      if name
        @name = name.to_s
      elsif source && source.respond_to?(:name)
        @name = source.name.to_s
      elsif side == :player
        @name = "Player"
      else
        @name = "Trainer"
      end

      #---------------------------------------------------------------------------
      # Build our own battle party.
      #---------------------------------------------------------------------------

      if party
        @party = convert_party(party)
      elsif source && source.respond_to?(:party)
        @party = convert_party(source.party)
      elsif source.is_a?(Array)
        @party = convert_party(source)
      else
        @party = []
      end

      @active_index = first_usable_index
    end

    #===========================================================================
    # Factory
    #===========================================================================

    def self.from_party(party, name="Trainer", side=:enemy)
      return Trainer.new(
        nil,
        party,
        name,
        side
      )
    end

    def self.player(party)
      return Trainer.new(
        nil,
        party,
        "Player",
        :player
      )
    end

    def self.enemy(party, name="Trainer")
      return Trainer.new(
        nil,
        party,
        name,
        :enemy
      )
    end

    #===========================================================================
    # Party Conversion
    #===========================================================================

    def convert_party(party)
      result = []

      return result if !party

      party.each do |pokemon|
        next if !pokemon

        # If it is already our battle Pokémon, keep it.
        if pokemon.is_a?(DeltaruneBattle::Pokemon)
          result << pokemon
          next
        end

        # Otherwise convert the Essentials Pokémon into our battle object.
        begin
          result << DeltaruneBattle::Pokemon.new(pokemon)
        rescue
          # Invalid party entry.
        end
      end

      return result
    end

    #===========================================================================
    # Active Pokémon
    #===========================================================================

    def active_pokemon
      return nil if @active_index < 0
      return nil if @active_index >= @party.length

      return @party[@active_index]
    end

    def active_index=(index)
      index = index.to_i

      return if index < 0
      return if index >= @party.length

      @active_index = index
    end

    #===========================================================================
    # Party State
    #===========================================================================

    def has_usable_pokemon?
      return first_usable_index >= 0
    end

    def all_fainted?
      return !has_usable_pokemon?
    end

    def remaining_pokemon
      count = 0

      @party.each do |pokemon|
        next if !pokemon
        count += 1 if !pokemon.fainted?
      end

      return count
    end

    #===========================================================================
    # Find Next Pokémon
    #===========================================================================

    def first_usable_index
      i = 0

      while i < @party.length
        pokemon = @party[i]

        if pokemon && !pokemon.fainted?
          return i
        end

        i += 1
      end

      return -1
    end

    def switch_to(index)
      index = index.to_i

      return false if index < 0
      return false if index >= @party.length
      return false if index == @active_index

      pokemon = @party[index]

      return false if !pokemon
      return false if pokemon.fainted?

      @active_index = index

      return true
    end

    def switch_to_next
      index = first_usable_index

      return false if index < 0

      return switch_to(index)
    end

    #===========================================================================
    # Graphics
    #
    # These are presentation resources, not battle logic.
    #===========================================================================

    def graphic
      if @side == :player
        return DeltaruneBattle::PLAYER_TRAINER_GRAPHIC
      end

      return DeltaruneBattle::ENEMY_TRAINER_GRAPHIC
    end

    def player?
      return @side == :player
    end

    def enemy?
      return @side == :enemy
    end

  end

end