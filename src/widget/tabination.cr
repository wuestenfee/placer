module Placer
  class Tabination < Widget
    include Container

    class Child < Child
      property title : String?
    end

    @children = {} of Widget => Tabination::Child

    def draw
      clear
      print(2, 0, "this the tabination: " + @children.each_value.map { |child| child.visible? ? "<#{child.title}>" : child.title }.join(" | "))
      print(2, 1, "─" * (size[0] - 4))
      draw_children
    end

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

    def []=(title, widget)
      child = Child.new
      width, height = size
      child.char_position = {0, 2}
      child.char_size = {width, height - 2}
      child.title = title
      child.visible = @children.empty?
      @children[widget] = child
      widget.parent = self
    end

    def [](title : String) : {Widget, Child}?
      @children.find &.[1].title.== title
    end

    def active_tab? : {Widget, Child}?
      @children.find &.[1].visible?
    end

    def active_tab=(widget : Widget)
      active_tab?.try &.[1].visible = false
      @children[widget].visible = true
      draw
    end

    def resize
      width, height = size
      new_size = {width, height - 2}
      @children.each do |widget, child|
        child.char_size = new_size
        widget.resize if widget.responds_to? :resize
      end
    end
  end
end
