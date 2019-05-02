module Dolly
  module DepracatedDatabase
    Database = Struct.new(:connection) do
      def request *args
        connection.request *args
      end
    end

    def database
      warn "[DEPRECATION] `database` is deprecated.  Please use `connection` instead."
      Database.new(connection)
    end
  end
end
