#===============================================================================
# Deltarune Battle - Moves
#
# Independent Move representation.
#
# Pokémon Essentials is used only as a source of move data.
# Damage, execution and battle behavior belong to DeltaruneBattle.
#===============================================================================

module DeltaruneBattle

  class Move

    attr_reader :source

    attr_reader :id
    attr_reader :name
    attr_reader :type
    attr_reader :category
    attr_reader :power
    attr_reader :accuracy
    attr_reader :pp
    attr_reader :max_pp
    attr_reader :priority

    def initialize(source=nil, options={})
      @source = source

      @id       = nil
      @name     = "Move"
      @type     = :NORMAL
      @category = 0
      @power    = 40
      @accuracy = 100
      @pp       = 1
      @max_pp   = 1
      @priority = 0

      copy_source(source)
      apply_options(options)
      normalize
    end

    #===========================================================================
    # Factory
    #===========================================================================

    def self.from_essentials(move)
      return nil if !move

      if move.is_a?(DeltaruneBattle::Move)
        return move
      end

      return DeltaruneBattle::Move.new(move)
    end

    #===========================================================================
    # Copy Essentials Move
    #===========================================================================

    def copy_source(move)
      return if !move

      #-----------------------------------------------------------------------
      # ID
      #-----------------------------------------------------------------------

      if move.respond_to?(:id)
        begin
          @id = move.id
        rescue
        end
      end

      #-----------------------------------------------------------------------
      # Name
      #-----------------------------------------------------------------------

      if move.respond_to?(:name)
        begin
          value = move.name

          if value &&
             !value.to_s.empty?

            @name = value.to_s
          end
        rescue
        end
      end

      #-----------------------------------------------------------------------
      # Type
      #-----------------------------------------------------------------------

      if move.respond_to?(:type)
        begin
          @type = move.type
        rescue
        end
      end

      #-----------------------------------------------------------------------
      # Category
      #
      # Essentials normally represents:
      #
      # 0 = Physical
      # 1 = Special
      # 2 = Status
      #-----------------------------------------------------------------------

      if move.respond_to?(:category)
        begin
          @category = move.category
        rescue
        end
      end

      #-----------------------------------------------------------------------
      # Power
      #-----------------------------------------------------------------------

      if move.respond_to?(:power)
        begin
          @power = move.power.to_i
        rescue
        end
      end

      #-----------------------------------------------------------------------
      # Accuracy
      #-----------------------------------------------------------------------

      if move.respond_to?(:accuracy)
        begin
          @accuracy = move.accuracy.to_i
        rescue
        end
      end

      #-----------------------------------------------------------------------
      # PP
      #-----------------------------------------------------------------------

      if move.respond_to?(:pp)
        begin
          @pp = move.pp.to_i
        rescue
        end
      end

      if move.respond_to?(:total_pp)
        begin
          @max_pp = move.total_pp.to_i
        rescue
        end
      elsif move.respond_to?(:max_pp)
        begin
          @max_pp = move.max_pp.to_i
        rescue
        end
      end

      #-----------------------------------------------------------------------
      # Priority
      #-----------------------------------------------------------------------

      if move.respond_to?(:priority)
        begin
          @priority = move.priority.to_i
        rescue
        end
      end
    end

    #===========================================================================
    # Options
    #===========================================================================

    def apply_options(options)
      return if !options
      return unless options.respond_to?(:[])

      @id =
        options[:id] if options[:id]

      @name =
        options[:name].to_s if options[:name]

      @type =
        options[:type] if options[:type]

      @category =
        options[:category].to_i if options[:category]

      @power =
        options[:power].to_i if options[:power]

      @accuracy =
        options[:accuracy].to_i if options[:accuracy]

      @pp =
        options[:pp].to_i if options[:pp]

      @max_pp =
        options[:max_pp].to_i if options[:max_pp]

      @priority =
        options[:priority].to_i if options[:priority]
    end

    #===========================================================================
    # Normalize
    #===========================================================================

    def normalize
      @power =
        0 if @power < 0

      @accuracy =
        100 if @accuracy <= 0

      @pp =
        0 if @pp < 0

      @max_pp =
        @pp if @max_pp <= 0

      @category =
        0 if @category < 0

      @priority =
        0 if !@priority
    end

    #===========================================================================
    # Categories
    #===========================================================================

    def physical?
      return @category == 0
    end

    def special?
      return @category == 1
    end

    def status?
      return @category == 2
    end

    #===========================================================================
    # Usability
    #===========================================================================

    def usable?
      return false if @pp <= 0
      return true
    end

    def damaging?
      return @power > 0
    end

    #===========================================================================
    # PP
    #===========================================================================

    def consume_pp
      return false if @pp <= 0

      @pp -= 1

      return true
    end

    def restore_pp(amount=nil)
      if amount.nil?
        @pp = @max_pp
      else
        @pp += amount.to_i

        if @pp > @max_pp
          @pp = @max_pp
        end
      end

      return @pp
    end

    #===========================================================================
    # Accuracy
    #===========================================================================

    def hits?
      return true if @accuracy >= 100

      return rand(100) < @accuracy
    end

    #===========================================================================
    # Execution
    #
    # The Move itself does not own the complete battle calculation.
    # Battle remains responsible for damage resolution.
    #===========================================================================

    def execute(user, target, battle)
      return false if !battle
      return false if !user
      return false if !target

      if !usable?
        if battle.respond_to?(:set_message)
          battle.set_message(
            "#{@name} has no PP left!"
          )
        end

        return false
      end

      consume_pp

      # Accuracy is handled here because it belongs to Move behavior.
      if !hits?

        if battle.respond_to?(:set_message)
          battle.set_message(
            "#{user.name}'s #{@name} missed!"
          )
        end

        return true
      end

      # The Battle owns damage calculation.
      if battle.respond_to?(:calculate_damage)

        damage =
          battle.calculate_damage(
            user,
            target,
            @power,
            self
          )

        old_hp =
          target.hp.to_i

        target.hp =
          [old_hp - damage, 0].max

        if battle.respond_to?(:set_message)
          battle.set_message(
            "#{user.name} used #{@name}! " \
            "#{damage} damage."
          )
        end

        if target.respond_to?(:fainted?) &&
           target.fainted?

          if battle.respond_to?(:handle_faint)
            battle.handle_faint(target)
          end
        end

        return true
      end

      return false
    end

    #===========================================================================
    # Debug
    #===========================================================================

    def inspect
      return(
        "#<DeltaruneBattle::Move " \
        "#{@name} #{@type} " \
        "Power=#{@power} PP=#{@pp}/#{@max_pp}>"
      )
    end

  end

  #=============================================================================
  # Move Data Helpers
  #=============================================================================

  module MoveData

    def self.from_essentials(move)
      return nil if !move

      return DeltaruneBattle::Move.from_essentials(
        move
      )
    end

    def self.from_id(id)
      return nil if !id

      begin

        move =
          GameData::Move.get(id)

        return from_essentials(move)

      rescue

        return nil

      end
    end

  end

end