require 'spec_helper'

RSpec.describe Result do
  subject { result }

  let(:result) { create(:result, points: 5) }

  describe ".points_with_adjustments" do
    let!(:adjustment) { create(:points_adjustment,
                              race_id: result.race_id,
                              registration_id: result.registration_id,
                              points: 3) }

    it "returns the point total with adjustments" do
      expect(subject.points_with_adjustments).to equal(8)
    end

  end
end
