require 'rails_helper'

describe QuakesController, type: :controller do
  let!(:quake) { FactoryGirl.create(:quake) }

  before do
    travel_to Time.now
  end

  after do
    travel_back
  end

  describe 'GET index' do
    let(:format){ :html }
    before { get :index, format: format }

    it { expect(response).to have_http_status(:success) }
    it { expect(assigns(:start_time)).to eq(Time.now - 7.days) }
    it { expect(assigns(:end_time)).to eq(Time.now) }
    it { expect(assigns(:mag_floor)).to eq(3.0) }
    it { expect(assigns(:mag_ceil)).to eq(quake.magnitude) }
    it { expect(assigns(:quakes)).to be_nil }

    context '.json' do
      let(:format){ :json }
      it { expect(assigns(:quakes)).to include(quake) }
    end

    context '.rss' do
      let(:format){ :rss }
      it { expect(assigns(:quakes)).to include(quake) }
    end
  end
end
