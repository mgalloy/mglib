; docformat = 'rst'

;+
; Base test class that all unit tests should inherit from.
;-

function mgutlibtestcase::have_dlm, dlm_name
  compile_opt strictarr

  catch, error
  if (error ne 0) then begin
    catch, /cancel
    return, 0
  endif

  dlm_load, dlm_name

  return, 1
end


pro mgutlibtestcase::setup
  compile_opt strictarr

  mg_heapinfo, n_pointers=nptrs, n_objects=nobjs
  self.nptrs = nptrs
  self.nobjs = nobjs
end


pro mgutlibtestcase::teardown
  compile_opt strictarr

  mg_heapinfo, n_pointers=nptrs, n_objects=nobjs
  assert, nptrs eq self.nptrs && nobjs eq self.nobjs, $
          'leaked %d pointers, %d objects', $
          nptrs - self.nptrs, $
          nobjs - self.nobjs
end


pro mgutlibtestcase::cleanup
  compile_opt strictarr

  if (self.idl_major_version ge 8) then begin
    ; set refcounting to state before test
    if (self.refcount_enabled) then begin
      dummy = heap_refcount(/enable)
    endif else begin
      dummy = heap_refcount(/disable)
    endelse
  endif

  self->MGutTestCase::cleanup
end


function mgutlibtestcase::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self.idl_major_version = long(strmid(!version.release, 0, strpos(!version.release, '.')))

  if (self.idl_major_version ge 8) then begin
    ; save current state of refcounting
    dummy = heap_refcount(is_enabled=refcount_enabled)
    self.refcount_enabled = refcount_enabled

    ; disable automatic garbage collection to test memory management
    dummy = heap_refcount(/disable)
  endif

  self.root = mg_src_root()

  return, 1
end


pro mgutlibtestcase__define
  compile_opt strictarr

  define = { MGutLibTestCase, inherits MGutTestCase, $
             nptrs: 0L, $
             nobjs: 0L, $
             idl_major_version: 0L, $
             refcount_enabled: 0B, $
             root: '' $
           }
end
