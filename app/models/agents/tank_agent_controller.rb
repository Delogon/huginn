require 'securerandom'

module Agents
  class TankAgentController <Agent
    cannot_be_scheduled!

    description <<-MD
    This agent is used as a controller for a fuelagentsystem.

It is used as an interface to the vehicle and receives the vehicle data. If the fuel tank reaches a critical point, it will send an event.

This agent needs the following informations:

    * `avg_csmpt` - the average consumption of the vehicle
    
    * `type` - The type which should be used for the decision which fuel station fits the best when the car is not used. Choose price, dist or combined

    * `type_used` - The type which should be used for the decision which fuel station fits the best when the car is used. Choose price, dist or combined

    * `fuel_cap` - the maximum fuel tank capacity 

    MD

    def default_options
      {
          'average_consumption': '7',
          'type': 'combined',
          'type_used': 'dist',
          'fuel_cap': '65'
      }
    end

    def working?
      !recent_error_logs?
    end

    def validate_options
      errors.add(:base, "Der Durchschnittsverbrauch wird benötigt") unless !options['average_consumption'].nil?
      errors.add(:base, "Der Durchschnittsverbrauch muss eine Zahl sein") unless options['average_consumption'].is_a?(Integer) || options['average_consumption'].is_a?(Float)
      errors.add(:base, "Entscheidugnskriterium für Fahrzeug ohne Fahrauftrag wird benötigt") unless !options['type'].nil?
      errors.add(:base, "Entscheidugnskriterium für Fahrzeug mit Fahrauftrag wird benötigt") unless !options['type_used'].nil?
      errors.add(:base, "Gesamtgröße des Tanks wird benötigt") unless !options['fuel_cap'].nil?
      if !options['type'] == 'price' || !options['type'] == 'dist' || !options['type'] == 'combined'
        errors.add(:base, "Entscheidungskriterium für Fahrzeuge ohne Fahrauftrag können nur 'price', 'dist' oder 'combined' sein")
      end
      if !options['type_used'] == 'price' || !options['type_used'] == 'dist' || !options['type_used'] == 'combined'
        errors.add(:base, "Entscheidungskriterium für Fahrzeuge mit Fahrauftrag können nur 'price', 'dist' oder 'combined' sein")
      end
    end


    def check_status(param, id)
      if memory['process'].nil?
        check_fuel(param, id)
      else
        entry = memory['process']
        if entry['found_routes'] == false && (Time.parse(entry['time'])-Time.now).to_i.abs > 120
          check_fuel(param, id)
        elsif entry['found_routes'] == true && param['fuel'].to_i > 10
          memory.clear
          save!
        else
          check_fuel(param, id)
        end
      end
    end


    def check_fuel(param, id)
      log('check')
      if param['fuel'].to_i <= 5 && !param['fuel'].nil?
        payload = {"type" => "dist", "lat" => param['lat'], "lng" => param['lng'], "fuel" => param['fuel'], "avg_csmpt" => param['avg_csmpt']}
        send_event(payload, id)
        memory['process']= {"found_routes" => false, "time" => Time.now}
        save!
      elsif param['fuel'].to_i > 5 && param['fuel'].to_i < 11
        if param['used'] == 'false'
          payload = {"type" => interpolated[:type], "lat" => param['lat'], "lng" => param['lng'], "fuel" => param['fuel'], "avg_csmpt" => param['avg_csmpt'], "fuel_cap"=> interpolated[:fuel_cap]}
          send_event(payload, id)
          memory['process']= {"found_routes" => false, "time" => Time.now}
          save!
        elsif param['used'] == 'true'
          log('used = true')
          payload = {"type" => interpolated[:type_used], "lat" => param['lat'], "lng" => param['lng'], "fuel" => param['fuel'], "avg_csmpt" => param['avg_csmpt'], "fuel_cap"=> interpolated[:fuel_cap]}
          send_event(payload, id)
          memory['process']= {"found_routes" => false, "time" => Time.now}
          save!
        else
          error('Undefined Usage Status')

        end
      end
    end

    def generate_id

      random = SecureRandom.uuid.to_s
      random.to_s
    end

    def send_event(param, id)
      param.merge!(key: id)
      create_event :payload => param
    end


    def receive(incoming_events)
      incoming_events.each do |event|
        payload = event.payload

        if payload['finished']
          log('finished')
          mem = memory['process']
          mem['found_routes']= true
          memory['process']= mem
          save!
        elsif !payload['finished'] && !payload['finished'].nil?
          log('false')
          return
        else
          log('new round')
          id = generate_id
          check_status(payload, id)
        end
      end
    end


  end
end


