#===============================================================================
# Deltarune Battle - Actions
#
# Independent action system.
#
# Actions are decisions made by battlers during a Deltarune Battle turn.
# This system does NOT use Pokémon Essentials' Battle::Action system.
#===============================================================================

module DeltaruneBattle

  module Actions

    #===========================================================================
    # Action Types
    #===========================================================================

    FIGHT   = :fight
    ACT     = :act
    ITEM    = :item
    BAG     = :bag
    DEFEND  = :defend
    SPARE   = :spare
    POKEMON = :pokemon
    RUN     = :run
    WAIT    = :wait

    #===========================================================================
    # Base Action
    #===========================================================================

    class Action

      attr_reader :type
      attr_reader :user
      attr_reader :target
      attr_reader :data

      attr_reader :priority
      attr_reader :speed

      def initialize(type, data=nil, user=nil, target=nil)
        @type = type
        @data = data

        @user = user
        @target = target

        @priority = 0
        @speed = 0

        load_priority
        load_speed
      end

      #-----------------------------------------------------------------------
      # Action State
      #-----------------------------------------------------------------------

      def valid?
        return true
      end

      def executable?
        return valid?
      end

      def execute(battle)
        return false
      end

      #-----------------------------------------------------------------------
      # Priority
      #-----------------------------------------------------------------------

      def load_priority
        if @data &&
           @data.respond_to?(:priority)

          begin
            @priority = @data.priority.to_i
            return
          rescue
          end
        end

        @priority = 0
      end

      #-----------------------------------------------------------------------
      # Speed
      #-----------------------------------------------------------------------

      def load_speed
        if @user &&
           @user.respond_to?(:speed)

          begin
            @speed = @user.speed.to_i
            return
          rescue
          end
        end

        @speed = 0
      end

      #-----------------------------------------------------------------------
      # Helpers
      #-----------------------------------------------------------------------

      def fight?
        return @type == FIGHT
      end

      def act?
        return @type == ACT
      end

      def item?
        return @type == ITEM || @type == BAG
      end

      def defend?
        return @type == DEFEND
      end

      def spare?
        return @type == SPARE
      end

      def pokemon?
        return @type == POKEMON
      end

      def run?
        return @type == RUN
      end

      def wait?
        return @type == WAIT
      end

    end

    #===========================================================================
    # Fight Action
    #===========================================================================

    class FightAction < Action

      attr_reader :move

      def initialize(user, target, move)
        @move = move

        super(
          FIGHT,
          move,
          user,
          target
        )
      end

      def valid?
        return false if !@user
        return false if !@target
        return false if !@move

        return false if @user.respond_to?(:fainted?) &&
                        @user.fainted?

        return false if @target.respond_to?(:fainted?) &&
                        @target.fainted?

        return false if @move.respond_to?(:usable?) &&
                        !@move.usable?

        return true
      end

      def execute(battle)
        return false if !battle
        return false if !valid?

        return @move.execute(
          @user,
          @target,
          battle
        )
      end

    end

    #===========================================================================
    # ACT Action
    #===========================================================================

    class ActAction < Action

      def initialize(user, target, act_id=nil)
        super(
          ACT,
          act_id,
          user,
          target
        )
      end

      def execute(battle)
        return false if !battle

        # ACT is intentionally handled by DeltaruneBattle.
        # No Essentials battle method is called here.

        if battle.respond_to?(:resolve_act)
          return battle.resolve_act(
            @data,
            @user,
            @target
          )
        end

        if battle.respond_to?(:set_message)
          battle.set_message(
            "#{@user.name} tried an ACT."
          )
        end

        return true
      end

    end

    #===========================================================================
    # Item Action
    #===========================================================================

    class ItemAction < Action

      def initialize(user, target, item_id)
        super(
          ITEM,
          item_id,
          user,
          target
        )
      end

      def execute(battle)
        return false if !battle

        if battle.respond_to?(:resolve_item)
          return battle.resolve_item(
            @data,
            @user,
            @target
          )
        end

        if battle.respond_to?(:execute_item)
          return battle.execute_item(
            @data
          )
        end

        return false
      end

    end

    #===========================================================================
    # Bag Action
    #===========================================================================

    class BagAction < ItemAction

      def initialize(user, target, item_id)
        super(
          user,
          target,
          item_id
        )

        @type = BAG
      end

    end

    #===========================================================================
    # Defend Action
    #===========================================================================

    class DefendAction < Action

      def initialize(user, target=nil)
        super(
          DEFEND,
          nil,
          user,
          target
        )
      end

      def execute(battle)
        return false if !battle

        if battle.respond_to?(:resolve_defend)
          return battle.resolve_defend(
            @user
          )
        end

        if battle.respond_to?(:set_message)
          battle.set_message(
            "#{@user.name} is defending."
          )
        end

        return true
      end

    end

    #===========================================================================
    # Spare Action
    #===========================================================================

    class SpareAction < Action

      def initialize(user, target)
        super(
          SPARE,
          nil,
          user,
          target
        )
      end

      def execute(battle)
        return false if !battle

        if battle.respond_to?(:resolve_spare)
          return battle.resolve_spare(
            @user,
            @target
          )
        end

        if battle.respond_to?(:set_message)
          battle.set_message(
            "#{@user.name} tried to spare #{ @target.name }."
          )
        end

        return true
      end

    end

    #===========================================================================
    # Pokémon Action
    #===========================================================================

    class PokemonAction < Action

      def initialize(user, party_index)
        super(
          POKEMON,
          party_index,
          user,
          nil
        )
      end

      def party_index
        return @data.to_i
      end

      def execute(battle)
        return false if !battle

        if battle.respond_to?(:resolve_pokemon)
          return battle.resolve_pokemon(
            @user,
            party_index
          )
        end

        if battle.respond_to?(:execute_switch)
          return battle.execute_switch(
            party_index
          )
        end

        return false
      end

    end

    #===========================================================================
    # Run Action
    #===========================================================================

    class RunAction < Action

      def initialize(user, target=nil)
        super(
          RUN,
          nil,
          user,
          target
        )
      end

      def execute(battle)
        return false if !battle

        if battle.respond_to?(:resolve_run)
          return battle.resolve_run(
            @user,
            @target
          )
        end

        if battle.respond_to?(:execute_run)
          return battle.execute_run
        end

        return false
      end

    end

    #===========================================================================
    # Wait Action
    #===========================================================================

    class WaitAction < Action

      def initialize(user=nil)
        super(
          WAIT,
          nil,
          user,
          nil
        )
      end

      def execute(battle)
        return true
      end

    end

    #===========================================================================
    # Factory
    #===========================================================================

    module Factory

      def self.create(
        type,
        user=nil,
        target=nil,
        data=nil
      )

        case type

        when FIGHT

          return FightAction.new(
            user,
            target,
            data
          )

        when ACT

          return ActAction.new(
            user,
            target,
            data
          )

        when ITEM

          return ItemAction.new(
            user,
            target,
            data
          )

        when BAG

          return BagAction.new(
            user,
            target,
            data
          )

        when DEFEND

          return DefendAction.new(
            user,
            target
          )

        when SPARE

          return SpareAction.new(
            user,
            target
          )

        when POKEMON

          return PokemonAction.new(
            user,
            data
          )

        when RUN

          return RunAction.new(
            user,
            target
          )

        when WAIT

          return WaitAction.new(
            user
          )

        end

        return Action.new(
          type,
          data,
          user,
          target
        )
      end

    end

    #===========================================================================
    # Helper Methods
    #===========================================================================

    def self.fight(user, target, move)
      return FightAction.new(
        user,
        target,
        move
      )
    end

    def self.act(user, target, act_id=nil)
      return ActAction.new(
        user,
        target,
        act_id
      )
    end

    def self.item(user, target, item_id)
      return ItemAction.new(
        user,
        target,
        item_id
      )
    end

    def self.defend(user, target=nil)
      return DefendAction.new(
        user,
        target
      )
    end

    def self.spare(user, target)
      return SpareAction.new(
        user,
        target
      )
    end

    def self.pokemon(user, party_index)
      return PokemonAction.new(
        user,
        party_index
      )
    end

    def self.run(user, target=nil)
      return RunAction.new(
        user,
        target
      )
    end

    def self.wait(user=nil)
      return WaitAction.new(
        user
      )
    end

  end

end