#===============================================================================
# Deltarune Battle
# 050_BattleIntegration.rb
#===============================================================================

class Battle::Scene

  #=============================================================================
  # Inicialização dos sprites
  #=============================================================================

  alias deltarune_battle_pbInitSprites pbInitSprites

  def pbInitSprites
    deltarune_battle_pbInitSprites

    DeltaruneBattle::Integration.start(self)
  end

  #=============================================================================
  # Atualização gráfica
  #=============================================================================

  alias deltarune_battle_pbGraphicsUpdate pbGraphicsUpdate

  def pbGraphicsUpdate
    deltarune_battle_pbGraphicsUpdate

    DeltaruneBattle::Integration.update
  end

end


#===============================================================================
# Deltarune Battle Integration
#===============================================================================

module DeltaruneBattle

  module Integration

    @scene = nil
    @viewport = nil
    @background = nil
    @started = false

    #===========================================================================
    # Iniciar
    #===========================================================================

    def self.start(scene)

      return if @started
      return if !scene

      @scene = scene

      puts "=============================================="
      puts "[Deltarune Battle] Integration START"
      puts "=============================================="

      #-----------------------------------------------------------------------
      # Viewport
      #-----------------------------------------------------------------------

      create_viewport

      #-----------------------------------------------------------------------
      # Background
      #-----------------------------------------------------------------------

      create_background

      #-----------------------------------------------------------------------
      # Trainers
      #-----------------------------------------------------------------------

      DeltaruneBattle::TrainerIntegration.create

      #-----------------------------------------------------------------------
      # Pokémon
      #-----------------------------------------------------------------------

      DeltaruneBattle::BattlerIntegration.create

      @started = true

      Handlers.trigger(
        :battle_start,
        get_battle,
        self
      )

    end

    #===========================================================================
    # Scene
    #===========================================================================

    def self.scene
      @scene
    end

    #===========================================================================
    # Viewport
    #===========================================================================

    def self.viewport
      @viewport
    end

    #===========================================================================
    # Battle
    #===========================================================================

    def self.get_battle

      return nil if !@scene

      return @scene.instance_variable_get(:@battle)

    end

    #===========================================================================
    # Viewport
    #===========================================================================

    def self.create_viewport

      return if @viewport

      @viewport = Viewport.new(
        0,
        0,
        Graphics.width,
        Graphics.height
      )

      @viewport.z = 100000

      puts "[Deltarune Battle] Viewport criado."

    end

    #===========================================================================
    # Background
    #===========================================================================

    def self.create_background

      return if !@viewport
      return if @background

      @background = DeltaruneBattle::BattleBackground.new(
        @viewport
      )

      puts "[Deltarune Battle] BBS Background criado."

    end

    #===========================================================================
    # Update
    #===========================================================================

    def self.update

      return if !@started

      # Background
      @background.update if @background

      # Trainers
      DeltaruneBattle::TrainerIntegration.update

      # Pokémon
      DeltaruneBattle::BattlerIntegration.update

    end

    #===========================================================================
    # Dispose
    #===========================================================================

    def self.dispose

      return if !@started

      puts "[Deltarune Battle] Integration END"

      # Pokémon
      DeltaruneBattle::BattlerIntegration.dispose

      # Trainers
      DeltaruneBattle::TrainerIntegration.dispose

      # Background
      if @background
        @background.dispose
        @background = nil
      end

      # Viewport
      if @viewport && !@viewport.disposed?
        @viewport.dispose
      end

      @viewport = nil
      @scene = nil
      @started = false

    end

  end

end