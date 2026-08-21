#===============================================================================
# Deltarune Battle - Core
#===============================================================================
module DeltaruneBattle
  @active = false
  @battle = nil

  def self.active
    return @active
  end

  def self.battle
    return @battle
  end

  def self.start_wild(species, level)
    pokemon = Pokemon.new(species, level)
    player_party = []
    $player.party.each { |p| player_party << p if p && !p.egg? }

    if player_party.empty?
      pbMessage(_INTL("You have no usable Pokémon!"))
      return false
    end

    enemy_party = [pokemon]
    return start(player_party, enemy_party, nil)
  end

  def self.start(player_party, enemy_party, trainer_name=nil)
    return false if @active
    return false if player_party.nil? || player_party.empty?
    return false if enemy_party.nil? || enemy_party.empty?

    @active = true
    begin
      @battle = DeltaruneBattle::Battle.new(
        player_party,
        enemy_party,
        trainer_name
      )
      @battle.start
    ensure
      @battle = nil
      @active = false
    end
    return true
  end
end

def pbDeltaruneBattle(species, level)
  return DeltaruneBattle.start_wild(species, level)
end

def pbDeltaruneWildBattle(species, level)
  return DeltaruneBattle.start_wild(species, level)
end
