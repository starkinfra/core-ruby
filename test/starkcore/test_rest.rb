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

describe StarkCore::Utils::Rest do
  it 'test rest get raw' do
  invoices = StarkCore::Utils::Rest.get_raw(
      sdk_version: "0.0.0",
      host:  StarkCore::Utils::StarkHost::BANK,
      api_version: "v2",
      user: StarkCore.user,
      language: "pt-BR",
      path: "/invoice",
      timeout: 15,
      prefix: "Joker",
      raiseException: false,
      limit: 1
    )

  invoice = invoices["invoices"][0]
    puts invoice
    expect(invoice["amount"]).wont_be_nil
  end
end

describe StarkCore::Utils::Rest do
  it 'test rest post raw' do

  invoices = {
    "invoices": [
        {
          "name": "Iron Bank S.A.",
          "taxId": "012.345.678-90",
          "amount": 400000
        }
    ]
  }  

  invoices = StarkCore::Utils::Rest.post_raw(
      sdk_version: "0.0.0",
      host:  StarkCore::Utils::StarkHost::BANK,
      api_version: "v2",
      user: StarkCore.user,
      language: "pt-BR",
      path: "/invoice",
      payload: invoices,
      timeout: 15,
      prefix: "Joker",
      raiseException: false,
      limit: 1
    )

  invoice = invoices["invoices"][0]
    puts invoice
    expect(invoice["amount"]).wont_be_nil
  end
end

describe StarkCore::Utils::Rest do
  it 'test rest patch raw' do

    invoices = StarkCore::Utils::Rest.get_raw(
      sdk_version: "0.0.0",
      host:  StarkCore::Utils::StarkHost::BANK,
      api_version: "v2",
      user: StarkCore.user,
      language: "pt-BR",
      path: "/invoice",
      timeout: 15,
      prefix: "Joker",
      raiseException: false,
      limit: 1
    )

    invoice = invoices["invoices"][0]

    payload = {
        "amount": 0
    }  

    invoice = StarkCore::Utils::Rest.patch_raw(
        sdk_version: "0.0.0",
        host:  StarkCore::Utils::StarkHost::BANK,
        api_version: "v2",
        user: StarkCore.user,
        language: "pt-BR",
        path: "/invoice/#{invoice["id"]}",
        payload: payload,
        timeout: 15,
        prefix: "Joker",
        raiseException: false,
        limit: 1
    )

    puts invoice
    expect(invoice["invoice"]["amount"]).wont_be_nil
  end
end

describe StarkCore::Utils::Rest do
  it 'test rest put raw' do

  payload = {
    "profiles": [
        {
          "interval": "day",
          "delay": 0,
        }
    ]
  }  

  profiles = StarkCore::Utils::Rest.put_raw(
      sdk_version: "0.0.0",
      host:  StarkCore::Utils::StarkHost::BANK,
      api_version: "v2",
      user: StarkCore.user,
      language: "pt-BR",
      path: "/split-profile",
      payload: payload,
      timeout: 15,
      prefix: "Joker",
      raiseException: false,
      limit: 1
    )

  profile = profiles["profiles"][0]
    puts profile
    expect(profile["delay"]).wont_be_nil
  end
end

describe StarkCore::Utils::Rest do
  it 'test rest delete raw' do

  payload = {
    "transfers": [
        {
          "amount": 10000,
          "name": "Steve Rogers",
          "taxId": "851.127.850-80",
          "bankCode": "001",
          "branchCode": "1234",
          "accountNumber": "123456-0",
          "accountType": "checking",
          "externalId": 'ruby-' + rand(1e10).to_s,
          "scheduled": "2033-05-02",
        }
    ]
  }

  transfers = StarkCore::Utils::Rest.post_raw(
      sdk_version: "0.0.0",
      host:  StarkCore::Utils::StarkHost::BANK,
      api_version: "v2",
      user: StarkCore.user,
      language: "pt-BR",
      path: "/transfer",
      payload: payload,
      timeout: 15,
      prefix: "Joker",
      raiseException: false,
      limit: 1
    )

  deletedTransfer = StarkCore::Utils::Rest.delete_raw(
      sdk_version: "0.0.0",
      host:  StarkCore::Utils::StarkHost::BANK,
      api_version: "v2",
      user: StarkCore.user,
      language: "pt-BR",
      path: "/transfer/#{transfers["transfers"][0]["id"]}",
      timeout: 15,
      prefix: "Joker",
      raiseException: false,
      limit: 1
    )

    deletedTransfer = deletedTransfer["transfer"]
    expect(deletedTransfer["id"]).wont_be_nil
  end
end