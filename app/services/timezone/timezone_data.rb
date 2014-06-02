module Timezone
  class TimezoneData
    attr_reader :name, :offset
    def initialize(timezone_data)
      @name = timezone_data.time_zone_name
      @offset = timezone_data.raw_offset / 3600
    end

    def offset 
      if @offset > 0 
        "UTC+#{@offset}"
      else
        "UTC#{@offset}"
      end
    end
  end
end
