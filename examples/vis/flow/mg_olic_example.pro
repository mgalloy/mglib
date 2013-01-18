restore, filepath('globalwinds.dat', subdir=['examples','data'])

scale = 4
npts = 800

tex = bytarr(128 * 2, 64 * 2)
ind = 128L * 64 * 4 * randomu(seed, npts)
tex[ind] = 255B

tex = rebin(tex, 128 * 4, 64 * 4)
tex = smooth(tex, 5, /edge_truncate)

u = rebin(u, 128 * scale, 64 * scale)
v = rebin(v, 128 * scale, 64 * scale)

im = mg_lic(u, v, texture=tex)

window, xsize=128 * scale, ysize=2 * 64 * scale

tv, tex, 0
tv, im, 1

end
