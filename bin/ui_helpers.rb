require 'ostruct'

module Helpers
  def self.webcams
    Dir['/dev/v4l/by-id/*0'].each do |dpath|
      yield OpenStruct.new({
        name: File.basename(dpath),
        path: dpath
      })
    end
  end
end
