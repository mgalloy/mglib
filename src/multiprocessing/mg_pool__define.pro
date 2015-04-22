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
  for p = 0L, n_processes - 1L do begin
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
  process->getProperty, name=process_name
  process->setVar, 'x', (*self.iterable)[self.i]
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
  return, self.n_done ge n_processes
end


;+
; Retrieve final result.
;
; :Private:
;-
function mg_map::get_result
  compile_opt strictarr

  indices = (self.result->keys())->toArray()
  values = (self.result->values())->toArray()

  return, values[sort(indices)]
end


;+
; Hand off the next work item to the finishing process.
;
; :Private:
;-
pro mg_map::next, process, status, error
  compile_opt strictarr

  ; store result
  process->getProperty, userdata=i, name=process_name

  self.result[i] = process->getVar('result')

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

  obj_destroy, self.result
  ptr_free, self.iterable
end


;+
; Create a `MG_Map` class.
;
; :Private:
;-
function mg_map::init, pool=pool, func=func, iterable=iterable
  compile_opt strictarr

  self.pool = pool
  self.result = hash()

  self.statement = string(func, format='(%"result = %s(x)")')

  self.iterable = ptr_new(iterable)
  self.count = n_elements(iterable)

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
             statement: '', $
             iterable: ptr_new(), $
             count: 0L, $
             i: 0L, $
             n_done: 0L, $
             result: obj_new() $
           }
end


;= API

;+
; :Todo:
;   this should be able to handle multiple arguments
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
;-
function mg_pool::map, f, iterable
  compile_opt strictarr

  map = obj_new('MG_Map', pool=self, func=f, iterable=iterable)
  map->launch

  while (~map->is_done()) do begin
    wait, self.polling_cycle
  endwhile

  result = map->get_result()
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


;= property access

;+
; Set properties.
;-
pro mg_pool::setProperty, polling_cycle=polling_cycle
  compile_opt strictarr

  if (n_elements(polling_cycle) gt 0L) then self.polling_cycle = polling_cycle
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

  define = { MG_Pool, $
             n_processes: 0L, $
             processes: ptr_new(), $
             polling_cycle: 0.0 $
           }
end