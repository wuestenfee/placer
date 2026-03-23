module Placer
  class Divider < Widget
    def draw
      print(2, 2, "─" * (size[0] - 4))
    end
  end
end
