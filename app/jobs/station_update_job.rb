class StationUpdateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Station.update_data
  end
end
