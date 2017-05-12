require 'rails_helper'

RSpec.describe Station, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :latitude }
    it { is_expected.to validate_presence_of :longitude }
  end

  describe "class methods" do
    describe "update_data" do
      before do
        expect(Station).to receive(:open).with("https://secure.bixi.com/data/stations.json").once.and_yield(File.open("#{Rails.root}/spec/stations.json"))
      end

      it "fetches json data, parse it and update the db" do
        expect(Station.where(terminal_id: "6001").count).to eq(0)

        Station.update_data

        expect(Station.where(terminal_id: "6001").count).to eq(1)
        sta = Station.find_by(terminal_id: "6001")
        expect(sta.name).to eq("Hôtel-de-Ville 2 (du Champs-de-Mars / Gosford)")
        expect(sta.nb_bike).to eq(12)
        expect(sta.nb_empty_dock).to eq(19)
        expect(sta.latitude).to eq(45.5093102856)
        expect(sta.longitude).to eq(-73.554431051)

        expect(Station.all.count).to eq(2)
      end

      it "updates existing entries" do
        Station.create(terminal_id: "6001", name: "Existing Station", latitude: 1, longitude: 1)
        expect(Station.where(terminal_id: "6001").count).to eq(1)

        Station.update_data

        expect(Station.where(terminal_id: "6001").count).to eq(1)
        sta = Station.find_by(terminal_id: "6001")
        expect(sta.name).to eq("Hôtel-de-Ville 2 (du Champs-de-Mars / Gosford)")
      end
    end

    describe "all_up_to_date" do
      before do
        Rails.cache.clear
      end

      it "performs a StationUpdateJob when data is stale for 5 minutes" do
        allow(Station).to receive(:all)
        expect(StationUpdateJob).to receive(:perform_now).twice

        Timecop.freeze(6.minutes.ago) do
          Station.all_up_to_date
        end
        Timecop.freeze(3.minutes.ago) do
          Station.all_up_to_date # Not calling StationUpdateJob
        end
        Timecop.freeze(10.seconds.ago) do
          Station.all_up_to_date
        end
      end

      it "returns Station.all" do
        allow(StationUpdateJob).to receive(:perform_now)

        expect(Station.all_up_to_date).to eq(Station.all)
      end
    end
  end

  describe "instance methods" do
    let(:station) { Station.new(latitude: 0, longitude: 0) }

    describe "latitude=" do
      it "truncate latitude to 10 digit precision" do
        float_test = 0.12345678901234567890
        station.latitude = float_test
        expect(station.latitude).to eq(0.1234567890)
        expect(float_test).to eq(0.12345678901234567890)
      end
    end

    describe "longitude=" do
      it "truncate longitude to 10 digit precision" do
        float_test = 0.12345678901234567890
        station.longitude = float_test
        expect(station.longitude).to eq(0.1234567890)
        expect(float_test).to eq(0.12345678901234567890)
      end
    end

    describe "distance_to_in_meters" do
      it "retuns distances in meters" do
        expect(station.distance_to_in_meters([0,0.001])).to eq(111.19492664455876)  # 0.11119492664455877 km
      end
    end
  end
end
