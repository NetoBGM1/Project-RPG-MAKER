#===============================================================================
# Deltarune Battle - Independent Scene
#===============================================================================
module DeltaruneBattle
  class Scene
    attr_reader :battle

    def initialize(battle)
      @battle = battle
      @viewport = nil
      @sprites = {}
      @command_index = 0
      @mode = :commands
      @closed = false
      @message = ""
      @message_timer = 0
      @transition = 0
    end

    def start
      create_viewport
      create_background
      create_trainers
      create_pokemon
      create_ui
      intro_sequence
      main_loop
      dispose
    end

    def create_viewport
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 50000
    end

    def create_background
      sprite = Sprite.new(@viewport)
      sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
      sprite.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height,
                              Color.new(18, 18, 24))
      sprite.z = 0
      @sprites["background"] = sprite
    end

    def create_trainers
      @sprites["player_trainer"] = make_optional_sprite(
        DeltaruneBattle::PLAYER_TRAINER_GRAPHIC,
        DeltaruneBattle::PLAYER_TRAINER_X,
        DeltaruneBattle::PLAYER_TRAINER_Y,
        20
      )
      @sprites["enemy_trainer"] = make_optional_sprite(
        DeltaruneBattle::ENEMY_TRAINER_GRAPHIC,
        DeltaruneBattle::ENEMY_TRAINER_X,
        DeltaruneBattle::ENEMY_TRAINER_Y,
        20
      )
    end

    def create_pokemon
      create_pokemon_sprite("player_pokemon", @battle.player_pokemon,
                            DeltaruneBattle::PLAYER_POKEMON_X,
                            DeltaruneBattle::PLAYER_POKEMON_Y, 40)
      create_pokemon_sprite("enemy_pokemon", @battle.enemy_pokemon,
                            DeltaruneBattle::ENEMY_POKEMON_X,
                            DeltaruneBattle::ENEMY_POKEMON_Y, 40)
    end

    def create_pokemon_sprite(key, pokemon, x, y, z)
      sprite = Sprite.new(@viewport)
      sprite.x = x
      sprite.y = y
      sprite.z = z
      set_pokemon_bitmap(sprite, pokemon, key == "player_pokemon")
      @sprites[key] = sprite
    end

    def set_pokemon_bitmap(sprite, pokemon, player_side)
      return if !pokemon
      bitmap = nil
      begin
        if player_side
          bitmap = pbLoadPokemonBitmap(pokemon, false, false)
        else
          bitmap = pbLoadPokemonBitmap(pokemon, true, false)
        end
      rescue
        begin
          bitmap = pbLoadPokemonBitmap(pokemon, player_side, false)
        rescue
          bitmap = Bitmap.new(96, 96)
          bitmap.fill_rect(8, 8, 80, 80, Color.new(180, 180, 180))
        end
      end
      sprite.bitmap = bitmap if bitmap
    end

    def create_ui
      create_turn
      create_hud("player_hud", DeltaruneBattle::PLAYER_HUD_X,
                 DeltaruneBattle::PLAYER_HUD_Y, @battle.player_pokemon, true)
      create_hud("enemy_hud", DeltaruneBattle::ENEMY_HUD_X,
                 DeltaruneBattle::ENEMY_HUD_Y, @battle.enemy_pokemon, false)
      create_menu
      create_command_box
      create_textbox
      refresh_all
    end

    def create_turn
      sprite = Sprite.new(@viewport)
      sprite.bitmap = Bitmap.new(120, 32)
      sprite.x = DeltaruneBattle::TURN_X
      sprite.y = DeltaruneBattle::TURN_Y
      sprite.z = 300
      @sprites["turn"] = sprite
    end

    def create_hud(key, x, y, pokemon, player_side)
      sprite = Sprite.new(@viewport)
      begin
        sprite.bitmap = Bitmap.new(DeltaruneBattle::HUD_GRAPHIC)
      rescue
        sprite.bitmap = Bitmap.new(240, 70)
        sprite.bitmap.fill_rect(0, 0, 240, 70, Color.new(8, 8, 12))
        sprite.bitmap.draw_text(8, 8, 224, 24, "HUD", 0)
      end
      sprite.x = x
      sprite.y = y
      sprite.z = 200
      @sprites[key] = sprite
      @sprites[key + "_data"] = pokemon
      @sprites[key + "_player"] = player_side
    end

    def create_menu
      sprite = Sprite.new(@viewport)
      begin
        sprite.bitmap = Bitmap.new(DeltaruneBattle::BATTLE_MENU_GRAPHIC)
      rescue
        sprite.bitmap = Bitmap.new(608, 70)
        sprite.bitmap.fill_rect(0, 0, 608, 70, Color.new(8, 8, 12))
      end
      sprite.x = DeltaruneBattle::MENU_X
      sprite.y = DeltaruneBattle::MENU_Y
      sprite.z = 100
      @sprites["menu"] = sprite
    end

    def create_command_box
      sprite = Sprite.new(@viewport)
      begin
        sprite.bitmap = Bitmap.new(DeltaruneBattle::COMMAND_BOX_GRAPHIC)
      rescue
        sprite.bitmap = Bitmap.new(120, 42)
        sprite.bitmap.fill_rect(0, 0, 120, 42, Color.new(255, 255, 255))
      end
      sprite.x = DeltaruneBattle::MENU_X
      sprite.y = DeltaruneBattle::MENU_Y
      sprite.z = 150
      @sprites["command_box"] = sprite
    end

    def create_textbox
      sprite = Sprite.new(@viewport)
      begin
        sprite.bitmap = Bitmap.new(DeltaruneBattle::TEXTBOX_GRAPHIC)
      rescue
        sprite.bitmap = Bitmap.new(608, 64)
        sprite.bitmap.fill_rect(0, 0, 608, 64, Color.new(8, 8, 12))
      end
      sprite.x = DeltaruneBattle::TEXTBOX_X
      sprite.y = DeltaruneBattle::TEXTBOX_Y
      sprite.z = 250
      @sprites["textbox"] = sprite
    end

    def intro_sequence
      message("A battle begins!")
      wait_for_input
      message("What will #{battle.player_pokemon.name} do?")
    end

    def main_loop
      until @closed
        Graphics.update
        Input.update
        update
      end
    end

    def update
      if @message_timer > 0
        @message_timer -= 1
      end

      if @mode == :commands
        update_commands
      elsif @mode == :moves
        update_moves
      elsif @mode == :bag
        update_bag
      elsif @mode == :pokemon
        update_pokemon
      elsif @mode == :message
        if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
          @mode = :commands
          message("What will #{battle.player_pokemon.name} do?")
        end
      end

      refresh_turn
      refresh_hud
    end

    def update_commands
      if Input.trigger?(Input::LEFT)
        @command_index -= 1
        @command_index = 3 if @command_index < 0
        refresh_command_box
      elsif Input.trigger?(Input::RIGHT)
        @command_index += 1
        @command_index = 0 if @command_index > 3
        refresh_command_box
      elsif Input.trigger?(Input::USE)
        command = DeltaruneBattle::COMMANDS[@command_index]
        case command
        when :fight
          open_moves
        when :bag
          open_bag
        when :pokemon
          open_pokemon
        when :run
          @mode = :message
          battle.execute_run
          message(battle.message)
          check_end
        end
      end
    end

    def open_moves
      @mode = :moves
      @move_index = 0
      refresh_move_message
    end

    def update_moves
      moves = battle.player_pokemon.moves
      count = moves ? moves.length : 0
      count = 1 if count <= 0

      if Input.trigger?(Input::UP)
        @move_index -= 1
        @move_index = count - 1 if @move_index < 0
        refresh_move_message
      elsif Input.trigger?(Input::DOWN)
        @move_index += 1
        @move_index = 0 if @move_index >= count
        refresh_move_message
      elsif Input.trigger?(Input::BACK)
        @mode = :commands
        message("What will #{battle.player_pokemon.name} do?")
      elsif Input.trigger?(Input::USE)
        battle.execute_fight(@move_index)
        message(battle.message)
        check_end
      end
    end

    def open_bag
      @mode = :bag
      @bag_items = get_bag_items
      @bag_index = 0
      if @bag_items.empty?
        message("Your Bag is empty.")
        @mode = :message
      else
        refresh_bag_message
      end
    end

    def update_bag
      if Input.trigger?(Input::UP)
        @bag_index -= 1
        @bag_index = @bag_items.length - 1 if @bag_index < 0
        refresh_bag_message
      elsif Input.trigger?(Input::DOWN)
        @bag_index += 1
        @bag_index = 0 if @bag_index >= @bag_items.length
        refresh_bag_message
      elsif Input.trigger?(Input::BACK)
        @mode = :commands
        message("What will #{battle.player_pokemon.name} do?")
      elsif Input.trigger?(Input::USE)
        item_id = @bag_items[@bag_index]
        battle.execute_item(item_id)
        message(battle.message)
        check_end
      end
    end

    def get_bag_items
      result = []
      return result if !$bag
      return result unless $bag.respond_to?(:quantity)

      GameData::Item.each do |item|
        next if item.nil?
        begin
          result << item.id if $bag.quantity(item.id) > 0
        rescue
        end
        break if result.length >= 8
      end
      return result
    end

    def open_pokemon
      @mode = :pokemon
      @party_index = 0
      refresh_pokemon_message
    end

    def update_pokemon
      if Input.trigger?(Input::UP)
        @party_index -= 1
        @party_index = battle.player_party.length - 1 if @party_index < 0
        refresh_pokemon_message
      elsif Input.trigger?(Input::DOWN)
        @party_index += 1
        @party_index = 0 if @party_index >= battle.player_party.length
        refresh_pokemon_message
      elsif Input.trigger?(Input::BACK)
        @mode = :commands
        message("What will #{battle.player_pokemon.name} do?")
      elsif Input.trigger?(Input::USE)
        battle.execute_switch(@party_index)
        message(battle.message)
        check_end
      end
    end

    def refresh_all
      refresh_turn
      refresh_command_box
      refresh_hud
      message("What will #{battle.player_pokemon.name} do?")
    end

    def refresh_turn
      return if !@sprites["turn"]
      bmp = @sprites["turn"].bitmap
      bmp.clear
      pbSetSystemFont(bmp)
      bmp.draw_text(0, 0, 120, 32, "TURN #{battle.turn}", 1)
    end

    def refresh_hud
      refresh_one_hud("player_hud", battle.player_pokemon)
      refresh_one_hud("enemy_hud", battle.enemy_pokemon)
    end

    def refresh_one_hud(key, pokemon)
      sprite = @sprites[key]
      return if !sprite || !pokemon
      bmp = sprite.bitmap
      return if !bmp
      # Only draw text if this is our fallback HUD. If a real HUD graphic
      # exists, text will be handled by the later UI pass.
      if bmp.width <= 300
        pbSetSystemFont(bmp)
        bmp.draw_text(8, 8, bmp.width - 16, 24, pokemon.name, 0)
        bmp.draw_text(8, 30, bmp.width - 16, 22,
                      "Lv. #{pokemon.level}  HP #{pokemon.hp}/#{pokemon.totalhp}", 0)
      end
    end

    def refresh_command_box
      sprite = @sprites["command_box"]
      return if !sprite
      positions = [[20, 396], [178, 396], [340, 396], [500, 396]]
      sprite.x = positions[@command_index][0]
      sprite.y = positions[@command_index][1]
    end

    def refresh_move_message
      moves = battle.player_pokemon.moves
      if moves && moves[@move_index]
        message("MOVE: #{moves[@move_index].name}   (Enter to use / Esc to back)")
      else
        message("Attack   (Enter to use / Esc to back)")
      end
    end

    def refresh_bag_message
      item_id = @bag_items[@bag_index]
      item = GameData::Item.get(item_id)
      message("ITEM: #{item.name}   (Enter to use / Esc to back)")
    end

    def refresh_pokemon_message
      pkmn = battle.player_party[@party_index]
      if pkmn
        message("#{pkmn.name}  Lv.#{pkmn.level}  HP #{pkmn.hp}/#{pkmn.totalhp}")
      end
    end

    def message(text)
      @message = text.to_s
      @mode = :message if @mode == :message
      sprite = @sprites["textbox"]
      return if !sprite || !sprite.bitmap
      bmp = sprite.bitmap
      bmp.clear
      pbSetSystemFont(bmp)
      bmp.draw_text(16, 10, bmp.width - 32, bmp.height - 20, @message, 0)
      @message_timer = 0
    end

    def wait_for_input
      loop do
        Graphics.update
        Input.update
        break if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
      end
    end

    def check_end
      if battle.result
        return
      end
      @mode = :message
      message(battle.message)
    end

    #===========================================================================
    # Battle animations
    #===========================================================================

    def send_out_player
      animate_send("player_pokemon")
      refresh_hud
    end

    def send_out_enemy
      animate_send("enemy_pokemon")
      refresh_hud
    end

    def animate_send(key)
      sprite = @sprites[key]
      return if !sprite
      start_x = sprite.x
      start_y = sprite.y + 30
      sprite.y = start_y
      i = 0
      while i < DeltaruneBattle::SEND_OUT_FRAMES
        Graphics.update
        Input.update
        t = i.to_f / DeltaruneBattle::SEND_OUT_FRAMES
        sprite.y = (start_y - 30 * t).to_i
        sprite.opacity = (255 * t).to_i
        i += 1
      end
      sprite.x = start_x
      sprite.y = start_y - 30
      sprite.opacity = 255
    end

    def recall_player
      sprite = @sprites["player_pokemon"]
      return if !sprite
      i = 0
      while i < DeltaruneBattle::RECALL_FRAMES
        Graphics.update
        Input.update
        t = i.to_f / DeltaruneBattle::RECALL_FRAMES
        sprite.opacity = (255 * (1.0 - t)).to_i
        sprite.y += 1 if i % 3 == 0
        i += 1
      end
      sprite.opacity = 255
    end

    def enemy_defeat
      animate_defeat("enemy_pokemon")
    end

    def player_defeat
      animate_defeat("player_pokemon")
    end

    def animate_defeat(key)
      sprite = @sprites[key]
      return if !sprite
      i = 0
      while i < DeltaruneBattle::DEFEAT_FRAMES
        Graphics.update
        Input.update
        sprite.opacity = [255 - i * 7, 0].max
        sprite.y += 1 if i % 4 == 0
        i += 1
      end
      sprite.opacity = 0
    end

    def run_away
      sprite = @sprites["player_trainer"]
      sprite = @sprites["player_pokemon"] if !sprite || sprite.bitmap.nil?
      return if !sprite
      i = 0
      while i < DeltaruneBattle::RUN_FRAMES
        Graphics.update
        Input.update
        sprite.x -= 6
        sprite.opacity = [255 - i * 7, 0].max
        i += 1
      end
    end

    def victory
      message("Victory!")
      wait_for_input
      @closed = true
    end

    def defeat
      message("You lost the battle.")
      wait_for_input
      @closed = true
    end

    #===========================================================================
    # Utility
    #===========================================================================

    def make_optional_sprite(path, x, y, z)
      sprite = Sprite.new(@viewport)
      begin
        sprite.bitmap = Bitmap.new(path)
      rescue
        sprite.bitmap = Bitmap.new(96, 96)
        sprite.bitmap.fill_rect(16, 8, 64, 80, Color.new(120, 120, 120))
      end
      sprite.x = x
      sprite.y = y
      sprite.z = z
      return sprite
    end

    def dispose
      @sprites.each_value do |obj|
        next unless obj.is_a?(Sprite)
        obj.dispose if !obj.disposed?
      end
      @sprites.clear
      @viewport.dispose if @viewport && !@viewport.disposed?
      @viewport = nil
    end
  end
end
