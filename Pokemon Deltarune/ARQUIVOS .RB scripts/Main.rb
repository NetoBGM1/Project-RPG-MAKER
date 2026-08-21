#==============================================================================
# Main
#==============================================================================

Graphics.freeze

AutotileTest.run

$engine = Engine.new
$engine.start

Graphics.transition

loop do
  Graphics.update
  Input.update
  $engine.update
end