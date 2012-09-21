; docformat = 'rst'

;+
; `vis_timeline` is a timeline creation routine which creates a PostScript 
; output file from an XML input file.
;
; :Examples:
;    Try the main-level example program at the end of this file::
;
;       IDL> .run vis_timeline
;
;    This should produce a timeline; below is a small section of it:
;
;    .. image:: athletic-thumbnail.png
;-


;+
; Helper routine to convert dates like "1-1-2009" to Julian dates.
;
; :Private:
;
; :Returns:
;    double
;
; :Params:
;    date : in, required, type=string
;       date like "1-1-2009"
;-
function vis_timeline_julday, date
  compile_opt strictarr

  tokens = strsplit(date, '-', /extract)
  return, julday(long(tokens[0]), long(tokens[1]), long(tokens[2]), 0., 0., 0.)
end

;+
; :Private:
;-
pro vis_timelineactivity::getProperty, name=name, color=color, value=value, $
                                       level=level, report=report, $
                                       start=start, graph=graph
  compile_opt strictarr
  
  if (arg_present(name)) then name = *self.name
  if (arg_present(value)) then value = *self.value
  if (arg_present(color)) then color = self.color
  if (arg_present(level)) then level = self.level
  if (arg_present(report)) then report = self.report
  if (arg_present(start)) then start = self.start
  if (arg_present(graph)) then graph = self.graph
end


;+
; :Private:
;-
pro vis_timelineactivity::setProperty, name=name, color=color, value=value, $
                                       level=level, report=report, $
                                       start=start, graph=graph
  compile_opt strictarr
  
  if (n_elements(name) gt 0L) then *self.name = strjoin(vis_strunmerge(name), '!C')
  if (n_elements(value) gt 0L) then *self.value = value
  if (n_elements(color) gt 0L) then self.color = color
  if (n_elements(level) gt 0L) then self.level = level
  if (n_elements(report) gt 0L) then self.report = report
  if (n_elements(start) gt 0L) then self.start = start
  if (n_elements(graph) gt 0L) then self.graph = graph
end


;+
; :Private:
;-
pro vis_timelineactivity::cleanup
  compile_opt strictarr
  
  ptr_free, self.name, self.value
end


;+
; :Private:
;-
function vis_timelineactivity::init
  compile_opt strictarr
  
  self.name = ptr_new(/allocate_heap)
  self.value = ptr_new(/allocate_heap)

  self.start = 1L

  return, 1  
end


;+
; :Private:
;-
pro vis_timelineactivity__define
  compile_opt strictarr
  
  define = { vis_timelineactivity, $
             name: ptr_new(), $
             value: ptr_new(), $
             color: '', $
             level: 0.0, $
             report: '', $
             graph: 0B, $
             start: 0L $
           }
end


;+
; :Private:
;-
pro vis_timelineinterval::getProperty, name=name, color=color, $
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
; :Private:
;-
pro vis_timelineinterval::setProperty, name=name, color=color, $
                                      start_date=startDate, end_date=endDate, $
                                      level=level
  compile_opt strictarr
  
  if (n_elements(name) gt 0L) then *self.name = strjoin(vis_strunmerge(name), '!C')
  if (n_elements(color) gt 0L) then self.color = color
  if (n_elements(startDate) gt 0L) then self.startDate = startDate
  if (n_elements(endDate) gt 0L) then self.endDate = endDate
  if (n_elements(level) gt 0L) then self.level = level
end


;+
; :Private:
;-
pro vis_timelineinterval::cleanup
  compile_opt strictarr
  
  ptr_free, self.name
end


;+
; :Private:
;-
function vis_timelineinterval::init
  compile_opt strictarr
  
  self.name = ptr_new(/allocate_heap)
  
  return, 1  
end


;+
; :Private:
;-
pro vis_timelineinterval__define
  compile_opt strictarr
  
  define = { vis_timelineinterval, $
             name: ptr_new(), $
             color: '', $
             startDate: 0.0D, $
             endDate: 0.0D, $
             level: 0.0 $
           }
end


;+
; :Private:
;-
pro vis_timelineevent::getProperty, text=text, color=color, date=date, level=level
  compile_opt strictarr
  
  if (arg_present(text)) then text = *self.text
  if (arg_present(color)) then color = self.color
  if (arg_present(date)) then date = self.date
  if (arg_present(level)) then level = self.level
