; docformat = 'rst'

;+
; This class is used to inherit from in IDL versions before 8.0, allowing
; operator overloaded classes to still compile on earlier versions (though not
; to offer operator overloading, of course). For IDL versions 8.0 or later,
; the internal IDL provided `IDL_Object` class should be found before this
; class.
;-


;+
; Free resources.
;-
pro idl_object::cleanup
  compile_opt strictarr

end


;+
; Create IDL_Object object.
;
; :Returns:
;   1 for success, 0 for failure
;-
function idl_object::init
  compile_opt strictarr

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;   idl_object_top
;     just to match IDL's IDL_Object
;   __obj__
;     just to match IDL's IDL_Object
;   idl_object_bottom
;     just to match IDL's IDL_Object
;-
pro idl_object__define
  compile_opt strictarr

  define = { IDL_Object, $
             idl_object_top: 0L, $
             __obj__: obj_new(), $
             idl_object_bottom: 0L }
end
