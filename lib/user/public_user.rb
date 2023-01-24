# frozen_string_literal: true

require_relative('user')

module StarkCore
  class PublicUser
    attr_reader :environment
    def initialize(environment)
      @environment = StarkCore::Utils::Checks.check_environment(environment)
    end
  end
end
