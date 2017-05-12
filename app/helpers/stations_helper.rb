module StationsHelper
  def valid_distances_options
    [
      ["500 m", 500],
      ["1 km", 1000],
      ["2 km", 2000],
      ["3 km", 3000],
      ["5 km", 5000],
      ["10 km", 10000]
    ]
  end
end
