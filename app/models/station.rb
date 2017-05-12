require 'json'

class Station < ApplicationRecord
  reverse_geocoded_by :latitude, :longitude
  
  validates_presence_of :name, :latitude, :longitude

  def self.update_data
    json_data = {}
    open("https://secure.bixi.com/data/stations.json") do |f|
      json_data = JSON.parse(f.read)
    end
    if json_data["stations"]
      json_data["stations"].each do |station_data|
        station = Station.where(terminal_id: station_data["n"].to_s).first_or_initialize
        station.name = station_data["s"]
        station.nb_bike = station_data["ba"]
        station.nb_empty_dock = station_data["da"]
        station.latitude = station_data["la"]
        station.longitude = station_data["lo"]
        station.save
      end
    end
  end

  def self.all_up_to_date
    # From the BIXI documentation: "Les données sont produites par le
    # système de gestion des stations de BIXI Montréal avec un taux de
    # rafraîchissement de 5 minutes."
    #
    # We are storing a dummy value in cache, expiring in 5 minutes. When
    # the cache expires, it means the data on the server has been updated
    # and it's time to refresh our db.
    # This could also be performed using a recurring job, but that means
    # we would update the db even when there's no user on our site.
    
    Rails.cache.fetch("station-data", expires_in: 5.minutes) do
      # To avoid to install sidekiq or some other background job engine.
      # We're calling perform_now. In a real system, we would call
      # perform_later.
      StationUpdateJob.perform_now
      nil
    end

    # Returning an ActiveRecord_Relation so filtering using query methods
    # is still possible.
    Station.all
  end

  # From the Google Maps documentation: "To keep the storage space required for your
  # table at a minimum, you can specify that the lat and lng attributes are floats
  # of size (10,6)". The BIXI JSON has more precision that 10 digits, so we truncate
  # the value to avoid updating the record when nothing has changed.
  def latitude=(lat)
    write_attribute(:latitude, lat.round(10)) if lat
  end
  def longitude=(long)
    write_attribute(:longitude, long.round(10)) if long
  end

  def distance_to_in_meters(point2)
    distance_to(point2)*1000
  end
end
