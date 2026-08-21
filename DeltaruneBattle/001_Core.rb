#===============================================================================
# Deltarune Battle - Core
#
# Entry point for the independent Deltarune Battle system.
#
# Pokémon Essentials is used only as a data/resource provider.
# This system does NOT use Battle::Battle.
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

    # Create OUR battle Pokémon.
    #
    # Do not use:
    #   Pokemon.new(...)
    #
    # because Pokémon Essentials also defines Pokemon.
    pokemon =
      DeltaruneBattle::Pokemon.new(
        species,
        level
      )

    #---------------------------------------------------------------------------
    # Player Party
    #---------------------------------------------------------------------------

    player_party = []

    if $player &&
       $player.respond_to?(:party)

      $player.party.each do |pokemon|

        next if !pokemon

        if pokemon.respond_to?(:egg?) &&
           pokemon.egg?

          next
        end

        player_party << pokemon
      end

    end

    #---------------------------------------------------------------------------
    # Validate Player Party
    #---------------------------------------------------------------------------

    if player_party.empty?

      pbMessage(
        _INTL("You have no usable Pokémon!")
      )

      return false
    end

    #---------------------------------------------------------------------------
    # Enemy Party
    #---------------------------------------------------------------------------

    enemy_party = [
      pokemon
    ]

    #---------------------------------------------------------------------------
    # Start Battle
    #---------------------------------------------------------------------------

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

    #---------------------------------------------------------------------------
    # Prevent Nested Battles
    #---------------------------------------------------------------------------

    return false if @active

    #---------------------------------------------------------------------------
    # Validate Parties
    #---------------------------------------------------------------------------

    return false if !player_party
    return false if player_party.empty?

    return false if !enemy_party
    return false if enemy_party.empty?

    #---------------------------------------------------------------------------
    # Activate
    #---------------------------------------------------------------------------

    @active = true

    begin

      #-----------------------------------------------------------------------
      # Create OUR Battle Controller
      #-----------------------------------------------------------------------

      @battle =
        DeltaruneBattle::Battle.new(
          player_party,
          enemy_party,
          trainer_name
        )

      #-----------------------------------------------------------------------
      # Start Battle Scene
      #-----------------------------------------------------------------------

      @battle.start

    ensure

      #-----------------------------------------------------------------------
      # Always Clean Up
      #-----------------------------------------------------------------------

      @battle = nil
      @active = false

    end

    return true
  end

end


#===============================================================================
# Script Entry Points
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