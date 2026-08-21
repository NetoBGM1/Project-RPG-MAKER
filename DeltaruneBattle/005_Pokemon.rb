#===============================================================================
# Deltarune Battle - Pokémon helpers
#===============================================================================
module DeltaruneBattle
  module PokemonData
    def self.copy_party(party)
      result = []
      party.each { |p| result << p if p && !p.egg? }
      return result
    end
  end
end
