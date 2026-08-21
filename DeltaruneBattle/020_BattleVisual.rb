#===============================================================================
# Deltarune Battle
# 020_BattleVisual.rb
#===============================================================================

module DeltaruneBattle

  #=============================================================================
  # BACKGROUND
  #=============================================================================

  class BattleBackground

    def initialize(viewport)
      @viewport = viewport
      @sprite = Sprite.new(@viewport)
      @frame = 1
      @timer = 0
      load_frame
    end

    def load_frame
      dispose_bitmap

      filename = sprintf(
        "%s%s%d",
        DeltaruneBattle::BACKGROUND_PATH,
        DeltaruneBattle::BACKGROUND_FRAME_PREFIX,
        @frame
      )

      @sprite.bitmap = Bitmap.new(filename)

      @sprite.x = Graphics.width / 2
      @sprite.y = Graphics.height / 2

      @sprite.ox = @sprite.bitmap.width / 2
      @sprite.oy = @sprite.bitmap.height / 2

      @sprite.z = 0
    end

    def update
      return if !@sprite || @sprite.disposed?

      @timer += 1

      return if @timer < DeltaruneBattle::BACKGROUND_FRAME_DELAY

      @timer = 0
      next_frame
    end

    def next_frame
      @frame += 1

      if @frame > DeltaruneBattle::BACKGROUND_FRAME_COUNT
        @frame = 1 if DeltaruneBattle::BACKGROUND_LOOP
      end

      load_frame
    end

    def dispose
      dispose_bitmap

      if @sprite && !@sprite.disposed?
        @sprite.dispose
      end

      @sprite = nil
      @viewport = nil
    end

    def dispose_bitmap
      return if !@sprite
      return if !@sprite.bitmap

      @sprite.bitmap.dispose
      @sprite.bitmap = nil
    end

  end


  #=============================================================================
  # BATTLE UI
  #=============================================================================

  class BattleUI

    UI_PATH = "Graphics/DeltaruneBattle/UI/"

    BATTLE_UI_PATH     = UI_PATH + "BattleUI"
    POKEMON_STATUS_PATH = UI_PATH + "PokemonStatus"
    MESSAGE_BOX_PATH   = UI_PATH + "MessageBox"
    COMMAND_BOX_PATH   = UI_PATH + "CommandBox"

    #-------------------------------------------------------------------------
    # Z
    #-------------------------------------------------------------------------

    Z_BATTLE_UI      = 200
    Z_STATUS         = 300
    Z_MESSAGE        = 400
    Z_COMMAND        = 500

    #-------------------------------------------------------------------------
    # Inicialização
    #-------------------------------------------------------------------------

    def initialize(viewport, battle)

      @viewport = viewport
      @battle = battle

      @battle_ui = nil
      @pokemon_status = nil
      @message_box = nil
      @command_box = nil

      @message = nil

      @last_player = nil
      @last_enemy = nil

      create

    end

    #-------------------------------------------------------------------------
    # Criar
    #-------------------------------------------------------------------------

    def create

      create_battle_ui
      create_pokemon_status
      create_message_box
      create_command_box

      refresh

    end

    #-------------------------------------------------------------------------
    # BattleUI
    #-------------------------------------------------------------------------

    def create_battle_ui

      @battle_ui = Sprite.new(@viewport)
      @battle_ui.z = Z_BATTLE_UI

      bitmap = load_bitmap(BATTLE_UI_PATH)

      return if !bitmap

      @battle_ui.bitmap = bitmap

      @battle_ui.x = 0
      @battle_ui.y = 0

    end

    #-------------------------------------------------------------------------
    # Pokemon Status
    #-------------------------------------------------------------------------

    def create_pokemon_status

      @pokemon_status = Sprite.new(@viewport)
      @pokemon_status.z = Z_STATUS

      bitmap = load_bitmap(POKEMON_STATUS_PATH)

      return if !bitmap

      @pokemon_status.bitmap = bitmap

      # Fica acima da área inferior da batalha.
      @pokemon_status.x = 12
      @pokemon_status.y = 215

    end

    #-------------------------------------------------------------------------
    # Message Box
    #-------------------------------------------------------------------------

    def create_message_box

      @message_box = Sprite.new(@viewport)
      @message_box.z = Z_MESSAGE

      bitmap = load_bitmap(MESSAGE_BOX_PATH)

      return if !bitmap

      @message_box.bitmap = bitmap

      @message_box.x = 0
      @message_box.y = 250

    end

    #-------------------------------------------------------------------------
    # Command Box
    #-------------------------------------------------------------------------

    def create_command_box

      @command_box = Sprite.new(@viewport)
      @command_box.z = Z_COMMAND

      bitmap = load_bitmap(COMMAND_BOX_PATH)

      return if !bitmap

      @command_box.bitmap = bitmap

      @command_box.x = 0
      @command_box.y = 320

    end

    #=============================================================================
    # UPDATE
    #=============================================================================

    def update

      return if !@battle

      refresh_status
      refresh_message

    end

    #=============================================================================
    # REFRESH
    #=============================================================================

    def refresh

      refresh_status
      refresh_message

    end

    #=============================================================================
    # BATTLE
    #=============================================================================

    def battlers

      return [] if !@battle

      begin
        return @battle.battlers
      rescue
        return []
      end

    end

    #=============================================================================
    # PLAYER
    #=============================================================================

    def player_battler

      list = battlers

      return nil if !list
      return nil if !list[0]

      list[0]

    end

    #=============================================================================
    # ENEMY
    #=============================================================================

    def enemy_battler

      list = battlers

      return nil if !list
      return nil if !list[1]

      list[1]

    end

    #=============================================================================
    # POKEMON
    #=============================================================================

    def pokemon_from_battler(battler)

      return nil if !battler

      begin

        if battler.respond_to?(:pokemon)
          return battler.pokemon
        end

      rescue
      end

      return battler if battler.is_a?(Pokemon)

      nil

    end

    #=============================================================================
    # PLAYER POKEMON
    #=============================================================================

    def player_pokemon

      pokemon_from_battler(
        player_battler
      )

    end

    #=============================================================================
    # ENEMY POKEMON
    #=============================================================================

    def enemy_pokemon

      pokemon_from_battler(
        enemy_battler
      )

    end

    #=============================================================================
    # STATUS
    #=============================================================================

    def refresh_status

      pokemon = player_pokemon

      return if !pokemon
      return if !@pokemon_status
      return if !@pokemon_status.bitmap

      bitmap = @pokemon_status.bitmap

      # Recarrega a arte para remover informações antigas.
      original = load_bitmap(
        POKEMON_STATUS_PATH
      )

      return if !original

      bitmap.clear

      bitmap.blt(
        0,
        0,
        original,
        original.rect
      )

      original.dispose

      #-----------------------------------------------------------------------
      # Nome
      #-----------------------------------------------------------------------

      bitmap.draw_text(
        15,
        5,
        bitmap.width - 100,
        24,
        pokemon.name.to_s
      )

      #-----------------------------------------------------------------------
      # Level
      #-----------------------------------------------------------------------

      bitmap.draw_text(
        bitmap.width - 75,
        5,
        65,
        24,
        "Lv.#{pokemon.level}",
        2
      )

      #-----------------------------------------------------------------------
      # HP
      #-----------------------------------------------------------------------

      draw_hp(
        bitmap,
        pokemon
      )

      @last_player = pokemon

    end

    #=============================================================================
    # HP
    #=============================================================================

    def draw_hp(bitmap, pokemon)

      total = pokemon.totalhp.to_i
      hp = pokemon.hp.to_i

      return if total <= 0

      ratio = hp.to_f / total.to_f

      ratio = 0.0 if ratio < 0.0
      ratio = 1.0 if ratio > 1.0

      bar_x = 15
      bar_y = bitmap.height - 28

      bar_width = bitmap.width - 30
      bar_height = 10

      bitmap.fill_rect(
        bar_x,
        bar_y,
        bar_width,
        bar_height,
        Color.new(35, 35, 35)
      )

      current_width =
        (bar_width * ratio).to_i

      if current_width > 0

        bitmap.fill_rect(
          bar_x,
          bar_y,
          current_width,
          bar_height,
          hp_color(ratio)
        )

      end

      bitmap.draw_text(
        bar_x,
        bar_y - 18,
        bar_width,
        18,
        "#{hp}/#{total}",
        2
      )

    end

    #=============================================================================
    # HP COLOR
    #=============================================================================

    def hp_color(ratio)

      return Color.new(220, 60, 60) if ratio <= 0.20
      return Color.new(220, 180, 50) if ratio <= 0.50

      Color.new(70, 210, 90)

    end

    #=============================================================================
    # MESSAGE
    #=============================================================================

    def refresh_message

      return if !@message_box
      return if !@message_box.bitmap

      pokemon = player_pokemon

      return if !pokemon

      # Enquanto ainda estamos na seleção de comandos.
      #
      # Depois o controller poderá trocar essa mensagem para:
      # "Rival sent out Pikachu!"
      # "Raichu used Thunderbolt!"
      # etc.

      text =
        @message ||
        "What will #{pokemon.name} do?"

      draw_message(
        @message_box.bitmap,
        text
      )

    end

    #=============================================================================
    # SET MESSAGE
    #=============================================================================

    def set_message(text)

      @message = text.to_s

      refresh_message

    end

    #=============================================================================
    # DRAW MESSAGE
    #=============================================================================

    def draw_message(bitmap, text)

      original =
        load_bitmap(
          MESSAGE_BOX_PATH
        )

      return if !original

      bitmap.clear

      bitmap.blt(
        0,
        0,
        original,
        original.rect
      )

      original.dispose

      bitmap.draw_text(
        18,
        10,
        bitmap.width - 36,
        28,
        text,
        0
      )

    end

    #=============================================================================
    # LOAD BITMAP
    #=============================================================================

    def load_bitmap(path)

      begin

        return Bitmap.new(path)

      rescue

        puts "[Deltarune Battle] Não foi possível carregar:"
        puts "  #{path}"

        return nil

      end

    end

    #=============================================================================
    # DISPOSE
    #=============================================================================

    def dispose

      dispose_sprite(@battle_ui)
      dispose_sprite(@pokemon_status)
      dispose_sprite(@message_box)
      dispose_sprite(@command_box)

      @battle_ui = nil
      @pokemon_status = nil
      @message_box = nil
      @command_box = nil

      @viewport = nil
      @battle = nil

    end

    #=============================================================================
    # DISPOSE SPRITE
    #=============================================================================

    def dispose_sprite(sprite)

      return if !sprite

      if sprite.bitmap &&
         !sprite.bitmap.disposed?

        sprite.bitmap.dispose

      end

      sprite.dispose if !sprite.disposed?

    end

  end

end