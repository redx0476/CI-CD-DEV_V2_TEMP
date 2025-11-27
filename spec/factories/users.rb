FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'Password123!' }  # Use consistent password for testing
    password_confirmation { 'Password123!' }
    user_name { Faker::Name.name }
    currently_active { true }
    status { :active }
    confirmed_at { Time.current }  # Add this to skip confirmation

    trait :inactive do
      currently_active { false }
      status { :inactive }
    end

    trait :banned do
      currently_active { false }
      status { :banned }
    end

    trait :deleted do
      currently_active { false }
      status { :deleted }
    end

    trait :suspended do
      currently_active { false }
      status { :suspended }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :locked do
      locked_at { Time.current }
      failed_attempts { 3 }
    end
  end
end
