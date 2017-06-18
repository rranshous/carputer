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
    log "is recording"
    true
  rescue Errno::ESRCH
    log "not recording"
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
    # spawn in to it's own process group
    self.pid = Process.spawn(command, pgroup: true)
    Process.detach pid
    log "spawned: #{pid}"
    return true
  rescue => ex
    error ex
    return false
  end

  def stop
    log "stop"
    return false if !recording?
    log "stopping"
    # negative signal applies to pgroup
    Process.kill "-SIGKILL", pid
    Process.wait pid
    log "still recording? #{recording?}"
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

  def recording? device
    log "checking recording"
    recording(device).recording?
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

class Camera
  include Log, Error

  def snapshot device
    log "snapshot: #{device}"
    temp do |tmp_path|
      jpg_path = "#{tmp_path}.jpeg"
      pid = Process.spawn command(device, jpg_path)
      Process.wait(pid)
      yield jpg_path
    end
  end

  def command device, out_path
    "streamer -c #{device.path} -o #{out_path}"
  end

  def temp
    Dir.mktmpdir do |path|
      log "temp dir path: #{path}"
      yield File.join(path, Time.now.to_f.to_s)
    end
  end
end
