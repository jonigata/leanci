require_relative 'script'

module MyWorker
  def run
    reload
    until @stop
      if @script_source
        Script.new(logger, @script_source)
      else
        sleep 1
      end
    end
  end

  def reload
    begin
      @script_source = nil
      File.open(config[:script]) do |f|
        @script_source = f.read
      end
    rescue
      logger.fatal "can't open script file"
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
