require 'rails_helper'

RSpec.describe "stations/index.html.erb", type: :view do
  subject { view }

  let(:station) do
    Station.create(
      name: "station",
      nb_bike: 1,
      nb_empty_dock: 2,
      latitude: 3,
      longitude: 4
    )
  end

  it "displays the filters" do
    assign :with_bikes_filter, true
    assign :with_docks_filter, false
    assign :distance_filter, 1000
    assign :fx_distances, {}
    assign :stations, []

    render

    assert_select 'form' do
      assert_select "#with_bikes_filter_yes[checked='checked']"
      assert_select "#with_bikes_filter_no"

      assert_select "#with_docks_filter_yes"
      assert_select "#with_docks_filter_no[checked='checked']"
      
      assert_select '#distance_filter'
      assert_select "#distance_filter option[selected='selected'][value='1000']"

      assert_select "input[type='submit'][value='Refresh']"
    end
  end

  it "displays an empty list" do
    assign :fx_distances, {}
    assign :stations, []

    render

    assert_select 'table td.empty', "No station found."
  end

  it "displays a list of stations" do
    assign :fx_distances, {station.id => 5}
    assign :stations, [station]

    render

    assert_select 'table td', "station"
    assert_select 'table td', "1"
    assert_select 'table td', "2"
    assert_select 'table td', "5 m"
  end
end
