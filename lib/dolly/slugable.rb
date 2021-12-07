module Dolly
  module Slugable
    def self.included(base)
      base.extend(ClassMethods)
    end

    def slug_hash
      slugable_properties.each_with_object(Hash.new) do |property, hsh|
        hsh[property] = self.send(property)
      end.merge(type: self.name_paramitized)
    end

    def slug
      raise unless self.respond_to?(:slugable_properties)
      raise if slugable_properties.none?
      slugable_properties.map do |property|
        self.send(property).to_s
      end.map(&parameterize_item).join('_')
    end

    def set_default_id
      self.id = self.class.namespace_key(slug)
    end

    def slug_callback
      nil
    end

    def callback_cond(condition)
      return condition unless condition.is_a?(Symbol)
      send(condition)
    end

    def parameterize_item
      proc do |msg|
        return msg.parameterize if msg.respond_to?(:parameterize)
        msg
      end
    end

    module ClassMethods
      def set_slug(method, opts = {})
        define_method(:slug_callback) do
          return if opts.key?(:unless) && callback_cond(opts[:unless])
          return if opts.key?(:if) && !callback_cond(opts[:id])
          return unless respond_to?(method)
          method
        end
      end

      def slug(slugable_properties)
        slugable_properties.map do |property|
          property.to_s
        end.map(&:parameterize).join('_')
      end

      def default_id(slug)
        namespace_key(slug)
      end
    end
  end
end
