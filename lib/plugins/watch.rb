# -*- coding: utf-8 -*-
module Script
  class Trigger
    def watch(filename, &block)
      @crawler = Watch.new(@toplevel, filename, &block)
    end
  end

  class Watch
    def initialize(toplevel, filename, &block)
      @toplevel = toplevel
      @filename = filename
      @notifier = INotify::Notifier.new
      instance_eval(&block)
    end

    def doit
      @notifier.to_io.tap do |io|
        rs, = IO.select([io], nil, nil, 0)
        @notifier.process if rs
      end
    end

    #---------------------------------------------------------------
    # DSL
    def modify(&block)
      @modify = Prog.new(@toplevel, &block)
      @notifier.watch(@filename, :modify) do
        @modify.doit
      end
    end
  end
end
