# encoding: UTF-8
# frozen_string_literal: true

# TODO: Generate operations in the way that transfer accounting is always valid.
FactoryBot.define do
  sequence :transfer_key do
    Faker::Number.unique.number(5).to_i
  end
  sequence :transfer_kind do |n|
    %w[referral-payoff token-distribution member-transfer].sample + "-#{n}"
  end

  factory :transfer do
    key  { generate(:transfer_key) }
    kind { generate(:transfer_kind) }
    desc { "#{kind} for #{Time.now.to_date}" }

    trait :with_assets do
      assets { build_list(:asset, 5, credit: 2.5, currency_id: :btc) }
    end

    trait :with_expenses do
      expenses { build_list(:expense, 5, credit: 2.5, currency_id: :btc) }
    end

    trait :with_liabilities do
      liabilities { build_list(:liability, 5, :with_member, credit: 2.5, currency_id: :btc) }
    end

    trait :with_revenues do
      revenues { build_list(:revenue, 5, credit: 2.5, currency_id: :btc) }
    end

    trait :with_operations do
      with_assets
      with_expenses
      with_liabilities
      with_revenues
    end

    factory :transfer_with_operations, traits: %i[with_operations]
  end
end
