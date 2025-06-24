require "termbox2"
require "./grid.cr"

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

  class Window
    include Grid

    def height
      Termbox.height
    end

    def width
      Termbox.width
    end

    def print(x, y, object, fg : Termbox::Attribute = Termbox::Color::Default, bg : Termbox::Attribute = Termbox::Color::Default)
      Termbox.print(x, y, fg, bg, object) if @big_enough
    end

    def peek?(timeout : Time::Span) : Termbox::Event::KeyEvent?
      peek?(timeout.total_milliseconds)
    end

    def peek?(timeout = -1) : Termbox::Event::KeyEvent?
      loop do
        case event = Termbox.peek? timeout
        when Termbox::Event::KeyEvent?
          return event unless event.try &.char == 'M'
        when Termbox::Event::ResizeEvent
          refresh
        when Termbox::Event::MouseEvent
          clicked = @children.find { |_, child|
            event.x >= child.x &&
              event.y >= child.y &&
              event.x < child.x + child.width &&
              event.y < child.y + child.height
          }

          return unless clicked

          widget, child = clicked

          if widget.is_a? Scrollable
            if event.button == Termbox::MouseButton::WheelDown
              widget.scroll_down(event.x - child.x, event.y - child.y)
            end
            if event.button == Termbox::MouseButton::WheelUp
              widget.scroll_up(event.x - child.x, event.y - child.y)
            end
          end
        end
      end
    end

    def refresh
      resize
      Termbox.clear
      draw_children
      Termbox.present
    end
  end

  abstract class Widget
    getter parent : Grid

    def initialize(@parent)
    end

    def height
      @parent.height self
    end

    def width
      @parent.width self
    end

    def print(x, y, object, fg : Termbox::Attribute = Termbox::Color::Default, bg : Termbox::Attribute = Termbox::Color::Default)
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
      super width - 2, height - 2, 1, 1
    end

    def draw
      width = width()
      height = height()

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
      @start = @start.clamp(0, Math.max(0, @lines.size - height))

      @lines[@start...(@start + Math.min(@lines.size, height))].each_with_index do |line, i|
        print 0, i, line.[...width]
      end
    end

    def scroll_up(x : Int32, y : Int32)
      @start -= 1
      draw
      Termbox.present
    end

    def scroll_down(x : Int32, y : Int32)
      @start += 1
      draw
      Termbox.present
    end
  end
end
