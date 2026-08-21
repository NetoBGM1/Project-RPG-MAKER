#==============================================================================
# SceneManager
#==============================================================================

module SceneManager

  @scene = nil

  def self.goto(scene_class)
    @scene.stop if @scene

    @scene = scene_class.new
    @scene.start
  end

  def self.update
    return unless @scene

    @scene.update
  end

  def self.scene
    @scene
  end

end