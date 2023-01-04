# frozen_string_literal: true

require('json')
require('starkbank-ecdsa')
require_relative('api')
require_relative('cache')
require_relative('request')
require_relative('../error')

module StarkCore
  module Utils
    module Parse
      def self.parse_and_verify(content:, signature:, sdk_version:, api_version:, 
                                host:, resource: nil, user:, language:, timeout:, key: nil)
        content = verify(content: content, signature: signature, sdk_version: sdk_version, 
                          api_version: api_version, host: host, user: user, language: language, 
                          timeout: timeout)
        json = JSON.parse(content)
        json = JSON.parse(content)[key] unless key.nil?

        StarkCore::Utils::API.from_api_json(resource[:resource_maker], json)
      end

      def self.verify(content:, signature:, sdk_version:, api_version:, host:, 
                      user:, language:, timeout:)
        begin
          signature = EllipticCurve::Signature.fromBase64(signature)
        rescue
          raise(StarkCore::Error::InvalidSignatureError, 'The provided signature is not valid')
        end

        if verify_signature(content: content, signature: signature, sdk_version: sdk_version, 
                            host: host, api_version: api_version, user: user, 
                            language: language, timeout: timeout)
          return content
        end

        if verify_signature(content: content, signature: signature, sdk_version: sdk_version, 
                            host: host, api_version: api_version, user: user, 
                            language: language, timeout: timeout, refresh: true)
          return content
        end

        raise(StarkCore::Error::InvalidSignatureError, 'The provided signature and content do not match the Stark bank public key')
      end

      def self.verify_signature(content:, signature:, sdk_version:, host:, api_version:,
                                user:, language:, timeout:, refresh: false)
        public_key = get_public_key_pem(
          sdk_version: sdk_version,
          host: host,
          api_version: api_version,
          user: user,
          language: language,
          timeout: timeout,
          refresh: refresh
        )
        return EllipticCurve::Ecdsa.verify(content, signature, public_key)
      end

      def self.get_public_key_pem(sdk_version:, host:, api_version:, user:, language:, timeout:, refresh: false, **query)
        public_key = StarkCore::Utils::Cache.starkbank_public_key
        return public_key unless (public_key.nil? || refresh)

        pem = StarkCore::Utils::Rest.get_raw(
          sdk_version: sdk_version,
          host: host,
          api_version: api_version,
          path: "public-key",
          user: user,
          language: language,
          timeout: timeout,
          limit: 1
        )['publicKeys'][0]['content']
        public_key = EllipticCurve::PublicKey.fromPem(pem)
        StarkCore::Utils::Cache.starkbank_public_key = public_key
        return public_key
      end
    end
  end
end
