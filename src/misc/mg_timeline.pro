; docformat = 'rst'

;+
; `MG_TIMELINE` is a timeline creation routine which creates a PostScript output
; file from an XML input file.
;
; :Examples:
;   Try the main-level example program at the end of this file::
;
;     IDL> .run mg_timeline
;
;   This should produce a timeline; below is a small section of it:
;
;   .. image:: athletic-thumbnail.png
;-


;= helper routines

;+
; Helper routine to convert dates like "1-1-2009" to Julian dates.
;
; :Private:
;
; :Returns:
;   double
;
; :Params:
;   date : in, required, type=string
;     date like "1-1-2009"
;-
function mg_timeline_julday, date
  compile_opt strictarr

  tokens = strsplit(date, '-', /extract)
  return, julday(long(tokens[0]), long(tokens[1]), long(tokens[2]), 0., 0., 0.)
end


;= property access for MG_TimelineText

;+
; Get properties.
;
; :Private:
;-
pro mg_timelinetext::getProperty, text=text, color=color, date=date, $
                                  level=level, alignment=alignment
  compile_opt strictarr

  if (arg_present(text)) then text = *self.text
  if (arg_present(color)) then color = self.color
  if (arg_present(date)) then date = self.date
  if (arg_present(level)) then level = self.level
  if (arg_present(alignment)) then alignment = self.alignment
end


;+
; Set properties.
;
; :Private:
;-
pro mg_timelinetext::setProperty, text=text, color=color, date=date, $
                                  level=level, alignment=alignment
  compile_opt strictarr

  if (n_elements(text) gt 0L) then *self.text = strjoin(mg_strunmerge(text), '!C')
  if (n_elements(color) gt 0L) then self.color = color
  if (n_elements(date) gt 0L) then self.date = date
  if (n_elements(level) gt 0L) then self.level = level
  if (n_elements(alignment) gt 0L) then self.alignment = alignment
end


;= lifecycle methods for MG_TimelineText

;+
; Free resources.
;
; :Private:
;-
pro mg_timelinetext::cleanup
  compile_opt strictarr

  ptr_free, self.text
end


;+
; Create timeline text object.
;
; :Private:
;
; :Returns:
;   1 for success, 0 otherwise
;-
function mg_timelinetext::init
  compile_opt strictarr

  self.text = ptr_new(/allocate_heap)

  return, 1
end


;+
; Define instance variables.
;
; :Private:
;-
pro mg_timelinetext__define
  compile_opt strictarr

  define = { mg_timelinetext, $
             text: ptr_new(), $
             color: '', $
             date: 0.0D, $
             level: 0.0, $
             alignment: 0.0 $
           }
end


;= property access for MG_TimelineActivity

;+
; Get properties.
;
; :Private:
;-
pro mg_timelineactivity::getProperty, name=name, color=color, value=value, $
                                      level=level, report=report, start=start
  compile_opt strictarr

  if (arg_present(name)) then name = *self.name
  if (arg_present(value)) then value = *self.value
  if (arg_present(color)) then color = self.color
  if (arg_present(level)) then level = self.level
  if (arg_present(report)) then report = self.report
  if (arg_present(start)) then start = self.start
end


;+
; Set properties.
;
; :Private:
;-
pro mg_timelineactivity::setProperty, name=name, color=color, value=value, $
                                      level=level, report=report, start=start
  compile_opt strictarr

  if (n_elements(name) gt 0L) then *self.name = strjoin(mg_strunmerge(name), '!C')
  if (n_elements(value) gt 0L) then *self.value = value
  if (n_elements(color) gt 0L) then self.color = color
  if (n_elements(level) gt 0L) then self.level = level
  if (n_elements(report) gt 0L) then self.report = report
  if (n_elements(start) gt 0L) then self.start = start
end


;= lifecycle methods for MG_TimelineActivity

;+
; Free resources.
;
; :Private:
;-
pro mg_timelineactivity::cleanup
  compile_opt strictarr

  ptr_free, self.name, self.value
end


;+
; Create a timeline activity object.
;
; :Private:
;
; :Returns:
;   1 for success, 0 otherwise
;-
function mg_timelineactivity::init
  compile_opt strictarr

  self.name = ptr_new(/allocate_heap)
  self.value = ptr_new(/allocate_heap)

  self.start = 1L

  return, 1
end


;+
; Define instance variables.
;
; :Private:
;-
pro mg_timelineactivity__define
  compile_opt strictarr

  define = { mg_timelineactivity, $
             name: ptr_new(), $
             value: ptr_new(), $
             color: '', $
             level: 0.0, $
             report: '', $
             start: 0L $
           }
