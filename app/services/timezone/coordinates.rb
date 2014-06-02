module Timezone
  class Coordinates
    attr_reader :latitude, :longitude
    def initialize(data)
      @latitude = data.fetch('latitude')
      @longitude = data.fetch('longitude')
      freeze
    end
  end
end
