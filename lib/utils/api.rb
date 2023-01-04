# frozen_string_literal: true

require_relative('case')

module StarkCore
  module Utils
    module API
      def self.build_entity_hash(entity)
        entity_hash = {}
        entity_hash = entity if entity.is_a?(Hash)

        entity.instance_variables.each do |key|
          variable = entity.instance_variable_get(key)
          entity_hash[key[1..-1]] = variable.is_a?(StarkCore::Utils::SubResource) ? build_entity_hash(variable) : entity.instance_variable_get(key)
        end
        return entity_hash
      end

      def self.api_json(entity)
        built_hash = build_entity_hash(entity)
        cast_json_to_api_format(built_hash)
      end

      def self.cast_json_to_api_format(hash)
        entity_hash = {}
        hash.each do |key, value|
          next if value.nil?
          entity_hash[StarkCore::Utils::Case.snake_to_camel(key)] = parse_value(value)
        end
        return entity_hash
      end

      def self.parse_value(value)
        return api_json(value) if value.is_a?(SubResource)
        return value.strftime('%Y-%m-%d') if value.is_a?(Date)
        return value.strftime('%Y-%m-%dT%H:%M:%S+00:00') if value.is_a?(DateTime) || value.is_a?(Time)
        return cast_json_to_api_format(value) if value.is_a?(Hash)
        return value unless value.is_a?(Array)

        list = []
        value.each do |v|
          if v.is_a?(Hash)
            list << cast_json_to_api_format(v)
            next
          end
          if v.is_a?(SubResource)
            list << api_json(v)
            next
          end
          list << v
        end
        return list
      end

      def self.from_api_json(resource_maker, json)
        snakes = {}
        json.each do |key, value|
          snakes[StarkCore::Utils::Case.camel_to_snake(key)] = value
        end

        resource_maker.call(snakes)
      end

      def self.endpoint(resource_name)
        kebab = StarkCore::Utils::Case.camel_to_kebab(resource_name)
        kebab.sub!('-log', '/log')
        kebab.sub!('-attempt', '/attempt')
        return kebab
      end

      def self.last_name_plural(resource_name)
        base = last_name(resource_name)

        return base if base[-1].eql?('s')
        return "#{base}s" if base[-2..-1].eql?('ey')
        return "#{base[0...-1]}ies" if base[-1].eql?('y')

        return "#{base}s"
      end

      def self.last_name(resource_name)
        return StarkCore::Utils::Case.camel_to_kebab(resource_name).split('-').last
      end
    end
  end
end
