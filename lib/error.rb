# frozen_string_literal: true

require('json')

module StarkCore
  module Error
    class StarkCoreError < StandardError
      attr_reader :message
      def initialize(message)
        @message = message
        super(message)
      end
    end

    class Error < StarkCoreError
      attr_reader :code, :message
      def initialize(code, message)
        @code = code
        @message = message
        super("#{code}: #{message}")
      end
    end

    class InputErrors < StarkCoreError
      attr_reader :errors
      def initialize(content)
        errors = []
        content.each do |error|
          errors << Error.new(error['code'], error['message'])
        end
        @errors = errors
        super(content.to_json)
      end
    end

    class InternalServerError < StarkCoreError
      def initialize(message = 'Houston, we have a problem.')
        super(message)
      end
    end

    class UnknownError < StarkCoreError
      def initialize(message)
        super("Unknown exception encountered: #{message}")
      end
    end

    class InvalidSignatureError < StarkCoreError
    end
  end
end
