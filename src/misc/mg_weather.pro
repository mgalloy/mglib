; docformat = 'rst'

;+
; Uses Google weather web service to report the current weather conditions and
; a 4 day forecast.
;
; The raw data from Google looks like::
;
;    <?xml version="1.0"?>
;    <xml_api_reply version="1">
;      <weather module_id="0" tab_id="0" mobile_row="0" mobile_zipped="1" row="0" section="0" >
;        <forecast_information>
;          <city data="Boulder, CO"/>
;          <postal_code data="80303"/>
;          <latitude_e6 data=""/>
;          <longitude_e6 data=""/>
;          <forecast_date data="2010-09-29"/>
;          <current_date_time data="2010-09-29 19:43:27 +0000"/>
;          <unit_system data="US"/>
;        </forecast_information>
;        <current_conditions>
;          <condition data="Sunny"/>
;          <temp_f data="82"/>
;          <temp_c data="28"/>
;          <humidity data="Humidity: 12%"/>
;          <icon data="/ig/images/weather/sunny.gif"/>
;          <wind_condition data="Wind: NE at 16 mph"/>
;        </current_conditions>
;        <forecast_conditions>
;          <day_of_week data="Wed"/>
;          <low data="52"/>
;          <high data="86"/>
;          <icon data="/ig/images/weather/cloudy.gif"/>
;          <condition data="Windy"/>
;        </forecast_conditions>
;        <forecast_conditions>
;          <day_of_week data="Thu"/>
;          <low data="55"/>
;          <high data="81"/>
;          <icon data="/ig/images/weather/sunny.gif"/>
;          <condition data="Sunny"/>
;        </forecast_conditions>
;        <forecast_conditions>
;          <day_of_week data="Fri"/>
;          <low data="54"/>
;          <high data="83"/>
;          <icon data="/ig/images/weather/partly_cloudy.gif"/>
;          <condition data="Partly Cloudy"/>
;        </forecast_conditions>
;        <forecast_conditions>
;          <day_of_week data="Sat"/>
;          <low data="50"/>
;          <high data="77"/>
;          <icon data="/ig/images/weather/sunny.gif"/>
;          <condition data="Sunny"/>
;        </forecast_conditions>
;      </weather>
;    </xml_api_reply>
;-


;+
; Print the information collected during the parsing.
;-
pro mgffweatherparser::print
  compile_opt strictarr, hidden

  print, self.city, self.datetime, format='(%"Weather report for %s (%s)")'
  print, self.current_temp, self.current_condition, $
         format='(%"Current conditions are %s and %s")'

  ; print the forecast
  foreach day, self.forecast_conditions do begin
    print, day['day_of_week'], day['condition'], day['high'], day['low'], $
           format='(%"%s -> %s %s/%s")'
  endforeach
end


;+
; Called by the parser when an XML tag is started.
;-
pro mgffweatherparser::startElement, uri, local, qname, attName, attValue
  compile_opt strictarr, hidden

  case qname of
    ; some information about the forecast itself
    'current_date_time': self.datetime = attValue[0]
    'city': self.city = attValue[0]

     ; determine if we are giving a current condition or a forecast condition
    'current_conditions': self.current = 1B
    'forecast_conditions': begin
        self.current = 0B

        ; forecast conditions add a hash table at the end of the forecast list
        self.forecast_conditions->add, hash()
      end

    ; the only special current condition tag
    'temp_f': self.current_temp = attValue

    ; the forecast condition tags
    'day_of_week': ((self.forecast_conditions)[-1])['day_of_week'] = attValue[0]
    'low': ((self.forecast_conditions)[-1])['low'] = attValue[0]
    'high': ((self.forecast_conditions)[-1])['high'] = attValue[0]

    ; condition is an accepted tag for both current and forecast conditions
    'condition': begin
        if (self.current) then begin
          self.current_condition = attValue
        endif else begin
          ((self.forecast_conditions)[-1])['condition'] = attValue[0]
        endelse
      end
    else:
  endcase

end


;+
; Initialize the weather parser object.
;
; :Returns:
;    1 for success, 0 for failure
;
; :Keywords:
;    _extra : in, optional, type=keywords
;       keywords to IDLffXMLSAX::init
;-
function mgffweatherparser::init, _extra=e
  compile_opt strictarr, hidden

  if (~self->IDLffXMLSAX::init(_extra=e)) then return, 0

  self.forecast_conditions = list()

  return, 1
end


;+
; Define inheritance from IDLffXMLSAX and the instance variables.
;-
pro mgffweatherparser__define
  compile_opt strictarr, hidden

  define = { MGffWeatherParser, inherits IDLffXMLSAX, $
             city: '', $
             datetime: '', $
             current: 0B, $
             current_temp: '', $
             current_condition: '', $
             forecast_conditions: obj_new() $
           }
end


;+
; Print the current conditions and a 4 day forecast for the given location.
;
; :Examples:
;   For example::
;
;      IDL> mg_weather, 'Boulder, CO'
;      Weather report for Boulder, CO at 2010-09-29 22:03:04 +0000
;      Current conditions are 84 and Partly Cloudy
;      Wed -> Clear 83/49
;      Thu -> Sunny 79/50
;      Fri -> Partly Cloudy 81/50
;      Sat -> Sunny 75/46
;
; :Params:
;    location : in, required, type=string
;       zip code or city/state name, like '80303' or 'Boulder, CO'
;-
pro mg_weather, location
  compile_opt strictarr

  ; replace contiguous spaces with a '%20'
  _location = strjoin(strsplit(location, ' ', /extract), '%20')

  ; define the web service call URL
  url = string(_location, format='(%"http://google.com/ig/api?weather=%s")')

  weatherParser = MGffWeatherParser()
  weatherParser->parseFile, url, /url
  weatherParser->print
  obj_destroy, weatherParser
end


; main-level example program

mg_weather, 'Boulder, CO'
mg_weather, '46350'

end

