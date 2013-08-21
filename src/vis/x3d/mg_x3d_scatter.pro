; docformat = 'rst'

pro mg_x3d_scatter, x, y, z, filename=filename
  compile_opt strictarr

  _filename = n_elements(filename) eq 0L ? 'x3d_scatter.html' : filename

  v = obj_new('IDLgrView')

  m = obj_new('IDLgrModel')
  v->add, m

  p = obj_new('IDLgrPolyline', x, y, z)
  m->add, p

  x3d = obj_new('MGgrx3d', filename=_filename)
  x3d->draw, v, /full_html

  obj_destroy, [v, x3d]
end


; main-level example program

n = 153L
x = randomu(seed, n)
y = randomu(seed, n)
z = randomu(seed, n)

mg_x3d_scatter, x, y, z, filename='x3d_scatter_example.html'

end

