module Dolly
  class Dolly::CLI

    def initialize(*argv)
      command = argv.shift
      command = command.tr('-', '_') if command
    end

  end
end
