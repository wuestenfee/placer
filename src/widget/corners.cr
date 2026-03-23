module Placer
  class Corners < Widget
    def draw
      width, height = size

      print(0, 0, "┌")
      print(width - 1, 0, "┐")
      print(0, height - 1, "└")
      print(width - 1, height - 1, "┘")
    end
  end
end
