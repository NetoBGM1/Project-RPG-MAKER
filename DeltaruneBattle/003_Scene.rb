#===============================================================================
# Deltarune Battle - Independent Scene
#
# The Scene belongs entirely to Deltarune Battle.
# Pokémon Essentials is used only as a resource/data provider through
# DeltaruneBattle::Pokemon#source.
#===============================================================================

module DeltaruneBattle

  class Scene

    attr_reader :battle

    #===========================================================================
    # Initialization
    #===========================================================================

    def initialize(battle)
      @battle = battle

      @viewport = nil
      @sprites = {}

      @command_index = 0
      @move_index = 0
      @bag_index = 0
      @party_index = 0

      @mode = :commands
      @closed = false

      @message = ""
      @message_timer = 0

      @transition = 0
    end

    #===========================================================================
    # Start
    #===========================================================================

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

    #===========================================================================
    # Viewport
    #===========================================================================

    def create_viewport
      @viewport = Viewport.new(
        0,
        0,
        Graphics.width,
        Graphics.height
      )

      @viewport.z = 50000
    end

    #===========================================================================
    # Background
    #===========================================================================

    def create_background
      sprite = Sprite.new(@viewport)

      sprite.bitmap = Bitmap.new(
        Graphics.width,
        Graphics.height
      )

      sprite.bitmap.fill_rect(
        0,
        0,
        Graphics.width,
        Graphics.height,
        Color.new(18, 18, 24)
      )

      sprite.z = 0

      @sprites["background"] = sprite
    end

    #===========================================================================
    # Trainers
    #===========================================================================

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

    #===========================================================================
    # Pokémon
    #===========================================================================

    def create_pokemon
      create_pokemon_sprite(
        "player_pokemon",
        @battle.player_pokemon,
        DeltaruneBattle::PLAYER_POKEMON_X,
        DeltaruneBattle::PLAYER_POKEMON_Y,
        40,
        true
      )

      create_pokemon_sprite(
        "enemy_pokemon",
        @battle.enemy_pokemon,
        DeltaruneBattle::ENEMY_POKEMON_X,
        DeltaruneBattle::ENEMY_POKEMON_Y,
        40,
        false
      )
    end

    def create_pokemon_sprite(key, pokemon, x, y, z, player_side)
      sprite = Sprite.new(@viewport)

      sprite.x = x
      sprite.y = y
      sprite.z = z

      set_pokemon_bitmap(
        sprite,
        pokemon,
        player_side
      )

      @sprites[key] = sprite
    end

    #===========================================================================
    # Pokémon Bitmap
    #
    # DeltaruneBattle::Pokemon is our object.
    # pbLoadPokemonBitmap still needs the original Essentials Pokémon.
    # Therefore we explicitly use pokemon.source here.
    #===========================================================================

    def set_pokemon_bitmap(sprite, pokemon, player_side)
      return if !sprite
      return if !pokemon

      source = pokemon.source

      if !source
        create_fallback_pokemon_bitmap(sprite)
        return
      end

      bitmap = nil

      begin
        if player_side
          bitmap = pbLoadPokemonBitmap(
            source,
            false,
            false
          )
        else
          bitmap = pbLoadPokemonBitmap(
            source,
            true,
            false
          )
        end
      rescue
        begin
          bitmap = pbLoadPokemonBitmap(
            source,
            player_side,
            false
          )
        rescue
          create_fallback_pokemon_bitmap(sprite)
          return
        end
      end

      sprite.bitmap = bitmap if bitmap
    end

    def create_fallback_pokemon_bitmap(sprite)
      bitmap = Bitmap.new(96, 96)

      bitmap.fill_rect(
        8,
        8,
        80,
        80,
        Color.new(180, 180, 180)
      )

      sprite.bitmap = bitmap
    end

    #===========================================================================
    # UI Creation
    #===========================================================================

    def create_ui
      create_turn

      create_hud(
        "player_hud",
        DeltaruneBattle::PLAYER_HUD_X,
        DeltaruneBattle::PLAYER_HUD_Y,
        @battle.player_pokemon,
        true
      )

      create_hud(
        "enemy_hud",
        DeltaruneBattle::ENEMY_HUD_X,
        DeltaruneBattle::ENEMY_HUD_Y,
        @battle.enemy_pokemon,
        false
      )

      create_menu
      create_command_box
      create_textbox

      refresh_all
    end

    #===========================================================================
    # Turn Display
    #===========================================================================

    def create_turn
      sprite = Sprite.new(@viewport)

      sprite.bitmap = Bitmap.new(
        120,
        32
      )

      sprite.x = DeltaruneBattle::TURN_X
      sprite.y = DeltaruneBattle::TURN_Y
      sprite.z = 300

      @sprites["turn"] = sprite
    end

    #===========================================================================
    # HUD
    #===========================================================================

    def create_hud(key, x, y, pokemon, player_side)
      sprite = Sprite.new(@viewport)

      begin
        sprite.bitmap = Bitmap.new(
          DeltaruneBattle::HUD_GRAPHIC
        )
      rescue
        sprite.bitmap = Bitmap.new(
          240,
          70
        )

        sprite.bitmap.fill_rect(
          0,
          0,
          240,
          70,
          Color.new(8, 8, 12)
        )

        sprite.bitmap.draw_text(
          8,
          8,
          224,
          24,
          "HUD",
          0
        )
      end

      sprite.x = x
      sprite.y = y
      sprite.z = 200

      @sprites[key] = sprite
      @sprites[key + "_data"] = pokemon
      @sprites[key + "_player"] = player_side
    end

    #===========================================================================
    # Battle Menu
    #===========================================================================

    def create_menu
      sprite = Sprite.new(@viewport)

      begin
        sprite.bitmap = Bitmap.new(
          DeltaruneBattle::BATTLE_MENU_GRAPHIC
        )
      rescue
        sprite.bitmap = Bitmap.new(
          608,
          70
        )

        sprite.bitmap.fill_rect(
          0,
          0,
          608,
          70,
          Color.new(8, 8, 12)
        )
      end

      sprite.x = DeltaruneBattle::MENU_X
      sprite.y = DeltaruneBattle::MENU_Y
      sprite.z = 100

      @sprites["menu"] = sprite
    end

    #===========================================================================
    # Command Box
    #===========================================================================

    def create_command_box
      sprite = Sprite.new(@viewport)

      begin
        sprite.bitmap = Bitmap.new(
          DeltaruneBattle::COMMAND_BOX_GRAPHIC
        )
      rescue
        sprite.bitmap = Bitmap.new(
          120,
          42
        )

        sprite.bitmap.fill_rect(
          0,
          0,
          120,
          42,
          Color.new(255, 255, 255)
        )
      end

      sprite.x = DeltaruneBattle::MENU_X
      sprite.y = DeltaruneBattle::MENU_Y
      sprite.z = 150

      @sprites["command_box"] = sprite
    end

    #===========================================================================
    # Text Box
    #===========================================================================

    def create_textbox
      sprite = Sprite.new(@viewport)

      begin
        sprite.bitmap = Bitmap.new(
          DeltaruneBattle::TEXTBOX_GRAPHIC
        )
      rescue
        sprite.bitmap = Bitmap.new(
          608,
          64
        )

        sprite.bitmap.fill_rect(
          0,
          0,
          608,
          64,
          Color.new(8, 8, 12)
        )
      end

      sprite.x = DeltaruneBattle::TEXTBOX_X
      sprite.y = DeltaruneBattle::TEXTBOX_Y
      sprite.z = 250

      @sprites["textbox"] = sprite
    end

    #===========================================================================
    # Intro
    #===========================================================================

    def intro_sequence
      message("A battle begins!")

      wait_for_input

      message(
        "What will #{@battle.player_pokemon.name} do?"
      )
    end

    #===========================================================================
    # Main Loop
    #===========================================================================

    def main_loop
      until @closed
        Graphics.update
        Input.update

        update
      end
    end

    #===========================================================================
    # Update
    #===========================================================================

    def update
      if @message_timer > 0
        @message_timer -= 1
      end

      case @mode
      when :commands
        update_commands

      when :moves
        update_moves

      when :bag
        update_bag

      when :pokemon
        update_pokemon

      when :message
        update_message
      end

      refresh_turn
      refresh_hud
    end

    #===========================================================================
    # Message Mode
    #===========================================================================

    def update_message
      if Input.trigger?(Input::USE) ||
         Input.trigger?(Input::BACK)

        @mode = :commands

        message(
          "What will #{@battle.player_pokemon.name} do?"
        )
      end
    end

    #===========================================================================
    # Commands
    #===========================================================================

    def update_commands
      if Input.trigger?(Input::LEFT)

        @command_index -= 1

        if @command_index < 0
          @command_index = 3
        end

        refresh_command_box

      elsif Input.trigger?(Input::RIGHT)

        @command_index += 1

        if @command_index > 3
          @command_index = 0
        end

        refresh_command_box

      elsif Input.trigger?(Input::USE)

        command =
          DeltaruneBattle::COMMANDS[@command_index]

        case command

        when :fight
          open_moves

        when :bag
          open_bag

        when :pokemon
          open_pokemon

        when :run
          @mode = :message

          @battle.execute_run

          message(@battle.message)

          check_end
        end
      end
    end

    #===========================================================================
    # Moves
    #===========================================================================

    def open_moves
      @mode = :moves
      @move_index = 0

      refresh_move_message
    end

    def update_moves
      pokemon = @battle.player_pokemon

      if !pokemon
        @mode = :commands
        return
      end

      moves = pokemon.moves

      count = moves ? moves.length : 0

      if count <= 0
        count = 1
      end

      if Input.trigger?(Input::UP)

        @move_index -= 1

        if @move_index < 0
          @move_index = count - 1
        end

        refresh_move_message

      elsif Input.trigger?(Input::DOWN)

        @move_index += 1

        if @move_index >= count
          @move_index = 0
        end

        refresh_move_message

      elsif Input.trigger?(Input::BACK)

        @mode = :commands

        message(
          "What will #{@battle.player_pokemon.name} do?"
        )

      elsif Input.trigger?(Input::USE)

        @battle.execute_fight(@move_index)

        message(@battle.message)

        check_end
      end
    end

    #===========================================================================
    # Bag
    #===========================================================================

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

        if @bag_index < 0
          @bag_index = @bag_items.length - 1
        end

        refresh_bag_message

      elsif Input.trigger?(Input::DOWN)

        @bag_index += 1

        if @bag_index >= @bag_items.length
          @bag_index = 0
        end

        refresh_bag_message

      elsif Input.trigger?(Input::BACK)

        @mode = :commands

        message(
          "What will #{@battle.player_pokemon.name} do?"
        )

      elsif Input.trigger?(Input::USE)

        item_id = @bag_items[@bag_index]

        @battle.execute_item(item_id)

        message(@battle.message)

        check_end
      end
    end

    #===========================================================================
    # Bag Data
    #
    # GameData::Item is only used as a data source for the battle UI.
    #===========================================================================

    def get_bag_items
      result = []

      return result if !$bag
      return result unless $bag.respond_to?(:quantity)

      GameData::Item.each do |item|
        next if !item

        begin
          if $bag.quantity(item.id) > 0
            result << item.id
          end
        rescue
        end

        break if result.length >= 8
      end

      return result
    end

    #===========================================================================
    # Pokémon Menu
    #===========================================================================

    def open_pokemon
      @mode = :pokemon
      @party_index = 0

      refresh_pokemon_message
    end

    def update_pokemon
      party = @battle.player_party

      if !party || party.empty?
        @mode = :commands
        return
      end

      if Input.trigger?(Input::UP)

        @party_index -= 1

        if @party_index < 0
          @party_index = party.length - 1
        end

        refresh_pokemon_message

      elsif Input.trigger?(Input::DOWN)

        @party_index += 1

        if @party_index >= party.length
          @party_index = 0
        end

        refresh_pokemon_message

      elsif Input.trigger?(Input::BACK)

        @mode = :commands

        message(
          "What will #{@battle.player_pokemon.name} do?"
        )

      elsif Input.trigger?(Input::USE)

        @battle.execute_switch(@party_index)

        message(@battle.message)

        check_end
      end
    end

    #===========================================================================
    # Refresh All
    #===========================================================================

    def refresh_all
      refresh_turn
      refresh_command_box
      refresh_hud

      message(
        "What will #{@battle.player_pokemon.name} do?"
      )
    end

    #===========================================================================
    # Turn Display
    #===========================================================================

    def refresh_turn
      sprite = @sprites["turn"]

      return if !sprite
      return if !sprite.bitmap

      bmp = sprite.bitmap

      bmp.clear

      pbSetSystemFont(bmp)

      bmp.draw_text(
        0,
        0,
        120,
        32,
        "TURN #{@battle.turn}",
        1
      )
    end

    #===========================================================================
    # HUD
    #===========================================================================

    def refresh_hud
      refresh_one_hud(
        "player_hud",
        @battle.player_pokemon
      )

      refresh_one_hud(
        "enemy_hud",
        @battle.enemy_pokemon
      )
    end

    def refresh_one_hud(key, pokemon)
      sprite = @sprites[key]

      return if !sprite
      return if !pokemon
      return if !sprite.bitmap

      bmp = sprite.bitmap

      # Temporary fallback HUD.
      # A proper UI system will eventually move this responsibility into 004_UI.
      if bmp.width <= 300

        pbSetSystemFont(bmp)

        bmp.clear

        bmp.draw_text(
          8,
          8,
          bmp.width - 16,
          24,
          pokemon.name,
          0
        )

        bmp.draw_text(
          8,
          30,
          bmp.width - 16,
          22,
          "Lv. #{pokemon.level}  HP #{pokemon.hp}/#{pokemon.max_hp}",
          0
        )
      end
    end

    #===========================================================================
    # Command Box
    #===========================================================================

    def refresh_command_box
      sprite = @sprites["command_box"]

      return if !sprite

      positions = [
        [20, 396],
        [178, 396],
        [340, 396],
        [500, 396]
      ]

      position = positions[@command_index]

      return if !position

      sprite.x = position[0]
      sprite.y = position[1]
    end

    #===========================================================================
    # Move Message
    #===========================================================================

    def refresh_move_message
      pokemon = @battle.player_pokemon

      return if !pokemon

      moves = pokemon.moves

      if moves && moves[@move_index]

        move = moves[@move_index]

        message(
          "MOVE: #{move.name}   " \
          "(Enter to use / Esc to back)"
        )

      else

        message(
          "No Move   (Enter to use / Esc to back)"
        )
      end
    end

    #===========================================================================
    # Bag Message
    #===========================================================================

    def refresh_bag_message
      item_id = @bag_items[@bag_index]

      return if !item_id

      begin
        item = GameData::Item.get(item_id)

        message(
          "ITEM: #{item.name}   " \
          "(Enter to use / Esc to back)"
        )
      rescue
        message(
          "ITEM   (Enter to use / Esc to back)"
        )
      end
    end

    #===========================================================================
    # Pokémon Message
    #===========================================================================

    def refresh_pokemon_message
      pokemon =
        @battle.player_party[@party_index]

      return if !pokemon

      message(
        "#{pokemon.name}  " \
        "Lv.#{pokemon.level}  " \
        "HP #{pokemon.hp}/#{pokemon.max_hp}"
      )
    end

    #===========================================================================
    # Message Box
    #===========================================================================

    def message(text)
      @message = text.to_s

      sprite = @sprites["textbox"]

      return if !sprite
      return if !sprite.bitmap

      bmp = sprite.bitmap

      bmp.clear

      pbSetSystemFont(bmp)

      bmp.draw_text(
        16,
        10,
        bmp.width - 32,
        bmp.height - 20,
        @message,
        0
      )

      @message_timer = 0
    end

    #===========================================================================
    # Wait
    #===========================================================================

    def wait_for_input
      loop do
        Graphics.update
        Input.update

        break if Input.trigger?(Input::USE)
        break if Input.trigger?(Input::BACK)
      end
    end

    #===========================================================================
    # End Check
    #===========================================================================

    def check_end
      if @battle.result
        return
      end

      @mode = :message

      message(
        @battle.message
      )
    end

    #===========================================================================
    # Pokémon Send Out
    #===========================================================================

    def send_out_player
      update_pokemon_sprite(
        "player_pokemon",
        @battle.player_pokemon,
        true
      )

      animate_send(
        "player_pokemon"
      )

      refresh_hud
    end

    def send_out_enemy
      update_pokemon_sprite(
        "enemy_pokemon",
        @battle.enemy_pokemon,
        false
      )

      animate_send(
        "enemy_pokemon"
      )

      refresh_hud
    end

    #===========================================================================
    # Update Pokémon Sprite
    #
    # This is important because Battle now uses DeltaruneBattle::Pokemon.
    #===========================================================================

    def update_pokemon_sprite(key, pokemon, player_side)
      sprite = @sprites[key]

      return if !sprite

      set_pokemon_bitmap(
        sprite,
        pokemon,
        player_side
      )

      sprite.opacity = 255
    end

    #===========================================================================
    # Send Animation
    #===========================================================================

    def animate_send(key)
      sprite = @sprites[key]

      return if !sprite

      start_x = sprite.x
      start_y = sprite.y + 30

      sprite.x = start_x
      sprite.y = start_y
      sprite.opacity = 0

      frames = DeltaruneBattle::SEND_OUT_FRAMES

      frames = 1 if frames <= 0

      i = 0

      while i < frames

        Graphics.update
        Input.update

        t = i.to_f / frames

        sprite.y =
          (start_y - 30 * t).to_i

        sprite.opacity =
          (255 * t).to_i

        i += 1
      end

      sprite.x = start_x
      sprite.y = start_y - 30
      sprite.opacity = 255
    end

    #===========================================================================
    # Recall
    #===========================================================================

    def recall_player
      sprite = @sprites["player_pokemon"]

      return if !sprite

      frames = DeltaruneBattle::RECALL_FRAMES

      frames = 1 if frames <= 0

      i = 0

      while i < frames

        Graphics.update
        Input.update

        t = i.to_f / frames

        sprite.opacity =
          (255 * (1.0 - t)).to_i

        sprite.y += 1 if i % 3 == 0

        i += 1
      end

      sprite.opacity = 0
    end

    #===========================================================================
    # Defeat
    #===========================================================================

    def enemy_defeat
      animate_defeat(
        "enemy_pokemon"
      )
    end

    def player_defeat
      animate_defeat(
        "player_pokemon"
      )
    end

    def animate_defeat(key)
      sprite = @sprites[key]

      return if !sprite

      frames = DeltaruneBattle::DEFEAT_FRAMES

      frames = 1 if frames <= 0

      i = 0

      while i < frames

        Graphics.update
        Input.update

        sprite.opacity =
          [255 - i * 7, 0].max

        sprite.y += 1 if i % 4 == 0

        i += 1
      end

      sprite.opacity = 0
    end

    #===========================================================================
    # Run Away
    #===========================================================================

    def run_away
      sprite = @sprites["player_trainer"]

      if !sprite || !sprite.bitmap
        sprite = @sprites["player_pokemon"]
      end

      return if !sprite

      frames = DeltaruneBattle::RUN_FRAMES

      frames = 1 if frames <= 0

      i = 0

      while i < frames

        Graphics.update
        Input.update

        sprite.x -= 6

        sprite.opacity =
          [255 - i * 7, 0].max

        i += 1
      end
    end

    #===========================================================================
    # Victory
    #===========================================================================

    def victory
      message("Victory!")

      wait_for_input

      @closed = true
    end

    #===========================================================================
    # Defeat
    #===========================================================================

    def defeat
      message("You lost the battle.")

      wait_for_input

      @closed = true
    end

    #===========================================================================
    # Optional Sprite
    #===========================================================================

    def make_optional_sprite(path, x, y, z)
      sprite = Sprite.new(@viewport)

      begin

        sprite.bitmap = Bitmap.new(path)

      rescue

        sprite.bitmap = Bitmap.new(
          96,
          96
        )

        sprite.bitmap.fill_rect(
          16,
          8,
          64,
          80,
          Color.new(120, 120, 120)
        )
      end

      sprite.x = x
      sprite.y = y
      sprite.z = z

      return sprite
    end

    #===========================================================================
    # Dispose
    #===========================================================================

    def dispose
      @sprites.each_value do |obj|

        next unless obj.is_a?(Sprite)

        if !obj.disposed?
          obj.dispose
        end
      end

      @sprites.clear

      if @viewport &&
         !@viewport.disposed?

        @viewport.dispose
      end

      @viewport = nil
    end

  end
end