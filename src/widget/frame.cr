module Placer
  class Frame < Widget
    include Grid

    def draw
      draw_children if @big_enough
    end
  end
end

require "./frame/*"
