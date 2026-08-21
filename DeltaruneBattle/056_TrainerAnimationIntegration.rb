#===============================================================================
# Deltarune Battle
# 056_TrainerAnimationIntegration.rb
#
# Conecta automaticamente o TrainerAnimation aos TrainerVisuals existentes.
#===============================================================================

module DeltaruneBattle

  module TrainerAnimationIntegration

    @attached = []

    #===========================================================================

    def self.update_all

      return if !defined?(DeltaruneBattle::TrainerVisual)

      visuals =
        ObjectSpace.each_object(
          DeltaruneBattle::TrainerVisual
        ).to_a

      visuals.each do |visual|

        attach(visual)
        update(visual)

      end

    rescue Exception => e

      puts "[Deltarune Battle] Erro no update das animações."
      puts "  #{e.class}: #{e.message}"

    end

    #===========================================================================

    def self.attach(trainer_visual)

      return if !trainer_visual

      animation =
        trainer_visual.instance_variable_get(
          :@deltarune_animation
        )

      # Já conectado.
      return animation if animation

      viewport =
        trainer_visual.instance_variable_get(
          :@viewport
        )

      filename =
        trainer_visual.instance_variable_get(
          :@filename
        )

      #-----------------------------------------------------------------------
      # Alguns TrainerVisual podem utilizar outro nome para o arquivo.
      #-----------------------------------------------------------------------

      if !filename

        filename =
          trainer_visual.instance_variable_get(
            :@path
          )

      end

      return if !viewport
      return if !filename

      puts "[Deltarune Battle] Conectando animação ao treinador."
      puts "  Path: #{filename}"

      animation =
        DeltaruneBattle::TrainerAnimation.new(
          viewport,
          filename
        )

      trainer_visual.instance_variable_set(
        :@deltarune_animation,
        animation
      )

      #-----------------------------------------------------------------------
      # Determinar lado
      #-----------------------------------------------------------------------

      side =
        trainer_visual.instance_variable_get(
          :@side
        )

      if side == :player ||
         side == :player_1

        animation.face_right

      else

        animation.face_left

      end

      animation.idle
      animation.show

      puts "[Deltarune Battle] TrainerAnimation ativo."
      puts "  Side: #{side}"

      animation

    rescue Exception => e

      puts "[Deltarune Battle] Falha ao conectar TrainerAnimation."
      puts "  #{e.class}: #{e.message}"

      nil

    end

    #===========================================================================

    def self.update(trainer_visual)

      animation =
        trainer_visual.instance_variable_get(
          :@deltarune_animation
        )

      return if !animation

      animation.update

    end

    #===========================================================================

    def self.send_out(trainer_visual)

      animation =
        trainer_visual.instance_variable_get(
          :@deltarune_animation
        )

      return if !animation

      animation.send_out

    end

    #===========================================================================

    def self.idle(trainer_visual)

      animation =
        trainer_visual.instance_variable_get(
          :@deltarune_animation
        )

      return if !animation

      animation.idle

    end

    #===========================================================================

    def self.switch_pokemon(trainer_visual)

      animation =
        trainer_visual.instance_variable_get(
          :@deltarune_animation
        )

      return if !animation

      animation.start_switch

    end

    #===========================================================================

    def self.bag(trainer_visual)

      animation =
        trainer_visual.instance_variable_get(
          :@deltarune_animation
        )

      return if !animation

      animation.start_bag

    end

    #===========================================================================

    def self.item(trainer_visual)

      animation =
        trainer_visual.instance_variable_get(
          :@deltarune_animation
        )

      return if !animation

      animation.start_item

    end

    #===========================================================================

    def self.run(trainer_visual)

      animation =
        trainer_visual.instance_variable_get(
          :@deltarune_animation
        )

      return if !animation

      animation.start_run

    end

    #===========================================================================

    def self.dispose(trainer_visual)

      animation =
        trainer_visual.instance_variable_get(
          :@deltarune_animation
        )

      return if !animation

      animation.dispose

      trainer_visual.instance_variable_set(
        :@deltarune_animation,
        nil
      )

    end

  end

end