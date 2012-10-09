pro mgffbrightkiteplace::displayPlace
  compile_opt strictarr

  lons = self.lons->get(/all)
  lats = self.lats->get(/all)

  limit = [min(lats), min(lons), max(lats), max(lons)]

  map_set, limit=limit
  map_continents
  plots, lons, lats, psym=1, color='00ffff'x
  xyouts, 0.25, 0.8, string(self.ncheckins, format='(%"Checkins: %d")'), /normal
end


pro mgffbrightkiteplace::characters, chars
  compile_opt strictarr

  if (self.insideLongitude) then begin
    self.lons->add, float(chars)
  endif

  if (self.insideLatitude) then begin
    self.lats->add, float(chars)
  endif
end


pro mgffbrightkiteplace::endElement, uri, loca, qname
  compile_opt strictarr

  case strlowcase(qname) of
    'checkin': self.insideCheckin = 0B
    'longitude': if (self.insideCheckin) then self.insideLongitude = 0B
    'latitude': if (self.insideCheckin) then self.insideLatitude = 0B
    else:
  endcase
end


pro mgffbrightkiteplace::startElement, uri, local, qname, attName, attValue
  compile_opt strictarr

  case strlowcase(qname) of
    'checkin': begin
        self.insideCheckin = 1B
        self.ncheckins++
      end
    'longitude': if (self.insideCheckin) then self.insideLongitude = 1B
    'latitude': if (self.insideCheckin) then self.insideLatitude = 1B
    else:
  endcase
end


pro mgffbrightkiteplace::cleanup
  compile_opt strictarr

  obj_destroy, [self.lats, self.lons]
end


function mgffbrightkiteplace::init
  compile_opt strictarr

  if (~self->IDLffXMLSAX::init()) then return, 0

  self.lats = obj_new('MGcoArrayList', type=4)
  self.lons = obj_new('MGcoArrayList', type=4)

  return, 1
end


pro mgffbrightkiteplace__define
  compile_opt strictarr

  define = { MGffBrightkitePlace, inherits IDLffXMLSAX, $
             lats: obj_new(), $
             lons: obj_new(), $
             ncheckins: 0L, $
             insideCheckin: 0B, $
             insideLongitude: 0B, $
             insideLatitude: 0B $
           }
end


pro mg_brightkite_heatmap, place
  compile_opt strictarr

  url = string(place, format='(%"http://brightkite.com/places/%s/objects.xml?filters=checkins")')

  placeParser = obj_new('MGffBrightkitePlace')
  placeParser->parseFile, url, /url
  placeParser->displayPlace
  obj_destroy, placeParser
end


; main-level example program

mg_brightkite_heatmap, 'eeb1943ea22411dd8482fba3141f3ee0'

end

