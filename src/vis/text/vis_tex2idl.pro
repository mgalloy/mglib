; docformat = 'rst'

;+
; Converts simple TeX notation to IDL format codes used in graphics output.
; Only handles subscripts, superscripts, and sequences listed below.
;
; :Todo:
;    should be able to handle fractions too, use 190 (276 octal) to draw 
;    fraction bars, and !A/!B to go above/below the bar; decide whether to
;    use \frac{1}{2}
;-

;+
; Translate TeX superscript (^) or subscript (_) to proper IDL format codes.
;
; :Returns:
;    string
;
; :Params:
;    token : in, required, type=string
;      either ^ or _, others will return an empty string
;
; :Keywords:
;    level : in, required, type=long
;       set to subscript/superscript level to get appropriate format code
;-
function vis_subsuper, token, level=level
  compile_opt strictarr
  on_error, 2
  
  case token of
    '^': return, (['!U', '!E'])[[level]]
    '_': return, (['!D', '!I'])[[level]]   ; '!D', '!L', '!I' to get 3 levels
    else: return, ''
  endcase
end


;+
; Returns the position in the input string of the closing curly brace that 
; matches the first open curly brace, -1L if not found.
;
; :Returns:
;    long
;
; :Params:
;    input : in, required, type=string
;       input string to search
;-
function vis_matchdelim, input
  compile_opt strictarr
  on_error, 2

  ; make sure there are at least two characters in the input string
  length = strlen(input) 
  if (length lt 1) then return, -1L

  ; find the opening curly brace
  openPos = strpos(input, '{')
  if (openPos eq -1) then return, -1L

  ; use integer ASCII values to do searching
  bOpenDelim = fix((byte('{'))[0])
  bCloseDelim = fix((byte('}'))[0])
  bInput = fix(byte(strmid(input, openPos, length)))

  bInput = fix(bInput eq bOpenDelim) - fix(bInput eq bCloseDelim)
  length = n_elements(bInput) 

  braceCnt = 1L   ; one open brace has already been found
  closePos = 0L
  while (braceCnt gt 0) && (closePos lt length - 1L) do begin
    braceCnt += bInput[++closePos]
  endwhile
  
  closePos += openPos
  if (braceCnt gt 0L) then return, -1L
  
  return, closePos
end


;+
; Count number of occurrences of a substring in a string.
;
; :Params:
;    input : in, required, type=string
;       string to search
;    substr : in, required, type=string
;       substring to search for
;-
function vis_strcnt, input, substr
  compile_opt strictarr
  on_error, 2

  ;  can't search for a null string
  if (strlen(substr) eq 0L) then begin 
    message, 'cannot count occurances of null string', /informational
    return, -1L
  endif
  
  ; for a single character, use the ASCII value of the character
  if (strlen(substr) eq 1L) then begin
    bInput = byte(input)
    ind = where(bInput eq (byte(substr))[0], count)
  endif else begin 
    count = 0L
    pos = strpos(input, substr, /reverse_search)
    while (pos ge 0L) do begin
      count++
      pos = strpos(input, substr, pos, /reverse_search)
    endwhile
  endelse 

  return, count
end 


;+
; Find the next token in a given string.
;
; :Returns:
;    string
;
; :Params:
;    str : in, required, type=string
;       string to search
;    tokens : in, required, type=string
;       tokens
;
; :Keywords:
;     position : out, optional, type=long
;        position in str of next token
;-
function vis_nexttoken, str, tokens, position=position
  on_error, 2

  bStr = byte(str)
  bTokens = byte(tokens)
  nTokens = n_elements(bTokens) 

  ; initialize these arrays with a dummy element
  matchIndices = [0L]
  allMatches = [0L]
  
  for j = 0L, nTokens - 1L do begin 
    match = where(bStr eq bTokens[j], count)
    if (count gt 0L) then begin
      matchIndices = [matchIndices, replicate(j, count)]
      allMatches = [allMatches, match]
    endif 
  endfor 

  ; if no matches found
  if (n_elements(matchIndices) eq 1L) then begin 
    position = -1L
    return, ''
  endif 

  ; remove the dummy elements
  matchIndices = matchIndices[1:*]
  allMatches = allMatches[1:*]

  sortIndices = sort(allMatches)
  position = allMatches[sortIndices[0]]

  return, string(bTokens[matchIndices[sortIndices[0]]])
