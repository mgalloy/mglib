; docformat = 'rst'

;+
; Spread data apart using a force directed algorithm.
;
; :Bugs:
;    very simple implementation
;
; :Categories:
;    graphics computation
;-

;+
; Spread data apart using a force directed algorithm.
;
; :Returns:
;    fltarr
;
; :Params:
;    data : in, required, type=fltarr
;       input data to force apart
;
; :Keywords:
;    min_distance : in, optional, type=float
;       min distance that items need to be separated by
;    n_rounds : in, optional, type=long, default=20L
;       number of times to run algorithm
;-
function mg_force, data, min_distance=minDistance, n_rounds=nrounds
  compile_opt strictarr

  ndata = n_elements(data)
  result = data

  _nrounds = n_elements(nrounds) eq 0L ? 20L : nrounds
  maxValue = max(data, min=minValue)
  inc = (maxValue - minValue ) / ndata / 10.0

  for r = 0L, _nrounds - 1L do begin
    for item = 0L, ndata - 1L do begin
      for otherItem = 0L, ndata - 1L do begin
        if (item eq otherItem) then continue

        if ((result[item] ge result[otherItem]) $
              and (result[item] - result[otherItem] lt minDistance)) then begin
          result[item] += inc
          result[otherItem] -= inc
        endif
      endfor
    endfor
  endfor

  return, result
end