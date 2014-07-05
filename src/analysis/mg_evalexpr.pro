; docformat = 'rst'

;+
; Evaluates a mathematical expression using the basic arithmetic operators
; +, -, *, /, and ^ along with parentheses for grouping and simple function
; calls of a single variable.
;
; This routine does not use `EXECUTE`, so it is safe to use in the Virtual
; Machine.
;
; :Examples:
;   For example, simple arithmetic expressions can be evaluated::
;
;     IDL> print, mg_evalexpr('1 + 2 + 3', error=error), error
;                          6       0
;
;   Note that the `ERROR` keyword returns whether there was an error in
;   evaluating the expression. Expressions can also take variables, if their
;   values are provided via a structure or hash-like object::
;
;     IDL> print, mg_evalexpr('exp(i * pi)', { pi: !dpi, i: complex(0, 1) })
;     (      -1.0000000,   1.2246468e-16)
;
; :Bugs:
;   does not support functions of multiple variables
;
; :Author:
;   Michael D. Galloy, 2012
;
; :Requires:
;   IDL 8.0
;-


;+
; Given a starting position in a string representing an expression, returns
; the next token.
;
; :Returns:
;   string, double, long64, or `!null` if no tokens left
;
; :Private:
;
; :Params:
;   expr : in, required, type=string
;     mathematical expression to parse
;   start_index : in, required, type=long
;     index to start looking for the next token at
;
; :Keywords:
;   length : out, optional, type=long
;     set to a named variable to get the length of the returned token from
;     `start_index`, i.e., it might include whitespace and hence by longer
;     than the actual length of the return token; this is the value to
;     advance the `start_index` to find the next token
;-
function mg_evalexpr_parse, expr, start_index, length=length
  compile_opt strictarr

  if (start_index ge strlen(expr)) then begin
    length = 0
    return, !null
  endif

  char = strmid(expr, start_index, 1)
  bchar = (byte(char))[0]

  ; whitespace

  if (char eq ' ') then begin
    result = mg_evalexpr_parse(expr, start_index + 1, length=slength)
    length = slength + 1
    return, result
  endif

  ; operator/symbol

  if (char eq '(' || char eq ')' $
        || char eq '+' || char eq '-' or char eq '*' || char eq '/' $
        || char eq '^') then begin
    length = 1
    return, char
  endif

  ; number

  ; ASCII 48 = '0', ASCII 57 = '9'
  if (char eq '.' || (bchar ge 48 && bchar le 57)) then begin
    i = start_index + 1
    done = 0
    while (i lt strlen(expr) && ~done) do begin
      char = strmid(expr, i, 1)
      bchar = (byte(char))[0]
      done = (char eq '.' || (bchar ge 48 && bchar le 57)) eq 0
      if (~done) then i++
    endwhile
    length = i - start_index
    value = strmid(expr, start_index, length)
    if (strpos(value, '.') lt 0) then begin
      return, long64(value)
    endif else begin
      return, double(value)
    endelse
  endif

  ; name

  ; ASCII 65 = 'a', ASCII 90 = 'z', ASCII 97 = 'A', ASCII 122 = 'Z'
  if (char eq '_' $
        || (bchar ge 65 && bchar le 90) $
        || (bchar ge 97 && bchar le 122)) then begin
    i = start_index + 1
    done = 0
    while (i lt strlen(expr) && ~done) do begin
      char = strmid(expr, i, 1)
      bchar = (byte(char))[0]
      done = (char eq '_' $
                || (char eq '$') $
                || (bchar ge 65 && bchar le 90) $
                || (bchar ge 97 && bchar le 122)) eq 0
      if (~done) then i++
    endwhile
    length = i - start_index
    return, strmid(expr, start_index, length)
  endif
end


;+
; Lookup the value for given name in a set of values provided by a structure
; or hash-like object.
;
; :Private:
;
; :Returns:
;   value of variable or `!null` if not found
;
; :Params:
;   name : in, required, type=string
;     name of variable to lookup
;   vars : in, required, type=structure/object
;     either a structure or a hash-like object, i.e., an object that has a
;     `hasKey` method and implements the right-side bracket operators to
;     retrieve a value for a given name
;
; :Keywords:
;   found : out, optional, type=boolean
;     set to a named variable to return whether the name was found
;-
function mg_evalexpr_lookup, name, vars, found=found
  compile_opt strictarr
  on_error, 2

  if (size(vars, /type) eq 8) then begin
    tags = tag_names(vars)
    ind = where(tags eq strupcase(name), count)
    found = count gt 0
    return, found ? vars.(ind[0]) : !null
  endif else if (size(vars, /type) eq 11) then begin
    found = vars->hasKey(name)
    return, found ? vars[name] : !null
  endif else begin
    found = 0
    message, 'unknown variable table type'
  endelse
end


;+
; Evaluate an expression.
;
; :Private:
;
; :Returns:
;   double or long64
;
; :Params:
;   stack : in, required, type=list object
;     current stack of parser tokens
;   pos : in, out, required, type=long
;     current position on the stack
;   vars : in, required, type=structure/object
;     structure or hash-like object which defines the values of variables in
;     the expression
;-
function mg_evalexpr_expr, stack, pos, vars
  compile_opt strictarr

  value = mg_evalexpr_term(stack, pos, vars)
  while (pos lt stack->count() && (stack[pos] eq '+' || stack[pos] eq '-')) do begin
    if (size(stack[pos], /type) eq 7) then begin
      if (stack[pos] eq '+') then begin
        pos++
        value += mg_evalexpr_term(stack, pos, vars)
      endif else if (stack[pos] eq '-') then begin
        pos++
        value -= mg_evalexpr_term(stack, pos, vars)
      endif
    endif
  endwhile

  return, value
