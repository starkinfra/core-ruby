# frozen_string_literal: true

module StarkCore
  module Utils
    class StarkHost < Enum
      INFRA = "infra"
      BANK = "bank"
      SIGN = "sign"

      public_constant :INFRA, :BANK, :SIGN
    end
  end
end
