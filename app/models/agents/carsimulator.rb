module Agents

  class CarSimulatorAgent < Agent

    default_schedule "every_1m"


    def change(param)
      

    end

    def sendevent(param)
      payload = param
      create_event :payload => payload
    end

    def check

    end

    def receive(incoming_events)
      incoming_events.each do |event|
        payload = event.payload
        change(payload)
      end
    end

  end
end