Building
--------

Use CMake (see http://www.cmake.org for download and more information) to configure mglib. For example, for a basic install, you would do the following from the root directory of mglib::

  cmake -DCMAKE_INSTALL_PREFIX=/path/to/install .

There is a more complete configuration in `example_configure.sh` which specifies some optional libraries that are linked to if present.

After configuration, build mglib with::

  make
  
And install with::

  make install


Testing
-------

To run the unit tests, use the `unit` Makefile target::

  make unit

The results will be in `mglib-test-results.html` in the root directory of the project.


Generating documentation
------------------------

To generate documentation, use the `doc` or `userdoc` Makefile targets::

  make doc
  make userdoc

The `doc` target generates documentation appropriate for developers/contributors to mglib, while `userdoc` generates documentation appropriate for users of mglib.