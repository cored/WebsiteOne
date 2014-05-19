class AuthenticationsController < ApplicationController
  before_action :authenticate_user!, only: [:destroy]

  def create
    @path = request.env['omniauth.origin'] || root_path

    if request.env['omniauth.params']['youtube']
      link_to_youtube and return
    end

    if current_user.present?
      if authentication.present?
        AttemptLoginWithAuthService.(current_user, @path, 
                                    success: ->(authentication){ 
          flash[:notice] = 'Signed in successfully.'
          sign_in_and_redirect(:user, authentication.user)
        }, 
                                    failure: ->(path) {
          flash[:alert] = 'Another account is already associated with these credentials!'
          redirect_to path
        })

      else
        create_new_authentication_for_current_user(@path)
        profile_service_factory.(current_user, omniauth, failure: ->(current_user, provider){
          flash[:alert] = "Linking your #{provider} profile has failed"
          Rails.logger.error current_user.errors.full_messages
        })

      end
    else
      create_new_user_with_authentication
    end
  end

  def profile_service_factory 
    "#{omniauth.fetch('provider').capitalize}ProfileService".constantize
  end

  def omniauth 
    @omniauth ||= request.env['omniauth.auth']
  end

  def authentication 
    @authentication ||= Authentication.find_by_provider_and_uid(omniauth.fetch('provider'), omniauth.fetch('uid'))
  end

  def failure
    # Bryan: TESTED
    flash[:alert] = 'Authentication failed.'
    redirect_to root_path
  end

  def destroy
    if params[:id]=='youtube'
      unlink_from_youtube and return
    end

    @authentication = current_user.authentications.find(params[:id])
    if @authentication
      if current_user.authentications.count == 1 and current_user.encrypted_password.blank?
        # Bryan: TESTED
        flash[:alert] = 'Bad idea!'
      elsif @authentication.destroy
        flash[:notice] = 'Successfully removed profile.'
      else
        flash[:alert] = 'Authentication method could not be removed.'
      end
    else
      flash[:alert] = 'Authentication method not found.'
    end
    redirect_to edit_user_registration_path(current_user)
  end


  private

  def link_to_youtube
    current_user.update_youtube_id_if(request.env['omniauth.auth']['credentials']['token'])
    redirect_to(request.env['omniauth.origin'] || root_path)
  end


  def unlink_from_youtube
    current_user.youtube_id = nil
    current_user.save

    redirect_to(params[:origin] || root_path)
  end

  def create_authentication_for_user
    current_user.authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid']).save
  end

  def create_new_authentication_for_current_user(path)
    if create_authentication_for_user
      # Bryan: TESTED
      flash[:notice] = 'Authentication successful.'
      redirect_to path
    else
      # Bryan: TESTED
      flash[:alert] = 'Unable to create additional profiles.'
      redirect_to @path
    end
  end

  def create_new_user_with_authentication
    user = User.new
    user.apply_omniauth(omniauth)

    # if this is a brand new user
    if user.save
      # Bryan: TESTED
      Mailer.send_welcome_message(user).deliver
      flash[:notice] = 'Signed in successfully.'
      sign_in_and_redirect(:user, user)
    # if this is a returning user
    else
      # Bryan: TESTED
      session[:omniauth] = omniauth.except('extra')
      redirect_to new_user_registration_url
    end
  end
end











