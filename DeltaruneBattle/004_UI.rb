#===============================================================================
# Deltarune Battle - UI
#
# Independent UI helpers.
#
# This file contains presentation objects only.
# It does not use Pokémon Essentials' Battle::Scene.
#===============================================================================

module DeltaruneBattle

  module UI

    #===========================================================================
    # Basic Drawing
    #===========================================================================

    def self.draw_label(bitmap, x, y, width, height, text, align=0)
      return if !bitmap

      pbSetSystemFont(bitmap)

      bitmap.draw_text(
        x,
        y,
        width,
        height,
        text.to_s,
        align
      )
    end

    def self.clear(bitmap)
      return if !bitmap

      bitmap.clear
    end

    def self.fill(bitmap, x, y, width, height, color)
      return if !bitmap

      bitmap.fill_rect(
        x,
        y,
        width,
        height,
        color
      )
    end

    #===========================================================================
    # Text Box
    #===========================================================================

    class TextBox

      attr_reader :sprite
      attr_reader :bitmap

      def initialize(viewport, x, y, width, height)
        @sprite = Sprite.new(viewport)

        @sprite.x = x
        @sprite.y = y

        @bitmap = Bitmap.new(
          width,
          height
        )

        @sprite.bitmap = @bitmap
        @sprite.z = 250
      end

      def text=(value)
        clear

        DeltaruneBattle::UI.draw_label(
          @bitmap,
          12,
          8,
          @bitmap.width - 24,
          @bitmap.height - 16,
          value,
          0
        )
      end

      def clear
        @bitmap.clear
      end

      def visible=(value)
        @sprite.visible = value
      end

      def dispose
        if @sprite &&
           !@sprite.disposed?

          @sprite.dispose
        end

        @sprite = nil
        @bitmap = nil
      end

    end

    #===========================================================================
    # Battle HUD
    #===========================================================================

    class HUD

      attr_reader :sprite
      attr_reader :pokemon

      def initialize(
        viewport,
        x,
        y,
        width=240,
        height=70
      )

        @sprite = Sprite.new(viewport)

        @sprite.x = x
        @sprite.y = y

        @bitmap = Bitmap.new(
          width,
          height
        )

        @sprite.bitmap = @bitmap
        @sprite.z = 200

        @pokemon = nil
      end

      def set_pokemon(pokemon)
        @pokemon = pokemon
        refresh
      end

      def refresh
        return if !@pokemon

        @bitmap.clear

        DeltaruneBattle::UI.draw_label(
          @bitmap,
          8,
          6,
          @bitmap.width - 16,
          22,
          @pokemon.name,
          0
        )

        DeltaruneBattle::UI.draw_label(
          @bitmap,
          8,
          28,
          @bitmap.width - 16,
          18,
          "Lv. #{@pokemon.level}",
          0
        )

        DeltaruneBattle::UI.draw_label(
          @bitmap,
          8,
          46,
          @bitmap.width - 16,
          18,
          "HP #{@pokemon.hp}/#{@pokemon.max_hp}",
          0
        )
      end

      def dispose
        if @sprite &&
           !@sprite.disposed?

          @sprite.dispose
        end

        @sprite = nil
        @bitmap = nil
      end

    end

    #===========================================================================
    # Command Menu
    #===========================================================================

    class CommandMenu

      attr_reader :index

      def initialize(
        viewport,
        x,
        y,
        width=608,
        height=70
      )

        @sprite = Sprite.new(viewport)

        @sprite.x = x
        @sprite.y = y

        @bitmap = Bitmap.new(
          width,
          height
        )

        @sprite.bitmap = @bitmap
        @sprite.z = 150

        @index = 0

        refresh
      end

      def index=(value)
        value = value.to_i

        count = DeltaruneBattle::COMMANDS.length

        return if count <= 0

        while value < 0
          value += count
        end

        while value >= count
          value -= count
        end

        @index = value

        refresh
      end

      def left
        self.index = @index - 1
      end

      def right
        self.index = @index + 1
      end

      def current
        return nil if @index < 0
        return DeltaruneBattle::COMMANDS[@index]
      end

      def refresh
        @bitmap.clear

        commands = DeltaruneBattle::COMMANDS

        i = 0

        while i < commands.length

          command = commands[i]

          if DeltaruneBattle::COMMAND_NAMES &&
             DeltaruneBattle::COMMAND_NAMES[command]

            name =
              DeltaruneBattle::COMMAND_NAMES[command]

          else

            name =
              command.to_s.upcase

          end

          x =
            (i * @bitmap.width / commands.length)

          width =
            @bitmap.width / commands.length

          if i == @index
            name = "> #{name} <"
          end

          DeltaruneBattle::UI.draw_label(
            @bitmap,
            x,
            20,
            width,
            28,
            name,
            1
          )

          i += 1
        end
      end

      def dispose
        if @sprite &&
           !@sprite.disposed?

          @sprite.dispose
        end

        @sprite = nil
        @bitmap = nil
      end

    end

    #===========================================================================
    # Move Menu
    #===========================================================================

    class MoveMenu

      attr_reader :index

      def initialize(viewport, x, y, width=608, height=120)
        @sprite = Sprite.new(viewport)

        @sprite.x = x
        @sprite.y = y

        @bitmap = Bitmap.new(
          width,
          height
        )

        @sprite.bitmap = @bitmap
        @sprite.z = 160

        @index = 0
        @moves = []

        refresh
      end

      def set_moves(moves)
        @moves = moves || []

        @index = 0

        refresh
      end

      def up
        return if @moves.empty?

        @index -= 1

        if @index < 0
          @index = @moves.length - 1
        end

        refresh
      end

      def down
        return if @moves.empty?

        @index += 1

        if @index >= @moves.length
          @index = 0
        end

        refresh
      end

      def current
        return nil if @moves.empty?

        return @moves[@index]
      end

      def refresh
        @bitmap.clear

        if @moves.empty?

          DeltaruneBattle::UI.draw_label(
            @bitmap,
            12,
            12,
            @bitmap.width - 24,
            24,
            "No Moves",
            0
          )

          return
        end

        i = 0

        while i < @moves.length

          move = @moves[i]

          name =
            if move
              move.name.to_s
            else
              "---"
            end

          if i == @index
            name = "> " + name
          end

          DeltaruneBattle::UI.draw_label(
            @bitmap,
            12,
            8 + i * 25,
            @bitmap.width - 24,
            24,
            name,
            0
          )

          i += 1
        end
      end

      def dispose
        if @sprite &&
           !@sprite.disposed?

          @sprite.dispose
        end

        @sprite = nil
        @bitmap = nil
      end

    end

    #===========================================================================
    # Party Menu
    #===========================================================================

    class PartyMenu

      attr_reader :index

      def initialize(viewport, x, y, width=608, height=180)
        @sprite = Sprite.new(viewport)

        @sprite.x = x
        @sprite.y = y

        @bitmap = Bitmap.new(
          width,
          height
        )

        @sprite.bitmap = @bitmap
        @sprite.z = 160

        @party = []
        @index = 0

        refresh
      end

      def set_party(party)
        @party = party || []
        @index = 0

        refresh
      end

      def up
        return if @party.empty?

        @index -= 1

        if @index < 0
          @index = @party.length - 1
        end

        refresh
      end

      def down
        return if @party.empty?

        @index += 1

        if @index >= @party.length
          @index = 0
        end

        refresh
      end

      def current
        return nil if @party.empty?

        return @party[@index]
      end

      def refresh
        @bitmap.clear

        if @party.empty?

          DeltaruneBattle::UI.draw_label(
            @bitmap,
            12,
            12,
            @bitmap.width - 24,
            24,
            "No Pokémon",
            0
          )

          return
        end

        i = 0

        while i < @party.length

          pokemon = @party[i]

          next if !pokemon

          marker =
            if i == @index
              "> "
            else
              "  "
            end

          text =
            marker +
            pokemon.name.to_s +
            "  Lv." +
            pokemon.level.to_s +
            "  HP " +
            pokemon.hp.to_s +
            "/" +
            pokemon.max_hp.to_s

          DeltaruneBattle::UI.draw_label(
            @bitmap,
            12,
            8 + i * 27,
            @bitmap.width - 24,
            25,
            text,
            0
          )

          i += 1
        end
      end

      def dispose
        if @sprite &&
           !@sprite.disposed?

          @sprite.dispose
        end

        @sprite = nil
        @bitmap = nil
      end

    end

  end

end