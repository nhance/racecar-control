module DeviseParameterPermissions
  extend ActiveSupport::Concern

  included do
    before_action :configure_permitted_parameters, if: :devise_controller?
  end

  def after_sign_in_path_for(resource)
    if redirect_url = stored_location_for(resource)
      redirect_url
    elsif resource.kind_of?(User)
      rails_admin_path
    else
      team_path
    end
  end

  def configure_permitted_parameters
    driver_params = [:email, :password, :password_confirmation, :current_password,
                    :first_name, :last_name, :notes,
                    :street_address, :city, :state, :details,
                    :zip_code, :emergency_contact_name, :referred_by, :cell_phone, :shirt_size, :allow_sms,
                    :emergency_contact_phone]

    devise_parameter_sanitizer.permit(:account_update) do |driver|
      driver.permit(driver_params).tap { |permitted_params|
         permitted_params[:details] = params[:driver][:details] if params[:driver][:details]
      }
    end

    devise_parameter_sanitizer.permit(:sign_up) do |driver|
      # https://github.com/rails/rails/issues/9454
      # https://github.com/plataformatec/devise#strong-parameters
      driver.permit(driver_params).tap { |permitted_params|
         permitted_params[:details] = params[:driver][:details] if params[:driver][:details]
      }
    end
  end
end
