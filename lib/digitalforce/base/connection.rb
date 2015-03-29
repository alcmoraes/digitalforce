module Digitalforce
  module Base
    module Connection
      def self.connect(*args)
        Restforce.new *args
      end
    end
  end
end