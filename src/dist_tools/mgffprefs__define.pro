; docformat = 'rst'

;+
; Class responsible for storing and retrieving preferences. Preferences are
; persistent across IDL sessions on the same computer.
;
; :Examples:
;   The main-level program at the end of this file has an example use of
;   `MGffPrefs`. To run it, type::
;
;     IDL> .run mgffprefs__define
;
;   The code creates an `MFffPrefs` object and uses the `set` and `get`
;   methods to set and retrieve a preference.
;
;   Creating the `MGffPrefs` requires setting the `AUTHOR_NAME` and
;   `APP_NAME` properties so that the `APP_DIRECTORY`, where the prefence
;   value files are stored, can be specified::
;
;     authorName = 'mgffprefs_demo'
;     appName = 'mgffprefs_demo'
;     prefs = obj_new('mgffprefs', author_name=authorName, app_name=appName)
;
;   We can now set a preference value, remember the preference name is
;   case-insensitive, but the value is stored exactly::
;
;     prefs->set, 'name', 'Michael'
;
;   The preferences object can now be destroyed to show the preferences are
;   persistent between IDL sessions::
;
;     obj_destroy, prefs
;
;   A new `MGffPrefs` object is created with the same `AUTHOR_NAME` and
;   `APP_NAME` values::
;
;     prefs = obj_new('mgffprefs', author_name=authorName, app_name=appName)
;
;   The "name" preference can now be retrieved::
;
;     name = prefs->get('name', found=found)
;
;   We can retrieve the `APP_DIRECTORY` property to know where the preference
;   files are stored::
;
;     prefs->getProperty, app_directory=appdir
;
;   We are done with the `MGffPrefs` object::
;
;     obj_destroy, prefs
;
;   Print the preference value::
;
;     print, name, format='(%"Preference value for name: %s")'
;
;   We can manually clean out the entire directory for our preferences::
;
;     file_delete, file_dirname(appdir), /recursive, /allow_nonexistent, /quiet
;
;   Individual preferences can be cleared with the `clear` method.
;
; :Properties:
;   author_name
;     short name of the author
;   app_name
;     short name of the application
;   author_description
;     full name of the author
;   app_description
;     full name of the application
;   app_directory
;     location of the directory for the application using these preferences
;-


;+
; Save the value of a preference.
;
; :Params:
;   prefname : in, required, type=string
;     case-insensitive name of preference to retrieve
;   prefvalue : in, required, type=any
;     value of the preference
;-
pro mgffprefs::set, prefname, prefvalue
  compile_opt strictarr
  on_error, 2

  filename = filepath(self->_prefnameToFilename(prefname), root=self.appdir)
  save, prefvalue, filename=filename
end


;+
; Clear the value of a preference.
;
; :Params:
;   prefname : in, required, type=string
;     case-insensitive name of preference to retrieve
;-
pro mgffprefs::clear, prefname
  compile_opt strictarr

  filename = filepath(self->_prefnameToFilename(prefname), root=self.appdir)
  if (file_test(filename)) then file_delete, filename
end


;+
; Retrieve the value of a preference.
;
; :Returns:
;   preference value
;
; :Params:
;   prefname : in, required, type=string
;     case-insensitive name of preference to retrieve
;
; :Keywords:
;   found : out, optional, type=boolean
;     set to a named variable to return whether the preference was found
;   default : in, optional, type=any
;     default value to use if no preference value is found for the given
;     preference name
;   names : in, optional, type=boolean
;     set to return a list of the preference names instead of a value; names
;     may not agree exactly with the names given in the set method because
;     they have been modified to make valid filename
;-
function mgffprefs::get, prefname, found=found, default=default, names=names
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return, n_elements(default) gt 0L ? default : -1L
  endif

  if (keyword_set(names)) then begin
    searchPattern = filepath('*.sav', root=self.appdir)
    files = file_search(searchPattern, count=count)
    found = count gt 0L
    return, found ? file_basename(files, '.sav') : -1L
  endif

  found = 0B
  if (n_elements(prefname) eq 0L) then message, 'preference name required'

  filename = filepath(self->_prefnameToFilename(prefname), root=self.appdir)
  if (~file_test(filename)) then return, n_elements(default) gt 0L ? default : -1L
  restore, filename=filename

  found = 1B
  return, prefvalue
end


;+
; Converts a preference name to a valid save filename.
;
; :Private:
;
; :Returns:
;   string
;
; :Params:
;   prefname : in, required, type=string
;     name of preference
;-
function mgffprefs::_prefnameToFilename, prefname
  compile_opt strictarr

  return, strlowcase(idl_validname(prefname, /convert_all)) + '.sav'
end


;+
; Returns directory for application data.
;
; :Private:
;
; :Returns:
;   string
;
; :Params:
;   authorName : in, required, type=string
;     short name of the author
;   appName : in, required, type=string
;     short application name
;
; :Keywords:
;   author_description : in, optional, type=string
;     full name of the author
;   app_description : in, optional, type=string
;     full name of the application
;-
function mgffprefs::_getAppDir, authorName, appName, $
                                author_description=authorDescription, $
                                app_description=appDescription
  compile_opt strictarr

  readmeVersion = 1

  _authorDescription = n_elements(authorDescription) eq 0L $
                         ? authorName $
                         : authorDescription
  _appDescription = n_elements(appDescription) eq 0L $
                      ? appName $
                      : appDescription

  readmeText = ['This is the user configuration directory for ' + _appDescription, $
                'by ' + _authorDescription + '.']

  configDir = app_user_dir(authorName, _authorDescription, $
                           appName, _appDescription, $
                           readmeText, readmeVersion)

  return, configDir
end


;+
; Get properties.
;-
pro mgffprefs::getProperty, app_directory=appDirectory
  compile_opt strictarr

  if (arg_present(appDirectory)) then appDirectory = self.appdir
end


;+
; Free resources.
;-
pro mgffprefs::cleanup
  compile_opt strictarr

end


;+
; Initialize a prefs object.
;
; :Returns:
;   1 for success, 0 for failure
;
; :Keywords:
;   author_name : in, required, type=string
;     short name of the author
;   app_name : in, required, type=string
;     short name of the application
;   author_description : in, optional, type=string
;     full name of the author
;   app_description : in, optional, type=string
;     full name of the application
;-
function mgffprefs::init, author_name=authorName, app_name=appName, $
                          author_description=authorDescription, $
                          app_description=appDescription
  compile_opt strictarr
  on_error, 2

  if (n_elements(authorName) eq 0L || n_elements(appName) eq 0L) then begin
    message, 'Author and application name required'
  endif

  self.appdir = self->_getAppDir(authorName, appName, $
                                 author_description=authorDescription, $
                                 app_description=appDescription)

  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;   appdir
;     directory to place preference files
;-
pro mgffprefs__define
  compile_opt strictarr

  define = { MGffPrefs, $
             appdir: '' $
           }
end


; main-level example program

authorName = 'mgffprefs_demo'
appName = 'mgffprefs_demo'
prefs = obj_new('mgffprefs', author_name=authorName, app_name=appName)

prefs->set, 'name', 'Michael'
obj_destroy, prefs

prefs = obj_new('mgffprefs', author_name=authorName, app_name=appName)
name = prefs->get('name', found=found)
prefs->getProperty, app_directory=appdir
obj_destroy, prefs

print, name, format='(%"Preference value for name: %s")'

file_delete, file_dirname(appdir), /recursive, /allow_nonexistent, /quiet

end