end


;= property access for MG_TimelineInterval

;+
; Get properties.
;
; :Private:
;-
pro mg_timelineinterval::getProperty, name=name, color=color, $
                                      start_date=startDate, end_date=endDate, $
                                      level=level
  compile_opt strictarr

  if (arg_present(name)) then name = *self.name
  if (arg_present(color)) then color = self.color
  if (arg_present(startDate)) then startDate = self.startDate
  if (arg_present(endDate)) then endDate = self.endDate
  if (arg_present(level)) then level = self.level
end


;+
; Set properties.
;
; :Private:
;-
pro mg_timelineinterval::setProperty, name=name, color=color, $
                                      start_date=startDate, end_date=endDate, $
                                      level=level
  compile_opt strictarr

  if (n_elements(name) gt 0L) then *self.name = strjoin(mg_strunmerge(name), '!C')
  if (n_elements(color) gt 0L) then self.color = color
  if (n_elements(startDate) gt 0L) then self.startDate = startDate
  if (n_elements(endDate) gt 0L) then self.endDate = endDate
  if (n_elements(level) gt 0L) then self.level = level
end


;= lifecycle methods for MG_TimelineInterval

;+
; Free resources.
;
; :Private:
;-
pro mg_timelineinterval::cleanup
  compile_opt strictarr

  ptr_free, self.name
end


;+
; Create a timeline interval object.
;
; :Private:
;
; :Returns:
;   1 for success, 0 otherwise
;-
function mg_timelineinterval::init
  compile_opt strictarr

  self.name = ptr_new(/allocate_heap)

  return, 1
end


;+
; Define instance variables.
;
; :Private:
;-
pro mg_timelineinterval__define
  compile_opt strictarr

  define = { mg_timelineinterval, $
             name: ptr_new(), $
             color: '', $
             startDate: 0.0D, $
             endDate: 0.0D, $
             level: 0.0 $
           }
end


;= property access for MG_TimelineEvent

;+
; Get properties.
;
; :Private:
;-
pro mg_timelineevent::getProperty, text=text, color=color, date=date, level=level
  compile_opt strictarr

  if (arg_present(text)) then text = *self.text
  if (arg_present(color)) then color = self.color
  if (arg_present(date)) then date = self.date
  if (arg_present(level)) then level = self.level
end


;+
; Set properties.
;
; :Private:
;-
pro mg_timelineevent::setProperty, text=text, color=color, date=date, level=level
  compile_opt strictarr

  if (n_elements(text) gt 0L) then *self.text = strjoin(mg_strunmerge(text), '!C')
  if (n_elements(color) gt 0L) then self.color = color
  if (n_elements(date) gt 0L) then self.date = date
  if (n_elements(level) gt 0L) then self.level = level
end


;= lifecycle methods for MG_TimelineEvent

;+
; Free resources.
;
; :Private:
;-
pro mg_timelineevent::cleanup
  compile_opt strictarr

  ptr_free, self.text
end


;+
; Create timeline event object.
;
; :Private:
;
; :Returns:
;   1 for success, 0 otherwise
;-
function mg_timelineevent::init
  compile_opt strictarr

  self.text = ptr_new(/allocate_heap)

  return, 1
end


;+
; Define instance variables.
;
; :Private:
;-
pro mg_timelineevent__define
  compile_opt strictarr

  define = { mg_timelineevent, $
             text: ptr_new(), $
             color: '', $
             date: 0.0D, $
             level: 0.0 $
           }
end


;= property access for MG_Timeline

;+
; Get properties.
;
; :Private:
;-
pro mg_timeline::getProperty, start_date=startDate, end_date=endDate, $
                              ticks=ticks, major=major, $
                              events=events, intervals=intervals, $
                              activities=activities, texts=texts, $
                              mark_now=markNow, now_color=nowColor
  compile_opt strictarr

  if (arg_present(startDate)) then startDate = self.startDate
  if (arg_present(endDate)) then endDate = self.endDate
  if (arg_present(ticks)) then ticks = self.ticks
  if (arg_present(major) && self.major gt 0L) then major = self.major
  if (arg_present(events)) then events = self.events
  if (arg_present(intervals)) then intervals = self.intervals
  if (arg_present(activities)) then activities = self.activities
  if (arg_present(texts)) then texts = self.texts
  if (arg_present(markNow)) then markNow = self.markNow
  if (arg_present(nowColor)) then nowColor = self.nowColor
end


;= IDLffXMLSAX parser methods for MG_Timeline

