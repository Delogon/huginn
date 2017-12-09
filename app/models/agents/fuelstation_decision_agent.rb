module Agents
  class FuelstationDecisionAgent< Agent


    cannot_be_scheduled!

    description <<-MD
    This agent enables the access to the Tankerkoenig API. You need latitude, longitude, a search radius, sort of fuel, the type of searche (distance or price) and an apikey.

    MD

    def default_options
      {}
    end

    def working?
      !recent_error_logs?
    end

    def validate_options
      true
    end

    def get_stations(param, type)
      list= param[type]
      stations= list['stations']
      i = 0
      while i < stations.length
        station= stations[i]
        if station['isOpen'].to_s == 'true'
          koords = [station['lat'], station['lng']]
          return koords
        else
          i+= 1
        end
      end

    end


    def choose_station (param)
      if param['type'] == 'combined' || param['type'] == 'price'
        station = get_stations(param, param['type'])
        dist_station= get_stations(param, 'dist')

        payload= {"key"=> param['key'], "type" => "route", "1" => station, "2" =>  dist_station}
      elsif param['type'] == 'dist'
        station = get_stations(param, param['type'])
        payload= {"key" => param['key'], "type" => "route", "1" => station}
      else
        errors.add(:base, 'Undefiniertes Entscheidungskriterium')
      end
      create_event :payload => payload


    end

    def receive(incomming_events)
      incomming_events.each do |event|
        pl= event.payload
        choose_station(pl)
      end

    end


  end
end

