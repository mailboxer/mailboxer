Factory.define :cylon do |c|
  c.sequence(:name) { |n| "Cylon #{ n }" }
end
