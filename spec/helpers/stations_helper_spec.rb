require 'spec_helper'

describe StationsHelper, :type => :helper do
  describe "valid_distances_options" do
    it "returns an option list of distances" do
      expected =     [
        ["500 m", 500],
        ["1 km", 1000],
        ["2 km", 2000],
        ["3 km", 3000],
        ["5 km", 5000],
        ["10 km", 10000]
      ]

      expect(valid_distances_options).to eq(expected)
    end
  end
end
