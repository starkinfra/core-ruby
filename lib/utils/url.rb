# frozen_string_literal: true

require 'erb'

module StarkCore
  module Utils
    module URL
      # generates query string from hash
      def self.urlencode(params)
        return '' if params.nil?

        params = StarkCore::Utils::API.cast_json_to_api_format(params)
        return '' if params.empty?

        string_params = {}
        params.each do |key, value|
          string_params[key] = value.is_a?(Array) ? value.join(',') : value
        end

        query_list = []
        string_params.each do |key, value|
          query_list << "#{key}=#{ERB::Util.url_encode(value)}"
        end
        return '?' + query_list.join('&')
      end
    end
  end
end
