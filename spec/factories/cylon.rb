FactoryGirl.define do
  factory :cylon do
    sequence :name do |n|
      "Cylon #{ n }"
    end
    sequence :email do |n|
      "cylon#{ n }@cylon.com"
    end
  end
end
