require 'rails_helper'

describe Agents::FuelingCostsAgent do
  before(:each) do
    @checker = Agents::FuelingCostsAgent.new(:name => "somename", :options => Agents::FuelingCostsAgent.new.default_options)
    @checker.user = users(:jane)
    @checker.save!
  end

  it "event description does not throw an exception" do
    expect(@checker.event_description).to include('parsed')
  end

  describe "validating" do
    before do
      expect(@checker).to be_valid
    end

    it "requires data to be present" do
      @checker.options['api_key'] = ''
      expect(@checker).not_to be_valid
    end
  end

  context '#working' do
    it 'is not working without having received an event' do
      expect(@checker).not_to be_working
    end

    it 'is working after receiving an event without error' do
      @checker.last_receive_at = Time.now
      expect(@checker).to be_working
    end
  end

  describe "#receive" do
    it "parses valid JSON" do
      event = Event.new(payload: { data: '{ "api_key": "00000000-0000-0000-0000-000000000002", "vehicle_id": "1", "lat": "52.52099975265203", "lng":"13.43803882598877", "rad": "2", "type": "diesel"}' } )
      expect { @checker.receive([event]) }.to change(Event, :count).by(1)
    end

    it "writes to the error log when the JSON could not be parsed" do
      event = Event.new(payload: { data: '{ "api_key": "00000000-0000-0000-0000-000000000002", "vehicle_id": "1", "lat": "52.52099975265203", "lng":"13.43803882598877", "rad": "2", "type": "diesel"}' } )
      expect { @checker.receive([event]) }.to change(AgentLog, :count).by(1)
    end
  end
end
