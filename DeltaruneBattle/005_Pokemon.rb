#===============================================================================
# Deltarune Battle - Pokemon
#===============================================================================

module DeltaruneBattle

  class Pokemon

    attr_reader :source
    attr_reader :species
    attr_reader :name
    attr_reader :level

    attr_accessor :hp

    attr_reader :max_hp
    attr_reader :attack
    attr_reader :defense
    attr_reader :spatk
    attr_reader :spdef
    attr_reader :speed

    attr_reader :moves
    attr_reader :types
    attr_reader :status

    #=============================================================================
    # Initialize
    #=============================================================================

    def initialize(species_or_pokemon=nil, level=nil)

      @source = nil

      @species = nil
      @name = "Pokémon"
      @level = 1

      @hp = 1
      @max_hp = 1

      @attack = 1
      @defense = 1
      @spatk = 1
      @spdef = 1
      @speed = 1

      @moves = []
      @types = []
      @status = nil

      #---------------------------------------------------------------------------
      # DeltaruneBattle::Pokemon.new(:PIKACHU, 10)
      #---------------------------------------------------------------------------

      if species_or_pokemon.is_a?(Symbol) ||
         species_or_pokemon.is_a?(String)

        @species = species_or_pokemon

        if level
          @level = level.to_i
        end

        create_from_species

      #---------------------------------------------------------------------------
      # DeltaruneBattle::Pokemon.new(existing_pokemon)
      #---------------------------------------------------------------------------

      elsif species_or_pokemon

        @source = species_or_pokemon

        copy_from_source(
          species_or_pokemon
        )

      end

      normalize
    end

    #=============================================================================
    # Create From Species
    #=============================================================================

    def create_from_species

      begin

        pokemon =
          ::Pokemon.new(
            @species,
            @level
          )

        @source = pokemon

        copy_from_source(
          pokemon
        )

      rescue => e

        # The independent battle object remains valid even if
        # Essentials cannot create the source Pokémon.

        @name =
          @species.to_s

        @max_hp = 100
        @hp = 100

      end
    end

    #=============================================================================
    # Copy Data From Essentials
    #=============================================================================

    def copy_from_source(pokemon)

      return if !pokemon

      #---------------------------------------------------------------------------
      # Species
      #---------------------------------------------------------------------------

      if pokemon.respond_to?(:species)

        begin
          @species = pokemon.species
        rescue
        end

      end

      #---------------------------------------------------------------------------
      # Name
      #---------------------------------------------------------------------------

      if pokemon.respond_to?(:name)

        begin

          value =
            pokemon.name

          if value &&
             !value.to_s.empty?

            @name =
              value.to_s

          end

        rescue
        end

      end

      #---------------------------------------------------------------------------
      # Level
      #---------------------------------------------------------------------------

      if pokemon.respond_to?(:level)

        begin
          @level =
            pokemon.level.to_i
        rescue
        end

      end

      #---------------------------------------------------------------------------
      # HP
      #---------------------------------------------------------------------------

      if pokemon.respond_to?(:hp)

        begin
          @hp =
            pokemon.hp.to_i
        rescue
        end

      end

      #---------------------------------------------------------------------------
      # Maximum HP
      #---------------------------------------------------------------------------

      if pokemon.respond_to?(:totalhp)

        begin
          @max_hp =
            pokemon.totalhp.to_i
        rescue
        end

      elsif pokemon.respond_to?(:max_hp)

        begin
          @max_hp =
            pokemon.max_hp.to_i
        rescue
        end

      end

      #---------------------------------------------------------------------------
      # Stats
      #---------------------------------------------------------------------------

      copy_stat(pokemon, :attack)
      copy_stat(pokemon, :defense)
      copy_stat(pokemon, :spatk)
      copy_stat(pokemon, :spdef)
      copy_stat(pokemon, :speed)

      #---------------------------------------------------------------------------
      # Types
      #---------------------------------------------------------------------------

      if pokemon.respond_to?(:types)

        begin
          @types =
            pokemon.types.clone
        rescue
          @types = []
        end

      end

      #---------------------------------------------------------------------------
      # Status
      #---------------------------------------------------------------------------

      if pokemon.respond_to?(:status)

        begin
          @status =
            pokemon.status
        rescue
          @status = nil
        end

      end

      #---------------------------------------------------------------------------
      # Moves
      #---------------------------------------------------------------------------

      copy_moves(pokemon)
    end

    #=============================================================================
    # Copy Stat
    #=============================================================================

    def copy_stat(pokemon, stat)

      return if !pokemon.respond_to?(stat)

      begin

        value =
          pokemon.send(stat).to_i

        instance_variable_set(
          "@#{stat}",
          value
        )

      rescue
      end
    end

    #=============================================================================
    # Copy Moves
    #=============================================================================

    def copy_moves(pokemon)

      @moves = []

      return if !pokemon.respond_to?(:moves)

      begin

        pokemon.moves.each do |move|

          next if !move

          #-----------------------------------------------------------------------
          # Already our Move object
          #-----------------------------------------------------------------------

          if defined?(DeltaruneBattle::Move) &&
             move.is_a?(DeltaruneBattle::Move)

            @moves << move
            next
          end

          #-----------------------------------------------------------------------
          # Convert Essentials move
          #-----------------------------------------------------------------------

          if defined?(DeltaruneBattle::Move)

            begin

              @moves <<
                DeltaruneBattle::Move.new(
                  move
                )

            rescue
            end

          end
        end

      rescue
        @moves = []
      end
    end

    #=============================================================================
    # HP
    #=============================================================================

    def hp=(value)

      value =
        value.to_i

      value =
        0 if value < 0

      value =
        @max_hp if value > @max_hp

      @hp =
        value
    end

    def fainted?
      return @hp <= 0
    end

    def alive?
      return !fainted?
    end

    def full_hp?
      return @hp >= @max_hp
    end

    def max_hp
      return @max_hp
    end

    #=============================================================================
    # Moves
    #=============================================================================

    def move(index)

      return nil if index.nil?

      index =
        index.to_i

      return nil if index < 0
      return nil if index >= @moves.length

      return @moves[index]
    end

    def move_count
      return @moves.length
    end

    #=============================================================================
    # Normalize
    #=============================================================================

    def normalize

      @level =
        1 if @level <= 0

      @max_hp =
        1 if @max_hp <= 0

      @hp =
        @max_hp if @hp > @max_hp

      @hp =
        0 if @hp < 0

      @attack =
        1 if @attack <= 0

      @defense =
        1 if @defense <= 0

      @spatk =
        1 if @spatk <= 0

      @spdef =
        1 if @spdef <= 0

      @speed =
        1 if @speed <= 0

    end

    #=============================================================================
    # Synchronize Back To Essentials
    #
    # This is explicit. The Essentials Pokémon is NOT the battle object.
    #=============================================================================

    def sync_to_source

      return false if !@source

      if @source.respond_to?(:hp=)

        begin
          @source.hp =
            @hp
        rescue
        end

      end

      return true
    end

  end

  #=============================================================================
  # Pokemon Data Helpers
  #=============================================================================

  module PokemonData

    def self.from_essentials(pokemon)

      return nil if !pokemon

      if pokemon.is_a?(DeltaruneBattle::Pokemon)

        return pokemon

      end

      return DeltaruneBattle::Pokemon.new(
        pokemon
      )
    end

    def self.copy_party(party)

      result = []

      return result if !party

      party.each do |pokemon|

        next if !pokemon

        if pokemon.respond_to?(:egg?) &&
           pokemon.egg?

          next
        end

        result <<
          from_essentials(pokemon)
      end

      return result
    end

  end

end