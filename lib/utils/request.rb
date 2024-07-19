# frozen_string_literal: true

require('json')
require('starkbank-ecdsa')
require('net/http')
require_relative('url')
require_relative('checks')
require_relative('../error')

module StarkCore
  module Utils
    module Request
      class Response
        attr_reader :status, :content
        def initialize(status, content)
          @status = status
          @content = content
        end

        def json
          JSON.parse(@content)
        end
      end

      def self.fetch(host:, sdk_version:, user:, method:, path:, payload: nil, query: nil, 
                      api_version: "v2", language: "en-US", timeout: 15, prefix: nil, raiseException: true)
        user = Checks.check_user(user)
        language = Checks.check_language(language)

        service = {
          StarkCore::Utils::StarkHost::INFRA => "starkinfra",
          StarkCore::Utils::StarkHost::BANK => "starkbank",
          StarkCore::Utils::StarkHost::SIGN => "starksign",
        }[host]

        base_url = {
          Environment::PRODUCTION => "https://api.#{service}.com/",
          Environment::SANDBOX => "https://sandbox.api.#{service}.com/"
        }[user.environment] + 'v2'

        url = "#{base_url}/#{path}#{StarkCore::Utils::URL.urlencode(query)}"
        uri = URI(url)

        access_time = Time.now.to_i
        body = payload.nil? ? '' : payload.to_json
        message = "#{user.access_id}:#{access_time}:#{body}"
        signature = EllipticCurve::Ecdsa.sign(message, user.private_key).toBase64

        case method
          when 'GET'
            req = Net::HTTP::Get.new(uri)
          when 'DELETE'
            req = Net::HTTP::Delete.new(uri)
          when 'POST'
            req = Net::HTTP::Post.new(uri)
            req.body = body
          when 'PATCH'
            req = Net::HTTP::Patch.new(uri)
            req.body = body
          when 'PUT'
            req = Net::HTTP::Put.new(uri)
            req.body = body
          else
            raise(ArgumentError, 'unknown HTTP method ' + method)
        end

        agent = prefix ? "Joker-Ruby-#{RUBY_VERSION}-SDK-#{host}-#{sdk_version}" : "Ruby-#{RUBY_VERSION}-SDK-#{host}-#{sdk_version}"

        req['Access-Id'] = user.access_id
        req['Access-Time'] = access_time
        req['Access-Signature'] = signature
        req['Content-Type'] = 'application/json'
        req['User-Agent'] = agent
        req['Accept-Language'] = language

        request = Net::HTTP.start(uri.hostname, use_ssl: true) { |http| http.request(req) }

        response = Response.new(Integer(request.code, 10), request.body)

        return response if raiseException != true

        raise(StarkCore::Error::InternalServerError) if response.status == 500
        raise(StarkCore::Error::InputErrors, response.json['errors']) if response.status == 400
        raise(StarkCore::Error::UnknownError, response.content) unless response.status == 200

        return response
      end
    end
  end
end
