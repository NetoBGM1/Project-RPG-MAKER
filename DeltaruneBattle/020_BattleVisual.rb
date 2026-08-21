#===============================================================================
# Deltarune Battle
# 020_BattleVisual.rb
#===============================================================================

module DeltaruneBattle
  #=============================================================================
  # Battle Background
  #=============================================================================

  class BattleBackground
    #---------------------------------------------------------------------------
    # Inicialização
    #---------------------------------------------------------------------------

    def initialize(viewport)
      @viewport = viewport
      @sprite = Sprite.new(@viewport)

      @frame = 1
      @timer = 0

      load_frame
    end

    #---------------------------------------------------------------------------
    # Carrega o frame atual
    #---------------------------------------------------------------------------

    def load_frame
      dispose_bitmap

      filename = sprintf(
        "%s%s%d",
        DeltaruneBattle::BACKGROUND_PATH,
        DeltaruneBattle::BACKGROUND_FRAME_PREFIX,
        @frame
      )

      @sprite.bitmap = Bitmap.new(filename)

      # Centraliza o background na tela.
      @sprite.x = Graphics.width / 2
      @sprite.y = Graphics.height / 2

      @sprite.ox = @sprite.bitmap.width / 2
      @sprite.oy = @sprite.bitmap.height / 2

      @sprite.z = 0
    end

    #---------------------------------------------------------------------------
    # Atualização
    #---------------------------------------------------------------------------

    def update
      return if !@sprite || @sprite.disposed?

      @timer += 1

      return if @timer < DeltaruneBattle::BACKGROUND_FRAME_DELAY

      @timer = 0
      next_frame
    end

    #---------------------------------------------------------------------------
    # Próximo frame
    #---------------------------------------------------------------------------

    def next_frame
      @frame += 1

      if @frame > DeltaruneBattle::BACKGROUND_FRAME_COUNT
        if DeltaruneBattle::BACKGROUND_LOOP
          @frame = 1
        else
          @frame = DeltaruneBattle::BACKGROUND_FRAME_COUNT
        end
      end

      load_frame
    end

    #---------------------------------------------------------------------------
    # Finalização
    #---------------------------------------------------------------------------

    def dispose
      dispose_bitmap

      if @sprite && !@sprite.disposed?
        @sprite.dispose
      end

      @sprite = nil
      @viewport = nil
    end

    #---------------------------------------------------------------------------
    # Liberar Bitmap
    #---------------------------------------------------------------------------

    def dispose_bitmap
      return if !@sprite
      return if !@sprite.bitmap

      @sprite.bitmap.dispose
      @sprite.bitmap = nil
    end
  end
end