module Agents
  class RoutesOutputAgent< Agent
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
      true
    end

    def get_dist(param)
      route= param['route']
      log(route)
      bounds= route[0]
      b= bounds[0]
      legs= b['legs']
      dist= legs[0]
      value= dist['distance']
      value['value'].to_f
    end

    def check(param)
      value= get_dist(param)
      fuel= param['fuel_cap'].to_f * (param['fuel'].to_f/100)
      avg_csmpt= param['avg_csmpt'].to_f
      result= proof(value, fuel, avg_csmpt)
      route= param['route']
      if result

        payload = {'route' => route[0]}
        create_event :payload => payload
      elsif !result
        payload = {'backup_route' => route[1]}
        create_event :payload => payload
      else
        error('no Result')
      end
    end

    def proof(distance, fuel, avg_csmpt)
      fuel_cost= (distance/100000.0)*avg_csmpt
      if fuel_cost < fuel*0.9
        true
      else
        false
      end
    end


    def receive(incoming_events)
      incoming_events.each do |event|
        payload = event.payload
        if payload['finished']
          log(payload)
          check(payload)
        end
      end


    end
  end
end
