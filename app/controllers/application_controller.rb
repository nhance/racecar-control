class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  force_ssl if: :ssl_required?

  def ssl_required?
    Rails.env.production?
  end

  def user_for_paper_trail
    if current_user.present?
      "admin-#{current_user.id}"
    elsif current_driver.present?
      current_driver.id
    else
      ''
    end
  end

  def require_admin
    render text: "Admin is required" unless current_user.present?
    return false
  end

  def facebook_og(name = nil, value = nil)
    @facebook_og ||= {
      url: request.original_url,
      type: 'website',
      title: 'American Endurance Racing',
      description: 'Timing, Scoring and Registration for AER',
      image: "http://race.americanenduranceracing.com/logo-short.png"
    }

    if name.present?
      @facebook_og[name] = value
    end

    @facebook_og
  end

  helper_method :facebook_og

  def render_404
    raise ActionController::RoutingError.new('Not Found')
  end

  include DeviseParameterPermissions
end
