require 'test_helper'

class QuakesControllerTest < ActionController::TestCase
  setup do
    stub_request(:get, /.*magma\.geonet\.org\.nz.*/)
    .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
    .to_return(status: 200, body: xml_body, headers: {})
  end

  should 'view home page' do
    FactoryGirl.create_list(:quake, 10)
    get :index
    assert_response :success
  end

  should 'not be able to run manual pull' do
    assert_no_difference 'Quake.count' do
      get :manual_pull
    end
    assert_response :redirect
  end

  context 'logged in as admin' do
    setup do
      @user = FactoryGirl.create(:admin)
      sign_in @user
    end

    should 'be able to run manual pull' do
      get :manual_pull
      assert_response :success
    end
  end

  private

  def xml_body
    <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <quakeml xmlns="http://quakeml.org/xmlns/quakeml/1.0">
        <eventParameters publicID="smi:geonet.org.nz/quakeml/1.0.1">
        </eventParameters>
      </quakeml>
    XML
  end
end
