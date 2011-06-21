module Pivgeon
  module Token

    def self.included(base)
      base.extend(TokenClassMethods)
    end

    module TokenClassMethods
      def tokenize()
          (class << self; self; end).send(:define_method,"token") do
            self.headers['X-TrackerToken']
          end
          (class << self; self; end).send(:define_method,"token=") do |token|
            self.headers['X-TrackerToken'] = (token ? token : "")
          end
      end
    end

  end
end