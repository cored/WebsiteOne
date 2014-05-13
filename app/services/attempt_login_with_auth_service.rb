class AttemptLoginWithAuthService
  attr_reader :authentication, :path, :current_user

  def initialize(current_user, authentication, path) 
    @current_user = current_user
    @authentication = authentication
    @path = path
  end

  def call(success:raise, failure:raise)
    if current_user.present? and authentication.user != current_user
      failure.call(path)
    else
      success.call(path)
    end
  end

end
