require "../frame"

module Placer
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

      print 0, 0, "┌#{text + "─" * (width - 2 - text.size)}┐"
      print 0, height - 1, "└#{"─" * (width - 2)}┘"

      (height - 2).times do |i|
        print 0, i + 1, "│"
        print width - 1, i + 1, "│"
      end

      super
    end
  end
end
