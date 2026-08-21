#===============================================================================
# Deltarune Battle
# 059_BattleUI.rb
#
# Battle UI principal
#
# Resolução: 512x384
#
# Responsabilidades:
#   - Player Status
#   - Enemy Status
#   - HP dinâmica
#   - Nome
#   - Level
#   - Troca de Pokémon
#   - Pokémon derrotado
#
# A arte visual será adicionada posteriormente pelo usuário.
#===============================================================================

module DeltaruneBattle

  class BattleUI

    SCREEN_WIDTH  = 512
    SCREEN_HEIGHT = 384

    #===========================================================================
    # Posições
    #
    # Ajustaremos depois de você definir exatamente onde desenhou as caixas.
    #===========================================================================

    PLAYER_X = 20
    PLAYER_Y = 235

    ENEMY_X = 292
    ENEMY_Y = 20

    #===========================================================================
    # Dimensões
    #
    # Temporárias.
    # Quando você terminar a arte, podemos substituir pelos valores reais.
    #===========================================================================

    PLAYER_WIDTH  = 220
    PLAYER_HEIGHT = 55

    ENEMY_WIDTH  = 200
    ENEMY_HEIGHT = 55

    #===========================================================================

    def initialize(battle)

      @battle = battle

      @viewport =
        Viewport.new(
          0,
          0,
          Graphics.width,
          Graphics.height
        )

      # A UI fica acima do resto da batalha.

      @viewport.z = 1000

      @player_battler = nil
      @enemy_battler = nil

      @player_box = nil
      @enemy_box = nil

      @command_window = nil
      @message_window = nil

      @last_player_pokemon = nil
      @last_enemy_pokemon = nil

      @disposed = false

      puts "=============================================="
      puts "[Deltarune Battle] BattleUI criada."
      puts "  Resolution: #{Graphics.width}x#{Graphics.height}"
      puts "  UI Z: #{@viewport.z}"
      puts "=============================================="

      find_battlers
      create_status_boxes
      refresh

    end

    #===========================================================================

    def find_battlers

      return if !@battle

      battlers =
        if @battle.respond_to?(:battlers)
          @battle.battlers
        else
          []
        end

      return if !battlers

      #-----------------------------------------------------------------------
      # Primeiro Battler = Player
      # Segundo Battler = Enemy
      #
      # Nesta primeira versão trabalhamos somente com 1x1.
      #-----------------------------------------------------------------------

      @player_battler =
        battlers[0]

      @enemy_battler =
        battlers[1]

      puts "[Deltarune Battle] BattleUI Battlers:"
      puts "  Player: #{@player_battler}"
      puts "  Enemy: #{@enemy_battler}"

    end

    #===========================================================================

    def create_status_boxes

      #-----------------------------------------------------------------------
      # Player
      #-----------------------------------------------------------------------

      @player_box =
        create_box(
          PLAYER_X,
          PLAYER_Y,
          PLAYER_WIDTH,
          PLAYER_HEIGHT
        )

      #-----------------------------------------------------------------------
      # Enemy
      #-----------------------------------------------------------------------

      @enemy_box =
        create_box(
          ENEMY_X,
          ENEMY_Y,
          ENEMY_WIDTH,
          ENEMY_HEIGHT
        )

    end

    #===========================================================================

    def create_box(x, y, width, height)

      sprite =
        Sprite.new(@viewport)

      sprite.x = x
      sprite.y = y

      sprite.z = 10

      sprite.bitmap =
        Bitmap.new(
          width,
          height
        )

      sprite

    end

    #===========================================================================

    # UPDATE
    #===========================================================================

    def update

      return if @disposed

      return if !@battle

      find_battlers

      check_battler_changes

      refresh

    end

    #===========================================================================

    # Verificar troca
    #===========================================================================

    def check_battler_changes

      player_pokemon =
        get_pokemon(
          @player_battler
        )

      enemy_pokemon =
        get_pokemon(
          @enemy_battler
        )

      #-----------------------------------------------------------------------
      # Player mudou de Pokémon
      #-----------------------------------------------------------------------

      if player_pokemon != @last_player_pokemon

        if @last_player_pokemon

          puts "[Deltarune Battle] Player Pokémon mudou."

        end

        @last_player_pokemon =
          player_pokemon

        refresh_player

      end

      #-----------------------------------------------------------------------
      # Enemy mudou de Pokémon
      #-----------------------------------------------------------------------

      if enemy_pokemon != @last_enemy_pokemon

        if @last_enemy_pokemon

          puts "[Deltarune Battle] Enemy Pokémon mudou."

        end

        @last_enemy_pokemon =
          enemy_pokemon

        refresh_enemy

      end

    end

    #===========================================================================

    def get_pokemon(battler)

      return nil if !battler

      if battler.respond_to?(:pokemon)

        return battler.pokemon

      end

      return nil

    end

    #===========================================================================

    # REFRESH GERAL
    #===========================================================================

    def refresh

      refresh_player
      refresh_enemy

    end

    #===========================================================================

    # PLAYER
    #===========================================================================

    def refresh_player

      return if !@player_box

      pokemon =
        get_pokemon(
          @player_battler
        )

      draw_status(
        @player_box,
        pokemon,
        true
      )

    end

    #===========================================================================

    # ENEMY
    #===========================================================================

    def refresh_enemy

      return if !@enemy_box

      pokemon =
        get_pokemon(
          @enemy_battler
        )

      draw_status(
        @enemy_box,
        pokemon,
        false
      )

    end

    #===========================================================================

    # STATUS
    #===========================================================================

    def draw_status(sprite, pokemon, player)

      return if !sprite
      return if !sprite.bitmap

      bitmap =
        sprite.bitmap

      bitmap.clear

      #-----------------------------------------------------------------------
      # Se não existir Pokémon
      #-----------------------------------------------------------------------

      if !pokemon

        bitmap.draw_text(
          0,
          0,
          bitmap.width,
          bitmap.height,
          "",
          1
        )

        return

      end

      #-----------------------------------------------------------------------
      # Dados
      #-----------------------------------------------------------------------

      name =
        pokemon.name.to_s

      level =
        pokemon.level

      hp =
        pokemon.hp

      total_hp =
        pokemon.totalhp

      #-----------------------------------------------------------------------
      # Nome
      #
      # Temporariamente desenhado pelo sistema.
      # Depois podemos remover quando sua arte já tiver o texto.
      #-----------------------------------------------------------------------

      bitmap.draw_text(
        8,
        4,
        bitmap.width - 60,
        22,
        name
      )

      #-----------------------------------------------------------------------
      # Level
      #-----------------------------------------------------------------------

      bitmap.draw_text(
        bitmap.width - 55,
        4,
        50,
        22,
        "Lv.#{level}",
        2
      )

      #-----------------------------------------------------------------------
      # HP
      #-----------------------------------------------------------------------

      draw_hp_bar(
        bitmap,
        pokemon
      )

    end

    #===========================================================================

    def draw_hp_bar(bitmap, pokemon)

      hp =
        pokemon.hp

      total =
        pokemon.totalhp

      return if total <= 0

      ratio =
        hp.to_f / total.to_f

      ratio =
        [[ratio, 0.0].max, 1.0].min

      #-----------------------------------------------------------------------
      # Área temporária da HP bar.
      #
      # Player e Enemy podem ter tamanhos diferentes.
      #-----------------------------------------------------------------------

      width =
        bitmap.width - 20

      height =
        10

      x =
        10

      y =
        bitmap.height - 20

      # Fundo.

      bitmap.fill_rect(
        x,
        y,
        width,
        height,
        Color.new(
          45,
          45,
          45
        )
      )

      current_width =
        (width * ratio).to_i

      if current_width > 0

        bitmap.fill_rect(
          x,
          y,
          current_width,
          height,
          hp_color(ratio)
        )

      end

      #-----------------------------------------------------------------------
      # Texto
      #-----------------------------------------------------------------------

      bitmap.draw_text(
        x,
        y - 5,
        width,
        20,
        "#{hp}/#{total}",
        1
      )

    end

    #===========================================================================

    def hp_color(ratio)

      if ratio <= 0.20

        return Color.new(
          220,
          50,
          50
        )

      elsif ratio <= 0.50

        return Color.new(
          220,
          180,
          40
        )

      end

      return Color.new(
        70,
        210,
        90
      )

    end

    #===========================================================================

    # Comandos
    #
    # Ainda serão ligados à UI gráfica posteriormente.
    #===========================================================================

    def show_commands

      puts "[Deltarune Battle] Mostrar comandos."

    end

    #===========================================================================

    def hide_commands

      puts "[Deltarune Battle] Esconder comandos."

    end

    #===========================================================================

    def show_message(text)

      puts "[Deltarune Battle] Message: #{text}"

    end

    #===========================================================================

    # Acesso aos Battlers
    #===========================================================================

    def player_battler

      @player_battler

    end

    #===========================================================================

    def enemy_battler

      @enemy_battler

    end

    #===========================================================================

    # Viewport
    #===========================================================================

    def viewport

      @viewport

    end

    #===========================================================================

    # Dispose
    #===========================================================================

    def dispose

      return if @disposed

      @disposed = true

      if @player_box

        if @player_box.bitmap
          @player_box.bitmap.dispose
        end

        @player_box.dispose

      end

      if @enemy_box

        if @enemy_box.bitmap
          @enemy_box.bitmap.dispose
        end

        @enemy_box.dispose

      end

      if @viewport &&
         !@viewport.disposed?

        @viewport.dispose

      end

      @player_box = nil
      @enemy_box = nil
      @viewport = nil

    end

  end

end