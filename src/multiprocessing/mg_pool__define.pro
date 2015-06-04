; docformat = 'rst'

;+
; Class representing a pool of processes.
;
; :Properties:
;   n_processes : type=long
;     number of processes; default is the number of CPUs (cores) on the system
;   polling_cycle : type=float
;     time, in seconds, to wait before checking again to see if work is
;     completed
;   _extra : type=keywords
;     properties of individual `MG_Process` objects
;-

;= helper methods

;+
; Start a pool working on a map.
;
; :Private:
;-
pro mg_map::launch
  compile_opt strictarr

  ; setup processes to callback to map helper method
  self.pool->getProperty, n_processes=n_processes
  for p = 0L, (n_processes < self.count) - 1L do begin
    process = self.pool->get_process(p)
    process->setProperty, cb_object=self, $
                          cb_method='next'
    self->launch_process, process
  endfor
end


;+
; Launch a process on the next available work item.
;
; :Private:
;-
pro mg_map::launch_process, process
  compile_opt strictarr

  process->setProperty, userdata=self.i

  ; setup arguments
  for i = 0L, n_elements(self.iterable) - 1L do begin
    process->setVar, 'x' + strtrim(i, 2), (self.iterable[i])[self.i]
  endfor

  ; setup keywords
  if (n_elements(*self.keywords) gt 0L) then begin
    tnames = tag_names(*self.keywords)
    for k = 0L, n_tags(*self.keywords) - 1L do begin
      process->setVar, tnames[k], (*self.keywords).(k)
    endfor
  endif

  process->execute, self.statement, /nowait

  ++self.i
end


;+
; Returns whether the map is completed.
;
; :Private:
;-
function mg_map::is_done
  compile_opt strictarr

  self.pool->getProperty, n_processes=n_processes

  ; UNIX seems to need a status check for the IDL_IDLBridge to notice
  ; that it needs to call the callback routine
  status = self.pool->status(error=error)

  return, self.n_done ge (n_processes < self.count)
end


;+
; Retrieve final result.
;
; :Private:
;-
function mg_map::get_result
  compile_opt strictarr
  on_error, 2

  if (self.is_procedure) then message, 'no result for procedure map'

  indices = (self.result->keys())->toArray()

  if (self.is_list) then begin
    values = self.result->values()
    return, values[sort(indices)]
  endif else begin
    values = (self.result->values())->toArray()
    return, values[sort(indices)]
  endelse

end


;+
; Hand off the next work item to the finishing process.
;
; :Private:
;-
pro mg_map::next, process, status, error
  compile_opt strictarr
  on_error, 2

  ; store result
  process->getProperty, userdata=i, name=process_name

  status = process->status(error=error)
  if (status eq 3 || status eq 4) then begin
    message, 'error completing pool command: ' + error
  endif

  if (~self.is_procedure) then begin
    result = process->getVar('result', error=error)
    if (error eq 0L) then begin
      ; need the parentheses around self.result on UNIX
      (self.result)[i] = result
    endif else begin
      message, string(i, format='(%"result not calculated for process %d")')
    endelse
  endif

  if (self.i lt self.count) then begin
    self->launch_process, process
  endif else begin
    process->setProperty, cb_object=obj_new(), $
                          cb_method=''
    ++self.n_done
  endelse
end


;+
; Free resources.
;
; :Private:
;-
pro mg_map::cleanup
  compile_opt strictarr

  if (~self.is_procedure) then obj_destroy, self.result
  obj_destroy, self.iterable
  ptr_free, self.keywords
end


