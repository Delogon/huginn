require 'rails_helper'

describe Agents::TankAgentController do

  before(:each) do
    @valid_params = {
        'average_consumption': '7',
        'type': 'combined',
        'type_used': 'dist',
        'fuel_cap': '65'
    }

    @checker = Agents::TankAgentController.new(:name => 'somename', :options => @valid_params, :keep_events_for => 2.days)
    @checker.user = users(:jane)
    @checker.save!


  end

  describe "validations" do
    before do
      expect(@checker).to be_valid
    end

    it "validates that type is combined, dist, or price" do
      @checker.options['average_consumption'] = 'nothing'
      expect(@checker).to_not be_valid
    end
  end
end