end


;+
; :Private:
;-
pro vis_timelineevent::setProperty, text=text, color=color, date=date, level=level
  compile_opt strictarr
  
  if (n_elements(text) gt 0L) then *self.text = strjoin(vis_strunmerge(text), '!C')
  if (n_elements(color) gt 0L) then self.color = color
  if (n_elements(date) gt 0L) then self.date = date
  if (n_elements(level) gt 0L) then self.level = level
end


;+
; :Private:
;-
pro vis_timelineevent::cleanup
  compile_opt strictarr
  
  ptr_free, self.text
end


;+
; :Private:
;-
function vis_timelineevent::init
  compile_opt strictarr
  
  self.text = ptr_new(/allocate_heap)
  
  return, 1  
end


;+
; :Private:
;-
pro vis_timelineevent__define
  compile_opt strictarr
  
  define = { vis_timelineevent, $
             text: ptr_new(), $
             color: '', $
             date: 0.0D, $
             level: 0.0 $
           }
end


;+
; :Private:
;-
pro vis_timeline::getProperty, start_date=startDate, end_date=endDate, $
                              ticks=ticks, $
                              events=events, intervals=intervals, $
                              activities=activities, $
                              mark_now=markNow, now_color=nowColor
  compile_opt strictarr

  if (arg_present(startDate)) then startDate = self.startDate
  if (arg_present(endDate)) then endDate = self.endDate
  if (arg_present(ticks)) then ticks = self.ticks
  if (arg_present(events)) then events = self.events
  if (arg_present(intervals)) then intervals = self.intervals
  if (arg_present(activities)) then activities = self.activities
  if (arg_present(markNow)) then markNow = self.markNow
  if (arg_present(nowColor)) then nowColor = self.nowColor
end

                              
;+
; :Private:
;-
pro vis_timeline::startElement, uri, local, qname, attname, attvalue
  compile_opt strictarr

  case strlowcase(qname) of
    'timeline': begin
        for a = 0L, n_elements(attname) - 1L do begin
          case strlowcase(attname[a]) of
            'start': self.startDate = vis_timeline_julday(attvalue[a])
            'end': self.endDate = vis_timeline_julday(attvalue[a])
            'ticks': self.ticks = attvalue[a]
            'color': self.color = attvalue[a]
            else: print, attname[a], format='(%"%s attribute unknown")'
          endcase
        endfor
      end
      
    'event': begin
        event = obj_new('vis_timelineEvent')
        
        for a = 0L, n_elements(attname) - 1L do begin
          case strlowcase(attname[a]) of
            'date': event->setProperty, date=vis_timeline_julday(attvalue[a])
            'color': event->setProperty, color=attvalue[a]
            'level': event->setProperty, level=float(attvalue[a])
            else: print, attname[a], format='(%"%s attribute unknown")'
          endcase
        endfor
        
        self.events->add, event
        self.insideEvent = 1B
      end
      
    'interval': begin
        interval = obj_new('vis_timelineInterval')
        
        for a = 0L, n_elements(attname) - 1L do begin
          case strlowcase(attname[a]) of
            'start': interval->setProperty, start_date=vis_timeline_julday(attvalue[a])
            'end': interval->setProperty, end_date=vis_timeline_julday(attvalue[a])
            'color': interval->setProperty, color=attvalue[a]
            'level': interval->setProperty, level=float(attvalue[a])
            'name': interval->setProperty, name=attvalue[a]
            else: print, attname[a], format='(%"%s attribute unknown")'
          endcase
        endfor
        
        self.intervals->add, interval      
      end

    'activity': begin
        activity = obj_new('vis_timelineActivity')
        
        for a = 0L, n_elements(attname) - 1L do begin
          case strlowcase(attname[a]) of
            'color': activity->setProperty, color=attvalue[a]
            'level': activity->setProperty, level=float(attvalue[a])
            'name': activity->setProperty, name=attvalue[a]
            'report': activity->setProperty, report=attvalue[a]
            'start': activity->setProperty, start=long(attvalue[a])
            'graph': activity->setProperty, graph=byte(attvalue[a])
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
            'color': self.nowColor=attvalue[a]
            else: print, attname[a], format='(%"%s attribute unknown")'
          endcase
        endfor
      end
                  
    else: print, qname, format='(%"%s element unknown")'
  endcase