;+
; Create a `MG_Map` class.
;
; :Private:
;-
function mg_map::init, pool=pool, func=func, iterable=iterable, $
                       is_procedure=is_procedure, _extra=e
  compile_opt strictarr

  self.pool = pool

  self.is_procedure = keyword_set(is_procedure)
  if (n_elements(e) eq 0L) then begin
    kw = ''
  endif else begin
    tnames = tag_names(e)
    kw = ', ' + strjoin(tnames + '=' + tnames, ', ')
  endelse

  self.iterable = iterable
  self.keywords = ptr_new(e)
  self.i = 0L

  ; find max number of elements in all iterables
  self.count = (self.iterable->map('n_elements'))->reduce(lambda(x, y: x > y))

  ; determine if any iterable is a list
  self.is_list = (self.iterable->map(lambda(x: isa(x, 'IDL_Object'))))->reduce(lambda(x, y: x > y))

  args = strjoin('x' + strtrim(indgen(n_elements(self.iterable)), 2), ', ')

  if (self.is_procedure) then begin
    self.statement = string(func, args, kw, format='(%"%s, %s%s")')
  endif else begin
    self.result = hash()
    self.statement = string(func, args, kw, format='(%"result = %s(%s%s)")')
  endelse

  return, 1
end


;+
; Define `MG_Map` class.
;
; :Private:
;-
pro mg_map__define
  compile_opt strictarr

  define = { MG_Map, $
             pool: obj_new(), $
             is_procedure: 0B, $
             statement: '', $
             iterable: obj_new(), $
             is_list: 0B, $
             count: 0L, $
             keywords: ptr_new(), $
             i: 0L, $
             n_done: 0L, $
             result: obj_new() $
           }
end


;= API

;+
; Execute a function/procedure on each item of an array and returns
; the result.
;
; :Todo:
;   this should be able to handle multiple arguments
;
; :Returns:
;   the result of appling the function to each element of the iterable as an
;   array if `iterable1` as an array or as a `list` if `iterable1` was a `list`
;   (or some other appropriate subclass of `IDL_Object`), or `!null` if
;   `is_procedure` is set
;
; :Examples:
;   For example, suppose we want to execute a simple function on an array of
;   items and return the result. The function we wish to execute on each
;   element is::
;
;     function mg_map_demo_func, x
;       return, x^2
;     end
;
;   Then the function can be done with::
;
;     pool = obj_new('MG_Pool')
;     x_squared = pool->map('mg_map_demo_func', findgen(100))
;
; :Params:
;   f : in, required, type=string
;     function to call on each item of the iterable arguments, unless
;     `is_procedure` is set, in which case it is considered a procedure
;   iterable1, iterable2, iterable3 , iterable4 : in, required, type=iterable type
;     array or list (technically any `IDL_Object` subclass which implements
;     the `_overloadSize` and `_overloadBracketsRightSide` methods where the
;     items are given by `iterable[i]` with `i=0,1,...n-1`)
;
; :Keywords:
;   is_procedure : in, optional, type=boolean
;     set to indicate `f` is procedure, otherwise it is assumed to be
;     a function
;   _extra : in, optional, type=numeric/string
;     keywords to pass to `f`; keywords are not iterated through, they are
;     passed as a whole to `f` in each call
;-
function mg_pool::map, f, iterable1, iterable2, iterable3, iterable4, $
                       is_procedure=is_procedure, _extra=e
  compile_opt strictarr
  on_error, 2

  iterable = list()
  switch n_params() of
    5: iterable->add, iterable4, 0
    4: iterable->add, iterable3, 0
    3: iterable->add, iterable2, 0
    2: begin
        iterable->add, iterable1, 0
        break
      end
    1: message, 'at least one iterable argument required'
    0: message, 'function name argument required'
  endswitch

  map = obj_new('MG_Map', $
                pool=self, $
                func=f, $
                iterable=iterable, $
                _extra=e)
  map->launch

  while (~map->is_done()) do begin
    wait, self.polling_cycle
  endwhile

  if (keyword_set(is_procedure)) then begin
    result = !null
  endif else begin
    result = map->get_result()
  endelse

  obj_destroy, map

  return, result
end


;+
; Retrieve a process from the pool by index.
;
; :Returns:
;   `MG_Process` object
;
; :Params:
;   i : in, required, type=integer
;     index of process, 0...n_processes - 1
;-
function mg_pool::get_process, i
  compile_opt strictarr

  return, (*self.processes)[i]
end


