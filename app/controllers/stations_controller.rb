class StationsController < ApplicationController
  def index
    @with_bikes_filter = (params[:with_bikes_filter] || "yes") == "yes"
    @with_docks_filter = (params[:with_docks_filter] || "no") == "yes"
    @distance_filter = (params[:distance_filter] || 1000).to_i

    station_scope = Station.all_up_to_date
    if @with_bikes_filter
      station_scope = station_scope.where("nb_bike > 0")
    end
    if @with_docks_filter
      station_scope = station_scope.where("nb_empty_dock > 0")
    end

    @fx_distances = {}
    station_scope.each do |s|
      @fx_distances[s.id] = s.distance_to_in_meters(fx_innovation)
    end
    @stations = []
    station_scope.sort_by {|s| @fx_distances[s.id] }.each do |s|
      if @fx_distances[s.id] < @distance_filter
        @stations << s
      else
        break
      end
    end
  end

  protected
  def fx_innovation
    [45.506318, -73.569021]
  end
end
