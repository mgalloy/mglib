; docformat = 'rst'

;+
; Rectangle.
;
; :Properties:
;   x
;     x-coordinate of lower-left corner
;   y
;     y-coordinate of lower-left corner
;   width
;     width of rectangle
;   height
;     height of rectangle
;-

;+
; Make a copy of the rectangle.
;
; :Returns:
;   `MGgrRect` object
;-
function mggrrect::copy
  compile_opt strictarr

  return, obj_new('MGgrRect', $
                  x=self.x, y=self.y, $
                  width=self.width, height=self.height)
end


;+
; Find the distance.
;
; :Returns:
;   float
;
; :Params:
;   rect : in, required, type=`MGgrRect`
;     rectangle to find the distance to
;-
function mggrrect::distance, rect
  compile_opt strictarr

  return, sqrt((self.x - rect.x) ^ 2 $
                 + (self.y - rect.y) ^ 2 $
                 + (self.width - rect.width) ^ 2 $
                 + (self.height - self.height) ^ 2)
end


;+
; Determine aspect ratio of rectangle.
;
; :Returns:
;   float
;-
function mggrrect::aspectRatio
  compile_opt strictarr

  return, max([self.width / self.height, self.height / self.width])
end


;= property access

;+
; Set properties.
;-
pro mggrrect::setProperty, x=x, y=y, width=width, height=height
  compile_opt strictarr

  if (n_elements(x) gt 0L) then self.x = x
  if (n_elements(y) gt 0L) then self.y = y
  if (n_elements(width) gt 0L) then self.width = width
  if (n_elements(height) gt 0L) then self.height = height
end


;+
; Get properties.
;-
pro mggrrect::getProperty, x=x, y=y, width=width, height=height
  compile_opt strictarr

  if (arg_present(x)) then x = self.x
  if (arg_present(y)) then y = self.y
  if (arg_present(width)) then width = self.width
  if (arg_present(height)) then height = self.height
end


;= lifecycle methods

;+
; Create rectangle.
;
; :Returns:
;   1 for success, 0 otherwise
;-
function mggrrect::init, x=x, y=y, width=width, height=height
  compile_opt strictarr

  self.x = n_elements(x) eq 0L ? 0.0 : x
  self.y = n_elements(y) eq 0L ? 0.0 : y
  self.width = n_elements(width) eq 0L ? 1.0 : width
  self.height = n_elements(height) eq 0L ? 1.0 : height

  return, 1
end


;+
; Define instance variables.
;-
pro mggrrect__define
  compile_opt strictarr

  define = { mggrrect, $
             x: 0.0, $
             y: 0.0, $
             width: 0.0, $
             height: 0.0 $
           }
end