;+
; Returns the status, and optionally error messages, of the processes
; in the pool.
;
; ::
;
;   code  description             error message
;   ----  ----------------------  -------------
;      0  idle                    empty string
;      1  executing command       empty string
;      2  completed               empty string
;      3  error halted execution  error message
;      4  aborted execution       abort message
;
; :Returns:
;   `lonarr(n_processes)`
;
; :Keywords:
;   error : out, optional, type=strarr(n_processes)
;     set to a named variable to retrieve the error messages for the
;     processes, will be empty strings if no error messages
;-
function mg_pool::status, error=error
  compile_opt strictarr

  error = strarr(self.n_processes)
  status = lonarr(self.n_processes) 

  for p = 0L, self.n_processes - 1L do begin
    status[p] = ((*self.processes)[p])->status(error=p_error)
    error[p] = p_error
  endfor

  return, status
end


;= overloaded operators

;+
; Provides convenient output for `HELP` on `NAME` pool object.
;
; :Examples:
;   Use `HELP` to show output::
;
;     IDL> pool = mg_pool()
;     IDL> help, pool
;     POOL            MG_POOL  <N_PROCESSES=8>
;
; :Params:
;   name : in, required, type=string
;     name of variable
;-
function mg_pool::_overloadHelp, name
  compile_opt strictarr

  return, string(name, obj_class(self), self.n_processes, $
                 format='(%"%-16s%s  <N_PROCESSES=%d>")')
end


;= property access

;+
; Set properties.
;-
pro mg_pool::setProperty, polling_cycle=polling_cycle, _extra=e
  compile_opt strictarr

  if (n_elements(polling_cycle) gt 0L) then self.polling_cycle = polling_cycle
  if (n_elements(e) gt 0L) then begin
    for p = 0L, self.n_processes - 1L do begin
      ((*self.processes)[p])->setProperty, _extra=e
    endfor
  endif
end


;+
; Retrieve properties.
;-
pro mg_pool::getProperty, n_processes=n_processes, polling_cycle=polling_cycle
  compile_opt strictarr

  if (arg_present(n_processes)) then n_processes = self.n_processes
  if (arg_present(polling_cycle)) then polling_cycle = self.polling_cycle
end


;= lifecycle methods

;+
; Free resources.
;-
pro mg_pool::cleanup
  compile_opt strictarr

  for p = 0L, self.n_processes - 1L do begin
    obj_destroy, (*self.processes)[p]
  endfor
end


;+
; Create a process object.
;
; :Returns:
;   1 for success, 0 for failure
;
; :Keywords:
;   n_processes : in, optional, type=long, default=!cpu.hw_ncpu
;     number of processes; default is the number of CPUs (cores) on the system
;   polling_cycle : in, optional, type=float, default=0.5
;     time, in seconds, to wait before checking again to see if work is
;     completed
;   _extra : in, optional, type=keywords
;     keywords to 'MG_Process::init'
;-
function mg_pool::init, n_processes=n_processes, $
                        polling_cycle=polling_cycle, $
                        _extra=e
  compile_opt strictarr

  self.n_processes = n_elements(n_processes) eq 0L ? !cpu.hw_ncpu : n_processes

  self.processes = ptr_new(objarr(self.n_processes))
  for p = 0L, self.n_processes - 1L do begin
    (*self.processes)[p] = obj_new('MG_Process', name=strtrim(p, 2), _extra=e)
  endfor

  self.polling_cycle = n_elements(polling_cycle) eq 0 ? 0.5 : polling_cycle

  return, 1
end


;+
; Define `MG_Pool` class.
;
; :Fields:
;   n_processes
;     number of processes
;   processes
;     pointer to `objarr` of processes
;   polling_cycle
;     amount of time, in seconds, to wait before checking to see if result is
;     completed
;-
pro mg_pool__define
  compile_opt strictarr

  define = { MG_Pool, inherits IDL_Object, $
             n_processes: 0L, $
             processes: ptr_new(), $
             polling_cycle: 0.0 $
           }
end
