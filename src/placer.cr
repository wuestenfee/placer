require "termisu"
require "./grid.cr"
require "uniwidth"

module Placer
  VERSION = "0.1.0"

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

  class Window < Termisu
    include Grid

    def print(x, y, object, fg : Termisu::Color = Termisu::Color::Default, bg : Termisu::Color = Termisu::Color::Default)
      object.each_grapheme do |grapheme|
        grapheme = grapheme.to_s
        set_cell(x, y, grapheme, fg, bg)
        x += UnicodeCharWidth.width(grapheme)
      end
    end

    def refresh
      resize
      clear
      draw_children
      sync
    end
  end

  abstract class Widget
    getter parent : Grid

    def initialize(@parent)
    end

    def size
      @parent.size self
    end

    def print(x, y, object, fg : Termisu::Color = Termisu::Color::Default, bg : Termisu::Color = Termisu::Color::Default)
      @parent.print(self, x, y, object, fg, bg)
    end

    abstract def draw
  end

  class Frame < Widget
    include Grid

    def initialize(@parent)
    end

    def draw
      draw_children if @big_enough
    end
  end

  class LabelFrame < Frame
    property label : String

    def initialize(@parent, @label)
    end

    def resize
      width, height = size
      super width - 2, height - 2, 1, 1
    end

    def draw
      width, height = size

      text =
        if width - 2 < @label.size
          @label[...(width - 2)]
        elsif width - 4 >= @label.size
          " #{@label} "
        else
          @label
        end

      print 0, 0, "┌#{"─" * (width - 2)}┐"
      print 1, 0, text
      print 0, height - 1, "└#{"─" * (width - 2)}┘"

      (height - 2).times do |i|
        print 0, i + 1, "│"
        print width - 1, i + 1, "│"
      end

      draw_children
    end
  end

  class Divider < Widget
    def draw
      width, height = size
      print(2, 2, "─" * (width - 4))
    end
  end

  class Pager < Widget
    include Scrollable

    property lines : Array(String)
    property start = 0

    def initialize(@parent, @lines = [] of String)
    end

    def draw
      width, height = size
      @start = @start.clamp(0, Math.max(0, @lines.size - height))

      @lines[@start...(@start + Math.min(@lines.size, height))].each_with_index do |line, i|
        print 0, i, line.[...width]
      end
    end

    def scroll_up(x : Int32, y : Int32)
      @start -= 1
      draw
    end

    def scroll_down(x : Int32, y : Int32)
      @start += 1
      draw
    end
  end
end
