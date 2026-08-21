#===============================================================================
# Deltarune Battle - Independent Battle Controller
#
# This is NOT Pokémon Essentials' Battle::Battle.
#
# Essentials is only used as a source of Pokémon / Move / Item data.
# All battle state, turns, actions and results belong to DeltaruneBattle.
#===============================================================================

module DeltaruneBattle

  class Battle

    attr_reader :player_trainer
    attr_reader :enemy_trainer

    attr_reader :turn
    attr_reader :scene
    attr_reader :result
    attr_reader :message

    #---------------------------------------------------------------------------
    # Initialization
    #---------------------------------------------------------------------------

    def initialize(player_party, enemy_party, trainer_name=nil)

      # Convert the supplied parties into our own Trainer objects.
      @player_trainer =
        if player_party.is_a?(DeltaruneBattle::Trainer)
          player_party
        else
          DeltaruneBattle::Trainer.player(
            player_party
          )
        end

      @enemy_trainer =
        if enemy_party.is_a?(DeltaruneBattle::Trainer)
          enemy_party
        else
          DeltaruneBattle::Trainer.enemy(
            enemy_party,
            trainer_name || "Trainer"
          )
        end

      @turn = 1
      @result = nil
      @message = ""
      @scene = nil

      @current_turn = nil

      @player_action = nil
      @enemy_action = nil

      @processing_turn = false
    end

    #---------------------------------------------------------------------------
    # Compatibility / Accessors
    #---------------------------------------------------------------------------

    def player_party
      return @player_trainer.party
    end

    def enemy_party
      return @enemy_trainer.party
    end

    def player_index
      return @player_trainer.active_index
    end

    def enemy_index
      return @enemy_trainer.active_index
    end

    def player_pokemon
      return @player_trainer.active_pokemon
    end

    def enemy_pokemon
      return @enemy_trainer.active_pokemon
    end

    #---------------------------------------------------------------------------
    # Current Turn Object
    #---------------------------------------------------------------------------

    def current_turn
      return @current_turn
    end

    #---------------------------------------------------------------------------
    # Start
    #---------------------------------------------------------------------------

    def start

      @scene = DeltaruneBattle::Scene.new(self)

      @scene.start

      return @result
    end

    #---------------------------------------------------------------------------
    # State
    #---------------------------------------------------------------------------

    def set_result(value)
      @result = value
    end

    def set_message(text)
      @message = text.to_s
    end

    #---------------------------------------------------------------------------
    # Player Action
    #
    # These methods are kept as the public interface used by Scene.
    # Internally they now create our own Action objects.
    #---------------------------------------------------------------------------

    def player_action(action, data=nil)

      return if @result

      @player_action =
        DeltaruneBattle::Actions::Factory.create(
          action,
          player_pokemon,
          enemy_pokemon,
          data
        )

      return @player_action
    end

    def execute_player_action(action, data=nil)

      return if @result

      case action

      when :fight
        return execute_fight(data)

      when :act
        return execute_act(data)

      when :bag
        return execute_item(data)

      when :pokemon
        return execute_switch(data)

      when :defend
        return execute_defend

      when :spare
        return execute_spare

      when :run
        return execute_run
      end

      return false
    end

    #===========================================================================
    # FIGHT
    #===========================================================================

    def execute_fight(move_index)

      return if @result

      attacker = player_pokemon
      target = enemy_pokemon

      if !attacker || !target
        return false
      end

      move = nil

      if attacker.moves &&
         attacker.moves[move_index]

        move = attacker.moves[move_index]

      elsif attacker.moves &&
            attacker.moves[0]

        move = attacker.moves[0]

      end

      if !move

        set_message(
          "#{attacker.name} has no move!"
        )

        return false
      end

      @player_action =
        DeltaruneBattle::Actions.fight(
          attacker,
          target,
          move
        )

      enemy_create_action

      resolve_turn

      return true
    end

    #===========================================================================
    # ACT
    #===========================================================================

    def execute_act(act_id=nil)

      return if @result

      @player_action =
        DeltaruneBattle::Actions.act(
          player_pokemon,
          enemy_pokemon,
          act_id
        )

      enemy_create_action

      resolve_turn

      return true
    end

    #===========================================================================
    # ITEM
    #===========================================================================

    def execute_item(item_id)

      return if @result

      item =
        begin
          GameData::Item.try_get(item_id)
        rescue
          nil
        end

      if !item

        set_message(
          "That item cannot be used."
        )

        return false
      end

      @player_action =
        DeltaruneBattle::Actions.item(
          player_pokemon,
          player_pokemon,
          item_id
        )

      enemy_create_action

      resolve_turn

      return true
    end

    #===========================================================================
    # POKÉMON SWITCH
    #===========================================================================

    def execute_switch(index)

      return if @result
      return false if index.nil?

      index = index.to_i

      party = @player_trainer.party

      return false if index < 0
      return false if index >= party.length

      candidate = party[index]

      return false if !candidate

      if candidate.respond_to?(:egg?) &&
         candidate.egg?

        return false
      end

      if candidate.respond_to?(:fainted?) &&
         candidate.fainted?

        return false
      end

      return false if index == @player_trainer.active_index

      @player_action =
        DeltaruneBattle::Actions.pokemon(
          player_pokemon,
          index
        )

      # Switching does not need a target.
      enemy_create_action

      resolve_turn

      return true
    end

    #===========================================================================
    # DEFEND
    #===========================================================================

    def execute_defend

      return if @result

      @player_action =
        DeltaruneBattle::Actions.defend(
          player_pokemon
        )

      enemy_create_action

      resolve_turn

      return true
    end

    #===========================================================================
    # SPARE
    #===========================================================================

    def execute_spare

      return if @result

      @player_action =
        DeltaruneBattle::Actions.spare(
          player_pokemon,
          enemy_pokemon
        )

      enemy_create_action

      resolve_turn

      return true
    end

    #===========================================================================
    # RUN
    #===========================================================================

    def execute_run

      return if @result

      @player_action =
        DeltaruneBattle::Actions.run(
          player_pokemon,
          enemy_pokemon
        )

      # Run is resolved immediately because there is no reason to make the
      # enemy attack if the escape succeeds.
      resolve_run

      return true
    end

    #===========================================================================
    # Enemy AI
    #===========================================================================

    def enemy_create_action

      attacker = enemy_pokemon
      target = player_pokemon

      if !attacker || !target
        return
      end

      move = nil

      if attacker.moves &&
         attacker.moves.length > 0

        if DeltaruneBattle::ENEMY_AI == :RANDOM

          index =
            rand(attacker.moves.length)

          move =
            attacker.moves[index]

        else

          move =
            attacker.moves[0]

        end
      end

      if move

        @enemy_action =
          DeltaruneBattle::Actions.fight(
            attacker,
            target,
            move
          )

      else

        @enemy_action =
          DeltaruneBattle::Actions.wait(
            attacker
          )
      end

      return @enemy_action
    end

    #===========================================================================
    # Resolve Turn
    #===========================================================================

    def resolve_turn

      return if @result
      return if @processing_turn

      @processing_turn = true

      @current_turn =
        DeltaruneBattle::Turn.new(
          @turn
        )

      @current_turn.set_player_action(
        @player_action
      )

      @current_turn.set_enemy_action(
        @enemy_action
      )

      actions =
        @current_turn.start_execution

      actions.each do |action|

        break if @result

        execute_action(
          action
        )

      end

      if !@result
        @current_turn.finish
      end

      @player_action = nil
      @enemy_action = nil

      @processing_turn = false

      return true
    end

    #===========================================================================
    # Execute Action
    #===========================================================================

    def execute_action(action)

      return if !action
      return if @result

      case action.type

      when DeltaruneBattle::Actions::FIGHT

        execute_fight_action(
          action
        )

      when DeltaruneBattle::Actions::ACT

        execute_act_action(
          action
        )

      when DeltaruneBattle::Actions::ITEM,
           DeltaruneBattle::Actions::BAG

        execute_item_action(
          action
        )

      when DeltaruneBattle::Actions::POKEMON

        execute_pokemon_action(
          action
        )

      when DeltaruneBattle::Actions::DEFEND

        execute_defend_action(
          action
        )

      when DeltaruneBattle::Actions::SPARE

        execute_spare_action(
          action
        )

      when DeltaruneBattle::Actions::RUN

        resolve_run

      when DeltaruneBattle::Actions::WAIT

        return
      end
    end

    #===========================================================================
    # Fight Resolution
    #===========================================================================

    def execute_fight_action(action)

      attacker = action.user
      target = action.target
      move = action.move

      return if !attacker
      return if !target
      return if !move

      return if fainted?(attacker)
      return if fainted?(target)

      power = 40

      if move.respond_to?(:power)

        power =
          move.power.to_i

        power = 40 if power <= 0
      end

      damage =
        calculate_damage(
          attacker,
          target,
          power,
          move
        )

      old_hp =
        target.hp.to_i

      target.hp =
        [old_hp - damage, 0].max

      set_message(
        "#{attacker.name} used #{move.name}! #{damage} damage."
      )

      if target.hp <= 0

        handle_faint(
          target
        )

        return
      end

      # Player attack is followed by enemy action.
      # Enemy action itself will be processed by Turn if it comes next.
      return
    end

    #===========================================================================
    # ACT Resolution
    #===========================================================================

    def execute_act_action(action)

      user = action.user
      target = action.target

      return if !user
      return if !target

      if respond_to?(:resolve_act)

        resolve_act(
          action.data,
          user,
          target
        )

      else

        set_message(
          "#{user.name} tried an ACT."
        )

      end
    end

    #===========================================================================
    # ITEM Resolution
    #===========================================================================

    def execute_item_action(action)

      item_id =
        action.data

      item =
        begin
          GameData::Item.try_get(item_id)
        rescue
          nil
        end

      if !item

        set_message(
          "That item cannot be used."
        )

        return
      end

      pokemon =
        player_pokemon

      if !pokemon

        return
      end

      amount = 0

      if item.respond_to?(:heal_amount)

        amount =
          item.heal_amount.to_i

      end

      max_hp =
        pokemon_max_hp(
          pokemon
        )

      if amount > 0 &&
         pokemon.hp < max_hp

        old_hp =
          pokemon.hp

        pokemon.hp =
          [pokemon.hp + amount, max_hp].min

        healed =
          pokemon.hp - old_hp

        if healed > 0

          if $bag &&
             $bag.respond_to?(:quantity) &&
             $bag.quantity(item_id) > 0

            if $bag.respond_to?(:remove)

              $bag.remove(
                item_id,
                1
              )

            end
          end

          set_message(
            "Used #{item.name}! " \
            "#{pokemon.name} recovered #{healed} HP."
          )

          return
        end
      end

      set_message(
        "It had no effect."
      )
    end

    #===========================================================================
    # Pokémon Resolution
    #===========================================================================

    def execute_pokemon_action(action)

      index =
        action.party_index

      party =
        @player_trainer.party

      return if index < 0
      return if index >= party.length

      candidate =
        party[index]

      return if !candidate

      if candidate.respond_to?(:egg?) &&
         candidate.egg?

        return
      end

      if fainted?(candidate)

        return
      end

      if index ==
         @player_trainer.active_index

        set_message(
          "#{candidate.name} is already battling!"
        )

        return
      end

      if @scene

        @scene.recall_player

      end

      @player_trainer.active_index =
        index

      if @scene

        @scene.send_out_player

      end

      set_message(
        "Go, #{player_pokemon.name}!"
      )
    end

    #===========================================================================
    # Defend Resolution
    #===========================================================================

    def execute_defend_action(action)

      user =
        action.user

      return if !user

      set_message(
        "#{user.name} is defending."
      )
    end

    #===========================================================================
    # Spare Resolution
    #===========================================================================

    def execute_spare_action(action)

      user =
        action.user

      target =
        action.target

      return if !user
      return if !target

      if respond_to?(:resolve_spare)

        resolve_spare(
          user,
          target
        )

      else

        set_message(
          "#{user.name} tried to spare #{target.name}."
        )

      end
    end

    #===========================================================================
    # Run Resolution
    #===========================================================================

    def resolve_run

      return if @result

      chance =
        DeltaruneBattle::RUN_BASE_CHANCE

      player =
        player_pokemon

      enemy =
        enemy_pokemon

      if player &&
         enemy

        chance +=
          (player.level - enemy.level) * 0.02

      end

      chance =
        [[chance, 0.15].max, 0.95].min

      if rand < chance

        if @scene

          @scene.run_away

        end

        @result = :run

        set_message(
          "Got away safely!"
        )

      else

        set_message(
          "Couldn't escape!"
        )

        # The failed escape still allows the enemy to act.
        enemy_create_action

        resolve_enemy_only_turn
      end
    end

    #===========================================================================
    # Enemy-only Turn
    #===========================================================================

    def resolve_enemy_only_turn

      return if @result

      action =
        @enemy_action

      return if !action

      execute_action(
        action
      )

      @enemy_action = nil

      advance_turn unless @result
    end

    #===========================================================================
    # Faint Handling
    #===========================================================================

    def handle_faint(pokemon)

      if pokemon ==
         enemy_pokemon

        if @scene

          @scene.enemy_defeat

        end

        check_enemy_party

      elsif pokemon ==
            player_pokemon

        if @scene

          @scene.player_defeat

        end

        check_player_party
      end
    end

    #===========================================================================
    # Enemy Party
    #===========================================================================

    def check_enemy_party

      index =
        @enemy_trainer.first_usable_index

      if index < 0

        @result = :win

        if @scene

          @scene.victory

        end

        return
      end

      @enemy_trainer.active_index =
        index

      if @scene

        @scene.send_out_enemy

      end

      set_message(
        "#{enemy_pokemon.name} entered the battle!"
      )

      advance_turn
    end

    #===========================================================================
    # Player Party
    #===========================================================================

    def check_player_party

      index =
        @player_trainer.first_usable_index

      if index < 0

        @result = :lose

        if @scene

          @scene.defeat

        end

        return
      end

      @player_trainer.active_index =
        index

      if @scene

        @scene.send_out_player

      end

      set_message(
        "Go, #{player_pokemon.name}!"
      )

      advance_turn
    end

    #===========================================================================
    # Turn Advancement
    #===========================================================================

    def advance_turn

      return if @result

      @turn += 1

      @current_turn = nil
    end

    #===========================================================================
    # Damage
    #===========================================================================

    def calculate_damage(
      attacker,
      defender,
      power,
      move
    )

      level =
        attacker.level.to_i

      attack_stat =
        0

      defense_stat =
        0

      category =
        nil

      if move &&
         move.respond_to?(:category)

        category =
          move.category

      end

      # Pokémon Essentials move categories:
      # 0 = physical
      # 1 = special
      # 2 = status
      #
      # We do NOT use Essentials' damage calculation.
      if category == 1

        if attacker.respond_to?(:spatk)

          attack_stat =
            attacker.spatk.to_i

        end

        if defender.respond_to?(:spdef)

          defense_stat =
            defender.spdef.to_i

        end

      else

        if attacker.respond_to?(:attack)

          attack_stat =
            attacker.attack.to_i

        end

        if defender.respond_to?(:defense)

          defense_stat =
            defender.defense.to_i

        end

      end

      attack_stat =
        1 if attack_stat <= 0

      defense_stat =
        1 if defense_stat <= 0

      damage =
        (
          (
            (
              (2 * level / 5 + 2) *
              power *
              attack_stat /
              defense_stat
            ) / 50
          ) + 2
        )

      variance =
        1.0 -
        DeltaruneBattle::DAMAGE_VARIANCE +
        rand *
        DeltaruneBattle::DAMAGE_VARIANCE *
        2.0

      damage =
        (damage * variance).to_i

      minimum =
        DeltaruneBattle::DAMAGE_MINIMUM

      damage =
        minimum if damage < minimum

      return damage
    end

    #===========================================================================
    # Pokémon Helpers
    #===========================================================================

    def fainted?(pokemon)

      return true if !pokemon

      if pokemon.respond_to?(:fainted?)

        return pokemon.fainted?

      end

      return pokemon.hp.to_i <= 0
    end

    def pokemon_max_hp(pokemon)

      if pokemon.respond_to?(:max_hp)

        return pokemon.max_hp.to_i

      end

      if pokemon.respond_to?(:totalhp)

        return pokemon.totalhp.to_i

      end

      return pokemon.hp.to_i
    end

  end

end