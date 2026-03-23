abstract class Placer::Widget
  getter parent : Grid

  def initialize(@parent)
  end

  def size
    @parent.size self
  end

  def clear
    width, height = size
    height.times do |i|
      print(0, i, " " * width)
    end
  end

  def print(
    x, y, object,
    fg : Termisu::Color = Termisu::Color::Default,
    bg : Termisu::Color = Termisu::Color::Default,
  )
    @parent.print(self, x, y, object, fg, bg)
  end

  abstract def draw
end

require "./widget/*"
