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
    flow do
      Helpers.webcams do |webcam|
        button(webcam.name).click do
          puts "button press #{webcam}"
          booth.toggle(webcam)
        end
      end
    end
  end
end

