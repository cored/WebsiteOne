module Timezone
  class LastSignInIp
    def self.for(user)
      new(user.last_sign_in_ip || '0.0.0.0').ip
    end

    attr_reader :ip
    def initialize(ip)
      @ip = ip
    end
  end
end
