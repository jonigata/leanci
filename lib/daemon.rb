module MyWorker
  def run
    reload
    until @stop
      if @script
        @script.doit
      end
      sleep 1
    end
  end

  def reload
    begin
      @script = nil
      File.open(config[:script]) do |f|
        @script = Script::TopLevel.new(logger, f.read)
      end
    rescue => e
      logger.fatal "can't open script file"
      logger.fatal e.to_s
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
