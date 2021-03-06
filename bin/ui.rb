#!/usr/bin/env shoes

require_relative 'ui_helpers'
require_relative 'ui_objs'

REFRESH_SECS = 4

OUT_PATH = ENV['OUT_PATH']
if OUT_PATH.nil?
  puts "ERROR: missing env var OUT_PATH"
  exit 1
end

def setup_booth
  booth = Booth.new
  target = Target.new OUT_PATH
  puts "target: #{target}"
  Helpers.webcams do |webcam|
    puts "registering: #{webcam}"
    booth.register webcam, target
  end
  booth
end

booth = setup_booth
camera = Camera.new

Shoes.app("camera control", width: 400, height: 450, resizable: false) do
  background "#EEE"
  stack(margin: 3) do
    flow do
      Helpers.webcams do |webcam|
        f = flow do
          b = background yellow
          i = image("notfound").click { booth.toggle(webcam) }
          i.style(height: 200)
          p = para "loading"
          every REFRESH_SECS do
            b.remove
            if booth.recording?(webcam)
              f.prepend { b = background red }
              p.text = "RECORDING"
            else
              f.prepend { b = background green }
              p.text = ""
              camera.snapshot(webcam) do |thumbnail_path|
                i.path = thumbnail_path
              end
            end
          end
        end
      end
    end
  end
end
