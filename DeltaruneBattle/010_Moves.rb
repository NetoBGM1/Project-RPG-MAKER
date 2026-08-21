#===============================================================================
# Deltarune Battle - Moves
#
# This class is independent from the Pokémon Essentials battle system.
# GameData::Move is used only as a data source.
#===============================================================================

module DeltaruneBattle

  class Move

    attr_reader :id
    attr_reader :name
    attr_reader :type
    attr_reader :power
    attr_reader :accuracy
    attr_reader :category
    attr_reader :pp
    attr_reader :max_pp
    attr_reader :priority
    attr_reader :source

    def initialize(move_id, source=nil)
      @id       = move_id
      @source   = source

      @name     = nil
      @type     = nil
      @power    = 0
      @accuracy = 100
      @category = 0
      @pp       = 0
      @max_pp   = 0
      @priority = 0

      load_data
    end

    #---------------------------------------------------------------------------
    # Load data from Pokémon Essentials.
    #
    # This is the ONLY place where the battle system reads GameData::Move.
    #---------------------------------------------------------------------------

    def load_data
      move_data = @source

      if !move_data
        begin
          move_data = GameData::Move.get(@id)
        rescue
          move_data = nil
        end
      end

      if !move_data
        @name = @id.to_s
        return
      end

      @name = move_data.name if move_data.respond_to?(:name)

      if move_data.respond_to?(:type)
        @type = move_data.type
      end

      if move_data.respond_to?(:base_damage)
        @power = move_data.base_damage.to_i
      elsif move_data.respond_to?(:power)
        @power = move_data.power.to_i
      end

      if move_data.respond_to?(:accuracy)
        @accuracy = move_data.accuracy.to_i
      end

      if move_data.respond_to?(:category)
        @category = move_data.category
      end

      if move_data.respond_to?(:total_pp)
        @max_pp = move_data.total_pp.to_i
        @pp = @max_pp
      elsif move_data.respond_to?(:pp)
        @max_pp = move_data.pp.to_i
        @pp = @max_pp
      end

      if move_data.respond_to?(:priority)
        @priority = move_data.priority.to_i
      end
    end

    #---------------------------------------------------------------------------
    # Basic helpers
    #---------------------------------------------------------------------------

    def damaging?
      return @power > 0
    end

    def physical?
      return @category == 0
    end

    def special?
      return @category == 1
    end

    def status?
      return @category == 2
    end

    def usable?
      return @pp > 0
    end

    def consume_pp(amount=1)
      return false if @pp <= 0

      @pp -= amount.to_i
      @pp = 0 if @pp < 0

      return true
    end

    #---------------------------------------------------------------------------
    # Battle-specific behavior
    #
    # These methods intentionally do NOT call Pokémon Essentials' battle
    # mechanics. They are our own rules.
    #---------------------------------------------------------------------------

    def calculate_power(user, target)
      return @power
    end

    def calculate_accuracy(user, target)
      return @accuracy
    end

    def execute(user, target, battle)
      return false if !usable?

      consume_pp

      return battle.resolve_move(self, user, target)
    end

  end

  #=============================================================================
  # Move Factory
  #=============================================================================

  module MoveFactory

    def self.from_id(move_id)
      return DeltaruneBattle::Move.new(move_id)
    end

    def self.from_essentials(move_data)
      return nil if !move_data

      move_id = nil

      if move_data.respond_to?(:id)
        move_id = move_data.id
      end

      return nil if !move_id

      return DeltaruneBattle::Move.new(move_id, move_data)
    end

  end

end