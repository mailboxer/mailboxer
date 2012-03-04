FactoryGirl.define do
  factory :user do
    sequence :name do |n|
      "User #{ n }"
    end
    sequence :email do |n|
      "user#{ n }@user.com"
    end
  end
end