end


;+
; Find a substring in an input string, return the portion of the input string
; before the substring, and modify the input string to contain only the 
; portion of the string after the token.
;
; :Returns:
;    string
;
; :Params:
;    str : in, out, required, type=string
;       input string; the output value of this string is the remaining portion
;       of the string after the token
;    token : in, required, type=string
;       substring to find in the input string
;-
function vis_token, str, token
  on_error, 2
  
  pos = strpos(str, token)

  if (pos ge 0L) then begin
    front = strmid(str, 0L, pos) 
    str = strmid(str, pos + strlen(token))
  endif else begin    
    front = str
    str = ''
  endelse

  return, front
end


;+
; Convert TeX superscripts and subscripts in a given string to IDL format 
; codes.
;
; :Returns:
;    string
;
; :Params:
;    input : in, required, type=string
;       input string to process
; 
; :Keywords:
;    level : in, optional, type=long
;       set to subscript/superscipt level to indicate which format code is 
;       used to format it (and hence !E and !I are used instead of !U and !D)
;-
function vis_convert_subsuper, input, level=level
  on_error, 2
  
  _level = n_elements(level) eq 0 ? 0L : level
  
  fontRestore = _level gt 0L ? '' : '!N'

  bSpace = (byte(' '))[0]   ; ASCII value for a space
  
  _input = input   ; portion of the input that hasn't been handled yet

  savePos = ''
  restorePos = ''
  
  lenLastScript = 0L

  ; find subscript/superscript location
  token = vis_nexttoken(_input, '^_', position=pos)
  if (pos eq -1L) then return, input

  fontChange = vis_subsuper(token, level=_level)

  ; get substring up to next '^' or '_'
  phrase = vis_token(_input, token)

  while (strlen(_input) gt 0L) do  begin
    script = strmid(_input, 0L, 1L)
    endOfScript = 0L
    if (script eq '{') then begin
      endOfScript = vis_matchdelim(_input)      
      script = vis_convert_subsuper(strmid(_input, 1L, endOfScript - 1L), $
                                   level=_level + 1L)
    endif
    
    ; get substring after the end of the script
    _input = strmid(_input, endOfScript + 1L, strlen(_input) - endOfScript - 1L)

    ; find next script
    fontChange = vis_subsuper(token, level=_level)
    oldToken = token
    token = vis_nexttoken(_input, '^_', position=pos)

    ; make subscript and superscript align by saving position
    if (savePos eq '!S') then begin
      savePos = ''
      restorePos = ''
      ; the number of format codes is twice the number of !'s
      nspaces = lenLastScript - (strlen(script) - 2 * vis_strcnt(script, '!'))
      nspaces = (nspaces + 1) > 0
      if (nspaces gt 0L) then script += string(replicate(bSpace, nspaces))
    endif else begin
      if (token ne oldToken) && (pos eq 0) then begin
        ; the next script follows this one
        savePos = '!S'
        restorePos = '!R'
        lenLastScript = strlen(script) - 2 * vis_strcnt(script, '!')
      endif
    endelse  

    ; add on the just processed script
    phrase += savePos + fontChange + script + restorePos + fontRestore

    if (pos ne -1L) then begin   
      phrase += vis_token(_input, token)   
    endif else begin
      phrase += _input
      _input = ''
    endelse
  endwhile 

  return, phrase
end


