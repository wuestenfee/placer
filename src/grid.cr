module Placer
  module Grid
    class Child
      property x : Int32 = 0
      property y : Int32 = 0
      property width : Int32 = 0
      property height : Int32 = 0
      property column : UInt8 = 1_u8
      property row : UInt8 = 1_u8
      property column_span : UInt8 = 1_u8
      property row_span : UInt8 = 1_u8
      property sticky : Direction = Direction::Center
      property padx : UInt8 = 0_u8
      property pady : UInt8 = 0_u8
      property ipadx : UInt8 = 0_u8
      property ipady : UInt8 = 0_u8
      property? visible : Bool = true
    end

    class Dimension
      property weight : Int32
      property min : Int32
      property max : Int32?

      def initialize(@weight, @min, @max)
      end
    end

    enum Direction
      Center
      North
      NorthEast
      East
      SouthEast
      South
      SouthWest
      West
      NorthWest
      NorthSouth
      EastWest
    end

    getter children : Hash(Widget, Child) = {} of Widget => Child
    getter columns = {} of Int32 => Dimension
    getter rows = {} of Int32 => Dimension
    getter? big_enough : Bool = true

    def height(child : Widget)
      @children[child].height
    end

    def width(child : Widget)
      @children[child].width
    end

    def print(
      child : Widget, x, y, object,
      fg : Termbox::Attribute = Termbox::Color::Default,
      bg : Termbox::Attribute = Termbox::Color::Default,
    )
      child_meta = @children[child]
      print(x + child_meta.x, y + child_meta.y, object, fg, bg)
    end

    abstract def width
    abstract def height

    private def draw_children
      @children.each do |widget, _|
        widget.draw
      end
    end

    def draw
      draw_children
    end

    def []=(
      x : Int | Range(Int, Int),
      y : Int | Range(Int, Int),
      widget : Widget,
      padx = 0,
      pady = 0,
      ipadx = 0,
      ipady = 0,
      sticky : Direction = Direction::Center,
      visible : Bool = true,
    )
      child = Child.new

      if x.is_a? Int
        child.column = x.to_u8
      else
        child.column = x.begin
        child.column_span = x.size
      end

      if y.is_a? Int
        child.row = y.to_u8
      else
        child.row = y.begin
        child.row_span = y.size
      end

      child.padx = padx.to_u8
      child.pady = pady.to_u8
      child.ipadx = ipadx.to_u8
      child.ipady = ipady.to_u8
      child.visible = visible
      child.sticky = sticky
      @children[widget] = child
    end

    def row_configure(
      index : Int,
      weight : Int? = nil,
      min : Int? = nil,
      max : Int? = nil,
    )
      if row = @rows[index]?
        row.weight = weight if weight
        row.min = min if min
        row.max = max if max
      else
        @rows[index] = Dimension.new(weight || 1, min || 1, max)
      end
    end

    def column_configure(
      index : Int,
      weight : Int? = nil,
      min : Int? = nil,
      max : Int? = nil,
    )
      if column = @columns[index]?
        column.weight = weight if weight
        column.min = min if min
        column.max = max if max
      else
        @columns[index] = Dimension.new(weight || 1, min || 1, max)
      end
    end

    def resize(
      width : Int32? = nil,
      height : Int32? = nil,
      x_offset : Int32 = 0,
      y_offset : Int32 = 0,
    )
      width ||= width()
      height ||= height()

      columns = @children.map(&.[1].column).uniq!.sort!
      min_widths = columns.map { |column| @columns[column]?.try &.min || 1 }
      max_widths = columns.map { |column| @columns[column]?.try &.max || width }
      width_weights = columns.map { |column| @columns[column]?.try &.weight || 1 }

      rows = @children.map(&.[1].row).uniq!.sort!
      min_heights = rows.map { |row| @rows[row]?.try &.min || 1 }
      max_heights = rows.map { |row| @rows[row]?.try &.max || height }
      height_weights = rows.map { |row| @rows[row]?.try &.weight || 1 }

      return unless @big_enough = min_widths.sum <= width && min_heights.sum <= height

      # min-width/-height is diferentiated from extra-width/-height
      # to make sure all min-spaces can be fulfilled whenever possible

      remaining_extra_width = Math.min(width, max_widths.sum) - min_widths.sum
      remaining_width_weight = width_weights.sum
      widths = columns.zip(min_widths, max_widths, width_weights).map do |column, min, max, weight|
        column_width = Math.min(max, min + ((weight / remaining_width_weight) * remaining_extra_width).to_i32)
        result = {column, {x_offset, column_width}}
        remaining_extra_width -= column_width - min
        remaining_width_weight -= weight
        x_offset += column_width
        result
      end.to_h

      remaining_extra_height = Math.min(height, max_heights.sum) - min_heights.sum
      remaining_height_weight = height_weights.sum
      heights = rows.zip(min_heights, max_heights, height_weights).map do |row, min, max, weight|
        row_height = Math.min(max, min + ((weight / remaining_height_weight) * remaining_extra_height).to_i32)
        result = {row, {y_offset, row_height}}
        remaining_extra_height -= row_height - min
        remaining_height_weight -= weight
        y_offset += row_height
        result
      end.to_h

      # TODO: implement row-/column-spans
      @children.each do |widget, child|
        child.x, child.width = widths[child.column]
        child.y, child.height = heights[child.row]

        widget.resize if widget.responds_to? :resize
      end
    end
  end
end
