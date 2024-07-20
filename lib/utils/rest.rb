# frozen_string_literal: true

require_relative('request')
require_relative('api')

module StarkCore
  module Utils
    module Rest
      def self.get_page(resource_name:, resource_maker:, sdk_version:, host:, api_version:, user:, language:, timeout:, **query)
        json = StarkCore::Utils::Request.fetch(
          host: host,
          sdk_version: sdk_version,
          user: user,
          method: 'GET',
          path: StarkCore::Utils::API.endpoint(resource_name),
          query: query,
          api_version: api_version,
          language: language,
          timeout: timeout,
        ).json
        entities = []
        json[StarkCore::Utils::API.last_name_plural(resource_name)].each do |entity_json|
          entities << StarkCore::Utils::API.from_api_json(resource_maker, entity_json)
        end
        return entities, json['cursor']
      end

      def self.get_stream(resource_name:, resource_maker:, sdk_version:, host:, api_version:, user:, language:, timeout:, **query)
        limit = query[:limit]
        query[:limit] = limit.nil? ? limit : [limit, 100].min

        Enumerator.new do |enum|
          loop do
            json = StarkCore::Utils::Request.fetch(
              host: host,
              sdk_version: sdk_version,
              user: user,
              method: 'GET',
              path: StarkCore::Utils::API.endpoint(resource_name),
              query: query,
              api_version: api_version,
              language: language,
              timeout: timeout,
            ).json
            entities = json[StarkCore::Utils::API.last_name_plural(resource_name)]

            entities.each do |entity|
              enum << StarkCore::Utils::API.from_api_json(resource_maker, entity)
            end

            unless limit.nil?
              limit -= 100
              query[:limit] = [limit, 100].min
            end

            cursor = json['cursor']
            query['cursor'] = cursor
            break if cursor.nil? || cursor.empty? || (!limit.nil? && limit <= 0)
          end
        end
      end

      def self.get_id(resource_name:, resource_maker:, sdk_version:, host:, api_version:, user:, id:, language:, timeout:, **query)
        json = StarkCore::Utils::Request.fetch(
          host: host,
          sdk_version: sdk_version,
          user: user,
          method: 'GET',
          path: "#{StarkCore::Utils::API.endpoint(resource_name)}/#{id}",
          query: query,
          api_version: api_version,
          language: language,
          timeout: timeout,
        ).json
        entity = json[StarkCore::Utils::API.last_name(resource_name)]
        return StarkCore::Utils::API.from_api_json(resource_maker, entity)
      end

      def self.get_content(resource_name:, resource_maker:, sdk_version:, host:, api_version:, user:, language:, timeout:, sub_resource_name:, id:, **query)
        return StarkCore::Utils::Request.fetch(
          host: host,
          sdk_version: sdk_version,
          user: user,
          method: 'GET',
          path: "#{StarkCore::Utils::API.endpoint(resource_name)}/#{id}/#{StarkCore::Utils::API.endpoint(sub_resource_name)}",
          query: query,
          api_version: api_version,
          language: language,
          timeout: timeout,
        ).content
      end
      
      def self.get_sub_resource(resource_name:, sub_resource_maker:, sub_resource_name:, sdk_version:, host:, api_version:, user:, language:, timeout:, id:, **query)
        json = StarkCore::Utils::Request.fetch(
          host: host,
          sdk_version: sdk_version,
          user: user,
          method: 'GET',
          path: "#{StarkCore::Utils::API.endpoint(resource_name)}/#{id}/#{StarkCore::Utils::API.endpoint(sub_resource_name)}",
          query: StarkCore::Utils::API.cast_json_to_api_format(query),
          api_version: api_version,
          timeout: timeout,
        ).json
        entity = json[StarkCore::Utils::API.last_name(sub_resource_name)]
        return StarkCore::Utils::API.from_api_json(sub_resource_maker, entity)
      end

      def self.get_sub_resources(resource_name:, sub_resource_maker:, sub_resource_name:, sdk_version:, host:, api_version:, user:, language:, timeout:, id:, **query)
        json = StarkCore::Utils::Request.fetch(
          host: host,
          sdk_version: sdk_version,
          user: user,
          method: 'GET',
          path: "#{StarkCore::Utils::API.endpoint(resource_name)}/#{id}/#{StarkCore::Utils::API.endpoint(sub_resource_name)}",
          query: StarkCore::Utils::API.cast_json_to_api_format(query),
          api_version: api_version,
          timeout: timeout,
        ).json
        returned_jsons = json[StarkCore::Utils::API.last_name_plural(sub_resource_name)]
        entities = []
        returned_jsons.each do |returned_json|
          entities << StarkCore::Utils::API.from_api_json(sub_resource_maker, returned_json)
        end
        return entities
      end

      def self.post(resource_name:, resource_maker:, sdk_version:, host:, api_version:, user:, language:, timeout:, entities:, **query)
        
        jsons = []
        entities.each do |entity|
          jsons << StarkCore::Utils::API.api_json(entity)
        end
        payload = { StarkCore::Utils::API.last_name_plural(resource_name) => jsons }

        json = StarkCore::Utils::Request.fetch(
          host: host,
          sdk_version: sdk_version,
          user: user,
          method: 'POST',
          path: StarkCore::Utils::API.endpoint(resource_name),
          query: query,
          payload: payload,
          api_version: api_version,
          timeout: timeout          
        ).json
        returned_jsons = json[StarkCore::Utils::API.last_name_plural(resource_name)]
        entities = []
        returned_jsons.each do |returned_json|
          entities << StarkCore::Utils::API.from_api_json(resource_maker, returned_json)
        end
        return entities
      end

      def self.post_single(resource_name:, resource_maker:, sdk_version:, host:, api_version:, user:, language:, timeout:, entity:)
        payload = StarkCore::Utils::API.api_json(entity)
        json = StarkCore::Utils::Request.fetch(
          host: host,
          sdk_version: sdk_version,
          user: user,
          method: 'POST',
          path: StarkCore::Utils::API.endpoint(resource_name),
          payload: payload,
          api_version: api_version,
          timeout: timeout
        ).json
        entity_json = json[StarkCore::Utils::API.last_name(resource_name)]
        return StarkCore::Utils::API.from_api_json(resource_maker, entity_json)
      end

      def self.delete_id(resource_name:, resource_maker:, sdk_version:, host:, api_version:, user:, language:, timeout:, id:)
        json = StarkCore::Utils::Request.fetch(
          host: host,
          sdk_version: sdk_version,
          user: user,
          method: 'DELETE',
          path: "#{StarkCore::Utils::API.endpoint(resource_name)}/#{id}",
          api_version: api_version,
          timeout: timeout
        ).json
        entity = json[StarkCore::Utils::API.last_name(resource_name)]
        return StarkCore::Utils::API.from_api_json(resource_maker, entity)
      end

      def self.patch_id(resource_name:, resource_maker:, sdk_version:, host:, api_version:, user:, language:, timeout:, id:, **payload)
        json = StarkCore::Utils::Request.fetch(
          host: host,
          sdk_version: sdk_version,
          user: user,
          method: 'PATCH',
          path: "#{StarkCore::Utils::API.endpoint(resource_name)}/#{id}",
          payload: StarkCore::Utils::API.cast_json_to_api_format(payload),
          api_version: api_version,
          timeout: timeout
        ).json
        entity = json[StarkCore::Utils::API.last_name(resource_name)]
        return StarkCore::Utils::API.from_api_json(resource_maker, entity)
      end

      def self.get_raw(sdk_version:, host:, api_version:, path:, query:, user:, language:, timeout:, prefix:, raiseException:)
        json = StarkCore::Utils::Request.fetch(
          host: host,
          sdk_version: sdk_version,
          user: user,
          method: 'GET',
          path: path,
          query: query,
          api_version: api_version,
          timeout: timeout,
          prefix: prefix,
          raiseException: raiseException
        ).json
        return json
      end

      def self.post_raw(sdk_version:, host:, api_version:, user:, language:, path:, query:, payload:, timeout:, prefix:, raiseException:)
        json =  StarkCore::Utils::Request.fetch(
          host: host,
          sdk_version: sdk_version,
          user: user,
          method: 'POST',
          path: path,
          query: query,
          payload: payload,
          api_version: api_version,
          language: language,
          timeout: timeout,
          prefix: prefix,
          raiseException: raiseException
          ).json
        return json
      end

      def self.patch_raw(sdk_version:, host:, api_version:, user:, language:, path:, query:, payload:, timeout:, prefix:, raiseException:)
        json =  StarkCore::Utils::Request.fetch(
          host: host,
          sdk_version: sdk_version,
          user: user,
          method: 'PATCH',
          path: path,
          query: query,
          payload: payload,
          api_version: api_version,
          language: language,
          timeout: timeout,
          prefix: prefix,
          raiseException: raiseException
          ).json
        return json
      end

      def self.put_raw(sdk_version:, host:, api_version:, user:, language:, path:, query:, payload:, timeout:, prefix:, raiseException:)
        json =  StarkCore::Utils::Request.fetch(
          host: host,
          sdk_version: sdk_version,
          user: user,
          method: 'PUT',
          path: path,
          query: query,
          payload: payload,
          api_version: api_version,
          language: language,
          timeout: timeout,
          prefix: prefix,
          raiseException: raiseException
          ).json
        return json
      end

      def self.delete_raw(sdk_version:, host:, api_version:, user:, language:, path:, query:, timeout:, prefix:, raiseException:)
        json =  StarkCore::Utils::Request.fetch(
          host: host,
          sdk_version: sdk_version,
          user: user,
          method: 'DELETE',
          path: path,
          query: query,
          api_version: api_version,
          language: language,
          timeout: timeout,
          prefix: prefix,
          raiseException: raiseException
          ).json
        return json
      end

    end
  end
end
