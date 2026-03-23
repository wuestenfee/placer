module Placer
  class Window < Termisu
    include Grid

    def print(x, y, object : String, fg : Termisu::Color = Termisu::Color::Default, bg : Termisu::Color = Termisu::Color::Default)
      # object.each_grapheme do |grapheme|
      #   set_cell(x, y, grapheme.to_s, fg, bg)
      #   x += 1
      # end

      @terminal.unbuffered_write(x, y, object)
    end

    def draw
      super
      flush
    end

    def each_event(&)
      super do |event|
        case event
        when Termisu::Event::Resize
          draw
        when Termisu::Event::Mouse
          clicked = @children.find do |_, child|
            x, y = child.char_position
            width, height = child.char_size

            event.x >= x &&
              event.y >= y &&
              event.x < x + width &&
              event.y < y + height
          end

          return event unless clicked

          widget, child = clicked
          x, y = child.char_position
          width, height = child.char_size

          case widget
          when Scrollable
            case event.button
            when .wheel_down?
              widget.scroll_down(event.x - x, event.y - y)
            when .wheel_up?
              widget.scroll_up(event.x - x, event.y - y)
            end
          end
        else
          yield event
        end
      end
    end
  end
end
