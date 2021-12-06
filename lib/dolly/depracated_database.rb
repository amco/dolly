module Dolly
  module DepracatedDatabase
    Database = Struct.new(:connection) do
      def request(*args)
        connection.request(*args)
      end

      def post(*args)
        connection.post(*args)
      end
    end

    def view(*args)
      opts = args.pop if args.last.is_a? Hash
      opts ||= {}
      connection.view(*args, opts.merge(include_docs: true))
    end

    def database
      warn "[DEPRECATION] `database` is deprecated.  Please use `connection` instead."
      Database.new(connection)
    end
  end
end
