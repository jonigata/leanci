module Script
  class Prog
    def bash(injection = nil, &block)
      @prog.push Bash.new(@toplevel, injection, &block)
    end
  end

  class Bash
    def initialize(toplevel, injection = nil, &block)
      @toplevel = toplevel
      @injection = injection
      instance_eval(&block)
    end

    attr_reader :injection

    def doit
      if @code
        command = nil
        if @user
          if @user == 'root'
            command = "sudo /bin/bash"
          else
            group = @group || @user
            command = "sudo -u #{@user} -g #{group} /bin/bash"
          end
        else
          command = "/bin/bash"
        end

        if exec_code(command) == 0
          @success && @success.doit
        else
          @failure && @failure.doit
        end
      end
    end

    #---------------------------------------------------------------
    # DSL
    def user(s); @user = s end
    def group(s); @group = s end
    def code(s); @code = s end
    def log(s); @log = s end
    def echo(s); @echo = s end

    def success(inj = nil, &block)
      @success = Prog.new(@toplevel, inj, &block)
    end
    def failure(inj = nil, &block)
      @failure = Prog.new(@toplevel, inj, &block)
    end

    private
    def exec_code(cmd)
      logger = @toplevel.logger
      logger.info @log if @log
      logger.info @code.chomp if @echo
      o, e, s = Open3.capture3(cmd, stdin_data: @code)
      logger.info o.chomp if @echo
      logger.info e.chomp if e != ""
      s
    end
  end
end
