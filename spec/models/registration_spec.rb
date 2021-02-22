require 'spec_helper'

RSpec.describe Registration do
  context "validations" do
    subject { FactoryGirl.create(:registration) }

    it { expect(subject).to be_valid }

    context "car_number" do
      it "is valid if blank" do
        subject.car_number = ""
        expect(subject).to be_valid
      end

      it "is valid without a number" do
        subject.car_number = nil
        expect(subject).to be_valid
      end

      it "is valid with a number less than 1000" do
        subject.car_number = 51
        expect(subject).to be_valid
      end

      it "is valid if using a string number" do
        subject.car_number = "555"
        expect(subject).to be_valid
      end

      it "is invalid if number is greater than 1000" do
        subject.car_number = "1001"
        expect(subject).not_to be_valid
      end

      it "is valid if number is 00" do
        subject.car_number = "00"
        expect(subject).to be_valid
      end

      it "is not the same if '0' or '00'" do
        subject.car_number = "0"
        subject.save!

        car = FactoryGirl.create(:registration, car_number: "00")
        expect(car.car_number).to != subject.car_number
      end
    end
  end

  describe ".orbits_export_data" do
    let(:event)        { create(:event) }
    let(:rally_baby)   { create(:team, :rally_baby) }
    let(:porsche)      { create(:car, :porsche,
                                transponder_number: '1234567',
                                team: rally_baby) }
    let(:nick)         { create(:driver, :nick, team: rally_baby) }
    let(:registration) { create(:registration,
                                   car: porsche,
                                   event: event,
                                   registered_by: nick,
                                   car_class: "Daytona",
                                   car_number: "51") }

    let(:expected) { ["#51 Rally Baby", "1234567", "51", "Nick Hance", "Daytona", "2007 Porsche Cayman"] }

    subject { registration.orbits_export_data }

    it { is_expected.to eql(expected) }
  end
end
