#===============================================================================
# Deltarune Battle
# 053_BattlerSprite.rb
#
# Obtém o sprite de batalha diretamente da Battle::Scene do Essentials.
#===============================================================================

module DeltaruneBattle

  module BattlerSprite

    #===========================================================================
    # Criar bitmap
    #===========================================================================

    def self.create_bitmap(battler, side)

      return nil if !battler

      scene = DeltaruneBattle::Integration.scene

      return nil if !scene

      begin

        #-----------------------------------------------------------------------
        # Descobrir o índice do battler dentro da batalha.
        #-----------------------------------------------------------------------

        index = battler.index

        #-----------------------------------------------------------------------
        # O Essentials já criou o BattlerSprite correto.
        #-----------------------------------------------------------------------

        sprites = scene.instance_variable_get(:@sprites)

        return nil if !sprites

        key = "pokemon_#{index}"

        essentials_sprite = sprites[key]

        return nil if !essentials_sprite
        return nil if essentials_sprite.disposed?
        return nil if !essentials_sprite.bitmap

        #-----------------------------------------------------------------------
        # Copiar o bitmap.
        #
        # Não usamos o bitmap original diretamente porque o Essentials
        # continua controlando aquele sprite.
        #-----------------------------------------------------------------------

        bitmap = Bitmap.new(
          essentials_sprite.bitmap.width,
          essentials_sprite.bitmap.height
        )

        bitmap.blt(
          0,
          0,
          essentials_sprite.bitmap,
          essentials_sprite.bitmap.rect
        )

        return bitmap

      rescue Exception => e

        puts "[Deltarune Battle] Erro ao copiar sprite do Essentials."
        puts "  Pokémon: #{battler.pokemon.name}"
        puts "  Side: #{side}"
        puts "  #{e.class}: #{e.message}"

        return nil

      end

    end

  end

end