Factory.define :duck do |d|
  d.sequence(:name) { |n| "Duck #{ n }" }
end
