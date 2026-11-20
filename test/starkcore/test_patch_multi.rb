# frozen_string_literal: true

require('minitest/autorun')
require('minitest/spec')
require('json')
require('./lib/starkcore')

class PatchMultiCard < StarkCore::Utils::Resource
  attr_reader :holder_name, :tags

  def initialize(id: nil, holder_name: nil, tags: nil)
    super(id)
    @holder_name = holder_name
    @tags = tags
  end

  def self.resource
    {
      resource_name: 'Card',
      resource_maker: proc { |json| PatchMultiCard.new(id: json['id'], holder_name: json['holder_name'], tags: json['tags']) }
    }
  end
end

FakeReply = Struct.new(:code, :body)

# Only the outgoing HTTP call (Net::HTTP.start) is replaced: signing, headers and payload building run for real.
describe 'StarkCore::Utils::Rest.patch_multi' do
  let(:project) do
    StarkCore::Project.new(environment: 'sandbox', id: '5656565656565656', private_key: EllipticCurve::PrivateKey.new.toPem)
  end

  def patch_multi(entities, reply_code: '200', reply_body: '{"cards": [{"id": "1"}, {"id": "2"}]}', **query)
    sent = []
    http = Object.new
    http.define_singleton_method(:request) { |req| sent << req; FakeReply.new(reply_code, reply_body) }
    original_start = Net::HTTP.method(:start)
    Net::HTTP.define_singleton_method(:start) { |*_args, **_kwargs, &block| block.call(http) }
    begin
      result = StarkCore::Utils::Rest.patch_multi(
        **PatchMultiCard.resource,
        sdk_version: '0.0.0',
        host: StarkCore::Utils::StarkHost::INFRA,
        api_version: 'v2',
        user: project,
        language: 'en-US',
        timeout: 15,
        entities: entities,
        **query
      )
    ensure
      Net::HTTP.define_singleton_method(:start, original_start)
    end
    [result, sent]
  end

  it 'sends PATCH with the plural payload and parses the response' do
    cards, sent = patch_multi([
      { id: '1', holder_name: 'Tony Stark' },
      PatchMultiCard.new(id: '2', holder_name: 'Tony Stark')
    ])

    expect(sent.length).must_equal(1)
    expect(sent[0].method).must_equal('PATCH')
    expect(sent[0].path).must_equal('/v2/card')
    expect(sent[0]['Access-Signature']).wont_be_nil
    expect(JSON.parse(sent[0].body)).must_equal(
      { 'cards' => [{ 'id' => '1', 'holderName' => 'Tony Stark' }, { 'id' => '2', 'holderName' => 'Tony Stark' }] }
    )
    expect(cards.map(&:id)).must_equal(%w[1 2])
    expect(cards.all? { |card| card.is_a?(PatchMultiCard) }).must_equal(true)
  end

  it 'does not send unset attributes' do
    _, sent = patch_multi([PatchMultiCard.new(id: '1', tags: ['x'])])

    expect(JSON.parse(sent[0].body)).must_equal({ 'cards' => [{ 'id' => '1', 'tags' => ['x'] }] })
  end

  it 'sends the query in the url' do
    _, sent = patch_multi([{ id: '1' }], expand: ['rules'])

    expect(sent[0].path).must_equal('/v2/card?expand=rules')
  end

  it 'raises the API error untouched' do
    error = expect do
      patch_multi([{ id: '1', holder_name: 'Tony Stark' }], reply_code: '400',
                  reply_body: '{"errors": [{"code": "invalidHolder", "message": "must all be provided together"}]}')
    end.must_raise(StarkCore::Error::InputErrors)

    expect(error.errors.map(&:code)).must_equal(['invalidHolder'])
  end
end
