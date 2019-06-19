require 'dolly/callbacks'

module Couch
  class Base < Dolly::Document
    extend  ActiveModel::Translation
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include Dolly::Callbacks

    LAST_RECORD = '\u9999'.freeze

    def save
      return false if invalid? || run_callbacks(:save) == false
      super
    end

    #TODO: This is needed as the adapter does not handle validations yet, and FactoryBot.create looks for save!
    def save!
      save
    end

    #TODO: use Dolly native update_properties method
    def update_attributes! attributes
      attributes.each do |key, value|
        send(:"#{key}=", value)
      end

      save
    end

    def update_attributes(attributes)
      doc.merge(attributes)
      save
    end

    def base_id
      self.class.base_id(id)
    end

    def self.safe_find(id)
      begin
        find(id)
      rescue Dolly::ResourceNotFound
        nil
      end
    end

    alias_method :to_param, :base_id

    def persisted?
      doc['_rev'].present?
    end

    def self.raw_view(name, options = {})
      design = options.delete(:design)
      design ||= 'av'

      connection.get("_design/#{design}/_view/#{name}", options)
    end

    def self.last_record
      LAST_RECORD
    end

    def raw_view(name, options = {})
      self.class.raw_view(name, options)
    end

    def view_value(name, options = {})
      raw_view(name, options).flat_map { |result| result['value'] }
    end

    def reload
      self.doc = self.class.find(id).doc
    end

    def reload_rev!
      return unless persisted?
      doc['_rev'] = JSON.parse(connection.get CGI.escape(id))['_rev']
    end

    private

    def write_property name, value
      instance_variable_set(:"@#{name}", value)
      @doc[name.to_s] = value
    end

    def read_property name
      if instance_variable_get(:"@#{name}").nil?
        write_property name, (doc[name.to_s] || self.properties[name].value)
      end
      instance_variable_get(:"@#{name}")
    end
  end
end
