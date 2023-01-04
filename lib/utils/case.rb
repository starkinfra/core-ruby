# frozen_string_literal: true

module StarkCore
  module Utils
    module Case
      def self.camel_to_snake(camel)
        return camel.to_s.gsub(/([a-z])([A-Z\d])/, '\1_\2').downcase
      end

      def self.snake_to_camel(snake)
        camel = snake.to_s.split('_').map(&:capitalize).join
        camel[0] = camel[0].downcase
        return camel
      end

      def self.camel_to_kebab(camel)
        return camel_to_snake(camel).tr('_', '-')
      end
    end
  end
end