end


;+
; :Private:
;-
pro vis_timeline::endElement, uri, local, qname
  compile_opt strictarr
  
  case strlowcase(qname) of
    'timeline':
    'event': self.insideEvent = 0B
    'interval':
    'activity': self.insideActivity = 0B
    else:
  endcase  
end


;+
; :Private:
;-
pro vis_timeline::characters, chars
  compile_opt strictarr
  
  if (self.insideEvent) then begin
    event = self.events->get(position=self.events->count() - 1L)
    event->setProperty, text=chars
  endif
  
  if (self.insideActivity) then begin
    _chars = mg_strunmerge(chars)
    _chars = strjoin(_chars, ' ')
    activity = self.activities->get(position=self.activities->count() - 1L)
    activity->setProperty, value=long(strsplit(_chars, /extract))
  endif
end


;+
; :Private:
;-
pro vis_timeline::cleanup
  compile_opt strictarr

  obj_destroy, [self.events, self.intervals, self.activities]
end


;+
; :Private:
;-
function vis_timeline::init, _extra=e
  compile_opt strictarr

  if (~self->IDLffXMLSAX::init(_extra=e)) then return, 0
  
  self.ticks = 'weeks'
  self.color = 'black'
  self.markNow = 0B
  self.nowColor = 'black'
  
  self.events = obj_new('IDL_Container')
  self.intervals = obj_new('IDL_Container')
  self.activities = obj_new('IDL_Container')
  
  return, 1
end


;+
; :Private:
;-
pro vis_timeline__define
  compile_opt strictarr
  
  define = { vis_timeline, inherits IDLffXMLSAX, $
             startDate: 0.0D, $
             endDate: 0.0D, $
             ticks: '' , $
             color: '', $
             markNow: 0B, $
             nowColor: '', $
             insideEvent: 0B, $
             events: obj_new(), $
             intervals: obj_new(), $
             insideActivity: 0B, $
             activities: obj_new() $
           }
end


