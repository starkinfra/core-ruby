# frozen_string_literal: true

require('date')
require('starkbank-ecdsa')
require_relative('../environment')
require_relative('../user/user')

module StarkCore
  module Utils
    class Checks
      def self.check_environment(environment)
        environments = StarkCore::Environment.constants(false).map { |c| StarkCore::Environment.const_get(c) }
        raise(ArgumentError, "Select a valid environment: #{environments.join(', ')}") unless environments.include?(environment)
        return environment
      end
      
      def self.check_private_key(pem)
        EllipticCurve::PrivateKey.fromPem(pem)
        return pem
      rescue
        raise(ArgumentError, 'Private-key must be a valid secp256k1 ECDSA string in pem format')
      end

      def self.check_user(user)
        return user if user.is_a?(StarkCore::User)
        user = user.nil? ? StarkCore.user : user
        raise(ArgumentError, 'A user is required to access our API. Check our README: https://github.com/starkbank/sdk-ruby/') if user.nil?
        return user
      end

      def self.check_language(language)
        language = language.nil? ? StarkCore.language : language
        accepted_languages = %w[en-US pt-BR]
        raise(ArgumentError, "Select a valid language: #{accepted_languages.join(', ')}") unless accepted_languages.include?(language)
        return language
      end

      def self.check_date_or_datetime(data)
        return if data.nil?

        return data if data.is_a?(Time) || data.is_a?(DateTime)

        return data if data.is_a?(Date)

        data, type = check_datetime_string(data)
        type == 'date' ? Date.new(data.year, data.month, data.day) : data
      end

      def self.check_datetime(data)
        return if data.nil?

        return data if data.is_a?(Time) || data.is_a?(DateTime)

        return Time.new(data.year, data.month, data.day) if data.is_a?(Date)

        data, _type = check_datetime_string(data)
        return data
      end

      def self.check_date(data)
        return if data.nil?

        return Date.new(data.year, data.month, data.day) if data.is_a?(Time) || data.is_a?(DateTime)

        return data if data.is_a?(Date)

        data, type = check_datetime_string(data)

        type == 'date' ? Date.new(data.year, data.month, data.day) : data
      end

      class << self
        private

        def check_datetime_string(data)
          data = data.to_s

          begin
            return [DateTime.strptime(data, '%Y-%m-%dT%H:%M:%S.%L+00:00'), 'datetime']
          rescue ArgumentError
          end

          begin
            return [DateTime.strptime(data, '%Y-%m-%dT%H:%M:%S+00:00'), 'datetime']
          rescue ArgumentError
          end

          begin
            return [DateTime.strptime(data, '%Y-%m-%d'), 'date']
          rescue ArgumentError
            raise(ArgumentError, 'invalid datetime string ' + data)
          end
        end
      end
    end
  end
end