;+
; Convert TeX fractions in a given string to IDL format codes.
;
; :Returns:
;    string
;
; :Params:
;    input : in, required, type=string
;       input string to process
;
; :Keywords:
;    postscript : in, optional, type=boolean
;       set to use postscript fonts
;-
function vis_convert_fraction, input, postscript=postscript
  compile_opt strictarr
  
  bar = keyword_set(postscript) ? 190B : (byte('L'))[0]
  
  
  ; TODO: fix this to find correct matching {}'s
  pattern = '\\frac{(.*)}{(.*)}'
  
  ; TODO: not sure how to compute the number of bar characters to use
  ; TODO: 190B is only correct for postscript
  replace = '!S!S!A$1!R!B$2!N!R!9' + string(bytarr(6) + bar) + '!X'
  return, vis_streplace(input, pattern, replace, /global)
end


;+
; Returns table containing allowable TeX sequences and their translation to 
; IDL.
;
; :Returns:
;    strarr(2, n)
;
; :Keywords:
;    postscript : in, optional, type=boolean
;       set to use postscript fonts
;-
function vis_textable, postscript=postscript
  on_error, 2
  
  ; 1 => vector font, 2 => postscript font
  col = keyword_set(postscript) ? 2 : 1

  toGreekFont = ['', '!7', '!M']
  toSymbolFont = ['', '!M', '!M']
  toPreviousFont = ['', '!X', '!X']

  lowercase = [ $
    ['\alpha',      'a',     'a'     ], $
    ['\beta',       'b',     'b'     ], $
    ['\gamma',      'c',     'g'     ], $
    ['\delta',      'd',     'd'     ], $
    ['\epsilon',    'e',     'e'     ], $
    ['\zeta',       'f',     'z'     ], $
    ['\eta',        'g',     'h'     ], $
    ['\theta',      'h',     'q'     ], $
    ['\iota',       'i',     'i'     ], $
    ['\kappa',      'j',     'k'     ], $
    ['\lambda',     'k',     'l'     ], $
    ['\mu',         'l',     'm'     ], $
    ['\nu',         'm',     'n'     ], $
    ['\xi',         'n',     '!S !Rx'], $
    ['\pi',         'p',     'p'     ], $
    ['\rho',        'q',     'r'     ], $
    ['\sigma',      'r',     's'     ], $
    ['\tau',        's',     't'     ], $
    ['\upsilon',    't',     'u'     ], $
    ['\phi',        'u',     'f'     ], $
    ['\chi',        'v',     'c'     ], $
    ['\psi',        'w',     'y'     ], $
    ['\omega',      'x',     'w'     ], $
    ['\varpi',      'p',     'v'     ], $
    ['\varepsilon', 'e',     'e'     ], $
    ['\varphi',     '!MP!X', 'j'     ], $
    ['\vartheta',   '!Mt!X', 'J'     ]]
    
  uppercase = [ $
    ['\Gamma',   'C', 'G'         ], $
    ['\Delta',   'D', 'D'         ], $
    ['\Theta',   'H', 'Q'         ], $
    ['\Lambda',  'K', 'L'         ], $
    ['\Xi',      'N', '!S !RX'    ], $
    ['\Pi',      'P', 'P'         ], $
    ['\Sigma',   'R', 'S'         ], $
    ['\Upsilon', 'T', string(161B)], $
    ['\Phi',     'U', 'F'         ], $
    ['\Psi',     'W', 'Y'         ], $
    ['\Omega',   'X', 'W'         ]]
    
  symbols = [ $
    ['\aleph',      '@',   string(192B)], $
    ['\ast',        '*',   '*'         ], $
    ['\cap',        '3',   string(199B)], $
    ['\cdot',       '.',   string(215B)], $
    ['\cup',        '1',   string(200B)], $
    ['\exists',     'E',   '$'         ], $
    ['\infty',      '$',   string(165B)], $
    ['\int',        'i',   string(242B)], $
    ['\in',         'e',   string(206B)], $
    ['\equiv',      ':',   string(186B)], $
    ['\pm',         '+',   string(177B)], $
    ['\div',        '/',   string(184B)], $
    ['\subset',     '0',   string(204B)], $
    ['\superset',   '2',   string(201B)], $
    ['\leftarrow',  '4',   string(172B)], $
    ['\downarrow',  '5',   string(175B)], $
    ['\rightarrow', '6',   string(174B)], $
    ['\uparrow',    '7',   string(173B)], $
    ['\neq',        '=',   string(185B)], $
    ['\propto',     '?',   string(181B)], $
    ['\sim',        'A',   string(126B)], $
    ['\sqrt',       'R',   string(214B)], $
    ['\partial',    'D',   string(182B)], $
    ['\nabla',      'G',   string(209B)], $
    ['\angle',      'a',   string(208B)], $
    ['\times',      'X',   string(180B)], $
    ['\geq',        'b',   string(179B)], $
    ['\leq',        'l',   string(163B)], $
    ['\''',         '''',  string(162B)], $
    ['\prime',      '''',  string(162B)], $
    ['\circ',       '%',   string(176B)], $
    ['\arcdeg',     '%',   string(176B)], $
    ['\arcmin',     '''',  string(162B)], $
    ['\arcsec',     '"'  , string(178B)]]
  
  accents = [ $
    ['\AA', string(197B)], $
    ['\"{A}', string(196B)], $
    ['\"{E}', string(203B)], $
    ['\"{I}', string(207B)], $
    ['\"{O}', string(214B)], $
    ['\"{U}', string(220B)], $  
    ['\"{a}', string(228B)], $
    ['\"{e}', string(235B)], $
    ['\"{i}', string(239B)], $
    ['\"{o}', string(246B)], $
    ['\"{u}', string(252B)], $
    ['\\^{A}', string(194B)], $
    ['\\^{E}', string(202B)], $
    ['\\^{I}', string(206B)], $
    ['\\^{O}', string(212B)], $
    ['\\^{U}', string(219B)], $  
    ['\\^{a}', string(226B)], $
    ['\\^{e}', string(234B)], $
    ['\\^{i}', string(238B)], $
    ['\\^{o}', string(244B)], $
    ['\\^{u}', string(251B)], $
    ['\\^{y}', string(255B)], $    
    ['\`{A}', string(192B)], $
    ['\`{E}', string(200B)], $
    ['\`{I}', string(204B)], $
    ['\`{O}', string(210B)], $
    ['\`{U}', string(217B)], $  
    ['\`{a}', string(224B)], $
    ['\`{e}', string(232B)], $
    ['\`{i}', string(236B)], $
    ['\`{o}', string(242B)], $
    ['\`{u}', string(249B)], $
    ['\''{A}', string(193B)], $
    ['\''{E}', string(201B)], $
    ['\''{I}', string(205B)], $
    ['\''{O}', string(211B)], $
    ['\''{U}', string(218B)], $  
    ['\''{Y}', string(221B)], $
    ['\''{a}', string(225B)], $
    ['\''{e}', string(233B)], $
    ['\''{i}', string(237B)], $
    ['\''{o}', string(243B)], $
    ['\''{u}', string(250B)], $
    ['\''{y}', string(253B)], $    
    ['\~{A}', string(195B)], $
    ['\~{N}', string(209B)], $
    ['\~{O}', string(213B)], $
    ['\~{a}', string(227B)], $
    ['\~{n}', string(241B)], $
    ['\~{o}', string(245B)]]
  
  lowercase = lowercase[[0, col], *]
  uppercase = uppercase[[0, col], *]
  symbols   = symbols[[0, col], *]
  
  lowercase[1, *] = toGreekFont[col]  + lowercase[1, *] + toPreviousFont[col]
  uppercase[1, *] = toGreekFont[col]  + uppercase[1, *] + toPreviousFont[col]
  symbols[1, *]   = toSymbolFont[col] + symbols[1, *]   + toPreviousFont[col]
  
  table = [[accents], [lowercase], [uppercase], [symbols]]
    
  return, table
end 


;+
; Convert a TeX string to a string with embedded IDL format codes.
;
; :Returns:
;    string or strarr
; 
; :Params:
;    input : in, required, type=string/strarr
;       input TeX string or strarr
;
; :Keywords:
;    font : in, optional, type=long
;       set to -1 to translate for vector fonts, 0 for hardware fonts
;-
function vis_tex2idl, input, font=font
  compile_opt strictarr
  on_error, 2
  
  ; postscript = 0 means use vector
  postscript = 0
  if (n_elements(font) eq 0) then begin
    if (!p.font ne -1L) then postscript = 1
  endif else begin
    if (font ne -1L) then postscript = 1
  endelse

  ; done if the user wants non-Postscript hardware font
  if (postscript eq 1) and (!d.name ne 'PS') then begin   
    message, 'no translation for device: ' + !d.name, /informational
    return, input               
  endif 
    
  table = vis_textable(postscript=postscript)

  ; translate TeX sequences
  sequences = reform(table[0, *])  
  results = reform(table[1, *])
  output = input
    
  for s = 0L, n_elements(sequences) - 1L do begin
    ; need an extra \ to escape the \ symbol
    output = vis_streplace(output, '\' + sequences[s], results[s], /global)
  endfor
    
  ; place {}'s around TeX sequences in subscripts or superscripts
  for s = 0L, n_elements(sequences) - 1L do begin
    output = vis_streplace(output, $
                           '\^\' + sequences[s], $
                           '^{' + sequences[s] + '}', $
                           /global)
    output = vis_streplace(output, $
                           '\_\' + sequences[s], $
                           '_{' + sequences[s] + '}', $
                           /global)
  endfor

  ; take care of subscripts and superscripts
  for i = 0L, n_elements(output) - 1L do begin
    output[i] = vis_convert_subsuper(output[i]) 
  endfor

  ; take care of fractions
  for i = 0L, n_elements(output) - 1L do begin
    output[i] = vis_convert_fraction(output[i], postscript=postscript) 
  endfor
  
  return, output
end


; Main-level example program

if (keyword_set(ps)) then begin
  vis_psbegin, /image, filename='tex.ps'
endif

xyouts, 0.5, 0.90, vis_tex2idl('sin(2\pi t) where 0 \leq t \leq 1'), /normal, $
        charsize=2.0, alignment=0.5

xyouts, 0.5, 0.80, vis_tex2idl('a^5_b'), /normal, $
        charsize=2.0, alignment=0.5

xyouts, 0.5, 0.70, vis_tex2idl('a_{b_0}'), /normal, $
        charsize=2.0, alignment=0.5

xyouts, 0.5, 0.60, 'a!Db!Lc!N', /normal, $
        charsize=2.0, alignment=0.5

xyouts, 0.5, 0.50, vis_tex2idl('a_{b_c}'), /normal, $
        charsize=2.0, alignment=0.5
        
xyouts, 0.5, 0.40, vis_tex2idl('a^{b^c}'), /normal, $
        charsize=2.0, alignment=0.5

; an example from the online help
partialSol = '_{Lower_{Index}^{Exponent}}Normal' $
               + '!S!EExp!R!IInd!N!S!U Up!R!D Down!N!S!A Above!R!B Below'
xyouts, 0.5, 0.30, vis_tex2idl(partialSol), /normal, $
        charsize=2.0, alignment=0.5

; "complex equation" from online help about formatting codes translated to 
; TeX code
xyouts, 0.5, 0.20, vis_tex2idl('\int_p^x \rho_iU_i^2dx'), /normal, $
        charsize=2.0, alignment=0.5

equation = '\nablax\arcsec \propto \frac{-b \pm \sqrt b^2 - 4ac}{         2a}'
xyouts, 0.5, 0.10, vis_tex2idl(equation), /normal, $
        charsize=2.0, alignment=0.5                

if (keyword_set(ps)) then begin                
  vis_psend
  vis_convert, 'tex', /from_ps, /to_png, max_dim=[700, 700], output=im                            
  file_delete, 'tex.ps'
  file_delete, 'tex.png'
  window, xsize=700, ysize=500
  tvscl, im, true=1
endif

end
 
