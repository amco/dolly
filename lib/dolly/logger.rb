module Dolly
  class Logger < DelegateClass(::Logger)
    def initialize config
      logger = ::Logger.new(config.log_path)
      logger.progname = Dolly.name
      super logger
    end
  end
end
