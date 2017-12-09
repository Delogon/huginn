module Agents
  class SafeAgent < Agent
    cannot_be_scheduled!
    cannot_create_events!

    description <<-MD
    Debug

    MD

    event_description <<-MD
      Events look like this:

          {
            "events": [ event list ],
            "message": "Your message"
          }
    MD

    def default_options
      { "no options" => "are needed" }
    end

    def working?
      true
    end

    def validate_options
    end

    def receive(incoming_events)
      memory['events'] ||= []
      incoming_events.each do |event|
        memory['events'] << event
      end
    end


  end
end
