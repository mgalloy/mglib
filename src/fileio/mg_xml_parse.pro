; docformat = 'rst'

;+
; Parses an URL into a structure. If there are multiple elements of the same
; name at a given level an array of structures is created. For example::
;
;    <numlist>
;      <number>0</number>
;      <number>1</number>
;    </numlist>
;
; should create the same structure as::
;
;    { numlist: replicate({ number: 0}, 2) }
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
pro mgffxmlparser::startElement, uri, local, name, attName, attValue
  compile_opt strictarr

  if (n_elements(*self.struct) eq 0L) then begin
    if (n_elements(attName) eq 0L) then begin
      atts = ''
    endif else begin
      for i = 0L, n_elements(attName) - 1L do begin
        if (n_elements(atts) eq 0L) then begin
          atts = create_struct(attName[i], attValue[i])
        endif else begin
          atts = create_struct(atts, attName[i], attValue[i])
        endelse
      endfor
    endelse

    *self.struct = create_struct(name, atts)
  endif else begin
  endelse
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
pro mgffxmlparser::endElement, uri, local, name
  compile_opt strictarr

end


;+
; Called to process character data in an XML file.
;
; :Params:
;   chars : in, required, type=string
;     characters detected by parser
;-
pro mgffxmlparser::characters, chars
  compile_opt strictarr

end


;= helper methods

;+
; Get result.
;
; :Returns:
;   structure
;-
function mgffxmlparser::getResult
  compile_opt strictarr

  return, *self.struct
end


;= lifecycle methods

;+
; Free resources.
;-
pro mgffxmlparser::cleanup
  compile_opt strictarr

  self->idlffxmlsax::cleanup
  ptr_free, self.struct
end


;+
; Creates an XML parser.
;
; :Returns:
;   1 if successful, 0 otherwise
;
; :Keywords:
;   _extra : in, optional, type=keywords
;     `IDLffSMLSAX::init` keywords
;-
function mgffxmlparser::init, _extra=e
  compile_opt strictarr

  if (~self->idlffxmlsax::init(_extra=e)) then return, 0

  self.struct = ptr_new(/allocate_heap)

  return, 1
end


;+
; Define instance variables.
;-
pro mgffxmlparser__define
  compile_opt strictarr

  define = { MGffXMLParser, inherits IDLffXMLSAX, $
             currentPath: '', $
             struct: ptr_new() $
           }
end


;+
; Parse an XML file into a structure.
;
; :Returns:
;   structure
;
; :Params:
;   input : in, required, type=string
;     filename, URL or actual contents of the XML to parse
;
; :Keywords:
;   url : in, optional, type=boolean
;     set to specify that input is an URL
;   xml_string : in, optional, type=boolean
;     set to specify that input is a string containing XML
;-
function mg_xml_parse, input, url=url, xml_string=xmlString
  compile_opt strictarr

  parser = obj_new('MGffXMLParser')
  parser->parseFile, input, url=url, xml_string=xmlString
  result = parser->getResult()
  obj_destroy, parser
  return, result
end


; main-level example program

url = 'http://brightkite.com/people/mgalloy.xml'
s = mg_xml_parse(url, /url)
mg_help, s

end
