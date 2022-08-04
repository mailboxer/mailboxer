class Mailboxer::BaseBuilder

  attr_reader :params

  def initialize(params)
    @params = params.with_indifferent_access
  end

  def build
    klass.new.tap do |object|
      params.keys.each do |field|
        field_value = get(field)
        next if field_value.nil?

        attr = if field.to_s == "attachment" && field_value.is_a?(String)
                 "remote_#{field}_url"
               else
                 field
               end

        object.send("#{attr}=", field_value)
      end
    end
  end

  protected

  def get(key)
    respond_to?(key) ? send(key) : params[key]
  end

  def recipients
    Array(params[:recipients]).uniq
  end

end
