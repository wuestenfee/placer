module Placer
  class Frame < Widget
    include Grid

    def initialize(@parent)
    end

    def draw
      draw_children if @big_enough
    end
  end
end

require "./frame/*"
