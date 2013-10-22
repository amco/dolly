require 'forwardable'

module Dolly
  class Dolly::CLI
    extend Forwardable

    HELP = 'Run `dolly generate` to generate view docs'

    def_delegators :generator, :generate

    def initialize(*argv)
      command = argv.shift
      command = command.tr('-', '_') if command

      if command && respond_to?(command) && argv.any?
        send(command, argv)
      elsif command && respond_to?(command)
        send(command)
      else
        puts 'Command not found'
        help
      end
    end

    def generator
      @generator ||= MainGenerator.new
    end

    def help
      puts HELP
    end
  end
end
