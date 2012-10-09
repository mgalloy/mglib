pro mgffbrightkiteperson::printPlace
  compile_opt strictarr

  print, self.placeName
  print, self.displayLocation
  print, self.latitude + ', ' + self.longitude
end


pro mgffbrightkiteperson::displayPlace
  compile_opt strictarr

  map_set
  map_continents
  plots, self.longitude, self.latitude, psym=1, color='00ffff'x
end


pro mgffbrightkiteperson::characters, chars
  compile_opt strictarr

  if (self.insideName) then self.placeName = chars
  if (self.insideDisplayLocation) then self.displayLocation = chars
  if (self.insideLongitude) then self.longitude = chars
  if (self.insideLatitude) then self.latitude = chars
end


pro mgffbrightkiteperson::endElement, uri, loca, qname
  compile_opt strictarr

  case strlowcase(qname) of
    'place': self.insidePlace = 0B
    'name': if (self.insidePlace) then self.insideName = 0B
    'display_location': if (self.insideDisplayLocation) then self.insideDisplayLocation = 0B
    'longitude': if (self.insidePlace) then self.insideLongitude = 0B
    'latitude': if (self.insidePlace) then self.insideLatitude = 0B
    else:
  endcase
end


pro mgffbrightkiteperson::startElement, uri, local, qname, attName, attValue
  compile_opt strictarr

  case strlowcase(qname) of
    'place': self.insidePlace = 1B
    'name': if (self.insidePlace) then self.insideName = 1B
    'display_location': if (self.insidePlace) then self.insideDisplayLocation = 1B
    'longitude': if (self.insidePlace) then self.insideLongitude = 1B
    'latitude': if (self.insidePlace) then self.insideLatitude = 1B
    else:
  endcase
end


pro mgffbrightkiteperson__define
  compile_opt strictarr

  define = { MGffBrightkitePerson, inherits IDLffXMLSAX, $
             placeName: '', $
             displayLocation: '', $
             longitude: '', $
             latitude: '', $
             insidePlace: 0B, $
             insideName: 0B, $
             insideDisplayLocation: 0B, $
             insideLongitude: 0B, $
             insideLatitude: 0B $
           }
end


pro mg_whereismike
  compile_opt strictarr

  personParser = obj_new('MGffBrightkitePerson')
  personParser->parseFile, 'http://brightkite.com/people/mgalloy.xml', /url
  personParser->printPlace
  personParser->displayPlace
  obj_destroy, personParser
end