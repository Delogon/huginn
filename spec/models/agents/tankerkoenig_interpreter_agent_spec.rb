require 'rails_helper'

describe Agents::TankerkoenigInterpreterAgent do
  let(:agent) do
    Agents::TankerkoenigInterpreterAgent.create(
        name: 'tank',
    ).tap do |agent|
      agent.user = users(:bob)
      agent.save!
    end
  end

end
