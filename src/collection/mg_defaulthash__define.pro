; docformat = 'rst'

;+
; Hash with default value. Specify `default` when creating the default hash.
;-

;+
; Handle keys that are not present.
;-
function mg_defaulthash::_overloadBracketsRightSide, is_range, $
                                                     ss1, ss2, ss3, ss4, $
                                                     ss5, ss6, ss7, ss8
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, *self.default
  endif

  value = self->hash::_overloadBracketsRightSide(is_range, $
                                                 ss1, ss2, ss3, ss4, $
                                                 ss5, ss6, ss7, ss8)
  return, value
end


;+
; Free resources.
;-
pro mg_defaulthash::cleanup
  compile_opt strictarr

  ptr_free, self.default
  self->hash::cleanup
end


;+
; Create a default hash object.
;
; :Keywords:
;   default : in, optional, type=any
;     value to return for value retrieval if the key is not present
;-
function mg_defaulthash::init, key1, value1, key2, value2, key3, value3, $
                               key4, value4, key5, value5, key6, value6, $
                               key7, value7, key8, value8, key9, value9, $
                               key10, value10, key11, value11, key12, value12, $
                               key13, value13, key14, value14, key15, value15, $
                               key16, value16, key17, value17, key18, value18, $
                               key19, value19, key20, value20, key21, value21, $
                               key22, value22, key23, value23, key24, value24, $
                               key25, value25, key26, value26, key27, value27, $
                               key28, value28, key29, value29, key30, value30, $
                               key31, value31, key32, value32, key33, value33, $
                               key34, value34, key35, value35, key36, value36, $
                               key37, value37, key38, value38, key39, value39, $
                               key40, value40, key41, value41, key42, value42, $
                               key43, value43, key44, value44, key45, value45, $
                               key46, value46, key47, value47, key48, value48, $
                               key49, value49, key50, value50, key51, value51, $
                               key52, value52, key53, value53, key54, value54, $
                               key55, value55, key56, value56, key57, value57, $
                               key58, value58, key59, value59, key60, value60, $
                               key61, value61, key62, value62, key63, value63, $
                               key64, value64, key65, value65, key66, value66, $
                               key67, value67, key68, value68, key69, value69, $
                               key70, value70, key71, value71, key72, value72, $
                               key73, value73, key74, value74, key75, value75, $
                               key76, value76, key77, value77, key78, value78, $
                               key79, value79, key80, value80, key81, value81, $
                               key82, value82, key83, value83, key84, value84, $
                               key85, value85, key86, value86, key87, value87, $
                               key88, value88, key89, value89, key90, value90, $
                               key91, value91, key92, value92, key93, value93, $
                               key94, value94, key95, value95, key96, value96, $
                               key97, value97, key98, value98, key99, value99, $
                               key100, value100, key101, value101, $
                               key102, value102, key103, value103, $
                               key104, value104, key105, value105, $
                               key106, value106, key107, value107, $
                               key108, value108, key109, value109, $
                               key110, value110, key111, value111, $
                               key112, value112, key113, value113, $
                               key114, value114, key115, value115, $
                               key116, value116, key117, value117, $
                               key118, value118, key119, value119, $
                               key120, value120, key121, value121, $
                               key122, value122, key123, value123, $
                               key124, value124, key125, value125, $
                               key126, value126, key127, value127, $
                               key128, value128, $
                               default=default, _extra=e
  compile_opt strictarr

  if (~self->hash::init(_extra=e)) then return, 0

  self.default = ptr_new(/allocate_heap)

  if (n_elements(default) gt 0L) then *self.default = default

  return, 1
end


;+
; Define `mg_defaulthash`.
;-
pro mg_defaulthash__define
  compile_opt strictarr

  !null = {mg_defaulthash, inherits hash, $
           default: ptr_new()}
end


; main-level example program

h = mg_defaulthash(default=0L)

print, h[752], format='(%"h[752]: %d")'
print, h[751], format='(%"h[751]: %d")'

print, 'incrementing h[752]'
h[752] += 1

print, h[752], format='(%"h[752]: %d")'
print, h[751], format='(%"h[751]: %d")'

print, 'incrementing h[752]'
h[752] += 1

print, h[752], format='(%"h[752]: %d")'
print, h[751], format='(%"h[751]: %d")'

end
