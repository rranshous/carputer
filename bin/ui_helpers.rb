require 'ostruct'
require 'pathname'

module Log
  def log msg
    puts "[#{self.class.name}] #{msg}"
  end
end

module Error
  def error msg
    log "error: #{msg}"
    raise "error: #{msg}"
  end
end

module Helpers
  def self.webcams
    Dir['/dev/v4l/by-id/*'].each do |dpath|
      yield OpenStruct.new({
        name: File.basename(dpath),
        path: dpath
      })
    end
  end
end

class Target < Pathname
  def path
    to_s
  end
end

class Recording
  include Log, Error

  attr_accessor :device, :target, :pid

  def initialize device, target
    self.device = device
    self.target = target
  end

  def recording?
    log "checking recording: #{pid}"
    return false if pid.nil?
    Process.getpgid(pid)
    true
  rescue Errno::ESRCH
    false
  end

  def toggle
    log "toggling"
    if recording?
      stop
    else
      log "starting"
      start
    end
  end

  def start
    log "starting: #{command}"
    return false if recording?
    log "spawning"
    self.pid = Process.spawn(command)
    Process.detach pid
    log "spawned: #{pid}"
    return true
  rescue => ex
    error ex
    return false
  end

  def stop
    log "stopping"
    return false if !recording?
    Process.kill("KILL", pid)
    return true
  end

  def command
    "capture_video #{device.path} #{target.path}"
  end

  def inspect
    "<Recording #{device} => #{target}>"
  end

  def to_s
    inspect
  end

  def log msg
    puts "[#{self.class.name}] #{msg}"
  end
end

class Booth
  include Log, Error

  attr_accessor :recordings

  def initialize
    self.recordings = {}
  end

  def register device, target
    recordings[device] = Recording.new(device, target)
  end

  def toggle device
    log "toggling: #{recording(device)}"
    recording(device).toggle
  end

  def recording device
    recordings[device]
  end

  def inspect
    "<Booth #{recordings.values.join(', ')}>"
  end

  def to_s
    inspect
  end
end
