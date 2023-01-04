class Transaction < StarkCore::Utils::Resource
  attr_reader :amount, :description, :external_id, :receiver_id, :sender_id, :tags, :id, :fee, :created, :source
  def initialize(amount:, description:, external_id:, receiver_id:, sender_id: nil, tags: nil, id: nil, fee: nil, source: nil, balance: nil, created: nil)
    super(id)
    @amount = amount
    @description = description
    @external_id = external_id
    @receiver_id = receiver_id
    @sender_id = sender_id
    @tags = tags
    @fee = fee
    @source = source
    @balance = balance
    @created = StarkCore::Utils::Checks.check_datetime(created)
  end

  def self.resource
    {
      resource_name: 'Transaction',
      resource_maker: proc { |json|
        Transaction.new(
          amount: json['amount'],
          description: json['description'],
          external_id: json['external_id'],
          receiver_id: json['receiver_id'],
          sender_id: json['sender_id'],
          tags: json['tags'],
          id: json['id'],
          fee: json['fee'],
          source: json['source'],
          balance: json['balance'],
          created: json['created']
        )
      }
    }
  end
end
