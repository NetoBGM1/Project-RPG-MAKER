#===============================================================================
# Deltarune Battle - Independent Battle Controller
#===============================================================================
module DeltaruneBattle
  class Battle
    attr_reader :player_party
    attr_reader :enemy_party
    attr_reader :player_index
    attr_reader :enemy_index
    attr_reader :turn
    attr_reader :scene
    attr_reader :result
    attr_reader :message

    def initialize(player_party, enemy_party, trainer_name=nil)
      @player_party = player_party
      @enemy_party = enemy_party
      @trainer_name = trainer_name || "Trainer"
      @player_index = first_usable(@player_party)
      @enemy_index = first_usable(@enemy_party)
      @turn = 1
      @result = nil
      @message = ""
      @scene = nil
      @pending_action = nil
    end

    def player_pokemon
      return @player_party[@player_index]
    end

    def enemy_pokemon
      return @enemy_party[@enemy_index]
    end

    def start
      @scene = Scene.new(self)
      @scene.start
      return @result
    end

    def set_result(value)
      @result = value
    end

    def set_message(text)
      @message = text
    end

    def player_action(action, data=nil)
      @pending_action = [action, data]
    end

    def execute_player_action(action, data=nil)
      return if @result
      case action
      when :fight
        execute_fight(data)
      when :bag
        execute_item(data)
      when :pokemon
        execute_switch(data)
      when :run
        execute_run
      end
    end

    def execute_fight(move_index)
      pkmn = player_pokemon
      target = enemy_pokemon
      if !pkmn || !target
        return
      end
      move = pkmn.moves[move_index] if pkmn.moves && pkmn.moves[move_index]
      if !move
        move = pkmn.moves[0] if pkmn.moves && pkmn.moves[0]
      end
      if !move
        set_message("#{pkmn.name} has no move!")
        return
      end

      power = move.power.to_i
      power = 40 if power <= 0
      damage = calculate_damage(pkmn, target, power, move)
      target.hp = [target.hp - damage, 0].max
      set_message("#{pkmn.name} used #{move.name}! #{damage} damage.")

      if target.hp <= 0
        @scene.enemy_defeat
        check_enemy_party
        return
      end

      enemy_turn
    end

    def enemy_turn
      return if @result
      target = player_pokemon
      attacker = enemy_pokemon
      move = attacker.moves[0] if attacker.moves && attacker.moves[0]
      if !move
        move_power = 40
        move_name = "Attack"
      else
        move_power = move.power.to_i
        move_power = 40 if move_power <= 0
        move_name = move.name
      end
      damage = calculate_damage(attacker, target, move_power, move)
      target.hp = [target.hp - damage, 0].max
      set_message("#{attacker.name} used #{move_name}! #{damage} damage.")

      if target.hp <= 0
        @scene.player_defeat
        check_player_party
        return
      end

      advance_turn
    end

    def execute_item(item_id)
      return if @result
      item = GameData::Item.try_get(item_id)
      if !item
        set_message("That item cannot be used.")
        return
      end

      pkmn = player_pokemon
      healed = false
      amount = 0

      if item.respond_to?(:heal_amount)
        amount = item.heal_amount.to_i
      end

      if amount > 0 && pkmn.hp < pkmn.totalhp
        old_hp = pkmn.hp
        pkmn.hp = [pkmn.hp + amount, pkmn.totalhp].min
        healed = pkmn.hp > old_hp
      end

      if healed
        if $bag && $bag.respond_to?(:quantity) && $bag.quantity(item_id) > 0
          $bag.remove(item_id, 1) if $bag.respond_to?(:remove)
        end
        set_message("Used #{item.name}! #{pkmn.name} recovered #{pkmn.hp - old_hp} HP.")
        enemy_turn
      else
        set_message("It had no effect.")
      end
    end

    def execute_switch(index)
      return if @result
      return if index.nil?
      index = index.to_i
      return if index < 0 || index >= @player_party.length
      candidate = @player_party[index]
      return if !candidate || candidate.egg? || candidate.fainted?
      return if index == @player_index

      @scene.recall_player
      @player_index = index
      @scene.send_out_player
      set_message("Go, #{player_pokemon.name}!")
      enemy_turn
    end

    def execute_run
      chance = DeltaruneBattle::RUN_BASE_CHANCE
      if player_pokemon && enemy_pokemon
        chance += (player_pokemon.level - enemy_pokemon.level) * 0.02
      end
      chance = [[chance, 0.15].max, 0.95].min

      if rand < chance
        @scene.run_away
        @result = :run
      else
        set_message("Couldn't escape!")
        enemy_turn
      end
    end

    def check_enemy_party
      next_index = first_usable(@enemy_party)
      if next_index < 0
        @result = :win
        @scene.victory
      else
        @enemy_index = next_index
        @scene.send_out_enemy
        set_message("#{enemy_pokemon.name} entered the battle!")
        advance_turn
      end
    end

    def check_player_party
      next_index = first_usable(@player_party)
      if next_index < 0
        @result = :lose
        @scene.defeat
      else
        @player_index = next_index
        @scene.send_out_player
        set_message("Go, #{player_pokemon.name}!")
        advance_turn
      end
    end

    def advance_turn
      @turn += 1
    end

    def first_usable(party)
      i = 0
      while i < party.length
        pkmn = party[i]
        return i if pkmn && !pkmn.egg? && !pkmn.fainted?
        i += 1
      end
      return -1
    end

    def calculate_damage(attacker, defender, power, move)
      level = attacker.level.to_i
      attack_stat = 0
      defense_stat = 0

      if move && move.respond_to?(:category)
        if move.category == 2
          attack_stat = attacker.spatk.to_i
          defense_stat = defender.spdef.to_i
        else
          attack_stat = attacker.attack.to_i
          defense_stat = defender.defense.to_i
        end
      else
        attack_stat = attacker.attack.to_i
        defense_stat = defender.defense.to_i
      end

      attack_stat = 1 if attack_stat <= 0
      defense_stat = 1 if defense_stat <= 0

      damage = (((2 * level / 5 + 2) * power * attack_stat / defense_stat) / 50) + 2
      variance = 1.0 - DeltaruneBattle::DAMAGE_VARIANCE +
                 rand * DeltaruneBattle::DAMAGE_VARIANCE * 2.0
      damage = (damage * variance).to_i
      damage = DeltaruneBattle::DAMAGE_MINIMUM if damage < DeltaruneBattle::DAMAGE_MINIMUM
      return damage
    end
  end
end