;+
; Called to process the opening of a tag.
;
; :Private:
;
; :Params:
;   uri : in, required, type=string
;     namespace URI
;   local : in, required, type=string
;     element name with prefix removed
;   qname : in, required, type=string
;     element name
;   attName : in, optional, type=strarr
;     names of attributes
;   attValue : in, optional, type=strarr
;     attribute values
;-
pro mg_timeline::startElement, uri, local, qname, attname, attvalue
  compile_opt strictarr

  case strlowcase(qname) of
    'timeline': begin
        for a = 0L, n_elements(attname) - 1L do begin
          case strlowcase(attname[a]) of
            'start': self.startDate = mg_timeline_julday(attvalue[a])
            'end': self.endDate = mg_timeline_julday(attvalue[a])
            'ticks': self.ticks = attvalue[a]
            'major': self.major = long(attvalue[a])
            'color': self.color = attvalue[a]
            else: print, attname[a], format='(%"%s attribute unknown")'
          endcase
        endfor
      end

    'event': begin
        event = obj_new('MG_TimelineEvent')

        for a = 0L, n_elements(attname) - 1L do begin
          case strlowcase(attname[a]) of
            'date': event->setProperty, date=mg_timeline_julday(attvalue[a])
            'color': event->setProperty, color=attvalue[a]
            'level': event->setProperty, level=float(attvalue[a])
            else: print, attname[a], format='(%"%s attribute unknown")'
          endcase
        endfor

        self.events->add, event
        self.insideEvent = 1B
      end

    'interval': begin
        interval = obj_new('MG_TimelineInterval')

        for a = 0L, n_elements(attname) - 1L do begin
          case strlowcase(attname[a]) of
            'start': interval->setProperty, start_date=mg_timeline_julday(attvalue[a])
            'end': interval->setProperty, end_date=mg_timeline_julday(attvalue[a])
            'color': interval->setProperty, color=attvalue[a]
            'level': interval->setProperty, level=float(attvalue[a])
            'name': interval->setProperty, name=attvalue[a]
            else: print, attname[a], format='(%"%s attribute unknown")'
          endcase
        endfor

        self.intervals->add, interval
      end

    'activity': begin
        activity = obj_new('MG_TimelineActivity')

        for a = 0L, n_elements(attname) - 1L do begin
          case strlowcase(attname[a]) of
            'color': activity->setProperty, color=attvalue[a]
            'level': activity->setProperty, level=float(attvalue[a])
            'name': activity->setProperty, name=attvalue[a]
            'report': activity->setProperty, report=attvalue[a]
            'start': activity->setProperty, start=long(attvalue[a])
            else: print, attname[a], format='(%"%s attribute unknown")'
          endcase
        endfor

        self.activities->add, activity
        self.insideActivity = 1B
      end

    'now': begin
        self.markNow = 1B
        for a = 0L, n_elements(attname) - 1L do begin
          case strlowcase(attname[a]) of
            'color': self.nowColor = attvalue[a]
            else: print, attname[a], format='(%"%s attribute unknown")'
          endcase
        endfor
      end

      'text': begin
          text = obj_new('MG_TimelineText')

          for a = 0L, n_elements(attname) - 1L do begin
            case strlowcase(attname[a]) of
              'level': text->setProperty, level=float(attvalue[a])
              'date': text->setProperty, date=mg_timeline_julday(attvalue[a])
              'alignment': begin
                  case attvalue[a] of
                    'left':
                    'center':
                    'right':
                    else: print, attvalue[a], format='(%"unknown alignment value \"%s\"")'
                  endcase
                end
              else: print, attname[a], format='(%"%s attribute unknown")'
            endcase
          endfor

          self.texts->add, text
          self.insideText = 1B
        end

    else: print, qname, format='(%"%s element unknown")'
  endcase
end


;+
; Called to process the closing of a tag.
;
; :Private:
;
; :Params:
;   uri : in, required, type=string
;     namespace URI
;   local : in, required, type=string
;     element name with prefix removed
;   qname : in, required, type=string
;     element name
;-
pro mg_timeline::endElement, uri, local, qname
  compile_opt strictarr

  case strlowcase(qname) of
    'timeline':
    'event': self.insideEvent = 0B
    'interval':
    'activity': self.insideActivity = 0B
    'text': self.insideText = 0B
    else:
  endcase
end


