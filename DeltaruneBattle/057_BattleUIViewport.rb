#===============================================================================
# Deltarune Battle
# 057_BattleUIViewport.rb
#===============================================================================

module DeltaruneBattle

  module BattleUIViewport

    @viewport = nil

    #===========================================================================

    def self.create

      return @viewport if @viewport &&
                          !@viewport.disposed?

      @viewport =
        Viewport.new(
          0,
          0,
          Graphics.width,
          Graphics.height
        )

      #-----------------------------------------------------------------------
      # A UI fica acima do background, Pokémon e treinadores.
      #-----------------------------------------------------------------------

      @viewport.z = 1000

      puts "[Deltarune Battle] UI Viewport criado."
      puts "  Z: #{@viewport.z}"

      @viewport

    end

    #===========================================================================

    def self.viewport

      create

    end

    #===========================================================================

    def self.dispose

      return if !@viewport

      if !@viewport.disposed?

        @viewport.dispose

      end

      @viewport = nil

    end

  end

end