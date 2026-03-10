require "../src/placer.cr"

module Placer
  class Corners < Widget
    def draw
      width, height = size

      print(0, 0, "a")
      print(width - 1, 0, "b")
      print(0, height - 1, "c")
      print(width - 1, height - 1, "d")
    end
  end
end

license = File.read_lines(__DIR__ + "/../LICENSE")

win = Placer::Window.new

begin
  corners = Placer::Corners.new win
  win[0, 0] = corners

  win[1, 0...2] = Placer::Pager.new win, license

  win[0, 1] = label_frame = Placer::LabelFrame.new win, "Label Frame"

  label_frame[0, 0] = Placer::Corners.new label_frame
  label_frame[1, 1] = Placer::Corners.new label_frame
  # label_frame[0, 1] = Placer::Pager.new win, license

  # win.row_configure 0, max: 20

  # win.column_configure 0, weight: 2, min: 15
  # win.column_configure 1, min: 30

  win.refresh

  win.each_event do |event|
    if event.is_a? Termisu::Event::Resize
      win.refresh
    else
      break
    end
  end

  win.close
ensure
  win.close
end
