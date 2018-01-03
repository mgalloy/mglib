; docformat = 'rst'

;+
; Pull random data from `random.org <http://random.org>`.
;-

;+
; Read from an URL (with error checking).
;
; :Returns:
;    strarr
;
; :Params:
;    urlString : in, required, type=string
;       complete URL to query
;
; :Keywords:
;    error : out, optional, type=long
;       pass a named variable to get the response code: 0 for success,
;       anything else indicates a failure
;-
function mganrandom::_getData, urlString, error=error
  compile_opt strictarr

  error = 0L
  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    self.url->getProperty, response_code=error
    return, ''
  endif

  return, self.url->get(url=urlString, /string_array)
end


;+
; Convert data to given type.
;
; :Returns:
;   array of type `TYPE`
;
; :Params:
;   data : in, required, type=any
;     data to convert
;
; :Keywords:
;   type : in, required, type=long
;     `SIZE` type code
;   error : out, optional, type=long
;     set to a named variable to return whether the conversion was correctly
;     performed
;-
function mganrandom::_convertData, data, type=type, error=error
  compile_opt strictarr
  on_ioerror, bad_values

  error = 0L

  result = fix(data, type=type)
  return, result

  bad_values:
  error = 1L
  return, fix(-1, type=type)
end


;+
; Returns a permutation of the given range of integers.
;
; :Returns:
;   lonarr
;
; :Keywords:
;   minimum : in, optional, type=long, default=0
;     minimum value of returned integers
;   maximum : in, optional, type=long, default=100
;     maximum value of returned integers
;   error : out, optional, type=long
;     pass a named variable to get the response code: 0 for success,
;     anything else indicates a failure
;-
function mganrandom::getSequence, minimum=minimum, maximum=maximum, $
                                  error=error
  compile_opt strictarr

  _minimum = n_elements(minimum) eq 0 ? 0 : minimum
  _maximum = n_elements(maximum) eq 0 ? 100 : maximum

  format = '(%"%s/sequences/?min=%d&max=%d&col=1&format=plain&rnd=new")'
  urlString = string(self.randomUrl, _minimum, _maximum, format=format)

  result = self->_getData(urlString, error=error)

  return, self->_convertData(result, type=3, error=error)
end


;+
; Return the given number of random integers (with repetition).
;
; :Returns:
;   `lonarr`
;
; :Params:
;   n : in, required, type=long
;     number of random numbers to generate
;
; :Keywords:
;   minimum : in, optional, type=long, default=0
;     minimum value of returned integers
;   maximum : in, optional, type=long, default=100
;     maximum value of returned integers
;   error : out, optional, type=long
;     pass a named variable to get the response code: 0 for success,
;     anything else indicates a failure
;-
function mganrandom::getIntegers, n, minimum=minimum, maximum=maximum, $
                                  error=error
  compile_opt strictarr
  on_error, 2

  if (n_elements(n) eq 0) then message, 'n parameter required'

  _minimum = n_elements(minimum) eq 0 ? 0 : minimum
  _maximum = n_elements(maximum) eq 0 ? 100 : maximum

  format = '(%"%s/integers/?num=%d&min=%d&max=%d&col=1&base=10&format=plain&rnd=news")'
  urlString = string(self.randomUrl, n, _minimum, _maximum, $
                     format=format)

  result = self->_getData(urlString, error=error)

  return, self->_convertData(result, type=3, error=error)
end


;+
; Return the given number of random Gaussian floats.
;
; :Returns:
;   `fltarr`
;
; :Params:
;   n : in, required, type=long
;     number of random numbers to generate
;
; :Keywords:
;   mean : in, optional, type=float, default=0.0
;     mean of requested floats
;   stddev : in, optional, type=float, default=1.0
;     standard deviation of requested floats
;   error : out, optional, type=long
;     pass a named variable to get the response code: 0 for success,
;     anything else indicates a failure
;-
function mganrandom::getGaussians, n, mean=mean, stddev=stddev, error=error
  compile_opt strictarr
  on_error, 2

  if (n_elements(n) eq 0) then message, 'n parameter required'

  _mean = n_elements(mean) eq 0 ? 0. : mean
  _stddev = n_elements(stddev) eq 0 ? 1. : stddev

  format = '(%"%s/gaussian-distributions/?num=%d&mean=%f&stdev=%f&dec=10&col=1&notation=scientific&format=plain&rnd=new")'
  urlString = string(self.randomUrl, n, _mean, _stddev, format=format)

  result = self->_getData(urlString, error=error)

  return, self->_convertData(result, type=4, error=error)
end


;+
; Free resources.
;-
pro mganrandom::cleanup
  compile_opt strictarr

  obj_destroy, self.url
end


;+
; Creates a random number generator.
;
; :Returns:
;   1 if success, 0 if failure
;-
function mganrandom::init
  compile_opt strictarr

  self.url = obj_new('IDLnetURL')
  self.randomURL = 'http://random.org'

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;   url
;     IDLnetURL object used to communicate with random.org
;   randomURL
;     URL of the random.org website which generates the random numbers
;-
pro mganrandom__define
  compile_opt strictarr

  define = { mganrandom, $
             url: obj_new(), $
             randomUrl: '' $
           }
end


; main-level example program

mg_constants

r = obj_new('MGanRandom')

d = r->getIntegers(100, error=error)
if (error eq 0L) then begin
  window, /free
  plot, d
endif else print, 'Error generating integers'

d = r->getSequence(error=error)
if (error eq 0L) then begin
  window, /free
  plot, d
endif else print, 'Error generating sequence'

nbins = 1000
d = r->getGaussians(10000, error=error)
if (error eq 0L) then begin
  window, /free
  plot, 4. * findgen(nbins) / (nbins - 1.) - 2., $
        histogram(d, nbins=nbins, min=-2, max=2.), $
        psym=!mg.psym.histogram
endif else print, 'Error generating gaussians'

obj_destroy, r

end
