# frozen_string_literal: true

require_relative("sub_resource")

module StarkCore
  module Utils
    class Resource < StarkCore::Utils::SubResource
      attr_reader :id
      def initialize(id = nil)
        @id = id
      end
    end
  end
end
