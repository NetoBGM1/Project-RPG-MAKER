#===============================================================================
# Deltarune Battle - Core
#
# Entry point for the independent Deltarune Battle system.
#
# Pokémon Essentials is only used as a source of Pokémon data.
#===============================================================================

module DeltaruneBattle

  @active = false
  @battle = nil

  #=============================================================================
  # State
  #=============================================================================

  def self.active
    return @active
  end

  def self.battle
    return @battle
  end

  #=============================================================================
  # Wild Battle
  #=============================================================================

  def self.start_wild(species, level)

    # IMPORTANT:
    # Explicitly use the Essentials Pokémon class.
    #
    # We do NOT want:
    #
    #   DeltaruneBattle::Pokemon.new(...)
    #
    # here.
    #
    # This object is only the source data. Battle will convert it into
    # DeltaruneBattle::Pokemon.
    begin

      essentials_pokemon =
        ::Pokemon.new(
          species,
          level
        )

    rescue => e

      pbMessage(
        _INTL(
          "Could not create the wild Pokémon.\n" +
          "#{e.class}: #{e.message}"
        )
      )

      return false
    end

    #---------------------------------------------------------------------------
    # Player party
    #---------------------------------------------------------------------------

    player_party = []

    if $player &&
       $player.respond_to?(:party)

      $player.party.each do |pokemon|

        next if !pokemon

        begin
          next if pokemon.egg?
        rescue
        end

        player_party << pokemon
      end
    end

    if player_party.empty?

      pbMessage(
        _INTL(
          "You have no usable Pokémon!"
        )
      )

      return false
    end

    #---------------------------------------------------------------------------
    # Enemy party
    #---------------------------------------------------------------------------

    enemy_party = [
      essentials_pokemon
    ]

    return start(
      player_party,
      enemy_party,
      nil
    )
  end

  #=============================================================================
  # Start Battle
  #=============================================================================

  def self.start(
    player_party,
    enemy_party,
    trainer_name=nil
  )

    return false if @active

    return false if !player_party
    return false if player_party.empty?

    return false if !enemy_party
    return false if enemy_party.empty?

    @active = true

    begin

      @battle =
        DeltaruneBattle::Battle.new(
          player_party,
          enemy_party,
          trainer_name
        )

      @battle.start

    rescue Exception => e

      # Keep the original RPG Maker error system useful.
      raise e

    ensure

      @battle = nil
      @active = false

    end

    return true
  end

end

#===============================================================================
# Script Calls
#===============================================================================

def pbDeltaruneBattle(species, level)

  return DeltaruneBattle.start_wild(
    species,
    level
  )

end

def pbDeltaruneWildBattle(species, level)

  return DeltaruneBattle.start_wild(
    species,
    level
  )

end