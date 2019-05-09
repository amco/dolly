module Dolly
  module ClassMethodsDelegation
    def connection
      self.class.connection
    end

    def property_clean_doc(doc)
      self.class.property_clean_doc(doc)
    end

    def database
      self.class.database
    end
  end
end
