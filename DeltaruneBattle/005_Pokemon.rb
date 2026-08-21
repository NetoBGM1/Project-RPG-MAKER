#===============================================================================
# Deltarune Battle - Pokemon
#
# Independent battle-side Pokémon representation.
#
# Pokémon Essentials is ONLY the source of data/resources.
# The battle system owns this object.
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

    #===========================================================================
    # Initialize
    #===========================================================================

    def initialize(source=nil, options={})

      @source = source

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

      copy_source(source)
      apply_options(options)

      normalize
    end

    #===========================================================================
    # Create From Essentials Pokémon
    #===========================================================================

    def self.from_essentials(pokemon)
      return Pokemon.new(pokemon)
    end

    #===========================================================================
    # Copy Source
    #
    # This reads the Essentials Pokémon once and copies the information needed
    # by the independent battle object.
    #===========================================================================

    def copy_source(pokemon)

      return if !pokemon

      #-----------------------------------------------------------------------
      # Species
      #-----------------------------------------------------------------------

      if pokemon.respond_to?(:species)
        @species = pokemon.species
      end

      #-----------------------------------------------------------------------
      # Name
      #-----------------------------------------------------------------------

      if pokemon.respond_to?(:name)

        begin
          value = pokemon.name

          if value &&
             !value.to_s.empty?

            @name = value.to_s

          end
        rescue
        end

      end

      #-----------------------------------------------------------------------
      # Level
      #-----------------------------------------------------------------------

      if pokemon.respond_to?(:level)

        begin
          @level = pokemon.level.to_i
        rescue
        end

      end

      #-----------------------------------------------------------------------
      # HP
      #-----------------------------------------------------------------------

      if pokemon.respond_to?(:hp)

        begin
          @hp = pokemon.hp.to_i
        rescue
        end

      end

      #-----------------------------------------------------------------------
      # Maximum HP
      #
      # Our battle object owns max_hp.
      #-----------------------------------------------------------------------

      if pokemon.respond_to?(:totalhp)

        begin
          @max_hp = pokemon.totalhp.to_i
        rescue
        end

      elsif pokemon.respond_to?(:max_hp)

        begin
          @max_hp = pokemon.max_hp.to_i
        rescue
        end

      end

      #-----------------------------------------------------------------------
      # Stats
      #-----------------------------------------------------------------------

      copy_stat(
        pokemon,
        :attack
      )

      copy_stat(
        pokemon,
        :defense
      )

      copy_stat(
        pokemon,
        :spatk
      )

      copy_stat(
        pokemon,
        :spdef
      )

      copy_stat(
        pokemon,
        :speed
      )

      #-----------------------------------------------------------------------
      # Types
      #-----------------------------------------------------------------------

      if pokemon.respond_to?(:types)

        begin
          @types =
            pokemon.types.clone
        rescue
          @types = []
        end

      end

      #-----------------------------------------------------------------------
      # Status
      #-----------------------------------------------------------------------

      if pokemon.respond_to?(:status)

        begin
          @status = pokemon.status
        rescue
          @status = nil
        end

      end

      #-----------------------------------------------------------------------
      # Moves
      #-----------------------------------------------------------------------

      copy_moves(pokemon)

    end

    #===========================================================================
    # Stat Copy
    #===========================================================================

    def copy_stat(pokemon, stat)

      return unless pokemon.respond_to?(stat)

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

    #===========================================================================
    # Moves
    #===========================================================================

    def copy_moves(pokemon)

      @moves = []

      return unless pokemon.respond_to?(:moves)

      begin

        source_moves =
          pokemon.moves

        return unless source_moves

        source_moves.each do |move|

          next if !move

          # Already our independent Move object.
          if move.is_a?(DeltaruneBattle::Move)

            @moves << move
            next

          end

          # Convert Essentials move into our Move object.
          begin

            @moves <<
              DeltaruneBattle::Move.new(move)

          rescue

            # If conversion isn't possible, don't allow the Essentials
            # move object to leak into the battle system.
          end

        end

      rescue

        @moves = []

      end

    end

    #===========================================================================
    # Options
    #===========================================================================

    def apply_options(options)

      return if !options
      return unless options.respond_to?(:[])

      if options[:name]
        @name =
          options[:name].to_s
      end

      if options[:level]
        @level =
          options[:level].to_i
      end

      if options[:hp]
        @hp =
          options[:hp].to_i
      end

      if options[:max_hp]
        @max_hp =
          options[:max_hp].to_i
      end

      if options[:attack]
        @attack =
          options[:attack].to_i
      end

      if options[:defense]
        @defense =
          options[:defense].to_i
      end

      if options[:spatk]
        @spatk =
          options[:spatk].to_i
      end

      if options[:spdef]
        @spdef =
          options[:spdef].to_i
      end

      if options[:speed]
        @speed =
          options[:speed].to_i
      end

      if options[:moves]
        @moves =
          options[:moves]
      end

      if options[:types]
        @types =
          options[:types]
      end

      if options[:status]
        @status =
          options[:status]
      end

    end

    #===========================================================================
    # Normalize
    #===========================================================================

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

      @moves =
        [] if !@moves

      @types =
        [] if !@types

    end

    #===========================================================================
    # HP
    #===========================================================================

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

    def full_hp?
      return @hp >= @max_hp
    end

    def fainted?
      return @hp <= 0
    end

    def alive?
      return !fainted?
    end

    def hp_ratio
      return 0.0 if @max_hp <= 0

      return @hp.to_f / @max_hp.to_f
    end

    #===========================================================================
    # Moves
    #===========================================================================

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

    def has_moves?
      return !@moves.empty?
    end

    #===========================================================================
    # Status
    #===========================================================================

    def status?
      return @status != nil
    end

    def clear_status
      @status = nil
    end

    #===========================================================================
    # Types
    #===========================================================================

    def type(index)
      return nil if index.nil?

      index =
        index.to_i

      return nil if index < 0
      return nil if index >= @types.length

      return @types[index]
    end

    def has_type?(type)
      return false if !type

      @types.each do |current|

        return true if current == type

      end

      return false
    end

    #===========================================================================
    # Source Synchronization
    #
    # This is deliberately explicit. The battle does NOT continuously modify
    # the Essentials Pokémon object.
    #===========================================================================

    def sync_to_source

      return false if !@source

      if @source.respond_to?(:hp=)

        begin
          @source.hp = @hp
        rescue
        end

      end

      if @source.respond_to?(:status=)

        begin
          @source.status = @status
        rescue
        end

      end

      return true
    end

    #===========================================================================
    # Debug
    #===========================================================================

    def inspect
      return(
        "#<DeltaruneBattle::Pokemon " \
        "#{@name} Lv.#{@level} " \
        "HP #{@hp}/#{@max_hp}>"
      )
    end

  end

  #=============================================================================
  # Party Conversion
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

        result <<
          from_essentials(pokemon)

      end

      return result
    end

  end

end