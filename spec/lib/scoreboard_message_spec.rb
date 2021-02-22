require 'spec_helper'
require 'scoreboard_message'

RSpec.describe ScoreboardMessage do
  describe ".fields" do
    before do
      ScoreboardMessage.fields :command, :test, "this_is_escaped"
    end

    let(:registry) { ScoreboardMessage.registry[ScoreboardMessage] }

    it "assigns into the registry" do
      expect(registry[1]).to eq({name: "test", escaped: false})
    end

    it "creates accessors" do
      message = ScoreboardMessage.new

      expect(message).to respond_to(:test)
      expect(message).to respond_to(:test=)
    end

    it "marks strings as escaped" do
      expect(registry[2][:escaped]).to be(true)
    end
  end

  describe "#map_message_to_fields (private method)" do
    before { ScoreboardMessage.fields(:command, :test, "foo") }

    let(:message) { ScoreboardMessage.new('$TEST,test,"bar"') }

    it "assigns the accessors from each of the parts in the initial string" do
      expect(message.command).to eq("$TEST")
      expect(message.test).to eq("test")
      expect(message.foo).to eq("bar")
    end
  end

  describe "#to_s" do
    before { ScoreboardMessage.fields(:command, :test, "foo") }

    let(:message) { ScoreboardMessage.new(message_string) }
    let(:message_string) { '$TEST,test,"bar"' }

    it "returns the same string if it wasn't modified" do
      expect(message.to_s).to eq("#{message_string}\r\n")
    end

    it "reads from the accessors to build up an a string" do
      message.test = 51
      message.foo = "foobar"

      expect(message.to_s).to eq("$TEST,51,\"foobar\"\r\n")
    end

    it "escapes the escaped fields" do
      message.foo = 51
      expect(message.to_s).to eq("$TEST,test,\"51\"\r\n")
    end
  end
end
