require_relative '../test_helper'
require_relative 'transaction'

describe StarkCore::Utils::Rest do
  it 'test rest get' do
    transactions, cursor = StarkCore::Utils::Rest.get_page(
      sdk_version: "0.0.0",
      host:  StarkCore::Utils::StarkHost::BANK,
      api_version: "v2",
      user: StarkCore.user,
      language: "pt-BR",
      timeout: 15,
      before: "2022-02-01",
      limit: 1,
      **Transaction.resource,
    )
    transaction = transactions[0]
    puts transaction
    expect(transaction.amount).wont_be_nil
  end
end
