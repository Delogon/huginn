require 'google_maps_service'

module Agents
  class GoogleMapsApiAgent < Agent
    cannot_be_scheduled!

    description <<-MD
    This agent enables the access to the GoogleMaps API. You need a start address and a address for your endpoint. and ofcourse an apikey.

    MD

    def default_options
      {
          'api_key': 'AIzaSyC759CAxTJzAcFheoHXX2GjimqyebfOL_4'

      }
    end

    def working?
      !recent_error_logs?
    end

    def validate_options
      errors.add(:base, "API Key is required") unless options['api_key'].present?
    end


    def check (param)
      routes= Array.new
      c= param['coords']
      until c.empty? do
        coord= c.shift
        route= get_routes(coord['start'], coord['dest'])
        routes.push(route)
      end
      send_event(routes, param)
    end



    def get_routes (origin, destination)
      gmaps = GoogleMapsService::Client.new(key: interpolated[:api_key].to_s)
      gmaps.directions(
                origin,
                destination,
                mode: 'driving',
                alternatives: false)
    end

    def send_event(routes, param)
      payload = {"type"=> 'response', "key" => param['key'], "avg_csmpt" => param['avg_csmpt'], "fuel_cap" => param['fuel_cap'], "fuel" => param['fuel'], "route" => routes}
      create_event :payload => payload

    end

    def receive(incoming_events)
      incoming_events.each do |event|
        new_event = event.payload
        log(new_event)
        unless new_event['finished']
          check(new_event)
        end

      end
    end
  end
end

