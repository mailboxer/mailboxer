class Mailboxer::BaseBuilder

  attr_reader :params

  def initialize(params)
    @params = params.with_indifferent_access
  end

  def build
    klass.new.tap do |object|
      fields.each do |field|
        object.send("#{field}=", get(field)) unless get(field).nil?
      end
    end
  end

  private

  def get(key)
    respond_to?(key) ? send(key) : params[key]
  end

  def recipients
    Array(params.fetch(:recipients)).uniq
  end
end
