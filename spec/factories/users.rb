FactoryBot.define do
  factory :user do
    transient do
      unencrypted_reset_password_token { nil }
    end

    sequence(:email) { |n| "user#{SecureRandom.random_number(10000) + n}@domain.com" }
    password { '123123123a' }
    password_confirmation { '123123123a' }
    reset_password_token { nil }
    reset_password_sent_at { nil }
    name { Faker::Name.name }

    trait :user do
      role { :user }
    end

    trait :manager do
      role { :manager }
    end

    trait :company_owner do
      role { :company_owner }
    end

    trait :superadmin do
      role { :superadmin }
    end
  end
end
