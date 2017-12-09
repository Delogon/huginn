module Agents
  class TankerkoenigFormattingAgent < Agent
    cannot_be_scheduled!

    description <<-MD
    This agent enables the access to the Tankerkoenig API. You need latitude, longitude, a search radius, sort of fuel, the type of searche (distance or price) and an apikey.

    MD

    def default_options
      {
          'no Options': 'needed'
      }
    end


    def working?
      !recent_error_logs?
    end


    def formatting(data, type, key)
      output = {"key" => key, "type" => type, }

      price_list = data['price_list']
      pstations = price_list['stations']
      output['price'] = {"stations" => pstations}


      dist_list = data['dist_list']
      dstations = dist_list['stations']
      output['dist'] = {"stations" => dstations}


      if !data['price_list'].nil? && !data['dist_list'].nil?
        output['combined'] ={"stations" => combine(pstations, dstations)}
      else
        errors('Keine Daten vorhanden')
      end
      output
      #end

    end

    def combine(price, distance)
      combined= Array.new
      i= 0
      maxpricelist= price.length
      maxdistancelist= distance.length
      while i < maxpricelist do
        j= 0
        entry = price[i]
        id = entry[:id]
        while j < maxdistancelist do
          e = distance[j]
          eid = e[:id]
          if eid == id #&& e['isOpen'].to_s == 'true'
            entry['index']= i+j
            combined.push(entry)
            combined = combined.sort_by! {|k| k['index']}
          end
          j+= 1
        end
        i+= 1
      end
      combined
    end

    def send_event(param)
      create_event :payload => param
    end

    def receive(incoming_events)
      incoming_events.each do |event|
        payload = event.payload
        log(payload)
        formatted = formatting(payload['data'], payload['type'], payload['key'])
        send_event(formatted)
      end
    end
  end
end
