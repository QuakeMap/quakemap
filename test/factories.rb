FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'testing123'
    admin false
  end

  factory :admin, parent: :user do
    admin true
  end

  factory :quake do
    sequence(:strike_time) { |n| n.hours.ago }
    magnitude { 3 + (rand * 3) }
    depth { rand * 100 }
    lat { -45.52957 + (rand *  9.06355) }
    lng { 166.97964 + (rand * 11.06269) }
    sequence(:external_ref) { |n| "smi:geonet.org.nz/event/#{n}g" }
  end
end
