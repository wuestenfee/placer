module Placer
  class Pager < Widget
    include Scrollable

    LOG = Log.for("placer.pager")

    property lines : Array(String)
    getter start = 0
    @mu : Mutex = Mutex.new

    def initialize(@lines = [] of String)
    end

    def draw
      width, height = size

      @lines[@start...(@start + Math.min(@lines.size, height))].each_with_index do |line, i|
        if line.size < width
          line += " " * (width - line.size)
        elsif line.size > width
          line = line.[...width]
        end
        print 0, i, line
      end
    end

    def start=(start)
      start = start.clamp(0, Math.max(0, @lines.size - size[1]))
      return if @start == start
      draw
      @start = start
    end

    def scroll_up(x : Int32 = 0, y : Int32 = 0)
      @mu.synchronize do
        LOG.debug { "scrolling up" }
        self.start = @start - 1
        LOG.debug { "scrolled up" }
      end
    end

    def scroll_down(x : Int32 = 0, y : Int32 = 0)
      @mu.synchronize do
        LOG.debug { "scrolling down" }
        self.start = @start + 1
        LOG.debug { "scrolled down" }
      end
    end
  end
end
