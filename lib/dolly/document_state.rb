module Dolly
  module DocumentState
    def save
      write_timestamps(persisted?)
      after_save(self.class.connection.put(id, doc))
    end

    def destroy hard = true
      if hard
        self.class.connection.delete self.class.namespace_key(id), rev
      else
        doc[:_deleted] = true
        save
      end
    end

    def persisted?
      doc['_rev'].present?
    end

    def after_save(response)
      self.rev = response[:rev]
    end
  end
end
