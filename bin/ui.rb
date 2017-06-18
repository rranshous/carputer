#!/usr/bin/env shoes

require_relative 'ui_helpers'
require_relative 'ui_objs'

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

Shoes.app do
  background "#EEE"
  stack(margin: 12) do
    Helpers.webcams do |webcam|
      f = flow do
        b = button(webcam.name).click { booth.toggle(webcam) }
        p = para "status"
        i = image "notfound"
        every 1 do
          if booth.recording?(webcam)
            p.text = "status: recording"
            #f.background red
          else
            p.text = "status: --"
            #f.background green
          end
        end
        every 5 do
          if !booth.recording?(webcam)
            camera.snapshot(webcam) do |thumbnail_path|
              i.path = thumbnail_path
            end
          end
        end
      end
    end
  end
end
