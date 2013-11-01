require_relative 'script'

module MyWorker
  def run
    reload
    until @stop
      Script.new(logger, @script_source)
    end
  end

  def reload
    File.open(config[:script]) do |f|
      @script_source = f.read
    end
  end
  
  def stop
    @stop = true
  end
end

def run_daemon(config)
  se = ServerEngine.create(nil, MyWorker, {
      daemonize: true,
      supervisor: true,
      worker_type: 'process',
    }.merge!(config))
  se.run
end
