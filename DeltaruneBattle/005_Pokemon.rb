#===============================================================================
# Deltarune Battle - Pokemon
#
# Independent battle representation of a Pokémon.
# The Essentials Pokémon object is used only as a data source.
#===============================================================================

module DeltaruneBattle

  class Pokemon

    attr_reader :source
    attr_reader :species
    attr_reader :name
    attr_reader :level
    attr_reader :max_hp
    attr_reader :attack
    attr_reader :defense
    attr_reader :spatk
    attr_reader :spdef
    attr_reader :speed
    attr_reader :moves

    attr_accessor :hp

    def initialize(source)
      @source = source

      @species = nil
      @name = nil
      @level = 1

      @max_hp = 1
      @hp = 1

      @attack = 1
      @defense = 1
      @spatk = 1
      @spdef = 1
      @speed = 1

      @moves = []

      load_data
    end

    #---------------------------------------------------------------------------
    # Read Pokémon Essentials data.
    #---------------------------------------------------------------------------

    def load_data
      return if !@source

      @species = @source.species if @source.respond_to?(:species)

      if @source.respond_to?(:name)
        @name = @source.name
      end

      if !@name || @name == ""
        @name = @species.to_s
      end

      if @source.respond_to?(:level)
        @level = @source.level.to_i
      end

      if @source.respond_to?(:totalhp)
        @max_hp = @source.totalhp.to_i
      end

      if @source.respond_to?(:hp)
        @hp = @source.hp.to_i
      end

      if @max_hp <= 0
        @max_hp = 1
      end

      @hp = @max_hp if @hp <= 0

      load_stats
      load_moves
    end

    #---------------------------------------------------------------------------
    # Stats
    #---------------------------------------------------------------------------

    def load_stats
      if @source.respond_to?(:attack)
        @attack = @source.attack.to_i
      end

      if @source.respond_to?(:defense)
        @defense = @source.defense.to_i
      end

      if @source.respond_to?(:spatk)
        @spatk = @source.spatk.to_i
      end

      if @source.respond_to?(:spdef)
        @spdef = @source.spdef.to_i
      end

      if @source.respond_to?(:speed)
        @speed = @source.speed.to_i
      end

      @attack = 1 if @attack <= 0
      @defense = 1 if @defense <= 0
      @spatk = 1 if @spatk <= 0
      @spdef = 1 if @spdef <= 0
      @speed = 1 if @speed <= 0
    end

    #---------------------------------------------------------------------------
    # Moves
    #
    # Essentials provides the initial move data.
    # The battle uses DeltaruneBattle::Move afterwards.
    #---------------------------------------------------------------------------

    def load_moves
      @moves = []

      return if !@source.respond_to?(:moves)

      @source.moves.each do |source_move|
        next if !source_move

        move = DeltaruneBattle::MoveFactory.from_essentials(source_move)

        @moves << move if move
      end
    end

    #---------------------------------------------------------------------------
    # Battle state
    #---------------------------------------------------------------------------

    def fainted?
      return @hp <= 0
    end

    def alive?
      return !fainted?
    end

    def full_hp?
      return @hp >= @max_hp
    end

    def damage(amount)
      amount = amount.to_i
      amount = 0 if amount < 0

      @hp -= amount
      @hp = 0 if @hp < 0

      return amount
    end

    def heal(amount)
      amount = amount.to_i
      amount = 0 if amount < 0

      old_hp = @hp

      @hp += amount
      @hp = @max_hp if @hp > @max_hp

      return @hp - old_hp
    end

    #---------------------------------------------------------------------------
    # Move access
    #---------------------------------------------------------------------------

    def move(index)
      return nil if index.nil?
      return nil if index < 0
      return nil if index >= @moves.length

      return @moves[index]
    end

  end

end