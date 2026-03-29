require "../src/placer"

license = File.read_lines(__DIR__ + "/../LICENSE")

win = Placer::Window.new

begin
  win.enable_mouse
  corners = Placer::Corners.new win
  win[0, 0] = corners

  win[1, 0...2] = pager = Placer::Pager.new win, license

  win[0, 1] = label_frame = Placer::LabelFrame.new win, "Label Frame"

  label_frame[0, 0] = Placer::Corners.new label_frame
  label_frame[1, 1] = Placer::Corners.new label_frame

  win.row_configure 0, max: 20

  win.column_configure 0, weight: 2, min: 15
  win.column_configure 1, min: 30

  win.draw

  win.each_event do |event|
    case event
    when Termisu::Event::Key
      case event.key
      when .up?
        pager.scroll_up
        win.flush
      when .down?
        pager.scroll_down
        win.flush
      else
        win.close
        pp event
        break
      end
    end
  end
ensure
  win.close
end
