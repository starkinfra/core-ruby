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
                      api_version: "v2", language: "en-US", timeout: 15)
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

        agent = "Ruby-#{RUBY_VERSION}-SDK-#{host}-#{sdk_version}"

        body = payload.nil? ? '' : payload.to_json

        headers = {
          'User-Agent' => agent,
          'Accept-Language' => language,
          'Content-Type' => 'application/json'
        }
        headers.update(_authentication_headers(user, body))

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

        headers.each do |key, value|
          req[key] = value
        end

        request = Net::HTTP.start(uri.hostname, use_ssl: true) { |http| http.request(req) }

        response = Response.new(Integer(request.code, 10), request.body)

        raise(StarkCore::Error::InternalServerError) if response.status == 500
        raise(StarkCore::Error::InputErrors, response.json['errors']) if response.status == 400
        raise(StarkCore::Error::UnknownError, response.content) unless response.status == 200

        return response
      end

      def self._authentication_headers(user, body)
        return {} if user.instance_of?(StarkCore::PublicUser)
        
        access_time = Time.now.to_i
        message = "#{user.access_id}:#{access_time}:#{body}"
        signature = EllipticCurve::Ecdsa.sign(message, user.private_key).toBase64
        
        return {
          "Access-Id" => user.access_id(),
          "Access-Time" => access_time,
          "Access-Signature" => signature,
        }
      end
    end
  end
end
