; docformat = 'rst'

;+
; Simple progress bar for use when iterating over elements of an array or
; elements in an `IDL_Object` which supports `FOREACH` and `N_ELEMENTS`.
;
; :Examples:
;   First, let's construct a hash to iterate over. The keys will just be
;   the first `n` letters of the alphabet::
;
;     n = 16
;     letters = string(reform(bindgen(n) + (byte('a'))[0], 1, n))
;
;   The values of the hash will be proportional to the amount of work to do to
;   process that element of the hash. We will make one element have a much
;   higher amount of work::
;
;     indices = randomu(seed, n)
;     indices[5] = 5.0
;
;     h = hash(letters, indices, /extract))
;
;   In the simple use of `mg_progress`, we get an indicator of the progress
;   through the work, but the estimated time to complete all the work jumps
;   around::
;
;     foreach v, mg_progress(h), k do begin
;       wait, v
;     endforeach
;
;   If, on the other hand, we can provide an amount of the total work and then
;   update the progress as we go, the estimate timed to complete all work is
;   much more accurate:
;
;     p = mg_progress(h, total=total(indices))
;     foreach v, p, k do begin
;       wait, v
;       p->update, v
;     endforeach
;-


;+
; Helper routine to format a number of seconds as a string.
;
; :Returns:
;   formatted string such as "00:10" (10 seconds) or "02:10:00" (2 hours and 10
;   minutes)
;
; :Params:
;   secs : in, required, type=float
;     number of seconds to format
;
; :Keywords:
;   width : out, optional, type=long
;     set to a named variable to retrieve the length of the returned string
;-
function mg_progress::secs2minsec, secs, width=width
  compile_opt strictarr

  hours = long(secs) / 60L / 60L
  minutes = long(secs - hours * 60L * 60L) / 60L
  seconds = long(secs - (minutes + hours * 60L) * 60L)

  if (n_elements(width) eq 0L) then begin
    if (hours eq 0L) then begin
      width = 5L
      return, string(minutes, seconds, format='(%"%02d:%02d")')
    endif else begin
      hours_width = (floor(alog10(hours)) + 1L) > 2
      width = hours_width + 6L
      format = string(hours_width, format='(%"(%%\"%%0%dd:%%02d:%%02d\")")')
      return, string(hours, minutes, seconds, format=format)
    endelse
  endif else begin
    if (width gt 6L) then begin
      hours_width = width - 6L
      format = string(hours_width, format='(%"(%%\"%%0%dd:%%02d:%%02d\")")')
      return, string(hours, minutes, seconds, format=format)
    endif else begin
      return, string(minutes, seconds, format='(%"%02d:%02d")')
    endelse
  endelse
end


;+
; Wrapper for `MG_TERMCOLUMNS` which returns a default if `MG_TERMCOLUMNS` not
; found.
;
; :Returns:
;   number of columns in terminal
;
; :Keywords:
;   default : in, optional, type=long, default=80
;     if `MG_TERMCOLUMNS` not present, will return this value
;-
function mg_progress::termcolumns, default=default
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, n_elements(default) eq 0L ? 80L : default
  endif

  n_cols = mg_termcolumns()
  return, n_cols
end


;+
; Update the amount of work completed by adding `x` to the current amount.
;
; :Params:
;   x : in, required, type=float
;     amount to add to current amount of work done
;-
pro mg_progress::update, x
  compile_opt strictarr

  self.current += x
end


;= overload methods

;+
; Allow object to be used in `FOREACH` loops.
;
; :Returns:
;   1 if more elements, 0 if done
;
; :Params:
;   value : out, required, type=any
;     value of array or object
;   key : in, out, required, type=any
;     key to index into iterable, i.e., array or object of class `IDL_Object`
;-
function mg_progress::_overloadForeach, value, key
  compile_opt strictarr

  if (n_elements(key) eq 0L) then self.start_time = systime(/seconds)
  now = systime(/seconds)

  it = *self.iterable
  if (isa(it, 'IDL_OBJECT')) then begin
    more_elements = it->_overloadForeach(value, key)
  endif else begin
    if (n_elements(key) eq 0L) then key = 0L
    value = it[key++]

    more_elements = key lt self.n
  endelse

  self.counter = (self.counter + 1) < self.n

  c = self.use_total ? self.current : self.counter
  t = self.use_total ? self.total : self.n

  n_cols = self->termcolumns() - 1L

  n_width = floor(alog10(t)) + 1L

  elapsed_time = now - self.start_time
  if (c ne 0) then begin
    est_time = elapsed_time / c * t
    est_time = self->secs2minsec(est_time, width=est_width)
  endif else begin
    est_time = '--:--'
    est_width = 5L
  endelse
  elapsed_time = self->secs2minsec(elapsed_time, width=est_width)

  format = string(n_width, n_width, $
                  format='(%"(%%\"%%s%%3d%%%% |%%s%%s| %%%dd/%%%dd [%%s/%%s]\")")')

  bar_length = n_cols - 5L - 2L - 1L - 1L - 2 * n_width - 4L - 2 * est_width - strlen(self.title)

  done_length = round(bar_length * c / t)
  todo_length = bar_length - done_length

  done_char = '#'
  todo_char = '-'

  done = done_length le 0L ? '' : string(bytarr(done_length) + (byte(done_char))[0])
  todo = todo_length le 0L ? '' : string(bytarr(todo_length) + (byte(todo_char))[0])

  msg = string(self.title,$
               round(100L * c / t), $
               done, todo, $
               self.counter, self.n, $
               elapsed_time, est_time, $
               format=format)

  if (more_elements) then begin
    mg_statusline, msg
  endif else begin
    mg_statusline, /clear
    print, msg
  endelse

  return, more_elements
end


;= lifecycle methods

;+
; Instantiate the progress object.
;
; :Returns:
;   1 for success, 0 for failure
;
; :Params:
;   iterable : in, required, type=array/object
;     either an array or an object of class `IDL_Object`
;-
function mg_progress::init, iterable, total=total, title=title
  compile_opt strictarr

  self.iterable = ptr_new(iterable)
  self.n = n_elements(iterable)
  self.counter = 0L
  self.title = n_elements(title) eq 0L ? '' : (title + ' ')

  if (n_elements(total) gt 0L) then begin
    self.use_total = 1B
    self.current = 0.0
    self.total = total
  endif

  return, 1
end


;+
; Define the progress class.
;-
pro mg_progress__define
  compile_opt strictarr

  !null = { mg_progress, inherits IDL_Object, $
            iterable: ptr_new(), $
            title: '', $
            n: 0L, $
            counter: 0L, $
            use_total: 0B, $
            current: 0.0, $
            total: 0.0, $
            start_time: 0.0D $
          }
end


; main-level example program

n = 16
letters = string(reform(bindgen(n) + (byte('a'))[0], 1, n))
indices = randomu(seed, n)
indices[5] = 5.0
h = hash(letters, indices, /extract)

print, 'Simple progress with no pre-calculation, note estimated time changes'
foreach v, mg_progress(h), k do begin
  wait, v
endforeach

print, 'Updating progress with pre-calculation gives a constant estimated time'
p = mg_progress(h, total=total(indices), title='Updating progress...')
foreach v, p, k do begin
  wait, v
  p->update, v
endforeach

end
