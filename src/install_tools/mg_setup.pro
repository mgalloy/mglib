;+
; install_tools should have ways to:
;   * install dependencies of a project
;   * handle path, DLM path, and compiling DLMs
;-

;+
;
;
; @keyword name {in}{required}{type=string}
;          name of the package
; @keyword version {in}{required}{type=string}
;          version of the package in the format "1.5.2alpha1"
;
; @keyword version_check {out}{optional}{type=string}
;          returns the version passed in (used by packages installing this
;          package as a requirement to find its version)
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
