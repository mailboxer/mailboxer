Factory.define :user do |u|
  u.sequence(:name) { |n| "User #{ n }" }
end
