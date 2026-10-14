# frozen_string_literal: true

require('minitest/autorun')
require('minitest/spec')
require('./lib/starkcore')

describe StarkCore::Utils::API do
  {
    'Log' => 'logs',
    'TransferLog' => 'logs',
    'Entity' => 'entities',
    'Key' => 'keys',
    'Boss' => 'boss',
    'AiSpeech' => 'speeches',
    'Patch' => 'patches',
    'Dish' => 'dishes',
    'Tax' => 'taxes',
    'Invoice' => 'invoices'
  }.each do |resource_name, plural|
    it "plural of #{resource_name} is #{plural}" do
      expect(StarkCore::Utils::API.last_name_plural(resource_name)).must_equal(plural)
    end
  end
end
