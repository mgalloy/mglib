; docformat = 'rst'

;+
; `install_tools` should have ways to:
;   * install dependencies of a project
;   * handle path, DLM path, and compiling DLMs
;-

;+
; Setup an installation.
;
; :Keywords:
;   name : in, required, type=string
;     name of the package
;   version : in, required, type=string
;     version of the package in the format "1.5.2alpha1"
;   install_requires : in, optional, type=strarr
;     string array of names of required packages
;   packages : in, optional, type=strarr
;     unknown
;   author : in, optional, type=string
;     author of package
;   author_email : in, optional, type=string
;     email address of author of package
;   description : in, optional, type=string
;     description of package
;   license : in, optional, type=string
;     license of package
;   keywords : in, optional, type=strarr
;     string array of keywords relating to package
;   version_check : out, optional, type=string
;     returns the version passed in (used by packages installing this package as
;     as a requirement to find its version)
;-
pro mg_setup, name=name, $
              version=version, $
              install_requires=installRequires, $
              packages=packages, $
              author=author, $
              author_email=authorEmail, $
              description=description, $
              license=license, $
              keywords=keywords, $
              version_check=versionCheck
  compile_opt strictarr
  on_error, 2

  if (n_elements(version) eq 0) then begin
    message, 'version required'
  endif

  if (arg_present(versionCheck)) then begin
    versionCheck = version
    return
  endif

  ; install packages here
  package_location = filepath('', subdir=['lib', 'hook'])

  ; find each requirement and install it
    ; check to see if requirement is already installed
    ; download each requirement to a temp directory
    ; check its version against requirement
    ; copy to package_location

  ; install itself
    ; get directory of caller's source code
    ; copy to package_location
end
