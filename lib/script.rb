require 'open3'

class Bash
  def initialize(logger, &block)
    @logger = logger
    instance_eval(&block)

    if @code 
      if @user
        if @user == 'root'
          exec_code("sudo /bin/bash")
        else
          group = @group || @user
          exec_code("sudo -u #{@user} -g #{group} /bin/bash", stdin_data: @code)
        end
      else
        exec_code("/bin/bash")
      end
      if status == 0
        InnerScript.new(@logger, &@success) if @success
      else
        InnerScript.new(@logger, &@failure) if @failure
      end
    end
  end

  def exec_code(cmd)
    @logger.info @logtext if @logtext
    @logger.info @code.chomp if @echo
    o, e, s = Open3.capture3(cmd, stdin_data: @code)
    @logger.info o.chomp if @echo
    @status = s
  end

  attr_reader :status

  def user(s)
    @user = s
  end

  def group(s)
    @group = s
  end

  def code(s)
    @code = s
  end

  def success(&block)
    @success = block
  end

  def failure(&block)
    @failure = block
  end

  def log(logtext)
    @logtext = logtext
  end

  def echo(flag)
    @echo = flag
  end
end

class InnerScript
  def initialize(logger, &block)
    @logger = logger
    instance_eval(&block)
  end

  def bash(&block)
    Bash.new(@logger, &block).status
  end
end


class Script
  def initialize(logger, script_source)
    @logger = logger
    instance_eval(script_source)
  end

  def per_sec(sec = 1, &block) 
    sleep sec
    instance_eval(&block)
  end

  def bash(&block)
    Bash.new(@logger, &block).status
  end
end
