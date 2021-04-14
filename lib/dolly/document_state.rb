require 'dolly/class_methods_delegation'

module Dolly
  module DocumentState
    include ClassMethodsDelegation

    def save(options = {})
      return false unless options[:validate] == false || valid?
      set_type if typed? && type.nil?
      write_timestamps(persisted?)
      after_save(connection.put(id, doc))
    end

    def save!
      raise DocumentInvalidError unless valid?
      save
    end

    def update_properties(properties)
      properties.deep_symbolize_keys.each(&update_attribute)
    end

    def update_properties!(properties)
      update_properties(properties)
      save!
    end

    def destroy is_hard = true
      return connection.delete(id, rev) if is_hard
      doc[:_deleted] = true
      save
    rescue Dolly::ResourceNotFound
      nil
    rescue Dolly::ServerError => error
      raise error unless error.message =~ /conflict/
      self.rev = self.class.safe_find(id)&.rev
      return unless self.rev
      destroy(is_hard)
    end

    def reload
      reloaded_doc = self.class.find(id).send(:doc)
      attributes   = property_clean_doc(reloaded_doc)

      attributes.each(&update_attribute)
    end

    def persisted?
      return false unless doc[:_rev]
      !doc[:_rev].empty?
    end

    def to_h
      doc
    end

    def valid?
      true
    end

    def after_save(response)
      self.rev = response[:rev]
      response[:ok]
    end
  end
end
