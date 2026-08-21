#===============================================================================
# Deltarune Battle
# 051_TrainerIntegration.rb
#===============================================================================

module DeltaruneBattle

  module TrainerIntegration

    @trainers = []

    #===========================================================================
    # Criar
    #===========================================================================

    def self.create

      return if @trainers.length > 0

      viewport =
        DeltaruneBattle::Integration.viewport

      return if !viewport

      puts "[Deltarune Battle] Criando TrainerVisuals."

      #-----------------------------------------------------------------------
      # PLAYER 1
      #-----------------------------------------------------------------------

      player =
        DeltaruneBattle::TrainerVisual.new(
          viewport,
          :player_1
        )

      player.play(:neutral)

      @trainers << player

      puts "[Deltarune Battle] Player 1 criado."
      puts "[Deltarune Battle] Outfit: #{player.outfit}"

      #-----------------------------------------------------------------------
      # ENEMY
      #-----------------------------------------------------------------------

      trainer_type =
        get_enemy_trainer_type

      enemy =
        DeltaruneBattle::TrainerVisual.new(
          viewport,
          :enemy_1,
          trainer_type
        )

      enemy.play(:neutral)

      @trainers << enemy

      puts "[Deltarune Battle] Enemy criado."
      puts "[Deltarune Battle] Trainer Class: #{trainer_type}"

    end

    #===========================================================================
    # Obter classe do treinador inimigo
    #===========================================================================

    def self.get_enemy_trainer_type

      battle =
        DeltaruneBattle::Integration.get_battle

      return :RIVAL if !battle

      begin

        trainers = battle.opponent

        if trainers && trainers.length > 0

          trainer = trainers[0]

          if trainer
            return trainer.trainer_type
          end

        end

      rescue Exception => e

        puts "[Deltarune Battle] Erro ao obter TrainerType."
        puts "  #{e.class}: #{e.message}"

      end

      return :RIVAL

    end

    #===========================================================================
    # Update
    #===========================================================================

    def self.update

      @trainers.each do |trainer|
        trainer.update
      end

    end

    #===========================================================================
    # Acesso
    #===========================================================================

    def self.trainers
      @trainers
    end

    #===========================================================================
    # Dispose
    #===========================================================================

    def self.dispose

      @trainers.each do |trainer|
        trainer.dispose
      end

      @trainers.clear

    end

  end

end