require 'json'
require 'httparty'

module Agents
  class TankerkoenigAgent < Agent
    cannot_be_scheduled!

    description <<-MD
    This agent enables the access to the Tankerkoenig API. You need latitude, longitude, a search radius, sort of fuel, the type of searche (distance or price) and an apikey.

    MD

    event_description <<-MD
    
      The Events that are received look like this:
        {
         "type": "price",
         "lat": "53.1434501",
         "lng": "8.2145521",
         "fuel": "20",
         "key": 20171103175515000
        }

       This Agent creates Events that look like this:
      
        { 
          "key": 20171103175515000
          "stations": [
            {
              "id": "458e54f6-0894-4e4b-a2ec-84d3ce0dd1a5",
              "name": "Raiffeisen Tungeln",
              "brand": "Raiffeisen Tungeln",
              "street": "Hundsmühler Landstr.",
              "place": "Wardenburg",
              "lat": 53.0939,
              "lng": 8.19,
              "dist": 5.7,
              "price": 1.129,
              "isOpen": true,
              "houseNumber": "8",
              "postCode": 26203
            },
            {
              "id": "ede4b796-e3f9-49ee-7735-1f6032ba0d6a",
              "name": "Tank & Waschcenter",
              "brand": "Tank und Waschcenter",
              "street": "Schwarzer Weg",
              "place": "Metjendorf",
              "lat": 53.185449,
              "lng": 8.180667,
              "dist": 5.2,
              "price": 1.139,
              "isOpen": false,
              "houseNumber": "1",
              "postCode": 26215
            },
            {
              "id": "5f900d17-672a-5053-87e7-aea7a2bbcdd1",
              "name": "Oldenburg",
              "brand": "Hoyer",
              "street": "Scheideweg",
              "place": "Oldenburg",
              "lat": 53.16849136353,
              "lng": 8.21372032166,
              "dist": 2.8,
              "price": 1.159,
              "isOpen": true,
              "houseNumber": "100",
              "postCode": 26127
            },
          }

    MD

    def default_options
      {
          'api_key': '8b8b4900-64c0-44b3-7f84-f5ea2220a9da',
          'rad': '10',
      }
    end

    def working?
      !recent_error_logs?
    end

    def validate_options
      errors.add(:base, "API Key is required") unless options['api_key'].present?
      errors.add(:base, "Radius is required") unless options['rad'].present?
      errors.add(:base, "Radius has to be a number") unless options['rad'].is_a?(Float) || options['rad'].is_a?(Integer)
    end

    def request_url(lat, lng, type, radius)
      "https://creativecommons.tankerkoenig.de/json/list.php?lat=#{lat}&lng=#{lng}&rad=#{radius}&sort=#{type}&type=diesel&apikey=#{interpolated[:api_key].to_s}"
    end

    def send_event(info, data)
      payload = {"type"=> info['type'], "key"=> info['key'], "data"=> data}
      create_event :payload => payload
    end

    def check_empty(list)
      if list['stations'].nil?
        false
      else
        list['stations'].first.nil? ?  false : true
      end
    end

    def check(param)
      list = Hash.new
      radius = interpolated[:rad].to_f
      events= Hash.new
      until check_empty(events)

        r = radius
        response = HTTParty.get(request_url(param['lat'], param['lng'], 'price', r))
        events = JSON.parse response.body
        events['ok'] ? list['price_list']= events : errors.add(:base, "Übertragung fehlgeschlagen")
        radius += interpolated[:rad].to_f/2.0
        log(events)
        log(radius)
        sleep(10)
      end


      response = HTTParty.get(request_url(param['lat'], param['lng'], 'dist',radius))
      events = JSON.parse response.body
      events['ok'] ? list['dist_list']= events : errors.add(:base, "Übertragung fehlgeschlagen")
      list
    end


    def receive(incoming_events)
      incoming_events.each do |event|
        new_event = event.payload
        log(event.agent)
        list = check(new_event)
        send_event(new_event, list)
      end
    end


  end


end