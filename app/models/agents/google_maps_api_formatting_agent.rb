module Agents
class GoogleMapsApiFormattingAgent < Agent


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


  def save_informations(param)
    log('save_informations')
    memory[param['key']] = {"type" => param['type'], "start" => [param['lat'].to_f, param['lng'].to_f], "avg_csmpt" => param['avg_csmpt'], "fuel_cap" => param['fuel_cap'], "fuel" => param['fuel']}
    save!

  end

  def start_planer(param)
    log('start_planer')
    log(param)
    s = memory[param['key']]
    if s['type'] == 'dist'
      start = s['start'].join(", ")
      d = param['1']
      dest = [d[0], d[1]]
      dest = dest.join(", ")
      coord = [{"start" => start, "dest" => dest}]
      log(coord)
      send_route_event(coord, param)
    else
      start = s['start'].join(", ")
      d = param['1']
      dest = [d[0], d[1]]
      dest = dest.join(", ")
      coord = {"start" => start, "dest" => dest}

      backup = param['2']
      log(backup)
      backup_dest = [backup[0], backup[1]]
      backup_dest = backup_dest.join(", ")
      backup_coord = {"start" => start, "dest" => backup_dest}

      coords = [coord, backup_coord]
      send_route_event(coords, param)
    end
  end

  def send_route_event(coords, param)
    log('send_route_event')
    mem = memory[param['key']]
      payload = {"finished" => false, "key" => param['key'],"avg_csmpt" => mem['avg_csmpt'], "fuel_cap" => mem['fuel_cap'], "fuel" => mem['fuel'], "coords" => coords}
      create_event :payload => payload
  end

  def send_event(param)
    log('send_event')
    log(param)
    mem = memory[param['key']]
    payload = {"finished" => true, "key" => param['key'], "avg_csmpt" => mem['avg_csmpt'], "fuel_cap" => mem['fuel_cap'], "fuel" => mem['fuel'], "route" => param['route']}
    create_event :payload => payload
  end


  def check(param)
    log('check')
    if param['type'].to_s == 'price' || param['type'].to_s == 'dist' || param['type'].to_s == 'combined'
      save_informations(param)
    elsif param['type'] == 'route'
      start_planer(param)
    elsif param['type'] == 'response'
      send_event(param)
    end

  end


  def receive(incoming_events)
    incoming_events.each do |event|
      new_event = event.payload
      log(new_event)
      check(new_event)
    end
  end








end
  end