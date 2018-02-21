; docformat = 'rst'

function mg_animation_demo, t
  compile_opt strictarr

  x = 16.0 * dindgen(200) / 199.0 - 8.0
  z = sin(x^2) / x^2 + sin(x + 2.0 * !dpi * t / 4.0)

  original_device = !d.name
  set_plot, 'Z'
  device, set_resolution=[600, 400], decomposed=1, z_buffering=0, $
          set_pixel_depth=24
  plot, x, z, yrange=[-1.5, 2.5], ystyle=9, xstyle=9, /nodata, $
        color='000000'x, background='ffffff'x
  oplot, x, z, color='ff0000'x, thick=5.0
  xyouts, 0.9, 0.9, string(t, format='(%"%0.2f secs")'), alignment=1.0, /normal, $
          color='000000'x
  im = tvrd(true=1)
  set_plot, original_device
  return, im
end


anim = mg_animation('mg_animation_demo', duration=4.0)
window, xsize=600, ysize=400, /free, title='Animation example'
anim->display, fps=40

end
