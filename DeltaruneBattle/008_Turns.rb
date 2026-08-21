#===============================================================================
# Deltarune Battle - Turns
#
# Independent turn controller.
#
# A Turn stores player/enemy decisions and determines their execution order.
# It does not use Pokémon Essentials' battle turn system.
#===============================================================================

module DeltaruneBattle

  class Turn

    attr_reader :number
    attr_reader :player_action
    attr_reader :enemy_action
    attr_reader :actions
    attr_reader :state

    def initialize(number=1)
      @number = number.to_i

      @player_action = nil
      @enemy_action = nil

      @actions = []

      @state = :input
    end

    #===========================================================================
    # Actions
    #===========================================================================

    def set_player_action(action)
      @player_action = action

      rebuild_actions

      return action
    end

    def set_enemy_action(action)
      @enemy_action = action

      rebuild_actions

      return action
    end

    #===========================================================================
    # Action List
    #===========================================================================

    def rebuild_actions
      @actions = []

      if @player_action
        @actions << @player_action
      end

      if @enemy_action
        @actions << @enemy_action
      end

      return @actions
    end

    #===========================================================================
    # Action Order
    #
    # Higher priority acts first.
    # If priority is equal, higher Speed acts first.
    # If Speed is equal, order is randomized.
    #===========================================================================

    def ordered_actions
      list = @actions.clone

      list.sort! do |a, b|

        priority_a = action_priority(a)
        priority_b = action_priority(b)

        if priority_a != priority_b

          priority_b <=> priority_a

        else

          speed_a = action_speed(a)
          speed_b = action_speed(b)

          if speed_a != speed_b

            speed_b <=> speed_a

          else

            if rand(2) == 0
              -1
            else
              1
            end

          end

        end
      end

      return list
    end

    #===========================================================================
    # Priority
    #===========================================================================

    def action_priority(action)
      return 0 if !action

      if action.respond_to?(:priority)
        begin
          return action.priority.to_i
        rescue
        end
      end

      if action.respond_to?(:move)
        move = action.move

        if move && move.respond_to?(:priority)
          return move.priority.to_i
        end
      end

      if action.respond_to?(:data)

        data = action.data

        if data && data.respond_to?(:priority)
          return data.priority.to_i
        end

      end

      return 0
    end

    #===========================================================================
    # Speed
    #===========================================================================

    def action_speed(action)
      return 0 if !action

      pokemon = action_user(action)

      if pokemon && pokemon.respond_to?(:speed)
        return pokemon.speed.to_i
      end

      return 0
    end

    def action_user(action)
      return nil if !action

      if action.respond_to?(:user)
        begin
          return action.user
        rescue
        end
      end

      if action.respond_to?(:pokemon)
        begin
          return action.pokemon
        rescue
        end
      end

      return nil
    end

    #===========================================================================
    # State
    #===========================================================================

    def ready?
      return @player_action != nil &&
             @enemy_action != nil
    end

    def input?
      return @state == :input
    end

    def executing?
      return @state == :executing
    end

    def finished?
      return @state == :finished
    end

    def start_execution
      @state = :executing

      return ordered_actions
    end

    def finish
      @state = :finished

      return true
    end

    #===========================================================================
    # Compatibility Helper
    #===========================================================================

    def current
      return @number
    end

  end

  #=============================================================================
  # Turns Helper Module
  #=============================================================================

  module Turns

    def self.current(battle)
      return nil if !battle

      return battle.turn
    end

    def self.current_turn(battle)
      return nil if !battle

      if battle.respond_to?(:current_turn)
        return battle.current_turn
      end

      return nil
    end

    def self.start(number=1)
      return DeltaruneBattle::Turn.new(number)
    end

  end

end