;+
; Called to process character data in an XML file.
;
; :Private:
;
; :Params:
;   chars : in, required, type=string
;     characters detected by parser
;-
pro mg_timeline::characters, chars
  compile_opt strictarr

  if (self.insideEvent) then begin
    event = self.events->get(position=self.events->count() - 1L)
    event->setProperty, text=chars
  endif

  if (self.insideActivity) then begin
    activity = self.activities->get(position=self.activities->count() - 1L)
    activity->setProperty, value=long(strsplit(chars, /extract))
  endif

  if (self.insideText) then begin
    text = self.texts->get(position=self.texts->count() - 1L)
    text->setProperty, text=chars
  endif
end


;= lifecycle methods for MG_Timeline

;+
; Free resources.
;
; :Private:
;-
pro mg_timeline::cleanup
  compile_opt strictarr

  obj_destroy, [self.events, self.intervals, self.activities]
end


;+
; Create timeline object.
;
; :Private:
;
; :Returns:
;   1 for success, 0 otherwise
;
; :Keywords:
;   _extra : in, optional, type=keywords
;     keywords to `IDLffXMLSAX::init`
;-
function mg_timeline::init, _extra=e
  compile_opt strictarr

  if (~self->IDLffXMLSAX::init(_extra=e)) then return, 0

  self.ticks = 'weeks'
  self.color = 'black'
  self.markNow = 0B
  self.nowColor = 'black'

  self.events = obj_new('IDL_Container')
  self.intervals = obj_new('IDL_Container')
  self.activities = obj_new('IDL_Container')
  self.texts = obj_new('IDL_Container')

  return, 1
end


;+
; Define instance variables.
;
; :Private:
;-
pro mg_timeline__define
  compile_opt strictarr

  define = { MG_Timeline, inherits IDLffXMLSAX, $
             startDate: 0.0D, $
             endDate: 0.0D, $
             ticks: '' , $
             major: 0L, $
             color: '', $
             markNow: 0B, $
             nowColor: '', $
             insideEvent: 0B, $
             events: obj_new(), $
             intervals: obj_new(), $
             insideActivity: 0B, $
             activities: obj_new(), $
             insideText: 0B, $
             texts: obj_new() $
           }
end


