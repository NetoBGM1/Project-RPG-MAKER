#===============================================================================
# Deltarune Battle - UI Helpers
#===============================================================================
# Kept intentionally small. The Scene owns the UI so that the battle system
# remains independent of Pokémon Essentials' Battle::Scene.
#===============================================================================
module DeltaruneBattle
  module UI
    def self.draw_label(bitmap, x, y, width, height, text, align=0)
      pbSetSystemFont(bitmap)
      bitmap.draw_text(x, y, width, height, text.to_s, align)
    end
  end
end