end


;+
; Evaluate a exponent.
;
; :Private:
;
; :Returns:
;   double or long64
;
; :Params:
;   stack : in, required, type=list object
;     current stack of parser tokens
;   pos : in, out, required, type=long
;     current position on the stack
;   vars : in, required, type=structure/object
;     structure or hash-like object which defines the values of variables in
;     the expression
;-
function mg_evalexpr_superscript, stack, pos, vars
  compile_opt strictarr
  on_error, 2

  value = mg_evalexpr_factor(stack, pos, vars)
  while (pos lt stack->count() && stack[pos] eq '^') do begin
    if (stack[pos] eq '^') then begin
      pos++
      value ^= mg_evalexpr_superscript(stack, pos, vars)
    endif
  endwhile

  return, value
end


;+
; Evaluate a term.
;
; :Private:
;
; :Returns:
;   double or long64
;
; :Params:
;   stack : in, required, type=list object
;     current stack of parser tokens
;   pos : in, out, required, type=long
;     current position on the stack
;   vars : in, required, type=structure/object
;     structure or hash-like object which defines the values of variables in
;     the expression
;-
function mg_evalexpr_term, stack, pos, vars
  compile_opt strictarr
  on_error, 2

  value = mg_evalexpr_superscript(stack, pos, vars)
  while (pos lt stack->count() && (stack[pos] eq '*' || stack[pos] eq '/')) do begin
    if (size(stack[pos], /type) eq 7) then begin
      if (stack[pos] eq '*') then begin
        pos++
        value *= mg_evalexpr_superscript(stack, pos, vars)
      endif else if (stack[pos] eq '/') then begin
        pos++
        value /= mg_evalexpr_superscript(stack, pos, vars)
      endif
    endif
  endwhile

  return, value
end


;+
; Evaluate a factor.
;
; :Private:
;
; :Returns:
;   double or long64
;
; :Params:
;   stack : in, required, type=list object
;     current stack of parser tokens
;   pos : in, out, required, type=long
;     current position on the stack
;   vars : in, required, type=structure/object
;     structure or hash-like object which defines the values of variables in
;     the expression
;-
function mg_evalexpr_factor, stack, pos, vars
  compile_opt strictarr
  on_error, 2

  if (size(stack[pos], /type) eq 5 || size(stack[pos], /type) eq 14) then begin
    factor = stack[pos]
    pos++
  endif else if (size(stack[pos], /type) eq 7 && stack[pos] eq '(') then  begin
    pos++
    factor = mg_evalexpr_expr(stack, pos, vars)
    if (stack[pos] eq ')') then pos++ else message, 'expecting close parenthesis'
  endif else if (size(stack[pos], /type) eq 7 && stregex(stack[pos], '[[:alpha:]_$]+', /boolean)) then begin
    if (((pos + 1) lt stack->count()) && (size(stack[pos + 1], /type) eq 7) && (stack[pos + 1] eq '(')) then begin
      fname = stack[pos]
      pos++
      pos++
      expr = mg_evalexpr_expr(stack, pos, vars)
      factor = call_function(fname, expr)
      if (stack[pos] eq ')') then pos++ else message, 'expecting close parenthesis'
    endif else begin
      factor = mg_evalexpr_lookup(stack[pos], vars)
      pos++
    endelse
  endif else begin
    message, 'unexpected operator'
  endelse

  return, factor
end


;+
; Evaluates a mathematical expression.
;
; :Returns:
;   double or long64
;
; :Params:
;   expr : in, required, type=string
;     expression to evaluate
;   vars : in, optional, type=structure or hash
;     variables to substitute into expression specified as a structure or
;     hash-like object; if a structure, the variable names are case-insensitive
;
; :Keywords:
;   error : out, optional, type=boolean
;     set to named variable to return if there was an error evaluating the
;     expression
;-
function mg_evalexpr, expr, vars, error=error
  compile_opt strictarr
  on_error, 2

  error = 0
  catch, err
  if (err ne 0) then begin
    catch, /cancel
    error = 1
    if (obj_valid(stack)) then obj_destroy, stack
    return, !null
  endif

  stack = list()

  start_index = 0
  token = mg_evalexpr_parse(expr, start_index, length=length)

  while (n_elements(token) gt 0) do begin
    ; handle current token
    stack->add, token

    ; get next token
    start_index += length
    token = mg_evalexpr_parse(expr, start_index, length=length)
  endwhile

  result = mg_evalexpr_expr(stack, 0, vars)

  obj_destroy, stack
  return, result
end


; main-level example program

print, mg_evalexpr('(aa  + 123)* b + exp(1.0)', { aa: 1, b: 2 })
print, mg_evalexpr('1  + 2*3')
print, mg_evalexpr('1 + 2 + 3', error=error), error
print, mg_evalexpr('a*b + c', {a:1, b:3, c:5}, error=error), error
print, mg_evalexpr('exp(i * pi)', { pi: !dpi, i: complex(0, 1) })

end
