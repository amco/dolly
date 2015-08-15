class BaseDolly < Dolly::Document; end

class BarFoo < BaseDolly
  property :a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :n, :persist
end

class FooBar < BaseDolly
  property :foo, :bar
  property :with_default, default: 1
  property :boolean, class_name: TrueClass, default: true
  property :date, class_name: Date
  property :time, class_name: Time
  property :datetime, class_name: DateTime
  property :is_nil, class_name: NilClass, default: nil

  timestamps!
end

class Baz < Dolly::Document; end

class FooBaz < Dolly::Document
  property :foo, class_name: Hash, default: {}

  def add_to_foo key, value
    foo[key] ||= value
    save!
  end
end

class WithTime < Dolly::Document
  property :created_at
end

class TestFoo < Dolly::Document
  property :default_test_property, class_name: String, default: 'FOO'
end

class ObjectWithValid < Dolly::Document
  property :foo

  def valid?
    foo.present?
  end
end
