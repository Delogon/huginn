require 'test/spec'
require 'rails_helper'

describe Agents::TankerkoenigAgent do
  let(:agent) do
    Agents::TankerkoenigAgent.create(
        name: 'tank',
        options: {
            :location => 26129,
            :lat => 53.1434501,
            :lng => 8.2145521,
            :api_key => 'test'
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