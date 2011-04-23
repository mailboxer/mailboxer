Factory.define :duck do |d|
  d.sequence(:name) { |n| "Duck #{ n }" }
  d.sequence(:email) { |n| "duck#{ n }@duck.com" }
end