;+
; Create a timeline from the given input file.
;
; :Params:
;   filename : in, required, type=string
;     input XML file
;   outputFilename : in, required, type=string
;     name of PostScript output file
;-
pro mg_timeline, filename, outputFilename
  compile_opt strictarr

  parser = obj_new('MG_Timeline')
  parser->parseFile, filename

  parser->getProperty, start_date=startDate, end_date=endDate, $
                       ticks=ticks, major=major_length, $
                       events=events, intervals=intervals, $
                       activities=activities, texts=texts, $
                       mark_now=markNow, now_color=nowColor

  case strlowcase(ticks) of
    'weeks': begin
        minor_length = 7.
        major_length = n_elements(major_length) eq 0L ? 4. : major_length
        minor = major_length - 1L
        major = (endDate - startDate) / minor_length / major_length + 1.
      end
  endcase

  xc = mg_linear_function([startDate, endDate], [0.1, 0.9])

  viewgroup = obj_new('IDLgrViewGroup')

  view = obj_new('IDLgrView', viewplane_rect=[0., 0., 1., 1.])
  viewgroup->add, view

  model = obj_new('IDLgrModel')
  view->add, model

  ; add axis
  result = label_date(date_format='%D %M %Y')

  topaxis = obj_new('IDLgrAxis', direction=0, location=[0.1, 0.9], $
                    textpos=1, textalignments=[0., 0.0], $
                    tickformat='label_date', $
                    thick=0.5, $
                    subticklen=0.5, ticklen=0.0075, $
                    minor=minor, major=major, $
                    range=[startDate, endDate], /exact, $
                    xcoord_conv=xc)
  model->add, topaxis

  bottomaxis = obj_new('IDLgrAxis', direction=0, location=[0.1, 0.1], $
                       textpos=0, textalignments=[0., 2.0], $
                       tickformat='label_date', $
                       thick=0.5, $
                       subticklen=0.5, ticklen=-0.0075, $
                       minor=minor, major=major, $
                       range=[startDate, endDate], /exact, $
                       xcoord_conv=xc)
  model->add, bottomaxis

  font = obj_new('IDLgrFont', size=8.)
  viewgroup->add, font

  smallfont = obj_new('IDLgrFont', size=6.)
  viewgroup->add, smallfont

  bigfont = obj_new('IDLgrFont', size=14.)
  viewgroup->add, bigfont

  topaxis->getProperty, ticktext=ticktext
  ticktext->setProperty, font=font
  bottomaxis->getProperty, ticktext=ticktext
  ticktext->setProperty, font=font

  xgap = 1.
  ygap = 0.01

  ; add vertical bars
  for m = 0L, (minor + 1L) * (major - 1L) + 1L - 1L do begin
    model->add, obj_new('IDLgrPolyline', $
                        fltarr(2) + startDate + m * minor_length, $
                        [0.1, 0.9], $
                        [-1., -1], $
                        linestyle=m mod major_length eq 0L ? 0L : 1L, $
                        color=[220, 220, 220], $
                        xcoord_conv=xc)
  endfor

  ; add events
  for e = 0L, events->count() - 1L do begin
    event = events->get(position=e)
    event->getProperty, date=eventDate, level=level, text=eventText, $
                        color=color

    ; skip events before or after timeline range
    if (eventDate lt startDate || eventDate gt endDate) then continue

    model->add, obj_new('IDLgrPolyline', $
                        fltarr(2) + eventDate, $
                        0.9 - [10 * ygap, level] / 10., $
                        thick=0.5, $
                        color=mg_color(color), $
                        xcoord_conv=xc)

    model->add, obj_new('IDLgrText', eventText, font=font, $
                        location=[eventDate, 0.9 - (4. * ygap + level) / 10.], $
                        vertical_alignment=1.0, $
                        /enable_formatting, $
                        xcoord_conv=xc)
  endfor

  ; add intervals
  for i = 0L, intervals->count() - 1L do begin
    interval = intervals->get(position=i)
    interval->getProperty, start_date=intervalStartDate, end_date=intervalEndDate, $
                           level=level, name=name, color=color

    ; skip events before or after timeline range
    if (intervalEndDate lt startDate || intervalStartDate gt endDate) then continue

    ; also truncate events to timeline range
    intervalStartDate >= startDate
    intervalEndDate <= endDate

    model->add, obj_new('IDLgrPolyline', $
                        [intervalStartDate, intervalEndDate], $
                        fltarr(2) + 0.9 - level / 10., $
                        thick=2.5, $
                        color=mg_color(color), $
                        xcoord_conv=xc)
    model->add, obj_new('IDLgrText', name, font=font, $
                        location=[(intervalStartDate + intervalEndDate) / 2.0, 0.9 - (6. * ygap + level) / 10.], $
                        alignment=0.5, vertical_alignment=1.0, $
                        /enable_formatting, $
                        xcoord_conv=xc)
  endfor

  ; add texts
  for i = 0L, texts->count() - 1L do begin
    text = texts->get(position=i)
    text->getProperty, date=date, level=level, text=textChars, color=color, $
                       alignment=alignment

    ; skip texts before or after timeline range
    if (date lt startDate || date gt endDate) then continue

    model->add, obj_new('IDLgrText', textChars, font=font, $
                        location=[date, 0.9 - (6. * ygap + level) / 10.], $
                        alignment=alignment, vertical_alignment=1.0, $
                        /enable_formatting, $
                        xcoord_conv=xc)
  endfor

  ; add activities
  for a = 0L, activities->count() - 1L do begin
    activity = activities->get(position=a)
    activity->getProperty, name=name, value=value, color=color, level=level, $
                           report=report, start=start

    model->add, obj_new('IDLgrText', name, $
                        location=[startDate - xgap, 0.9 - level / 10.], $
                        alignment=1.0, vertical_alignment=0.5, $
                        /enable_formatting, $
                        font=font, $
                        xcoord_conv=xc)

    case report of
      'weekly': skip = 1L
      'biweekly': skip = 2L
      else: skip = 1L
    endcase

    for v = 0L, n_elements(value) - 1L do begin
      model->add, obj_new('IDLgrText', strtrim(value[v], 2), $
                          location=[startDate + minor_length / 2. + (v * skip + start - 1L) * minor_length, 0.9 - level / 10.], $
                          alignment=0.5, vertical_alignment=0.5, $
                          /enable_formatting, $
                          font=smallfont, $
                          xcoord_conv=xc)
    endfor
  endfor

  ; mark now
  if (markNow) then begin
    now = systime(/julian)
    model->add, obj_new('IDLgrPolyline', $
                        fltarr(2) + now, $
                        [0.1, 0.9], $
                        thick=0.25, $
                        color=mg_color(nowColor), $
                        xcoord_conv=xc)
  endif

  clipboard = obj_new('IDLgrClipboard', dimensions=[11, 8.5], units=1)
  clipboard->draw, viewgroup, /vector, /postscript, filename=outputFilename
  obj_destroy, [viewgroup, clipboard]

  obj_destroy, parser
end


; main-level program

filename = filepath('athletic.xml', root=mg_src_root())

mg_timeline, filename, 'athletic.ps'

end
