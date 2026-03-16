module Placer
  module Grid
    class Child
      property char_position : {Int32, Int32} = {0, 0}
      property char_size : {Int32, Int32} = {0, 0}
      property position : {UInt8, UInt8} = {0_u8, 0_u8}
      property size : {UInt8, UInt8} = {1_u8, 1_u8}
      property sticky : Direction = Direction::Center
      property padding : {UInt8, UInt8} = {0_u8, 0_u8}
      property inner_padding : {UInt8, UInt8} = {0_u8, 0_u8}
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

    def size(child : Widget)
      @children[child].char_size
    end

    def print(
      child : Widget, x, y, object,
      fg : Termisu::Color = Termisu::Color::Default,
      bg : Termisu::Color = Termisu::Color::Default,
    )
      child_x, child_y = @children[child].char_position
      print(child_x + x, child_y + y, object, fg, bg)
    end

    abstract def size

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
      padding = {0, 0},
      inner_padding = {0, 0},
      sticky : Direction = Direction::Center,
      visible : Bool = true,
    )
      child = Child.new

      column, row = 0, 0
      column_span, row_span = 1, 1

      if x.is_a? Int
        column = x
      else
        column = x.begin
        column_span = x.size
      end

      if y.is_a? Int
        row = y
      else
        row = y.begin
        row_span = y.size
      end

      child.position = {column.to_u8, row.to_u8}
      child.size = {column_span.to_u8, row_span.to_u8}
      child.padding = {padding[0].to_u8, padding[1].to_u8}
      child.inner_padding = {inner_padding[0].to_u8, inner_padding[1].to_u8}
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
      width : Int32 = size[0].to_i32,
      height : Int32 = size[1].to_i32,
      x_offset : Int32 = 0,
      y_offset : Int32 = 0,
    )
      columns = @children.map(&.[1].position[0]).uniq!.sort!
      min_widths = columns.map { |column| @columns[column]?.try &.min || 1 }
      max_widths = columns.map { |column| @columns[column]?.try &.max || width }
      width_weights = columns.map { |column| @columns[column]?.try &.weight || 1 }

      rows = @children.map(&.[1].position[1]).uniq!.sort!
      min_heights = rows.map { |row| @rows[row]?.try &.min || 1 }
      max_heights = rows.map { |row| @rows[row]?.try &.max || height }
      height_weights = rows.map { |row| @rows[row]?.try &.weight || 1 }

      return unless @big_enough = min_widths.sum <= width && min_heights.sum <= height

      # min-width/-height is diferentiated from extra-width/-height
      # to make sure all min-spaces can be fulfilled whenever possible

      remaining_extra_width = Math.min(width, max_widths.sum) - min_widths.sum
      remaining_width_weight = width_weights.sum

      widths = Hash(UInt8, {Int32, Int32}).new

      columns.zip(min_widths, max_widths, width_weights).map do |column, min, max, weight|
        column_width = Math.min(max, min + (
          (weight / remaining_width_weight) * remaining_extra_width
        ).to_i32)

        widths[column] = {x_offset, column_width}

        remaining_extra_width -= column_width - min
        remaining_width_weight -= weight
        x_offset += column_width
      end

      remaining_extra_height = Math.min(height, max_heights.sum) - min_heights.sum
      remaining_height_weight = height_weights.sum

      heights = Hash(UInt8, {Int32, Int32}).new

      rows.zip(min_heights, max_heights, height_weights).map do |row, min, max, weight|
        row_height = Math.min(max, min + (
          (weight / remaining_height_weight) * remaining_extra_height
        ).to_i32)

        heights[row] = {y_offset, row_height}

        remaining_extra_height -= row_height - min
        remaining_height_weight -= weight
        y_offset += row_height
      end

      @children.each do |widget, child|
        child.char_position = {
          widths[child.position[0]][0],
          heights[child.position[1]][0],
        }

        child.char_size = {
          widths.keys
            .select! { |column| column >= child.position[0] && column < child.position[0] + child.size[0] }
            .sum { |column| widths[column][1] },
          heights.keys
            .select! { |row| row >= child.position[1] && row < child.position[1] + child.size[1] }
            .sum { |row| heights[row][1] },
        }

        widget.resize if widget.responds_to? :resize
      end
    end
  end
end
