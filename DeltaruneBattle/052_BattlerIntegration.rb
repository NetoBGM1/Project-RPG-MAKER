#===============================================================================
# Deltarune Battle
# 052_BattlerIntegration.rb
#===============================================================================

module DeltaruneBattle

  module BattlerIntegration

    @battlers = []

    #===========================================================================

    def self.create

      return if @battlers.length > 0

      scene =
        DeltaruneBattle::Integration.scene

      viewport =
        DeltaruneBattle::Integration.viewport

      return if !scene
      return if !viewport

      battle =
        DeltaruneBattle::Integration.get_battle

      return if !battle
      return if !battle.respond_to?(:battlers)

      puts "=============================================="
      puts "[Deltarune Battle] Criando BattlerVisuals."
      puts "=============================================="

      battle.battlers.each_with_index do |battler, index|

        next if !battler
        next if !battler.pokemon

        side =
          determine_side(index)

        puts "[Deltarune Battle] Battler #{index}"
        puts "  Pokémon: #{battler.pokemon.name}"
        puts "  Species: #{battler.pokemon.species}"
        puts "  Side: #{side}"

        visual =
          DeltaruneBattle::BattlerVisual.new(
            viewport,
            battler,
            side
          )

        visual.play(:hidden)

        @battlers << visual

      end

      #-----------------------------------------------------------------------
      # TESTE TEMPORÁRIO
      #
      # Mostra os Pokémon imediatamente.
      #
      # Isso serve somente para confirmar que:
      #
      # Battle
      #   ↓
      # Battler
      #   ↓
      # BattlerVisual
      #   ↓
      # AnimatedBattler
      #   ↓
      # Graphics/Characters
      #
      # está funcionando.
      #-----------------------------------------------------------------------

      @battlers.each do |visual|

        visual.play(:send_out)

      end

    end

    #===========================================================================

    def self.determine_side(index)

      case index

      when 0
        return :player_1

      when 1
        return :enemy_1

      when 2
        return :player_2

      when 3
        return :enemy_2

      end

      return :enemy_1

    end

    #===========================================================================

    def self.update

      @battlers.each do |visual|

        visual.update

      end

    end

    #===========================================================================

    def self.battlers

      return @battlers

    end

    #===========================================================================

    def self.find_by_battler(battler)

      @battlers.each do |visual|

        return visual if visual.battler == battler

      end

      return nil

    end

    #===========================================================================

    def self.send_out(battler)

      visual =
        find_by_battler(battler)

      return if !visual

      puts "[Deltarune Battle] Send Out:"
      puts "  #{battler.pokemon.name}"

      visual.play(:send_out)

    end

    #===========================================================================

    def self.recall(battler)

      visual =
        find_by_battler(battler)

      return if !visual

      puts "[Deltarune Battle] Recall:"
      puts "  #{battler.pokemon.name}"

      visual.play(:recall)

    end

    #===========================================================================

    def self.dispose

      @battlers.each do |visual|

        visual.dispose

      end

      @battlers.clear

    end

  end

end