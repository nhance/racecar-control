require 'faker'

FactoryGirl.define do
  factory :event do
    start_date    { 30.days.from_now }
    stop_date     { |e| e.start_date.present? ? e.start_date + 3.days : 32.days.from_now }
    track 'Watkins Glen'
    abbr  { Faker::Lorem.characters(10) }
    track_length 3.40

    trait :current do
      season_id  { Season.current.id }
      start_date { Date.today }
      stop_date  { 2.days.from_now }
    end
  end

  factory :season do
    sequence(:id, Date.today.year) do |n|
      n
    end
  end

  factory :race do
    event

    start_time { event.start_date.beginning_of_day }
    end_time { event.start_date.end_of_day }

    trait :qualifying do
      qualifying true
    end
  end

  factory :result do
    race
    registration
  end

  factory :points_adjustment do
    race
    registration

    reason "generated in test environment"
  end

  factory :user do
    email "admin@americanenduranceracing.com"
    password "iwannagofaster"
    password_confirmation "iwannagofaster"
  end

  factory :registration do
    event
    car
    association :registered_by, factory: :driver

    car_number      "51"
  end

  factory :scan do
    registration
    driver

    pit "OUT"
  end

  factory :car do |car|
    association :captain, factory: :driver

    color  { Faker::Commerce.color }
    year  { rand(1936..2015) }
    make  { Faker::App.name }
    model { Faker::App.name }

    trait :porsche do
      color "Gray"
      year  2007
      make  "Porsche"
      model "Cayman"
    end
  end

  factory :driver do
    first_name            { Faker::Name.first_name }
    last_name             { Faker::Name.last_name }
    email                 { Faker::Internet.email }
    password              "password"
    password_confirmation "password"
    emergency_contact_name "Nick Hance"
    emergency_contact_phone "215-804-9408"

    trait :with_team do
      team
    end

    trait :nick do
      first_name "Nick"
      last_name  "Hance"
      email      "nick@hance.org"
    end
  end

  factory :team do
    name        { "#{Faker::Company.name} Racing" }
    passcode    "racecar"

    association :captain, factory: :driver

    trait :with_drivers do
      drivers { build_list :driver, 3 }
    end

    trait :with_cars do
      cars    { build_list :car, 1 }
    end

    trait :rally_baby do
      name "Rally Baby"
    end
  end

  factory :payment do
    driver
    registration
    amount_paid_in_cents { rand(1800_00) }
  end
end
