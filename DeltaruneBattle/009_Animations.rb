#===============================================================================
# Deltarune Battle - Animation helpers
#===============================================================================
module DeltaruneBattle
  module Animations
    def self.flash(sprite, frames=12)
      return if !sprite
      i = 0
      while i < frames
        Graphics.update
        sprite.visible = !sprite.visible
        i += 1
      end
      sprite.visible = true
    end
  end
end
