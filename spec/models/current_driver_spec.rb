require 'spec_helper'

RSpec.describe CurrentDriver do
  describe ".driving_car" do
    context "with results" do
      let(:event)        { create(:event, :current) }
      let(:registration) { create(:registration, car_number: "51", event: event) }
      let!(:prior_scan)  { create(:scan, registration: registration, created_at: 2.hours.ago) }
      let(:scan)         { create(:scan, registration: registration) }
      let!(:driver)      { scan.driver }

      subject { CurrentDriver::driving_car(51) }

      it "returns a Driver instance" do
        expect(subject).to be_kind_of(Driver)
      end

      it "returns the driver driving the car number" do
        expect(subject).to eq(driver)
      end
    end
  end
end
