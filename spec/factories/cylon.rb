Factory.define :cylon do |c|
  c.sequence(:name) { |n| "Cylon #{ n }" }
  c.sequence(:email) { |n| "cylon#{ n }@cylon.com" }
end