;+
; Create a timeline from the given input file.
;
; :Params:
;    filename : in, required, type=string
;       input XML file
;    outputFilename : in, required, type=string
;       name of PostScript output file
;-
pro vis_timeline, filename, outputFilename
  compile_opt strictarr
  
  parser = obj_new('vis_timeline')
  parser->parseFile, filename
  
  parser->getProperty, start_date=startDate, end_date=endDate, ticks=ticks, $
                       events=events, intervals=intervals, $
                       activities=activities, $
                       mark_now=markNow, now_color=nowColor

  case strlowcase(ticks) of
    'weeks': begin
        minor_length = 7.
        major_length = 4.
        minor = major_length - 1L
        major = (endDate - startDate) / minor_length / major_length + 1.
      end
  endcase
  
  xc = vis_linear_function([startDate, endDate], [0.1, 0.9])

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
    
  font = obj_new('IDLgrFont', size=6.)
  viewgroup->add, font
  
  smallfont = obj_new('IDLgrFont', size=4.)
  viewgroup->add, smallfont

  bigfont = obj_new('IDLgrFont', size=14.)
  viewgroup->add, bigfont
  
  topaxis->getProperty, ticktext=ticktext
  ticktext->setProperty, font=font
  bottomaxis->getProperty, ticktext=ticktext
  ticktext->setProperty, font=font
  
  xgap = 1.0
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
    model->add, obj_new('IDLgrPolyline', $
                        fltarr(2) + eventDate, $
                        0.9 - [10 * ygap, level] / 10., $
                        thick=0.5, $
                        color=vis_color(color), $
                        xcoord_conv=xc)

    model->add, obj_new('IDLgrText', eventText, font=font, $
                        location=[eventDate + xgap, 0.9 - (2. * ygap + level) / 10.], $
                        vertical_alignment=1.0, $
                        /enable_formatting, $
                        xcoord_conv=xc)
  endfor
  
  ; add intervals
  for i = 0L, intervals->count() - 1L do begin
    interval = intervals->get(position=i)
    interval->getProperty, start_date=intervalStartDate, end_date=intervalEndDate, $
                           level=level, name=name, color=color

    model->add, obj_new('IDLgrPolyline', $
                        [intervalStartDate, intervalEndDate], $
                        fltarr(2) + 0.9 - level / 10., $
                        thick=2.5, $
                        color=vis_color(color), $
                        xcoord_conv=xc)
    model->add, obj_new('IDLgrText', name, font=font, $
                        location=[(intervalStartDate + intervalEndDate) / 2.0, 0.9 - (6. * ygap + level) / 10.], $
                        alignment=0.5, vertical_alignment=1.0, $
                        /enable_formatting, $
                        xcoord_conv=xc)
  endfor
  
  ; add activities
  for a = 0L, activities->count() - 1L do begin
    activity = activities->get(position=a)
    activity->getProperty, name=name, value=value, color=color, level=level, $
                           report=report, start=start, graph=graph
                           
    model->add, obj_new('IDLgrText', name, $
                        location=[startDate - xgap, 0.9 - level / 10.], $
                        alignment=1.0, vertical_alignment=0.5, $
                        /enable_formatting, $
                        font=font, $
                        xcoord_conv=xc)
                        
    for v = 0L, n_elements(value) - 1L do begin                       
      model->add, obj_new('IDLgrText', strtrim(value[v], 2), $
                          location=[startDate + minor_length / 2. + (v + start - 1L) * minor_length, 0.9 - level / 10.], $
                          alignment=0.5, vertical_alignment=0.5, $
                          /enable_formatting, $
                          font=smallfont, $
                          xcoord_conv=xc)
    endfor
    
    if (graph) then begin
      activityX = startDate + start * minor_length - minor_length / 2. + findgen(n_elements(value)) * minor_length
      activityY = 0.9 - level / 10. + 0.005 + float(value) / max(value) / 100.
      
      now = systime(/julian)
      nowInd = value_locate(activityX, now)
      
      case 1 of
        nowInd gt 0L && nowInd lt n_elements(activityY) - 1L: begin
            ; add activity history graph
            model->add, obj_new('IDLgrPolyline', $
                                [activityX[0:nowInd], now], $
                                [activityY[0:nowInd], $
                                 (activityY[nowInd] + activityY[nowInd + 1]) / 2.], $
                                xcoord_conv=xc, $
                                linestyle=0, $
                                color=bytarr(3) + 150B)

            ; add activity future graph
            endInd = n_elements(activityX) - 1L
            model->add, obj_new('IDLgrPolyline', $
                                [now, activityX[nowInd:endInd]], $
                                [(activityY[nowInd] + activityY[nowInd + 1]) / 2., $
                                 activityY[nowInd:endInd]], $
                                xcoord_conv=xc, $
                                linestyle=3, $
                                color=bytarr(3) + 150B)
          end          
        nowInd le 0L: begin
            ; add activity future graph
            endInd = n_elements(activityX) - 1L
            model->add, obj_new('IDLgrPolyline', $
                                activityX[0:endInd], $
                                activityY[0:endInd], $
                                xcoord_conv=xc, $
                                linestyle=3, $
                                color=bytarr(3) + 150B)          
          end
        nowInd ge n_elements(activityY) - 1L: begin
            ; add activity history graph
            endInd = n_elements(activityX) - 1L
            model->add, obj_new('IDLgrPolyline', $
                                activityX[0:endInd], $
                                activityY[0:endInd], $                              
                                xcoord_conv=xc, $
                                linestyle=0, $
                                color=bytarr(3) + 150B)          
          end
      endcase
      
      if (nowInd gt 0L) then begin

      endif
    endif
  endfor
  
  ; mark now
  if (markNow) then begin
    now = systime(/julian)
    model->add, obj_new('IDLgrPolyline', $
                        fltarr(2) + now, $
                        [0.1, 0.9], $
                        thick=0.25, $
                        color=vis_color(nowColor), $
                        xcoord_conv=xc)
  endif
  
  clipboard = obj_new('IDLgrClipboard', dimensions=[11, 8.5], units=1)
  clipboard->draw, viewgroup, /vector, /postscript, filename=outputFilename
  obj_destroy, [viewgroup, clipboard]
  
  obj_destroy, parser
end


; main-level program

filename = filepath('athletic.xml', root=vis_src_root())

vis_timeline, filename, 'athletic.ps'

end
