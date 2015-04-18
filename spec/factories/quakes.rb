FactoryGirl.define do
  factory :quake do
    origin_time { (rand * 7).to_i.days.ago }
    update_time { (rand * 7).to_i.days.ago }
    magnitude { (rand * 4) + 3.0 }
    depth { rand * 100 }
    public_id { |n| "#{Time.zone.now.year}p#{n}" }
    status { 'automatic' }
    coordinates do
      { lat: Faker::Address.latitude, lng: Faker::Address.longitude }
    end
    felt { false }
  end
end
