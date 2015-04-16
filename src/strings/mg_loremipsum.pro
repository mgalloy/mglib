; docformat = 'rst'

;+
; Returns the Lorem Ipsum text. Useful for placing dummy text in an output.
;
; :Returns:
;   string
;
; :Keywords:
;   n_repeat : in, optional, type=integer, default=1
;     number of times to repeat the text
;-
function mg_loremipsum, n_repeat=n_repeat
  compile_opt strictarr

  _n_repeat = n_elements(n_repeat) eq 0 ? 1L : n_repeat
  s = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do' $
        + ' eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut' $
        + ' enim ad minim veniam, quis nostrud exercitation ullamco laboris' $
        + ' nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor' $
        + ' in reprehenderit in voluptate velit esse cillum dolore eu fugiat' $
        + ' nulla pariatur. Excepteur sint occaecat cupidatat non proident,' $
        + ' sunt in culpa qui officia deserunt mollit anim id est laborum.'
  return, _n_repeat gt 1 ? strjoin(strarr(_n_repeat) + s, ' ') : s
end
