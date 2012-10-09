; docformat = 'rst'

;+
; Subclass of `IDLgrModel` intended to be passed to `IDLgrSymbol` to be used as
; a plot symbol.


;+
; Free resources.
;-
pro mggrchernoffface::cleanup
    compile_opt strictarr

    self->IDLgrModel::cleanup
end


;+
; Initialize instance variables.
;
; :Returns:
;    1 for success, 0 otherwise
;
; :Keywords:
;    head_eccentricity : in, optional, type=float, default=0.5
;       length of nose, range: 0 (small) - 1 (large)
;    nose_length : in, optional, type=float, default=0.5
;       size of nose, range: 0 (small) - 1 (large)
;    mouth_size : in, optional, type=float, default=0.5
;       size of mouth, range: 0 (small) - 1 (large)
;    mouth_shape : in, optional, type=float, default=0.5
;       shape of mouth, not implemented yet
;    eye_size : in, optional, type=float, default=0.5
;       size of eyes, range: 0 (small) - 1 (large)
;    eye_eccentricity : in, optional, type=float, default=0.5
;       shape of eyes, range: 0 (round) - 1 (oval)
;    eye_spacing : in, optional, type=float, default=0.5
;       space between eyes, range: 0 (close) - 1 (far apart)
;    pupil_size : in, optional, type=float, default=0.5
;       size of pupil relative to eye size, range: 0 (no pupils) - 1 (fills
;       eye)
;    eyebrow_slant : in, optional, type=float, default=0.5
;       slant of eyebrows, range: 0 (raised on outside) - 1 (raised on inside)
;    _ref_extra : in, optional, type=keywords
;       keywords to IDLgrModel::init or IDLgrPolygon::init
;-
function mggrchernoffface::init, head_eccentricity=head_eccentricity, $
                                 nose_length=nose_length, $
                                 mouth_size=mouth_size, $
                                 mouth_shape=mouth_shape, $
                                 eye_size=eye_size, $
                                 eye_eccentricity=eye_eccentricity, $
                                 eye_spacing=eye_spacing, $
                                 pupil_size=pupil_size, $
                                 eyebrow_slant=eyebrow_slant, $
                                 _ref_extra=e
  compile_opt strictarr

  if (~self->IDLgrModel::init(_extra=e)) then return, 0

  myThick = n_elements(thick) eq 0L ? 1.0 : thick

  ; nose
  self.noseLength = n_elements(nose_length) eq 0L ? 0.5 : nose_length
  onose = obj_new('IDLgrPolyline', $
                  [0.0, 0.0], $
                  [-self.noseLength, + self.noseLength] * 0.4, $
                  _extra=e)
  self->add, onose

  ; mouth
  self.mouthSize = n_elements(mouth_size) eq 0L ? 0.5 : mouth_size
  self.mouthShape = n_elements(mouth_shape) eq 0L ? 0.5 : mouth_shape

  startT = !pi / 2.0 * (3.0 - self.mouthSize)
  t = findgen(11) / 10.0 * !pi * self.mouthSize + startT
  smileCenter = [0.0, -0.2]
  smileX = smileCenter[0] + cos(t) / 2.0
  smileY = smileCenter[1] + sin(t) / 2.0
  omouth = obj_new('IDLgrPolyline', smileX, smileY, _extra=e)
  self->add, omouth

  ; eyes
  self.eyeSize = n_elements(eye_size) eq 0L ? 0.5 : eye_size
  self.eyeSpacing = n_elements(eye_spacing) eq 0L ? 0.5 : eye_spacing
  self.eyeEccentricity = n_elements(eye_eccentricity) eq 0L $
                           ? 0.5 $
                           : eye_eccentricity

  t = findgen(37) * 10.0 * !dtor
  eyeX = self.eyeSize / 6.0 * cos(t)
  eyeY = self.eyeSize * (1.0 - self.eyeEccentricity) / 6.0 * sin(t)
  eyeHeight = 0.4
  eyeSep = 0.2 + 0.15 * self.eyeSpacing
  oLeftEye = obj_new('IDLgrPolyline', - eyeSep + eyeX, eyeHeight + eyeY, _extra=e)
  self->add, oLeftEye
  oRightEye = obj_new('IDlgrPolyline', eyeSep + eyeX, eyeHeight + eyeY, _extra=e)
  self->add, oRightEye

  ; eyebrows
  self.eyebrowSlant = n_elements(eyebrow_slant) eq 0L ? 0.5 : eyebrow_slant

  leftEyebrowX = [-1.0, 1.0] * self.eyeSize / 6.0 - eyeSep
  rightEyebrowX = [-1.0, 1.0] * self.eyeSize / 6.0 + eyeSep
  eyebrowMargin = 0.2
  eyebrowHeight = 0.2
  eyebrowY = eyeHeight + eyebrowMargin $
               + [- self.eyebrowSlant + 1, self.eyebrowSlant] * eyebrowHeight

  oLeftEyebrow = obj_new('IDLgrPolyline', leftEyebrowX, reverse(eyebrowY), _extra=e)
  self->add, oLeftEyebrow
  oRightEyebrow = obj_new('IDLgrPolyline', rightEyebrowX, eyebrowY, _extra=e)
  self->add, oRightEyebrow

  ; pupils
  self.pupilSize = n_elements(pupil_size) eq 0L ? 0.5 : pupil_size

  oLeftPupil = obj_new('IDLgrPolygon', $
                       - eyeSep + eyeX * self.pupilSize, $
                       eyeHeight + eyeY * self.pupilSize, $
                       _extra=e)
  self->add, oLeftPupil
  oRightPupil = obj_new('IDLgrPolygon', $
                        eyeSep + eyeX * self.pupilSize, $
                        eyeHeight + eyeY * self.pupilSize, $
                       _extra=e)
  self->add, oRightPupil

  ; head
  self.headEccentricity = n_elements(head_eccentricity) eq 0L $
                            ? 0.5 $
                            : head_eccentricity

  t = findgen(37) * 10.0 * !dtor
  headX = (1.0 - 0.25 * self.headEccentricity) * cos(t)
  headY = (1.0 + 0.35 * self.headEccentricity) * sin(t)
  ohead = obj_new('IDLgrPolyline', headX, headY, _extra=e)
  self->add, ohead

  return, 1B
end


;+
; Define instance variables.
;
; :Fields:
;    noseLength
;       length of nose, range: 0 (small) - 1 (large)
;    mouthSize
;       size of mouth, range: 0 (small) - 1 (large)
;    mouthShape
;       shape of mouth, not implemented yet
;    eyeSize
;       size of eyes, range: 0 (small) - 1 (large)
;    eyeSpacing
;       space between eyes, range: 0 (close) - 1 (far apart)
;    eyeEccentricity
;       shape of eyes, range: 0 (round) - 1 (oval)
;    eyebrowSlant
;       slant of eyebrows, range: 0 (raised on outside) - 1 (raised on inside)
;    pupilSize
;       size of pupil relative to eye size, range: 0 (no pupils) - 1 (fills
;       eye)
;    headEccentricity
;       shape of head, range: 0 (round) - 1 (oval)
;-
pro mggrchernoffface__define
    compile_opt strictarr

    define = { MGgrChernoffFace, inherits IDLgrModel, $
               noseLength : 0.0, $
               mouthSize : 0.0, $
               mouthShape : 0.0, $
               eyeSize : 0.0, $
               eyeSpacing : 0.0, $
               eyeEccentricity : 0.0, $
               eyebrowSlant : 0.0, $
               pupilSize : 0.0, $
               headEccentricity : 0.0 $
             }
end
