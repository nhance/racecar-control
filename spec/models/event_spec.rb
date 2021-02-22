require 'spec_helper'

RSpec.describe Event do
  context "crazy associations" do
    describe "#cars" do
      let(:event)         { create(:event) }
      let(:car)           { create(:car) }
      let!(:registration) { create(:registration, event: event, car: car) }

      it "associates cars with events through registrations" do
        expect(event.cars).to eq([car])
      end
    end
  end

  context "scopes" do
    describe ".current" do
      it "returns an event in progress, started 2 days ago" do
        current_event = create(:event, start_date: 2.days.ago)
        expect(Event.current).to eq(current_event)
      end

      it "returns an event with a start date before today and ending today" do
        future_event = create(:event, start_date: 2.weeks.from_now)
        current_event = create(:event, start_date: 1.day.ago, stop_date: 2.days.from_now)

        expect(Event.current).to eq(current_event)
      end

      it "does not return an event with a stop date prior to today" do
        past_event = create(:event, start_date: 2.days.ago, stop_date: 1.day.ago)
        expect(Event.current).to eq(nil)
      end

      it "returns an event that starts tomorrow" do
        current_event = create(:event, start_date: 1.day.from_now)
        expect(Event.current).to eq(current_event)
      end
    end
  end
end
