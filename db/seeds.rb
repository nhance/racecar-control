# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#    Mayor.create(name: 'Emanuel', city: cities.first)
#
require 'factory_girl'
FactoryGirl.find_definitions


driver = FactoryGirl.create(:driver, email: "devs@reenhanced.com", password: "remember123", password_confirmation: "remember123")
team = FactoryGirl.create(:team, captain: driver)
car = FactoryGirl.create(:car, captain: driver, team: team)

FactoryGirl.create(:event)

FactoryGirl.create(:user, email: "devs@reenhanced.com", password: 'remember123', password_confirmation: 'remember123')
