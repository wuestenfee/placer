module Placer
  module Container
  end

  abstract class Widget
    getter parent : Container?

    def parent=(parent : Container)
      raise "#{self} already has a parent" if @parent
      @parent = parent
    end

    def size
      @parent.as(Container).size self
    end

    def print(
      x, y, object,
      fg : Termisu::Color = Termisu::Color::Default,
      bg : Termisu::Color = Termisu::Color::Default,
    )
      @parent.as(Container).print(self, x, y, object, fg, bg)
    end

    abstract def draw

    def clear
      # @parent.clear(self)
      width, height = size
      height.times do |i|
        print(0, i, " " * width)
      end
    end
  end

  module Container
    class Child
      property char_position : {Int32, Int32} = {0, 0}
      property char_size : {Int32, Int32} = {0, 0}
      property? visible : Bool = true

      def initialize(@visible = true)
      end
    end

    def children
      @children
    end

    getter? big_enough : Bool = true
    getter? needs_resizing : Bool = true

    abstract def size(widget : Widget) : {Int32, Int32}
    abstract def clear

    delegate :[], :[]?, to: @children

    def size(widget : Widget)
      @children[widget].char_size
    end

    def print(
      child : Widget, x, y, object,
      fg : Termisu::Color = Termisu::Color::Default,
      bg : Termisu::Color = Termisu::Color::Default,
    )
      child_x, child_y = @children[child].char_position
      print(child_x + x, child_y + y, object, fg, bg)
    end

    private def draw_children
      LOG.debug { "drawing children" }
      @children.each do |widget, child|
        widget.draw if child.visible?
      end
    end

    def draw
      resize if @needs_resizing
      draw_children
    end

    abstract def resize
  end
end
