module Placer
  VERSION = "0.1.0"
  Log     = ::Log.for("placer")

  module Clickable
    abstract def left_click(x : Int32, y : Int32)
    abstract def middle_click(x : Int32, y : Int32)
    abstract def right_click(x : Int32, y : Int32)
  end

  module Scrollable
    abstract def scroll_up(x : Int32, y : Int32)
    abstract def scroll_down(x : Int32, y : Int32)
  end

  module Draggable
    abstract def start_drag(x : Int32, y : Int32, button : Termbox::MouseButon)
    abstract def move_drag(x : Int32, y : Int32, button : Termbox::MouseButon)
    abstract def end_drag(x : Int32, y : Int32)
  end
end

require "./window"
require "./widget/*"
