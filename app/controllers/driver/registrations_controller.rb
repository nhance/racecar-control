class Driver::RegistrationsController < Devise::RegistrationsController
  def update
    @driver = Driver.find(current_driver.id)
    @driver.enable_extra_validation!

    if needs_password?(@driver, params)
      if successfully_updated = @driver.update_with_password(devise_parameter_sanitizer.sanitize(:account_update))
        flash[:notice] = "Please check your email to confirm your changes."
      end
    else
      params[:driver].delete(:current_password)
      puts devise_parameter_sanitizer.sanitize(:account_update).inspect
      if successfully_updated = @driver.update_without_password(devise_parameter_sanitizer.sanitize(:account_update))
        set_flash_message :notice, :updated
      end
    end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the driver bypassing validation in case his password changed
      sign_in @driver, :bypass => true if params[:driver][:password].present?
      redirect_to team_path
    else
      render "edit"
    end
  end

  private
  # check if we need password to update driver data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(driver, params)
    driver.email != params[:driver][:email] ||
      params[:driver][:password].present?
  end
end
