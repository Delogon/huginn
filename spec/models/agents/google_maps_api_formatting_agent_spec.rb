require 'rails_helper'

describe Agents::GoogleMapsApiFormattingAgent do

  before(:each) do
    @checker = Agents::GoogleMapsApiFormattingAgent.new
    @checker.user = users(:jane)
    @checker.save!
  end

  describe "#receive" do
    it "parses valid JSON" do
      event = Event.new(payload: { data: '{"test": "data"}' } )
      expect { @checker.receive([event]) }.to change(Event, :count).by(1)
    end


    end

end