module Dolly
  class Logger < DelegateClass(::Logger)
    def initialize config
      log_path = config.log_path || $stdout
      logger = ::Logger.new(log_path)
      logger.progname = Dolly.name
      super logger
    end
  end
end
