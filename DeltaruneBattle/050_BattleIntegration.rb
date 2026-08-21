#===============================================================================
# Deltarune Battle
# 050_BattleIntegration.rb
#===============================================================================

class Battle::Scene

  alias deltarune_battle_pbInitSprites pbInitSprites

  def pbInitSprites

    deltarune_battle_pbInitSprites

    DeltaruneBattle::Integration.start(self)

  end


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
    @battle_ui = nil

    @started = false

    #===========================================================================
    # START
    #===========================================================================

    def self.start(scene)

      return if @started
      return if !scene

      @scene = scene

      puts "=============================================="
      puts "[Deltarune Battle] Integration START"
      puts "=============================================="

      create_viewport

      create_background

      DeltaruneBattle::TrainerIntegration.create

      DeltaruneBattle::BattlerIntegration.create

      create_battle_ui

      @started = true

      Handlers.trigger(
        :battle_start,
        get_battle,
        self
      )

    end

    #===========================================================================
    # SCENE
    #===========================================================================

    def self.scene
      @scene
    end

    #===========================================================================
    # BATTLE
    #===========================================================================

    def self.get_battle

      return nil if !@scene

      @scene.instance_variable_get(:@battle)

    end

    #===========================================================================
    # VIEWPORT
    #===========================================================================

    def self.viewport

      @viewport

    end

    #===========================================================================
    # CREATE VIEWPORT
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
    # BACKGROUND
    #===========================================================================

    def self.create_background

      return if !@viewport
      return if @background

      @background =
        DeltaruneBattle::BattleBackground.new(
          @viewport
        )

      puts "[Deltarune Battle] Background criado."

    end

    #===========================================================================
    # UI
    #===========================================================================

    def self.create_battle_ui

      return if !@viewport
      return if @battle_ui

      battle = get_battle

      return if !battle

      @battle_ui =
        DeltaruneBattle::BattleUI.new(
          @viewport,
          battle
        )

      puts "[Deltarune Battle] BattleUI criada."

    end

    #===========================================================================
    # BATTLE UI
    #===========================================================================

    def self.battle_ui
      @battle_ui
    end

    #===========================================================================
    # UPDATE
    #===========================================================================

    def self.update

      return if !@started

      @background.update if @background

      DeltaruneBattle::TrainerIntegration.update

      DeltaruneBattle::BattlerIntegration.update

      @battle_ui.update if @battle_ui

    end

    #===========================================================================
    # MESSAGE
    #===========================================================================

    def self.set_message(text)

      return if !@battle_ui

      @battle_ui.set_message(text)

    end

    #===========================================================================
    # DISPOSE
    #===========================================================================

    def self.dispose

      return if !@started

      puts "=============================================="
      puts "[Deltarune Battle] Integration END"
      puts "=============================================="

      if @battle_ui

        @battle_ui.dispose
        @battle_ui = nil

      end

      DeltaruneBattle::BattlerIntegration.dispose

      DeltaruneBattle::TrainerIntegration.dispose

      if @background

        @background.dispose
        @background = nil

      end

      if @viewport &&
         !@viewport.disposed?

        @viewport.dispose

      end

      @viewport = nil
      @scene = nil
      @started = false

    end

  end

end