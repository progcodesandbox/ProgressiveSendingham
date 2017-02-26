class AuthController < ApplicationController
  skip_before_action :authenticate_user!,   only: [:oauth_callback, :slack_handshake, :slack_redirect]
  before_action      :authenticate_slack!,  only: [:slack_handshake]

  protect_from_forgery with: :null_session, only: [:slack_handshake]

  def oauth_callback
    if team_member?
      user = User.find_or_create_by(email: auth_email)
      sign_in(user)
      flash[:success] = I18n.t('controllers.auth_controller.successes.oauth_callback')
      redirect_to root_path
    else
      render :forbidden
    end
  end

  # TODO Relocate, rename. Make it make more sense :)
  def slack_handshake
    case params[:type]
    when "url_verification"
      render json: { challenge: params.require(:challenge) }
    when "event_callback"
      case params[:event][:type]
      when "channel_created"
      when "team_join"
        Employee.create({
          started_on:     Time.now.in_time_zone(
                            params[:event][:user].require(:tz)
                          ),
          time_zone:      params[:event][:user].require(:tz),
          slack_username: params[:event][:user].require(:name),
          slack_user_id:  params[:event][:user].require(:id)
        })
      end
      head :no_content
    end
  end

  private

  # TODO I don't like this, verify the token in a routing constraint
  # TODO With the routing constraint, requests without the matching verification token will be a 404
  def authenticate_slack!
    raise unless params.require(:token) === ENV['SLACK_APP_VERIFICATION_TOKEN']
  end

  def team_member?
    auth_hash.credentials.team_member?
  end

  def auth_email
    info.email
  end

  def info
    auth_hash.info
  end

  def auth_hash
    request.env["omniauth.auth"]
  end
end
