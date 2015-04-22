; docformat = 'rst'


;= helper methods

pro mg_map::launch, pool
  compile_opt strictarr

  ; setup processes to callback to map helper method
  pool->getProperty, n_processes=n_processes
  for p = 0L, n_processes - 1L do begin
    process = pool->get_process(p)
    process->setProperty, cb_object=self, $
                          cb_method='next'
    self->launch_process, process
  endfor
end


pro mg_map::launch_process, process
  compile_opt strictarr

  process->setProperty, userdata=self.i
  process->getProperty, name=process_name
  process->setVar, 'x', (*self.iterable)[self.i]
  process->execute, self.statement, /nowait
  ++self.i
end


function mg_map::is_done
  compile_opt strictarr

  self.pool->getProperty, n_processes=n_processes
  return, self.n_done ge n_processes
end


function mg_map::get_result
  compile_opt strictarr

  indices = (self.result->keys())->toArray()
  values = (self.result->values())->toArray()

  return, values[sort(indices)]
end


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


pro mg_map::cleanup
  compile_opt strictarr

  obj_destroy, self.result
  ptr_free, self.iterable
end


function mg_map::init, pool=pool, func=func, iterable=iterable
  compile_opt strictarr

  self.pool = pool
  self.result = hash()

  self.statement = string(func, format='(%"result = %s(x)")')

  self.iterable = ptr_new(iterable)
  self.count = n_elements(iterable)

  return, 1
end


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

function mg_pool::map, f, iterable
  compile_opt strictarr

  map = obj_new('MG_Map', pool=self, func=f, iterable=iterable)
  map->launch, self

  while (~map->is_done()) do begin
    wait, 0.5
  endwhile

  result = map->get_result()
  obj_destroy, map

  return, result
end


function mg_pool::get_process, i
  compile_opt strictarr

  return, (*self.processes)[i]
end


;= property access

pro mg_pool::setProperty
  compile_opt strictarr

end


pro mg_pool::getProperty, n_processes=n_processes
  compile_opt strictarr

  if (arg_present(n_processes)) then n_processes = self.n_processes
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
;   _extra : in, optional, type=keywords
;     keywords to 'MG_Process::init'
;-
function mg_pool::init, n_processes=n_processes, _extra=e
  compile_opt strictarr

  self.n_processes = n_elements(n_processes) eq 0L ? !cpu.hw_ncpu : n_processes

  self.processes = ptr_new(objarr(self.n_processes))
  for p = 0L, self.n_processes - 1L do begin
    (*self.processes)[p] = obj_new('MG_Process', name=strtrim(p, 2), _extra=e)
  endfor

  self.result = hash()

  return, 1
end


;+
; Class representing a process.
;
; :Fields:
;   n_processes
;     number of processes
;-
pro mg_pool__define
  compile_opt strictarr

  define = { MG_Pool, $
             n_processes: 0L, $
             processes: ptr_new(), $
             result: obj_new() $
           }
end