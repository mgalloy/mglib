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
;     work_amount = randomu(seed, n)
;     work_amount[5] = 5.0
;     h = hash(letters, work_amount, /extract)
;
;   In the simple use of `mg_progress`, we get an indicator of the progress
;   through the work, but the estimated time to complete all the work jumps
;   around because there is not a constant amount of work to be done on each
;   iteration::
;
;     foreach w, mg_progress(h), i do begin
;       wait, w
;     endforeach
;
;   If, on the other hand, we can provide an amount of the total work and then
;   update the progress as we go, the estimate time to complete all work is
;   much more accurate::
;
;     p = mg_progress(h, total=total(indices), title='Pre-calculation)
;     foreach w, p, i do begin
;       wait, w
;       p->advance, work=w
;     endforeach
;
;   It might also be necessary to not loop directly over the progress bar, but
;   to have some other type of loop, i.e., a FOR loop, WHILE loop, or a FOREACH
;   loop over some other object and manually update the progress bar. In this
;   case, set the `MANUAL` property of the progress bar and use the `advance`
;   method again to update the progress::
;
;     p = mg_progress(h, total=total(work_amount), title='Manual', /manual)
;     foreach w, h, i do begin
;       wait, w
;       p->advance, work=w
;     endforeach
;     p->advance
;
;   Note, that in the case of setting the `MANUAL` property and using the
;   `TOTAL` property, an extra `advance` call is needed for the progress bar to
;   show 100% completion.
;
;   For an example of using advance with a constant amount of work in each
;   iteration and not looping over the progress bar object itself, let's
;   do some processing on all the files in the IDL distribution::
;
;     idl_dir = filepath('')
;     files = file_search(idl_dir, '*', count=n_files)
;     p = mg_progress(files, title='Checking files', /manual)
;     for f = 0L, n_files - 1L do begin
;       ; process files[f]
;       p->advance
;     endfor
;     p->advance
;
; :Properties:
;   label_widget : type=long
;     widget identifier of a label widget to display progress bar; if present
;     displays in the label widget instead of the console
;   title : type=string
;     title to show on the left side of the progress bar display
;   total : type=float
;     set to indicate the total amount of work to be done and displayed; use
;     when the amount of work is not the same for each iteration; use the
;     `advance` method to step forward the correct amount
;   manual : type=boolean
;     set to indicate the progress bar will be updated via the `advance` method
;     instead of by looping with `FOREACH` on the progress bar object
;   hide : type=boolean
;     set to not show output; useful when running scripts both interactively and
;     non-interactively
;-


;+
; Helper routine to format a number of seconds as a string.
;
; :Private:
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
function mg_progress::_secs2minsec, secs, width=width
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
; :Private:
;
; :Returns:
;   number of columns in terminal
;
; :Keywords:
;   default : in, optional, type=long, default=80
;     if `MG_TERMCOLUMNS` not present, will return this value
;-
function mg_progress::_termcolumns, default=default
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, n_elements(default) eq 0L ? 80L : default
  endif

  if (self.label_widget gt 0L) then begin
    geo_info = widget_info(self.label_widget, /geometry)
    test_string = '##########'
    dims = widget_info(self.label_widget, string_size=test_string)
    n_cols = long(geo_info.scr_xsize / dims[0] * strlen(test_string))
  endif else begin
    n_cols = mg_termcolumns()
  endelse

  return, n_cols
end


;+
; Advance the progress bar a step. This is useful for using `MG_PROGRESS` with a
; when the `TOTAL` keyword is needed, i.e., when the amount of progress each
; iteration is not the same, or when not using a `FOREACH` loop on the progress
; bar iself.
; 
; :Keywords:
;   work : in, required, type=float
;     amount to add to current amount of work done
;-
pro mg_progress::advance, work=work
  compile_opt strictarr

  if (self.manual) then begin
    new_i = self.counter eq 0L ? !null : self.counter
    not_done = self->_overloadForeach(new_element, new_i)
  endif

  if (n_elements(work) gt 0L) then self.current += work
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
  on_error, 2

  if (n_elements(key) eq 0L) then self.start_time = systime(/seconds)
  now = systime(/seconds)

  iterable = *self.iterable
  if (isa(iterable, 'IDL_OBJECT')) then begin
    more_elements = iterable->_overloadForeach(value, key)
  endif else begin
    if (n_elements(key) eq 0L) then key = 0L else key += 1
    more_elements = key lt self.n
    value = iterable[key < (self.n - 1)]
  endelse

  self.counter = (self.counter + 1) < self.n

  if (~self.hide) then begin
    c = self.use_total ? self.current : (self.counter < self.n)
    t = self.use_total ? self.total : self.n

    n_cols = self->_termcolumns() - 1L

    n_width = floor(alog10(t)) + 1L

    elapsed_time = now - self.start_time
    if (c ne 0) then begin
      est_time = elapsed_time / c * t
      est_time = self->_secs2minsec(est_time, width=est_width)
    endif else begin
      est_time = '--:--'
      est_width = 5L
    endelse
    elapsed_time = self->_secs2minsec(elapsed_time, width=est_width)

    format = string(n_width, n_width, $
                    format='(%"(%%\"%%s%%3d%%%% |%%s%%s| %%%dd/%%%dd [%%s/%%s]\")")')

    bar_length = n_cols - 5L - 2L - 1L - 1L - 2 * n_width - 4L - 2 * est_width $
                   - strlen(self.title)

    done_length = round(bar_length * c / t)
    todo_length = bar_length - done_length

    done_char = '#'
    todo_char = '-'

    done = done_length le 0L ? '' : string(bytarr(done_length) + (byte(done_char))[0])
    todo = todo_length le 0L ? '' : string(bytarr(todo_length) + (byte(todo_char))[0])

    msg = string(self.title, $
                 round(100L * c / t), $
                 done, todo, $
                 self.counter, self.n, $
                 elapsed_time, est_time, $
                 format=format)

    if (self.label_widget gt 0L) then begin
      widget_control, self.label_widget, set_value=msg
    endif else begin
      if (more_elements) then begin
        mg_statusline, msg
      endif else begin
        mg_statusline, /clear
        print, msg
      endelse
    endelse
  endif

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
function mg_progress::init, iterable, total=total, title=title, manual=manual, $
                            hide=hide, label_widget=label_widget
  compile_opt strictarr

  self.iterable = ptr_new(iterable)
  self.n = n_elements(iterable)
  self.counter = 0L

  self.label_widget = n_elements(label_widget) eq 0L ? -1L : label_widget

  self.title = n_elements(title) eq 0L ? '' : (title + ' ')

  self.manual = keyword_set(manual)
  self.hide = keyword_set(hide)

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
            label_widget: 0L, $
            manual: 0B, $
            hide: 0B, $
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

work_amount = randomu(seed, n)
work_amount[5] = 5.0
h = hash(letters, work_amount, /extract)

; basic example

print, 'Simple progress with no pre-calculation, estimated time changes greatly'
foreach w, mg_progress(h), i do begin
  wait, w
endforeach

; example with pre-calculation

print, 'Updating progress with pre-calculation gives a constant estimated time'
p = mg_progress(h, total=total(work_amount), title='Pre-calculation')
foreach w, p, i do begin
  wait, w
  p->advance, work=w
endforeach

; example of looping on the hash and manually advancing progress bar

print, 'Looping over hash and manually advancing progress bar'
p = mg_progress(h, total=total(work_amount), title='Manual', /manual)
foreach w, h, i do begin
  wait, w
  p->advance, work=w
endforeach
; extra advance needed when not looping on the progress bar and using TOTAL
p->advance

; example of using with a FOR loop

idl_dir = filepath('')
print, idl_dir, format='(%"Finding files in IDL distribution: %s")'
files = file_search(idl_dir, '*', count=n_files)
p = mg_progress(files, title='Checking files', /manual)
for f = 0L, n_files - 1L do begin
  ; process files[f]
  p->advance
endfor
print, 'Done'

end
