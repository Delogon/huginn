require 'test/spec'
require 'rails_helper'

describe Agents::GoogleMapsApiAgent do
  let(:agent) do
    Agents::GoogleMapsApiAgent.create(
        name: 'gmaps',
        options: {
            'api_key': 'test',
            'start': 'teststraße 1, 12345, Test',
            'end': 'teststraße 2, 12344, testtest'
        }
    ).tap do |agent|
      agent.user = users(:bob)
      agent.save!
    end
  end

  it "creates a valid agent" do
    expect(agent).to be_valid
  end

  it "is valid with put-your-key-here or your-key" do
    agent.options['api_key'] = 'put-your-key-here'
    expect(agent).to be_valid
    expect(agent.working?).to be_falsey

    agent.options['api_key'] = 'your-key'
    expect(agent).to be_valid
    expect(agent.working?).to be_falsey
  end



  end