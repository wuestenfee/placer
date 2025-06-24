require "../src/placer.cr"
require "termbox2"

module Placer
  class Corners < Widget
    def draw
      print(0, 0, "a")
      print(width - 1, 0, "b")
      print(0, height - 1, "c")
      print(width - 1, height - 1, "d")
    end
  end
end

license = File.read_lines(__DIR__ + "/../LICENSE")

begin
  Termbox.enable
  Termbox.set_input_mode(Termbox::InputMode::Escape | Termbox::InputMode::Mouse)
  Termbox.set_output_mode(Termbox::OutputMode::M256)

  win = Placer::Window.new

  win[0, 0] = Placer::Corners.new win
  win[1, 1] = Placer::Pager.new win, license

  win[0, 1] = label_frame = Placer::LabelFrame.new win, "Awesome Label Frame"

  label_frame[0, 0] = Placer::Corners.new label_frame
  label_frame[1, 1] = Placer::Corners.new label_frame

  win.row_configure 0, max: 20

  win.column_configure 0, weight: 2, min: 15
  win.column_configure 1, min: 30

  win.refresh

  until event = win.peek?
  end
  Termbox.disable

  # It seems we're abandoning `termbox2`, as for some reason `peek?` will return stray KeyEvents when scrolling in the pager.
  pp event
ensure
  Termbox.disable
end
