; docformat = 'rst'

;= API

pro mg_animation::display, fps=fps, loop=loop
  compile_opt strictarr

  if (keyword_set(loop)) then while (1B) do self->display, fps=fps

  _fps = mg_default(fps, 20)

  n_frames = long(self.duration * _fps) + 1L
  t = 0.0
  increment = 1.0 / _fps
  for f = 0L, n_frames - 1L do begin
    current_time = systime(/seconds)
    im = self->get_frame(t)
    tv, im, true=1
    t += increment
    wait, (increment - (systime(/seconds) - current_time)) > 0
  endfor
end


pro mg_animation::write_gif, filename, fps=fps
  compile_opt strictarr

  _fps = mg_default(fps, 20)

  n_frames = long(self.duration * _fps) + 1L
  t = 0.0
  increment = 1.0 / _fps
  for f = 0L, n_frames - 1L do begin
    im = self->get_frame(t)
    write_gif, filename, im, /multiple, delay_time=increment
    t += increment
  endfor
  write_gif, filename, /close
end


;= helper methods

function mg_animation::get_frame, t
  compile_opt strictarr

  if (size(*self.frame_routine, /type) eq 7) then begin
    return, call_function(*self.frame_routine, t)
  endif else begin
    routine = *self.frame_routine
    return, routine(t)
  endelse
end


;= lifecycle methods

pro mg_animation::cleanup
  compile_opt strictarr

  if (size(*self.frame_routine, /type) eq 11) then obj_destroy, *self.frame_routine
end


function mg_animation::init, frame_routine, duration=duration
  compile_opt strictarr

  self.frame_routine = ptr_new(frame_routine)
  self.duration = mg_default(duration, 1.0)

  return, 1
end


pro mg_animation__define
  compile_opt strictarr

  !null = {mg_animation, inherits IDL_Object, $
           duration: 0.0, $
           frame_routine: ptr_new()}
end
