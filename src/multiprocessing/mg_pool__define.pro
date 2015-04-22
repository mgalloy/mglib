; docformat = 'rst'


;= helper methods

pro mg_pool::_map_result, process, status, error
  compile_opt strictarr

  process->getProperty, userdata=i, name=p
  self.result[i] = process->getVar('result')
end


;= API

function mg_pool::map, f, iterable
  compile_opt strictarr

  ; make sure no results from last operation
  self.result->remove, /all

  ; setup processes to callback to map helper method
  for p = 0L, self.n_processes - 1L do begin
    ((*self.processes)[p])->setProperty, callback_object=self, $
                                         callback_method='_map_result'
  endfor

  ; TODO: send element of iterable over
  ; TODO: execute, statement, /nowait
  ; TODO: retrieve element, put in h[p]

  indices = (self.result->keys())->toArray()
  values = (self.result->values())->toArray()

  ; free results
  self.result->remove, /all

  return, values[sort(indices)]
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
;-
function mg_pool::init, n_processes=n_processes
  compile_opt strictarr

  self.n_processes = n_elements(n_processes) eq 0L ? !cpu.hw_ncpu : n_processes

  self.processes = ptr_new(objarr(self.n_processes))
  for p = 0L, self.n_processes - 1L do begin
    (*self.processes)[p] = obj_new('MG_Process', name=strtrim(p, 2))
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