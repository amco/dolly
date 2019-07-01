module Couch
  class Base < Dolly::Document
    extend  ActiveModel::Translation  if defined?(ActiveModel)
    include ActiveModel::Conversion   if defined?(ActiveModel)
    include ActiveModel::Validations  if defined?(ActiveModel)

    LAST_RECORD = '\u9999'.freeze

    property :type, class_name: String

    def save
      set_type if self.type.nil?
      return false if respond_to?(:invalid?) && invalid?
      super
    end

    #TODO: This is needed as the adapter does not handle validations yet, and FactoryBot.create looks for save!
    def save!
      save(validate)
    end

    def update_attributes!(attributes)
      attributes.each(&update_attribute)
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
      find(id)
    rescue Dolly::ResourceNotFound
      nil
    end

    alias_method :to_param, :base_id
    alias_method :write_property, :write_attribute

    def persisted?
      rev.present?
    end

    def self.raw_view(name, options = {})
      design = options.delete(:design)
      connection.get("_design/#{design}/_view/#{name}", options)
    end

    def self.last_record
      LAST_RECORD
    end

    def raw_view(name, options = {})
      self.class.raw_view(name, options)
    end

    def view_value(name, options = {})
      raw_view(name, options).flat_map { |result| result[:value] }
    end

    def reload
      self.doc = self.class.find(id).doc
    end

    def reload_rev!
      return unless persisted?
      rev = connection.get(CGI.escape(id)[:_rev])
    end

    private

    def set_type
      write_property(:type, self.class.name_paramitized)
    end

    def read_property name
      if instance_variable_get(:"@#{name}").nil?
        write_property(name, (doc[name.to_s] || self.properties[name].value))
      end
      instance_variable_get(:"@#{name}")
    end
  end
end
