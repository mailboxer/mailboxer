class Mailboxer::BaseBuilder

  attr_reader :params

  def initialize(params)
    @params = params.with_indifferent_access
  end

  def build
    klass.new.tap do |object|
      fields.each do |field|
        object.send("#{field}=", send(field)) unless send(field).nil?
      end
    end
  end

  private

  def created_at
    params.fetch(:created_at, nil)
  end

  def updated_at
    params.fetch(:updated_at, nil)
  end

  def recipients
    Array(params.fetch(:recipients)).uniq
  end

  def body
    params.fetch(:body)
  end

  def subject
    params.fetch(:subject)
  end
end
