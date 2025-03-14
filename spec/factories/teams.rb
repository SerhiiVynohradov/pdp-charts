FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "Team #{n}" }
    charts_visible { true }
    company { nil }
  end

  trait :with_company do
    company { create(:company) }
  end
end
