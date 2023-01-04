# frozen_string_literal: true

module StarkCore
  module Utils
    class Enum
      def values
        list = []
        self.class.constants.each do |constant|
          unless constant[0] == '_' and constant.respond_to?(:call)
            list.push(self.class.const_get(constant))
          end
        end
        return list
      end

      def is_valid
        return values.include?(self)
      end
    end
  end
end
