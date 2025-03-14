FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
    charts_visible { true }
  end
end
