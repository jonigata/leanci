module Script
  class Trigger
    def mercurial(repository, &block)
      @crawler = Mercurial.new(@toplevel, repository, &block)
    end
  end

  class Mercurial
    def initialize(toplevel, repository, &block)
      @toplevel = toplevel
      @repository = repository
      @m = 0
      @interval = 5
      instance_eval(&block)
    end

    attr_reader :username, :groupname, :repository, :actiontag
    
    def doit
      @m += 1
      if @interval <= @m
        Dir.chdir(repository) do 
          Bash.new(@toplevel, self) do
            user injection.username
            group injection.groupname
            code <<-EOC
              hg incoming
            EOC
            success(injection) do
              bash(injection) do
                log "hg: pull --update #{injection.repository}"
                user injection.username
                group injection.groupname
                echo true
                code <<-EOC
                  HGENCODING=utf-8 hg pull --update
                EOC
              end
              run injection.actiontag
            end
          end.doit
        end
        @m = 0
      end
    end

    #---------------------------------------------------------------
    # DSL
    def interval(n)
      @interval = n
    end

    def user(username)
      @username = username
    end

    def group(groupname)
      @groupname = groupname
    end

    def action(tag)
      @actiontag = tag
    end
  end  
end
