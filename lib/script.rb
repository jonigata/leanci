require 'open3'

module Script
  class TopLevel
    def initialize(logger, script_source)
      @logger = logger
      @triggers = {}
      @actions = {}
      instance_eval(script_source)
    end

    attr_reader :logger, :triggers, :actions

    def doit
      @triggers.each do |k, t|
        t.doit
      end
    end

    #---------------------------------------------------------------
    # DSL
    def trigger(tag, &block)
      @triggers[tag] = Trigger.new(self, &block)
    end

    def action(tag, &block)
      @actions[tag] = Action.new(self, &block)
    end
  end

  ################################################################
  # in TopLevel
  class Trigger
    def initialize(toplevel, &block)
      @toplevel = toplevel
      instance_eval(&block)
    end

    def doit
      @crawler.doit
    end

    #---------------------------------------------------------------
    # DSL
    def interval(n, &block)
      @crawler = Interval.new(@toplevel, n, &block)
    end
  end

  class Action
    def initialize(toplevel, &block)
      @prog = Prog.new(toplevel, &block)
    end

    def doit
      @prog.doit
    end
  end

  ################################################################
  # in Trigger
  class Interval
    def initialize(toplevel, n, &block)
      @toplevel = toplevel
      @n = n
      @m = 0
      @prog = Prog.new(@toplevel, &block)
    end

    def doit
      @m += 1
      if @m == @n
        @prog.doit
        @m = 0
      end
    end
  end

  ################################################################
  # where procedure required
  class Prog
    def initialize(toplevel, injection = nil, &block)
      @toplevel = toplevel
      @injection = injection
      @prog = []
      instance_eval(&block)
    end

    attr_reader :injection

    def doit
      @prog.each do |p|
        p.doit
      end
    end

    #---------------------------------------------------------------
    # DSL
    def echo(s)
      @prog.push Echo.new(@toplevel, s)
    end

    def run(tag)
      @prog.push Run.new(@toplevel, tag)
    end
  end

  ################################################################
  # in Prog
  class Echo
    def initialize(toplevel, s)
      @toplevel = toplevel
      @s = s
    end

    def doit
      @toplevel.logger.info @s
    end
  end

  class Run
    def initialize(toplevel, tag)
      @toplevel = toplevel
      @tag = tag
    end

    def doit
      @toplevel.actions[@tag].doit
    end
  end
end
