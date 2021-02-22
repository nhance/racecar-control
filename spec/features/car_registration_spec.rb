require 'spec_helper'

RSpec.feature "Car Registration" do
  let(:driver) { create(:driver, :with_team) }
  let!(:event) { create(:event) }

  background do
    login_as driver
  end

  scenario "Driver registers new car" do
    visit new_car_path

    fill_in "Year", with: '2007'
    fill_in "Make", with: "Porsche"
    fill_in "Model", with: "Cayman"

    click_button "Save car"

    expect(page).to have_content("successfully added")

    car = Car.last

    expect(car.captain).to eq(driver)
    expect(car.team).to eq(driver.team)
  end

end
