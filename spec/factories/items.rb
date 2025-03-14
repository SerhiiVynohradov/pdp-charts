FactoryBot.define do
  factory :item do
    user
    sequence(:name) { |n| "Item #{n}" }
    description { Faker::Lorem.sentence }
    link { Faker::Internet.url }
    reason { Faker::Lorem.sentence }
    # category { Faker::Lorem.word }
    # status { true } # not active
    expected_results { Faker::Lorem.sentence }
    # progress { 0 } # not used, back-end change
    effort { 1 }
    result { Faker::Lorem.sentence }
    certificate_link { Faker::Internet.url }
    # position { 0 } # not implemented
  end
end
