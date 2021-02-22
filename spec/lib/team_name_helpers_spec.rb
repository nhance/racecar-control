require 'spec_helper'
require 'team_name_helpers'
require 'scoreboard_message'
require 'scoreboard_message/a'

RSpec.describe TeamNameHelpers do
  let(:klass) { ScoreboardMessage::A }
  subject { klass.new }

  describe ".driver_name" do
    it "is equal to last_name" do
      subject.last_name = "foobar"
      expect(subject.driver_name).to eq "foobar"
    end
  end

  describe ".driver_name=" do
    it "is trimmed to 30 characters" do
      fifty = "a" * 50
      subject.driver_name = fifty

      expect(subject.driver_name.length).to be 30
    end

    it "assigns to last_name" do
      subject.driver_name = "foobar"

      expect(subject.last_name).to eq 'foobar'
    end
  end

  describe ".team_name" do
    it "is equal to first_name" do
      subject.first_name = "foobar"
      expect(subject.team_name).to eq "foobar"
    end
  end

  describe ".team_name=" do
    it "is trimmed to 30 characters" do
      fifty = "a" * 50
      subject.team_name = fifty

      expect(subject.team_name.length).to be 30
    end
  end
end
