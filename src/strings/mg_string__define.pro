; docformat = 'rst'

;+
; Class representing a string and an example of using operator overloading
; available in IDL 8.0. 

; This class does not require IDL 8.0 to compile because an IDL_Object class 
; (which this class inherits from) is provided. Operator overloading will not
; be available when using IDL versions before 8.0, but the methods could be
; called directly.
;
; :Properties:
;    length
;       length of the string
;-


;+
; Get properties.
;
; :Examples:
;    Properties can be access with `.` in IDL 8.0::
;
;       IDL> s = mg_string('Hello, World!')
;       IDL> print, s.length
;                 13
;-
pro mg_string::getProperty, length=length
  compile_opt strictarr
  
  if (arg_present(length)) then length = strlen(self.s)
end


;+
; Returns the underlying IDL string.
;
; :Returns:
;    string
;-
function mg_string::toString
  compile_opt strictarr
  
  return, self.s
end


;+
; Called when a string object is accessed with the square brackets, i.e., 
; `[]`.
; 
; :Examples:
;    For example::
;
;       IDL> s = mg_string('Hello, World!')
;       IDL> print, s[0]                   
;       H
;       IDL> print, s[0:4]
;       Hello
;
; :Returns:
;    IDL string
;
; :Params:
;    isRange : in, required, type=lonarr(1..8)
;       array of the same length as the number of dimensions indexed in the 
;       bracket expression
;    ss1 : in, required, type=long or lonarr(3)
;       index or range of characters to extract
;    ss2 : in, optional, type=long or lonarr(3)
;       not used for strings
;    ss3 : in, optional, type=long or lonarr(3)
;       not used for strings
;    ss4 : in, optional, type=long or lonarr(3)
;       not used for strings
;    ss5 : in, optional, type=long or lonarr(3)
;       not used for strings
;    ss6 : in, optional, type=long or lonarr(3)
;       not used for strings
;    ss7 : in, optional, type=long or lonarr(3)
;       not used for strings
;    ss8 : in, optional, type=long or lonarr(3)
;       not used for strings
;-
function mg_string::_overloadBracketsRightSide, isRange, ss1, ss2, ss3, ss4, $
                                                ss5, ss6, ss7, ss8
  compile_opt strictarr

  if (isRange[0]) then begin
    return, mg_string((byte(self.s))[ss1[0]:ss1[1]:ss1[2]])
  endif else begin
    return, mg_string((byte(self.s))[ss1])
  endelse
end


;+
; Called when the two strings or string objects are joined using a format code
; by the `#` operator.
;
; :Examples:
;    For example::
;
;       IDL> print, mg_string('Location: %s') # 'Boulder, CO'
;       Location: Boulder, CO
;       IDL> print, 'Location: %s' # mg_string('Boulder, CO')
;       Location: Boulder, CO
;
; :Returns:
;    string object
;
; :Params:
;    left : in, required, type=string or string object
;       string on the left of the # operator
;    right : in, required, type=string or string object
;       string on the right of the # operator
;-
function mg_string::_overloadPound, left, right
  compile_opt strictarr

  _left = obj_valid(left) ? left->toString() : left
  _right = obj_valid(right) ? right->toString() : right
     
  return, mg_string(_right, format='(%"' + _left + '")')
end


;+
; Called when two strings or strings objects are concatenated with the `+`
; operator.
;
; :Examples:
;    For example::
;
;       IDL> s1 = mg_string('Hello')       
;       IDL> s2 = mg_string('World!')
;       IDL> print, s1 + s2
;       HelloWorld!
;       IDL> print, s1 + ", " + s2
;       Hello, World!
;
; :Returns:
;    string object
;
; :Params:
;    left : in, required, type=string or string object
;       string on the left of the + operator
;    right : in, required, type=string or string object
;       string on the right of the + operator
;-                                                  
function mg_string::_overloadPlus, left, right
  compile_opt strictarr

  _left = obj_valid(left) ? left->toString() : left
  _right = obj_valid(right) ? right->toString() : right
  
  return, mg_string(_left + _right)
end


;+
; Called by the `HELP` routine when information about this object is required.
;
; :Examples:
;    For example::
;
;       IDL> s = mg_string('Hello, World!')
;       IDL> help, s
;       S               MG_STRING = 'Hello, World!'
;
; :Returns:
;    string
;
; :Params:
;    varname : in, required, type=string
;       name of the variable at the level where `HELP` was called
;-
function mg_string::_overloadHelp, varname
  compile_opt strictarr

  return, string(varname, 'MG_STRING', self->toString(), $
                 format='(%"%-15s %-9s = ''%s''")')  
end


;+
; Called by the `PRINT` routine when this object is printed.
;
; :Examples:
;    For example::
;
;       IDL> s = mg_string('Hello, World!')
;       IDL> print, s                      
;       Hello, World!
;
; :Returns:
;    string
;-
function mg_string::_overloadPrint
  compile_opt strictarr
  
  return, self->toString()
end


;+
; Called by the `FOREACH` routine when this object is looped over.
;
; :Examples:
;    For example::
;
; :Returns:
;    1 if there are more characters in the string, 0 if not
;
; :Params:
;    value : out, required, type=string
;       character returned as the next character in the string
;    key : in, out, optional, type=undefined/long
;       index of current position in the string; undefined for starting
;-
function mg_string::_overloadForeach, value, key
  compile_opt strictarr

  key = n_elements(key) eq 0L ? 0L : (key + 1L)
  status = key lt strlen(self.s)
  if (status) then value = strmid(self.s, key, 1L)
  return, status
end


;+
; Initialize the object.
;
; :Returns:
;    1 if successful, 0 if not
;
; :Params:
;    str : in, required, type=string
;       IDL string to represent
;
; :Keywords:
;    format : in, optional, type=string
;       format string as expected by STRING routine
;-
function mg_string::init, str, format=format
  compile_opt strictarr
  
  self.s = string(str, format=format)
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    s
;       IDL string containing the string to represent
;-
pro mg_string__define
  compile_opt strictarr
  
  define = { MG_String, inherits IDL_Object, s: '' }
end


