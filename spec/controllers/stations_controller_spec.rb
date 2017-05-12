require 'rails_helper'

RSpec.describe StationsController, type: :controller do

  let(:near) { Station.create(name: "near", latitude: 45.5060, longitude: -73.569, nb_bike: 1, nb_empty_dock: 1) }
  let(:far) { Station.create(name: "far", latitude: 45.49, longitude: -73.55, nb_bike: 1, nb_empty_dock: 1) }
  let(:no_bike) { Station.create(name: "no_bike", latitude: 45.5059, longitude: -73.569, nb_bike: 0, nb_empty_dock: 1) }
  let(:no_dock) { Station.create(name: "no_dock", latitude: 45.5058, longitude: -73.569, nb_bike: 1, nb_empty_dock: 0) }

  before do
    near; far; no_bike; no_dock
  end

  describe "GET #index" do
    render_views

    before do
      allow(Station).to receive(:all_up_to_date).and_return(Station.all)
    end

    it "sets the default filters" do
      get :index

      # In Rails 5, calling assert_template or assigns will throw an exception.
      # These two methods have now been removed from the core and moved to a
      # separate gem rails-controller-testing. The idea behind the removal of
      # these methods is that instance variables and which template is rendered
      # in a controller action are internals of a controller, and controller
      # tests should not care about them.
      #
      # I personally disagree with that. To be the instance variables that are
      # passed to the view are a contracts between the controller and the view.
      # The same way parameters of an API are part of the agreed contract for
      # an API. This is why I use rails-controller-testing gem.
      #
      # For similar reasons, I use 'render_views' above to force the view to be
      # evaluated. This way, if one of the instance variable change name in the
      # controller and not in the view for example. The view will fail and the
      # test will tell me that the contract has been violated.
      #
      # The days of controller tests as units are over, and like me, you may be
      # now questioning the value of controller tests at all going forward,
      # since they are just integration tests. Until the comunity adopts a new
      # clear strategy. This is how I do my testing.


      expect(assigns(:with_bikes_filter)).to be_truthy
      expect(assigns(:with_docks_filter)).to be_falsey
      expect(assigns(:distance_filter)).to eq(1000)

      expect(assigns(:stations)).to eq([near, no_dock])
      expected_distances = {
        near.id    => 35.397836390878126,
        far.id => 2343.1038513443855,
        no_dock.id => 57.62221575787292,
        
      }
      expect(assigns(:fx_distances)).to eq(expected_distances)

      expect(response).to have_http_status(:success)
    end

    it "display stations with no bikes" do
      get :index, params: {with_bikes_filter: "no"}
      expect(assigns(:with_bikes_filter)).to be_falsey
      expect(assigns(:with_docks_filter)).to be_falsey
      expect(assigns(:distance_filter)).to eq(1000)

      expect(assigns(:stations)).to eq([near, no_bike, no_dock])
      expected_distances = {
        near.id    => 35.397836390878126,
        far.id => 2343.1038513443855,
        no_bike.id => 46.50828063850008,
        no_dock.id => 57.62221575787292,

      }
      expect(assigns(:fx_distances)).to eq(expected_distances)

      expect(response).to have_http_status(:success)
    end

    it "filters stations with no empty docks" do
      get :index, params: {with_docks_filter: "yes"}
      expect(assigns(:with_bikes_filter)).to be_truthy
      expect(assigns(:with_docks_filter)).to be_truthy
      expect(assigns(:distance_filter)).to eq(1000)

      expect(assigns(:stations)).to eq([near])
      expected_distances = {
        near.id    => 35.397836390878126,
        far.id => 2343.1038513443855,
      }
      expect(assigns(:fx_distances)).to eq(expected_distances)

      expect(response).to have_http_status(:success)
    end

    it "display stations far away" do
      get :index, params: {distance_filter: "10000"}
      expect(assigns(:with_bikes_filter)).to be_truthy
      expect(assigns(:with_docks_filter)).to be_falsey
      expect(assigns(:distance_filter)).to eq(10000)

      expect(assigns(:stations)).to eq([near, no_dock, far])
      expected_distances = {
        near.id    => 35.397836390878126,
        far.id => 2343.1038513443855,
        no_dock.id => 57.62221575787292,
      }
      expect(assigns(:fx_distances)).to eq(expected_distances)

      expect(response).to have_http_status(:success)
    end

    it "handles multi filters" do
      get :index, params: {with_bikes_filter: "no", with_docks_filter: "yes", distance_filter: "10000"}
      expect(assigns(:with_bikes_filter)).to be_falsey
      expect(assigns(:with_docks_filter)).to be_truthy
      expect(assigns(:distance_filter)).to eq(10000)

      expect(assigns(:stations)).to eq([near, no_bike, far])
      expected_distances = {
        near.id    => 35.397836390878126,
        far.id => 2343.1038513443855,
        no_bike.id => 46.50828063850008,
      }
      expect(assigns(:fx_distances)).to eq(expected_distances)

      expect(response).to have_http_status(:success)
    end
  end

end
