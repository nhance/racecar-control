require 'spec_helper'

RSpec.feature "Driver logs in" do
  let!(:driver) { create(:driver) }
  let!(:team)   { create(:team, name: "Rally Baby") }

  scenario "Driver visits homepage and logs in" do
    visit "/"
    fill_in("Email", with: driver.email)
    fill_in("Password", with: "password")

    click_button("Log in")

    expect(page).to have_content("Choose your team")
    expect(current_path).to eq(teams_path)
  end
end
