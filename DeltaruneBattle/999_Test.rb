#===============================================================================
# Deltarune Battle
# 999_Test.rb
#===============================================================================

module DeltaruneBattle
  module Test

    def self.start
      viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)

      background = DeltaruneBattle::BattleBackground.new(viewport)

      trainer = DeltaruneBattle::TrainerVisual.new(
        viewport,
        :player_1
      )

      puts "=============================================="
      puts " DELTARUNE BATTLE - TRAINER TEST"
      puts "=============================================="
      puts "Player ID: #{trainer.player_id}"
      puts "Outfit:    #{trainer.outfit}"
      puts "Estado:    #{trainer.state}"
      puts "=============================================="

      loop do
        Graphics.update
        Input.update

        background.update
        trainer.update

        break if Input.trigger?(Input::BACK)
      end

      trainer.dispose
      background.dispose
      viewport.dispose
    end

  end
end