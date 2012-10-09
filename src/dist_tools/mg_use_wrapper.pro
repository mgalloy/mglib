; docformat = 'rst'

;+
; Wrapper for `MG_USE` to be called from the command line.
;-
pro mg_use_wrapper
  compile_opt strictarr

  args = command_line_args(count=nargs)

  ; check for -h option
  if (total(args eq '-h') gt 0.) then begin
    print, 'usage: mg_use [options] routines...'
    print
    print, 'options:'
    print, '  -h         print this help'
    print, '  -o outdir  copy files to outdir'
    return
  endif

  ; check for -o option
  ind = where(args eq '-o', ofound)
  if (ofound gt 0L) then begin
    if (ind[0] eq nargs - 1L) then return
    outdir = args[ind[0] + 1L]
    case 1 of
      ind[0] eq 0L: if (nargs gt 2L) then routines = args[2:*] else return
      ind[0] eq nargs - 2L: routines = args[0:nargs - 3L]
      else: routines = [arg[0:ind[0] - 1L], args[ind[0] + 2L:*]]
    endcase
  endif else routines = args

  ; finally, call MG_USE
  mg_use, routines, outdir
end
