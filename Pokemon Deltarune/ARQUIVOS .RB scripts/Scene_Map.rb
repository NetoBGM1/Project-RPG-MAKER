#==============================================================================
# Scene_Map
#==============================================================================

class Scene_Map

  def initialize
    @sprite = nil
  end

  def start
    @sprite = Sprite.new
    @sprite.bitmap = Bitmap.new(200, 100)

    @sprite.bitmap.fill_rect(
      0,
      0,
      200,
      100,
      Color.new(0, 255, 0)
    )

    @sprite.x = 200
    @sprite.y = 150
  end

  def update
  end

  def stop
    return unless @sprite

    @sprite.bitmap.dispose
    @sprite.dispose
    @sprite = nil
  end

end