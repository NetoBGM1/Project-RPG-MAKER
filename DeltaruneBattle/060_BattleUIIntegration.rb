#===============================================================================
# Deltarune Battle
# 060_BattleUIIntegration.rb
#
# Integra o BattleUI ao BattleController existente.
#===============================================================================

module DeltaruneBattle

  module BattleUIIntegration

    #===========================================================================
    # Criar UI
    #===========================================================================

    def self.create(controller)

      return nil if !controller

      # Evita criar duas UI's.
      existing =
        controller.instance_variable_get(
          :@deltarune_battle_ui
        )

      return existing if existing

      #-----------------------------------------------------------------------
      # Descobrir a Battle
      #-----------------------------------------------------------------------

      battle =
        controller.instance_variable_get(
          :@battle
        )

      # Alguns controllers podem guardar como @battle_scene.
      if !battle

        battle =
          controller.instance_variable_get(
            :@battle_scene
          )

      end

      if !battle

        puts "[Deltarune Battle] BattleUI: battle não encontrada."

        return nil

      end

      #-----------------------------------------------------------------------
      # Criar
      #-----------------------------------------------------------------------

      ui =
        DeltaruneBattle::BattleUI.new(
          battle
        )

      controller.instance_variable_set(
        :@deltarune_battle_ui,
        ui
      )

      puts "[Deltarune Battle] BattleUI conectada ao controller."

      ui

    rescue Exception => e

      puts "[Deltarune Battle] Erro criando BattleUI."
      puts "  #{e.class}: #{e.message}"

      nil

    end

    #===========================================================================

    def self.update(controller)

      return if !controller

      ui =
        controller.instance_variable_get(
          :@deltarune_battle_ui
        )

      return if !ui

      ui.update

    rescue Exception => e

      puts "[Deltarune Battle] Erro atualizando BattleUI."
      puts "  #{e.class}: #{e.message}"

    end

    #===========================================================================

    def self.dispose(controller)

      return if !controller

      ui =
        controller.instance_variable_get(
          :@deltarune_battle_ui
        )

      return if !ui

      ui.dispose

      controller.instance_variable_set(
        :@deltarune_battle_ui,
        nil
      )

      puts "[Deltarune Battle] BattleUI destruída."

    rescue Exception => e

      puts "[Deltarune Battle] Erro destruindo BattleUI."
      puts "  #{e.class}: #{e.message}"

    end

    #===========================================================================

    # Acesso à UI
    #===========================================================================

    def self.ui(controller)

      return nil if !controller

      controller.instance_variable_get(
        :@deltarune_battle_ui
      )

    end

  end

end