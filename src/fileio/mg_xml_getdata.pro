; docformat = 'rst'

;+
; Returns an individual element or attribute's value.
;-

;= IDLffXMLSAX parser methods

;+
; Called to process the opening of a tag.
;
; :Params:
;   uri : in, required, type=string
;     namespace URI
;   local : in, required, type=string
;     element name with prefix removed
;   name : in, required, type=string
;     element name
;   attName : in, optional, type=strarr
;     names of attributes
;   attValue : in, optional, type=strarr
;     attribute values
;-
pro mgffxmlitemparser::startElement, uri, local, name, attName, attValue
  compile_opt strictarr

  self.currentPath += '/' + name

  pathIndex = self.counts->get(self.currentPath, found=pathFound)
  newIndex = pathFound gt 0L ? ++pathIndex : 0L
  self.counts->put, self.currentPath, newIndex

  self.currentPath += '[' + strtrim(newIndex, 2) + ']'

  if (self.currentPath eq self.itemPath && self.itemAttribute ne '') then begin
    if (n_elements(attName) gt 0) then begin
      ind = where(attName eq self.itemAttribute, nAttFound)
      if (nAttFound gt 0) then begin
        self.result = attValue[ind[0]]
        self.found = 1B
      endif
    endif
  endif
end


;+
; Called to process the closing of a tag.
;
; :Params:
;   uri : in, required, type=string
;     namespace URI
;   local : in, required, type=string
;     element name with prefix removed
;   name : in, required, type=string
;     element name
;-
pro mgffxmlitemparser::endElement, uri, local, name
  compile_opt strictarr

  slashPos = strpos(self.currentPath, '/', /reverse_search)
  self.currentPath = strmid(self.currentPath, 0, slashPos)
end


;+
; Called to process character data in an XML file.
;
; :Params:
;   chars : in, required, type=string
;     characters detected by parser
;-
pro mgffxmlitemparser::characters, chars
  compile_opt strictarr

  if (self.currentPath eq self.itemPath && self.itemAttribute eq '') then begin
    self.result = chars
    self.found = 1B
  endif
end


;= helper methods

;+
; Set the search item.
;
; :Params:
;   item : in, required, type=string
;     set the item to search for
;-
pro mgffxmlitemparser::setItem, item
  compile_opt strictarr
  on_error, 2

  itemTokens = strsplit(item, '.', /extract, count=nTokens)
  if (nTokens gt 2L) then begin
    message, 'only one . allowed to indicate an attribute'
  endif

  ; add [0] for items that don't already have an index
  self.itemPath = mg_streplace(itemTokens[0], '([^]])/', '$1[0]/', /global)
  self.itemPath = mg_streplace(self.itemPath, '([^]])$', '$1[0]', /global)

  ;self.itemPath = itemTokens[0]
  self.itemAttribute = nTokens lt 2 ? '' : itemTokens[1]
end


;+
; Get result.
;
; :Returns:
;   string
;
; :Keywords:
;   found : out, optional, type=boolean
;     set to a named variable to retrieve whether the result was found
;-
function mgffxmlitemparser::getResult, found=found
  compile_opt strictarr

  found = self.found
  return, self.result
end


;= lifecycle methods

;+
; Free resources.
;-
pro mgffxmlitemparser::cleanup
  compile_opt strictarr

  self->idlffxmlsax::cleanup
  obj_destroy, self.counts
end


;+
; Creates an XML item parser.
;
; :Returns:
;   1 if successful, 0 otherwise
;
; :Keywords:
;   _extra : in, optional, type=keywords
;     `IDLffSMLSAX::init` keywords
;-
function mgffxmlitemparser::init, _extra=e
  compile_opt strictarr

  if (~self->idlffxmlsax::init(_extra=e)) then return, 0

  self.counts = obj_new('MGcoHashTable', key_type=7, value_type=3)

  return, 1
end


;+
; Define instance variables.
;-
pro mgffxmlitemparser__define
  compile_opt strictarr

  define = { MGffXMLItemParser, inherits IDLffXMLSAX, $
             currentPath: '', $
             itemPath: '', $
             itemAttribute: '', $
             result: '', $
             found: 0B, $
             counts: obj_new() $
           }
end


;+
; Returns a specific element or attribute's value from an XML file.
;
; :Returns:
;   string
;
; :Params:
;   input : in, required, type=string
;     filename, URL or actual contents of the XML to parse
;   item : in, required, type=string
;     item from the file to retrieve; using the notation that / separates
;     elements, [n] are used to indicate the nth element of that type, and .
;     indicates an attribute, for example, in the file::
;
;       <numlist>
;         <number>0</number>
;         <number attr="int">1</number>
;         <number>2</number>
;       </numlist>
;
;     Then "/numlist/number[1].attr" returns "int". If no index is given,
;     [0] is assumed.
;
; :Keywords:
;   found : out, optional, type=boolean
;     returns 1 if the item was found, 0 if not
;   url : in, optional, type=boolean
;     set to specify that input is an URL
;   xml_string : in, optional, type=boolean
;     set to specify that input is a string containing XML
;-
function mg_xml_getdata, input, item, found=found, $
                         url=url, xml_string=xmlString
  compile_opt strictarr

  parser = obj_new('MGffXMLItemParser')
  parser->setItem, item
  parser->parseFile, input, url=url, xml_string=xmlString
  result = parser->getResult(found=found)
  obj_destroy, parser
  return, result
end


; main-level example program

f = file_which('num_array.xml')
print, mg_xml_getdata(f, '/array/number[7]')

url = 'http://brightkite.com/people/mgalloy.xml'
print, mg_xml_getdata(url, '/person/place/name', /url)

end
