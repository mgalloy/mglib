; docformat = 'rst'

;+
; Spread data apart using a force directed algorithm.
;
; :Categories:
;    graphics computation
;-

;+
; Spread data apart using a simple algorithm.
;
; :Returns:
;    fltarr
;
; :Params:
;    data : in, required, type=fltarr
;       input data to force apart
;
; :Keywords:
;    min_distance : in, optional, type=float, default=1.0
;       min distance that items need to be separated by
;    n_rounds : in, optional, type=long, default=20L
;       number of times to run algorithm
;-
function mg_force, data, min_distance=min_distance, n_rounds=nrounds
  compile_opt strictarr

  ndata = n_elements(data)
  result = data

  _nrounds = n_elements(nrounds) eq 0L ? 20L : nrounds
  _min_distance = n_elements(min_distance) eq 0L ? 1.0 : min_distance

  inc = 0.125 * _min_distance

  for r = 0L, _nrounds - 1L do begin
    for item = 0L, ndata - 1L do begin
      for otherItem = 0L, ndata - 1L do begin
        if (item eq otherItem) then continue

        if ((result[item] ge result[otherItem]) $
              and (result[item] - result[otherItem] lt _min_distance)) then begin
          result[item] += inc
          result[otherItem] -= inc
        endif
      endfor
    endfor
  endfor

  return, result
end
