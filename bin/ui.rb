#!/usr/bin/env shoes

video_path = "/tmp/1497225056.54754.gpg.mjpg"
puts "Exists?: #{File.exists?(video_path)}"

Shoes.app :width => 408, :height => 346, :resizable => false do
  background "#eee"
  stack :margin => 4 do
    puts "creating video"
    @vid = video "http://oneinchmile.com/tmp/helen.mp4"
    puts "done creatin video"
  end
  para "controls: ",
    link("play")  { @vid.play }, ", ",
    link("pause") { @vid.pause }, ", ",
    link("stop")  { @vid.stop }, ", ",
    link("hide")  { @vid.hide }, ", ",
    link("show")  { @vid.show }, ", ",
    link("+5 sec") { @vid.time += 5000 }
end
