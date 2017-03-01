module Dolly
  class ProxyDocument < DelegateClass(Hash)
    def initialize hash
      super(hash)
    end
  end
end
