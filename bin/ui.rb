#!/usr/bin/env shoes

require_relative 'ui_helpers'
require_relative 'ui_objs'

OUT_PATH = ENV['OUT_PATH']

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

Shoes.app do
  background "#EEE"
  stack(margin: 12) do
    Helpers.webcams do |webcam|
      f = flow do
        b = button(webcam.name).click { booth.toggle(webcam) }
        p = para "status"
        every 1 do
          if booth.recording?(webcam)
            p.text = "status: recording"
            b.background red
          else
            p.text = "status: --"
            b.background green
          end
        end
      end
    end
  end
end

