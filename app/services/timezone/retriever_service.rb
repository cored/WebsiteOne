require_relative '../timezone/timezone_data'
require_relative '../timezone/coordinates'
require_relative '../timezone/last_sign_in_ip'
require 'geocoder'
require 'google_timezone'

module Timezone
  class RetrieverService
    def self.for(user)
      new(user).timezone
    end

    def initialize(user)
      @user = user
      @coordinates = Coordinates.new(
        Geocoder.search(LastSignInIp.for(user)).first.data)
    end

    def timezone
      TimezoneData.new(GoogleTimezone.fetch(@coordinates.latitude,
                                        @coordinates.longitude))
    end

    private

    attr_reader :user
  end
end
